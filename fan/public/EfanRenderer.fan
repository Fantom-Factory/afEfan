
** A sane (const) wrapper around the generated efan renderer.
const class EfanRenderer {
	
	private const Type rendererType
	private const Int initBufSize
	
	const Type? ctxType

	internal new make(Type rendererType, Type? ctxType, Int initBufSize) {
		this.rendererType 	= rendererType
		this.ctxType 		= ctxType
		this.initBufSize 	= initBufSize
	}
	
	Str render(Obj? ctx) {
		if (ctx == null && ctxType != null && !ctxType.isNullable)
			throw Err("Bollocks!")	// FIXME: Err msg
		if (ctx != null && !ctx.typeof.fits(ctxType))
			throw Err("Bollocks!")	// FIXME: Err msg

		renderer := renderer(StrBuf(initBufSize))
		return renderer->render(ctx)
	}
	
	@NoDoc
	Str nestedRender(|Obj| bodyFunc, Obj bodyObj, StrBuf codeBuf, Obj? ctx) {
		// FIXME: ctx (like above)
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
}
