using concurrent::Actor
using afPlastic::SrcCodeSnippet

@NoDoc
class EfanRenderCtx {

	static Void renderWithBuf(EfanRenderer rendering, StrBuf renderBuf, |EfanRenderer|? bodyFunc, EfanRenderer? bodyObj, |->| renderFunc) {
		render := EfanRender(rendering, renderBuf, bodyFunc, bodyObj)

		try {
			CallStack.call("efan.renderCtx", render, renderFunc)
			
		} catch (Err err) {
			regex 	:= Regex.fromStr("^\\s*?${rendering.typeof.qname}\\._af_render\\s\\(${rendering.typeof.pod.name}:([0-9]+)\\)\$")
			codeLineNo := err.traceToStr.splitLines.eachWhile |line -> Int?| {
				reggy 	:= regex.matcher(line)
				return reggy.find ? reggy.group(1).toInt : null
			} ?: throw err

			rendering.efanMetaData.throwRuntimeErr(err, codeLineNo)
		}
	}
	
	static EfanRender? render() {
		CallStack.stackable("efan.renderCtx")
	}
}


@NoDoc
class EfanRender {
			StrBuf 			renderBuf
	private EfanRenderer	rendering
	private |EfanRenderer|? bodyFunc
	private EfanRenderer? 	bodyObj

	new make(EfanRenderer rendering, StrBuf renderBuf, |EfanRenderer|? bodyFunc, EfanRenderer? bodyObj) {
		this.rendering 	= rendering
		this.renderBuf 	= renderBuf
		this.bodyFunc 	= bodyFunc
		this.bodyObj 	= bodyObj
	}
	
	Void efan(EfanRenderer renderer, Obj? rendererCtx, |EfanRenderer obj|? bodyFunc) {
		renderer._af_render(renderBuf, rendererCtx, bodyFunc, rendering)
	}

	Void body() {
		bodyFunc?.call(bodyObj)
	}
}
