using concurrent::Actor
using afPlastic::SrcCodeSnippet

** This code could be in EfanRenderer but I want to keep that class as clean as possible.
@NoDoc
class EfanRenderCtx {
	EfanRenderer	rendering
	|->|? 			bodyFunc
	StrBuf 			efanBuf
	StrBuf?			bodyBuf
	Bool			inBody

	private new make(StrBuf renderBuf, EfanRenderer rendering, |->|? bodyFunc) {
		this.rendering	= rendering
		this.bodyFunc 	= bodyFunc
		this.efanBuf	= renderBuf
	}
	
	** As used by _af_code
	StrBuf renderBuf() {
		inBody ? bodyBuf : efanBuf
	}

	// ---- static methods ----

	static Void renderEfan(StrBuf renderBuf, EfanRenderer rendering, |->|? bodyFunc, |->| func) {
		EfanCtxStack.withCtx(rendering.efanMetaData.templateId) |EfanCtxStackElement element| {
			ctx := EfanRenderCtx(renderBuf, rendering, bodyFunc)
			element.ctx["efan.renderCtx"] = ctx
			convertErrs(func)
		}
	}

	static Void renderBody(StrBuf renderBuf) {
		bodyFunc := peek.bodyFunc
		if (bodyFunc == null)
			return
		
		parent := EfanCtxStack.peekParent("Could not render body - there is no enclosing template!")
		
		EfanCtxStack.withCtx("Body") |EfanCtxStackElement element| {
			// copy the ctx down from the parent
			element.ctx	= parent.ctx
			
			ctx := (EfanRenderCtx) element.ctx["efan.renderCtx"]
			try {
				ctx.bodyBuf = renderBuf
				ctx.inBody = true
				convertErrs(bodyFunc)
				
			} finally {
				ctx.inBody = false
			}			
		}
	}

	static EfanRenderCtx peek() {
		EfanCtxStack.peek.ctx["efan.renderCtx"]
	}
	
	private static Void convertErrs(|->| func) {
		try {
			// TODO: Dodgy Fantom Syntax! See EfanRender.render()
			// currently, there is no 'it' so we just pass in a number
			((|Obj?|) func).call(69)
			
		} catch (EfanRuntimeErr err) {
			// TODO: I'm not sure if it's helpful to trace through all templates...? 
			throw err

		} catch (Err err) {
			rType	:= peek.rendering.typeof
			regex 	:= Regex.fromStr("^\\s*?${rType.qname}\\._af_render\\s\\(${rType.pod.name}:([0-9]+)\\)\$")
			trace	:= Utils.traceErr(err, 50)
			codeLineNo := trace.splitLines.eachWhile |line -> Int?| {
				reggy 	:= regex.matcher(line)
				return reggy.find ? reggy.group(1).toInt : null
			} ?: throw err

			peek.rendering.efanMetaData.throwRuntimeErr(err, codeLineNo)
			throw Err("WTF?")
		}
	}
}