
** Represents a compiled efan template. Returned from `EfanCompiler`.
const mixin EfanRenderer {

	** Meta data about the compiled efan templates
	abstract EfanMetaData efanMetaData

	** The main render method. 
	** 
	** Renders the efan template to a Str, passing in the given 'ctx' (which must fit [ctxType]`#ctxType`).
	virtual Str render(Obj? ctx) {
		ctxType := efanMetaData.ctxType
		if (ctx == null && ctxType != null && !ctxType.isNullable)
			throw EfanErr("${ErrMsgs.rendererCtxIsNull} ${ctxType.typeof.signature}")
		if (ctx != null && ctxType != null && !ctx.typeof.fits(ctxType))
			throw EfanErr("ctx ${ctx.typeof.signature} ${ErrMsgs.rendererCtxBadFit(ctxType)}")

		return _af_render(ctx, null)
	}

	** Renders the given nested efan template. Use when you want to enclose content in an outer efan 
	** template. The content will be rendered whenever the renderer calls 'renderBody()'. Example:
	** 
	** pre>
	** ...
	** <%= renderEfan(ctx.layout, ctx.layoutCtx) { %>
	**   ... my body content ...
	** <% } %>
	** ...
	** <pre
	virtual Str renderEfan(EfanRenderer renderer, Obj? ctx := null, |Obj?|? bodyFunc := null) {
		// TODO: Dodgy Fantom syntax!!!		
		// if we change "|Obj?|? bodyFunc" to "|->| bodyFunc" then the following: 
		//    renderEfan(efanRenderer, ctx) { ... }
		// becomes
		//    renderEfan(efanRenderer, ctx).with { ... }
		// ARGH!!! The following works, but I don't want the extra |->| syntax - it looks crap in efan templates!
		//    renderEfan(efanRenderer, ctx) |->| { ... }
		renderer._af_render(ctx, (|->|?) bodyFunc)
	}
	
	** Renders the body of the enclosing efan template. Example, a simple 'layout.html' may be 
	** defined as: 
	** 
	** pre>
	** <html>
	** <head>
	**   <title><%= ctx.pageTitle %>
	** </html>
	** <body>
	**     <%= renderBody() %>
	** </html>
	** <pre
	virtual Str renderBody() {
		EfanRenderCtx.renderBody
	}

	@NoDoc
	abstract Str _af_render(Obj? _ctx, |->|? _bodyFunc)

	@NoDoc
	StrBuf _af_code() {
		EfanRenderCtx.peek.renderBuf
	}
}
