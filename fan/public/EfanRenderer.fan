
** A sane wrapper around the generated efan renderer.
const mixin EfanRenderer {

	** The 'ctx' type the renderer was generated for.
	abstract Type? ctxType
	
	** Renders with the given 'ctx'. 
	** Ensure the give 'ctx' is of the same type as [ctxType]`#ctxType`.
	Str render(Obj? ctx) {
		validateCtx(ctx)
		codeBuf := StrBuf()
		_af_render(codeBuf, ctx, null, null)
		return codeBuf.toStr
	}

	@NoDoc
	abstract Void _af_render(StrBuf _af_code, Obj? _ctx, |EfanRenderer t|? _bodyFunc, EfanRenderer? _bodyObj)
	
	@NoDoc
	protected Obj? validateCtx(Obj? ctx) {
		if (ctx == null && ctxType != null && !ctxType.isNullable)
			throw Err(ErrMsgs.rendererCtxIsNull(ctxType))
		if (ctx != null && ctxType != null && !ctx.typeof.fits(ctxType))
			throw Err(ErrMsgs.rendererCtxBadFit(ctx, ctxType))
		return ctx
	}
}
