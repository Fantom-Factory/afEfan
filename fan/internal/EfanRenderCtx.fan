using concurrent::Actor
using afPlastic::SrcCodeSnippet

** This code could be in EfanRenderer but I want to keep that class as clean as possible.
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

	// ---- static methods ----

	static Str renderEfan(EfanRenderer rendering, |->|? bodyFunc, |->| func) {
		codeBuf   	:= StrBuf()
		call(EfanRenderCtx(rendering, codeBuf, bodyFunc), func)
		return codeBuf.toStr
	}

	static Str renderBody() {
		bodyFunc 	:= peek(-1).bodyFunc
		codeBuf 	:= StrBuf()
		if (bodyFunc != null) {
			// Note we are now rendering the parent (again!)
			rendering	:= peek(-2).rendering
			call(EfanRenderCtx(rendering, codeBuf, null), bodyFunc)
		}
		return codeBuf.toStr
	}
	

	// nullable for use in renderEfan() above
	static EfanRenderCtx peek(Int i := -1) {
		EfanCtxStack.peek(i).ctx["efan.renderCtx"]
	}
	
	private static Void call(EfanRenderCtx ctx, |->| func) {
		try {
			EfanCtxStack.withCtx(ctx.rendering) |EfanCtxStackElement element->Obj?| {
				element.ctx["efan.renderCtx"] = ctx
				((|Obj?|) func).call(69)
				return null
			}

		} catch (EfanRuntimeErr err) {
			// TODO: I'm not sure if it's helpful to trace through all templates...? 
			throw err

		} catch (Err err) {
			rType	:= ctx.rendering.typeof
			regex 	:= Regex.fromStr("^\\s*?${rType.qname}\\._af_render\\s\\(${rType.pod.name}:([0-9]+)\\)\$")
			trace	:= Utils.traceErr(err, 50)
			codeLineNo := trace.splitLines.eachWhile |line -> Int?| {
				reggy 	:= regex.matcher(line)
				return reggy.find ? reggy.group(1).toInt : null
			} ?: throw err

			ctx.rendering.efanMetaData.throwRuntimeErr(err, codeLineNo)
		}		
	}
}