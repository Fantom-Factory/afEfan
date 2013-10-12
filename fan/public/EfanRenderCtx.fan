using concurrent::Actor
using afPlastic::SrcCodeSnippet

@NoDoc
class EfanRenderCtx {
	EfanRenderer	rendering
	StrBuf 			renderBuf
	|->|? 			bodyFunc

	private new make(EfanRenderer rendering, StrBuf renderBuf, |->|? bodyFunc) {
		this.rendering	= rendering
		this.renderBuf 	= renderBuf
		this.bodyFunc 	= bodyFunc
	}

	static Str renderEfan(EfanRenderer rendering, |->|? bodyFunc, |->| renderFunc) {
		codeBuf := StrBuf()
		call(EfanRenderCtx(rendering, codeBuf, bodyFunc), renderFunc)
		return codeBuf.toStr
	}

	static Str renderBody() {
		bodyFunc 	:= peek(-1).bodyFunc
		codeBuf 	:= StrBuf()
		if (bodyFunc != null) {
			rendering	:= peek(-2).rendering	// report errors against the parent
			call(EfanRenderCtx(rendering, codeBuf, null), bodyFunc)
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

	static EfanRenderCtx peek(Int i := -1) {
		CallStack.peek("efan.renderCtx", i)
	}
}
