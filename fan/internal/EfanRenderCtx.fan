using concurrent::Actor
using afPlastic::SrcCodeSnippet

** This code could be in EfanRenderer but I want to keep that class as clean as possible.
@NoDoc
class EfanRenderCtx {
	EfanRenderer	rendering
	StrBuf 			renderBuf
	|->|? 			bodyFunc
	Str				nestedId

	private new make(EfanRenderer rendering, StrBuf renderBuf, |->|? bodyFunc, Str nestedId) {
		this.rendering	= rendering
		this.renderBuf 	= renderBuf
		this.bodyFunc 	= bodyFunc
		this.nestedId	= nestedId
	}

	// ---- static methods ----

	static Str renderEfan(EfanRenderer rendering, |->|? bodyFunc, |->| renderFunc) {
		codeBuf   	:= StrBuf()
		nestedId	:= deeperNestedId(rendering)

		call(EfanRenderCtx(rendering, codeBuf, bodyFunc, nestedId), renderFunc)
		return codeBuf.toStr
	}

	static Str renderBody() {
		bodyFunc 	:= peek(-1).bodyFunc
		codeBuf 	:= StrBuf()
		if (bodyFunc != null) {
			// Note we are now rendering the parent (again!)
			rendering	:= peek(-2).rendering
			nestedId	:= peek(-2).nestedId
			call(EfanRenderCtx(rendering, codeBuf, null, nestedId), bodyFunc)
		}
		return codeBuf.toStr
	}
	
	static Void call(EfanRenderCtx renderCtx, |->| renderFunc) {
		try {
			CallStack.pushAndRun("efan.renderCtx", renderCtx, renderFunc)
			
		} catch (EfanRuntimeErr err) {
			// TODO: I'm not sure if it's helpful to trace through all templates...? 
			throw err
			
		} catch (Err err) {
			rType	:= renderCtx.rendering.typeof
			regex 	:= Regex.fromStr("^\\s*?${rType.qname}\\._af_render\\s\\(${rType.pod.name}:([0-9]+)\\)\$")
			trace	:= Utils.traceErr(err, 50)
			codeLineNo := trace.splitLines.eachWhile |line -> Int?| {
				reggy 	:= regex.matcher(line)
				return reggy.find ? reggy.group(1).toInt : null
			} ?: throw err

			renderCtx.rendering.efanMetaData.throwRuntimeErr(err, codeLineNo)
		}		
	}

	// nullable for use in renderEfan() above
	static EfanRenderCtx peek(Int i := -1) {
		CallStack.peek("efan.renderCtx", i)
	}
	
	static Str currentNestedId() {
		((EfanRenderCtx?) CallStack.peekSafe("efan.renderCtx"))?.nestedId ?: ""
	}

	static Str deeperNestedId(EfanRenderer rendering) {
		current	:= currentNestedId
		nested	:= "(${rendering.id})"
		return current.isEmpty ? nested : "${current}->${nested}"
	}
}