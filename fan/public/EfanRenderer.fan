
** As implemented by all generated efan types.
const mixin EfanRenderer {

	** The 'ctx' type the renderer was generated for.
	abstract Type? ctxType
	
	** Renders with the given 'ctx', which must fit [ctxType]`#ctxType`.
	virtual Str render(Obj? ctx) {
		codeBuf := StrBuf()
		_af_render(codeBuf, ctx, null, null)
		return codeBuf.toStr
	}

	virtual Void renderEfan(EfanRenderer renderer, Obj? rendererCtx := null, |EfanRenderer obj|? bodyFunc := null) {
		EfanRenderCtx.ctx.renderEfan(renderer, rendererCtx, bodyFunc)
	}

	virtual Void renderBody() {
		EfanRenderCtx.ctx.renderBody
	}
	
	@NoDoc
	abstract Void _af_render(StrBuf _af_code, Obj? _ctx, |EfanRenderer t|? _bodyFunc, EfanRenderer? _bodyObj)

}
