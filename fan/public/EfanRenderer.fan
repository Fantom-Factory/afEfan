
** A sane (const) wrapper around the generated efan renderer.
const class EfanRenderer {
	
	private const Type rendererType
	private const Int initBufSize
	
	const Type? ctxType
	
	new make(Type rendererType, Type? ctxType, Int initBufSize) {
		this.rendererType = rendererType
		this.ctxType = ctxType
		this.initBufSize = initBufSize
	}
	
	Str render(Obj? ctx) {
		if (ctx == null && ctxType != null && !ctxType.isNullable)
			throw Err("Bollocks!")	// FIXME: Err msg
		if (ctx != null && !ctx.typeof.fits(ctxType))
			throw Err("Bollocks!")	// FIXME: Err msg
		
		bob	:= CtorPlanBuilder(rendererType)
		bob["ctxType"] = ctxType
		bob["_afCode"] = StrBuf(initBufSize)
		renderer := bob.makeObj
		
		return renderer->render(ctx)
	}
}
