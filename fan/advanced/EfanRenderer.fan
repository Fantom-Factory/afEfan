
** Static methods for rendering efan templates.
** All data is saved onto the ThreadLocal rendering stack.
@NoDoc
const class EfanRenderer {
	
	static Str renderTemplate(EfanTemplateMeta templateMeta, Obj rendering, |->|? bodyFunc, |Obj?| func) {
		renderBuf := StrBuf(templateMeta.templateSrc.size)
		EfanRenderingStack.withCtx(templateMeta.templateId) |EfanRenderingStackElement element| {
			element.ctx["efan.renderCtx"] = EfanRendererCtx(templateMeta, rendering, renderBuf, bodyFunc)
			convertErrs(templateMeta, func)
		}
		return renderBuf.toStr
	}

	static Str renderBody() {
		renderBuf	:= null as StrBuf
		bodyFunc	:= peek.bodyFunc
		if (bodyFunc == null)
			return ""
		
		parent  := EfanRenderingStack.peekParent(true, "Could not render body - there is no enclosing template!")
		current := EfanRenderingStack.peek(true)
		
		EfanRenderingStack.withCtx("Body") |EfanRenderingStackElement element| {
			// copy the ctx down from the parent
			element.ctx	= parent.ctx.dup

			curCtx		:= current.ctx["efan.renderCtx"] as EfanRendererCtx
			renderBuf	= StrBuf(curCtx.efanMeta.templateSrc.size)
			element.ctx["efan.renderCtx"] = EfanRendererCtx(curCtx.efanMeta, curCtx.rendering, renderBuf, null)
				
			convertErrs(curCtx.efanMeta, bodyFunc)
		}
		return renderBuf.toStr
	}

	static EfanRendererCtx? peek(Bool checked := true) {
		EfanRenderingStack.peek(checked)?.ctx?.get("efan.renderCtx")
	}

	private static Void convertErrs(EfanTemplateMeta efanMetaData, |Obj?| func) {
		try {
			// TODO: Dodgy Fantom Syntax! See EfanRender.render()
			// currently, there is no 'it' so we just pass in a number
			func.call(69)
			
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
	EfanTemplateMeta	efanMeta
	Obj					rendering
	|->|? 				bodyFunc
	StrBuf				renderBuf
	@Deprecated
	StrBuf 				efanBuf	// for efanXtra 1.1.0

	new make(EfanTemplateMeta templateMeta, Obj rendering, StrBuf renderBuf, |->|? bodyFunc) {
		this.efanMeta	= templateMeta
		this.rendering	= rendering
		this.bodyFunc 	= bodyFunc
		this.renderBuf	= renderBuf
		this.efanBuf	= renderBuf
	}
	
}