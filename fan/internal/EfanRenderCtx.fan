using concurrent::Actor
using afPlastic::SrcCodeSnippet

** This code could be in EfanRenderer but I want to keep that class as clean as possible.
@NoDoc
class EfanRenderCtx {
	EfanMetaData	efanMetaData
	Obj				rendering
	|->|? 			bodyFunc
	StrBuf 			efanBuf
	StrBuf?			bodyBuf
	Bool			inBody

	private new make(EfanMetaData efanMetaData, Obj rendering, StrBuf renderBuf, |->|? bodyFunc) {
		this.efanMetaData	= efanMetaData
		this.rendering		= rendering
		this.bodyFunc 		= bodyFunc
		this.efanBuf		= renderBuf
	}
	
	** As used by _efan_output
	StrBuf renderBuf() {
		inBody ? bodyBuf : efanBuf
	}

	// ---- static methods ----

	static Obj? renderEfan(EfanMetaData efanMetaData, Obj rendering, StrBuf renderBuf, |->|? bodyFunc, |Obj?->Obj?| func) {
		return EfanCtxStack.withCtx(efanMetaData.templateId) |EfanCtxStackElement element->Obj?| {
			ctx := EfanRenderCtx(efanMetaData, rendering, renderBuf, bodyFunc)
			element.ctx["efan.renderCtx"] = ctx
			return convertErrs(efanMetaData, func)
		}
	}

	static Void renderBody(StrBuf renderBuf) {
		bodyFunc := peek.bodyFunc
		if (bodyFunc == null)
			return
		
		parent := EfanCtxStack.peekParent(true, "Could not render body - there is no enclosing template!")
		
		EfanCtxStack.withCtx("Body") |EfanCtxStackElement element| {
			// copy the ctx down from the parent
			element.ctx	= parent.ctx
			
			ctx := (EfanRenderCtx) element.ctx["efan.renderCtx"]
			try {
				ctx.bodyBuf = renderBuf
				ctx.inBody = true
				convertErrs(ctx.efanMetaData, bodyFunc)
				
			} finally {
				ctx.inBody = false
			}			
		}
	}

	static EfanRenderCtx peek() {
		EfanCtxStack.peek.ctx["efan.renderCtx"]
	}
	
	private static Obj? convertErrs(EfanMetaData efanMetaData, |Obj?->Obj?| func) {
		try {
			// TODO: Dodgy Fantom Syntax! See EfanRender.render()
			// currently, there is no 'it' so we just pass in a number
			return ((|Obj?->Obj?|) func).call(69)
			
		} catch (EfanCompilationErr err) {
			throw err

		} catch (EfanRuntimeErr err) {
			// TODO: I'm not sure if it's helpful to trace through all templates...? 
			throw err

		} catch (Err err) {
			rType	:= peek.rendering.typeof
			regex 	:= Regex.fromStr("^\\s*?${rType.qname}\\._efan_render\\s\\(${rType.pod.name}:([0-9]+)\\)\$")
			trace	:= Utils.traceErr(err, 50)
			codeLineNo := trace.splitLines.eachWhile |line -> Int?| {
				reggy 	:= regex.matcher(line)
				return reggy.find ? reggy.group(1).toInt : null
			} ?: throw err

			efanMetaData.throwRuntimeErr(err, codeLineNo)
			throw Err("WTF?")
		}
	}
}