
** A sane (const) wrapper around the generated efan renderer.
const class EfanRenderer {
	
	** The generated efan renderer.
	const Type rendererType
	
	** The 'ctx' type the renderer was generated for.
	const Type? ctxType

	private const Int initBufSize

	internal new make(Type rendererType, Type? ctxType, Int initBufSize) {
		this.rendererType 	= rendererType
		this.ctxType 		= ctxType
		this.initBufSize 	= initBufSize
	}
	
	** Instanstiates the efan renderer and renders with the given 'ctx'. Ensure the give 'ctx' is of 
	** the same type as [ctxType]`#ctxType`.
	Str render(Obj? ctx) {
		validateCtx(ctx)
		renderer := renderer(StrBuf(initBufSize))
		return renderer->render(ctx)
	}

	** I'd like this to be internal but it's called by renderers in diff pods
	@NoDoc
	Str nestedRender(|Obj| bodyFunc, Obj bodyObj, StrBuf codeBuf, Obj? ctx) {
		validateCtx(ctx)
		renderer := renderer(codeBuf)
		renderer->_bodyFunc	= bodyFunc
		renderer->_bodyObj 	= bodyObj
		return renderer->render(ctx)
	}

	private Obj renderer(StrBuf codeBuf) {
		bob	:= CtorPlanBuilder(rendererType)
		bob["_afCode"] = codeBuf
		return bob.makeObj
	}
	
	private Void validateCtx(Obj? ctx) {
		if (ctx == null && ctxType != null && !ctxType.isNullable)
			throw Err(ErrMsgs.rendererCtxIsNull(ctxType))
		if (ctx != null && !ctx.typeof.fits(ctxType))
			throw Err(ErrMsgs.rendererCtxBadFit(ctx, ctxType))
	}
}
