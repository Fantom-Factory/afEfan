
** Static methods for rendering efan templates.
** All data is saved onto the ThreadLocal rendering stack.
@NoDoc
const class EfanRenderer {
	
	static Obj? renderTemplate(EfanTemplateMeta templateMeta, Obj rendering, StrBuf renderBuf, |->|? bodyFunc, |Obj?->Obj?| func) {
		return EfanRenderingStack.withCtx(templateMeta.templateId) |EfanRenderingStackElement element->Obj?| {
			ctx := EfanRendererCtx(templateMeta, rendering, renderBuf, bodyFunc)
			element.ctx["efan.renderCtx"] = ctx
			return convertErrs(templateMeta, func)
		}
	}

	static Void renderBody(StrBuf renderBuf) {
		bodyFunc := peek.bodyFunc
		if (bodyFunc == null)
			return
		
		parent := EfanRenderingStack.peekParent(true, "Could not render body - there is no enclosing template!")
		
		EfanRenderingStack.withCtx("Body") |EfanRenderingStackElement element| {
			// copy the ctx down from the parent
			element.ctx	= parent.ctx

			ctx := (EfanRendererCtx) element.ctx["efan.renderCtx"]
			try {
				ctx.bodyBuf = renderBuf
				ctx.inBody = true
				convertErrs(ctx.efanMetaData, bodyFunc)
				
			} finally {
				ctx.inBody = false
			}			
		}
	}
	
	static EfanRendererCtx peek() {
		EfanRenderingStack.peek.ctx["efan.renderCtx"]
	}

	private static Obj? convertErrs(EfanTemplateMeta efanMetaData, |Obj?->Obj?| func) {
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

** Saved on the rendering stack, so we know what's currently being rendered
@NoDoc	// used by the compiled template to access the renderBuf 
class EfanRendererCtx {
	EfanTemplateMeta	efanMetaData
	Obj					rendering
	|->|? 				bodyFunc
	StrBuf 				efanBuf
	StrBuf?				bodyBuf
	Bool				inBody

	new make(EfanTemplateMeta templateMeta, Obj rendering, StrBuf renderBuf, |->|? bodyFunc) {
		this.efanMetaData	= templateMeta
		this.rendering		= rendering
		this.bodyFunc 		= bodyFunc
		this.efanBuf		= renderBuf
	}
	
	** As used by _efan_output
	StrBuf renderBuf() {
		inBody ? bodyBuf : efanBuf
	}
}