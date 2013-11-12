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

	private new make(EfanRenderer rendering, |->|? bodyFunc) {
		this.rendering	= rendering
		this.bodyFunc 	= bodyFunc
		this.efanBuf	= StrBuf()
	}
	
	StrBuf renderBuf() {
		inBody ? bodyBuf : efanBuf
	}

	// ---- static methods ----

	static Str renderEfan(EfanRenderer rendering, |->|? bodyFunc, |->| func) {
		EfanCtxStack.withCtx(rendering.efanMetaData.templateId) |EfanCtxStackElement element->Obj?| {
			ctx := EfanRenderCtx(rendering, bodyFunc)
			element.ctx["efan.renderCtx"] = ctx
			convertErrs(func)
			return ctx.renderBuf.toStr
		}
	}

	static Str renderBody() {
		p:=peek
		bodyFunc := p.bodyFunc
		if (bodyFunc == null)
			return Str.defVal
		
		parent		:= EfanCtxStack.peekParent("Could not render body - there is no enclosing template!")
		
		return EfanCtxStack.withCtx("Body") |EfanCtxStackElement element->Obj?| {
			// copy the ctx down from the parent
			element.ctx	= parent.ctx
			
			ctx := (EfanRenderCtx) element.ctx["efan.renderCtx"]
			try {
				ctx.bodyBuf = StrBuf()
				ctx.inBody = true
				convertErrs(bodyFunc)
				return ctx.renderBuf.toStr
				
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