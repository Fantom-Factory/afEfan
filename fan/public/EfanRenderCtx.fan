using concurrent::Actor

@NoDoc
class EfanRenderCtx {

	static const Str localsName	:= "efan.renderCtx"
	
	StrBuf renderBuf {
		get { renderBufs.peek }
		private set { }
	}
	
	private StrBuf[] 			renderBufs	:= [,]
	private EfanRenderer[]		renderings	:= [,]
	private |EfanRenderer|?[] 	bodyFuncs	:= [,]
	private EfanRenderer?[] 	bodyObjs	:= [,]

	Void renderEfan(EfanRenderer renderer, Obj? rendererCtx, |EfanRenderer obj|? bodyFunc) {
		renderer._af_render(renderBuf, rendererCtx, bodyFunc, renderings.peek)
	}

	Void renderBody() {
		bodyFuncs.peek?.call(bodyObjs.peek)
	}
	
	Void renderWithBuf(EfanRenderer rendering, StrBuf renderBuf, |EfanRenderer|? bodyFunc, EfanRenderer? bodyObj, |->| renderFunc) {
		Actor.locals[localsName] = this
		renderBufs.push(renderBuf)
		renderings.push(rendering)
		bodyFuncs.push(bodyFunc)
		bodyObjs.push(bodyObj)
		
		try {
			renderFunc()

		} finally {
			renderBufs.pop
			renderings.pop
			bodyFuncs.pop
			bodyObjs.pop
			if (renderBufs.isEmpty) {
				Actor.locals[localsName] = null
			}			
		}
	}
	
	static EfanRenderCtx? ctx(Bool checked := true) {
		((EfanRenderCtx?) Actor.locals[localsName]) ?: (checked ? throw Err("EfanRenderCtx does not exist") : null) 
	}	
}
