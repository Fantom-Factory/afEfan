using concurrent::Actor

@NoDoc
class EfanRenderCtx {

	static const Str localsName	:= "efan.renderCtx"

	EfanRender efanRender {
		get { efanRenders.peek }
		private set { }
	}
	
	private EfanRender[] efanRenders := [,]
	
	Void renderWithBuf(EfanRenderer rendering, StrBuf renderBuf, |EfanRenderer|? bodyFunc, EfanRenderer? bodyObj, |->| renderFunc) {
		Actor.locals[localsName] = this
		
		render := EfanRender(rendering, renderBuf, bodyFunc, bodyObj)
		efanRenders.push(render)
		
		try {
			// FIXME: catch Runtime expcetions and report srcErr
			renderFunc()

		} finally {
			efanRenders.pop
			if (efanRenders.isEmpty) {
				Actor.locals.remove(localsName)
			}			
		}
	}
	
	static EfanRenderCtx? ctx(Bool checked := true) {
		((EfanRenderCtx?) Actor.locals[localsName]) ?: (checked ? throw Err("EfanRenderCtx does not exist") : null) 
	}	

	static EfanRender? render() {
		ctx.efanRender
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
