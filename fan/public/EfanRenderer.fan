
** Represents a compiled efan template. Returned from `EfanCompiler`.
const mixin EfanRenderer {

	** Meta data about the compiled efan templates
	abstract EfanMetaData efanMetaData
	
	** The main render method. 
	** 
	** Renders the efan template to a Str, passing in the given 'ctx' (which must fit [ctxType]`#ctxType`).
	virtual Str render(Obj? ctx) {
		codeBuf := StrBuf()
		_af_render(codeBuf, ctx, null, null)
		return codeBuf.toStr
	}

	** Renders the given nested efan template. Use when you want to enclose content in an outer efan 
	** template. The content will be rendered whenever the renderer calls 'renderBody()'. Example:
	** 
	** pre>
	** ...
	** <% renderEfan(ctx.layout, ctx.layoutCtx) { %>
	**   ... my main content ...
	** <% } %>
	** ...
	** <pre
	virtual Void renderEfan(EfanRenderer renderer, Obj? rendererCtx := null, |EfanRenderer obj|? bodyFunc := null) {
		EfanRenderCtx.render.efan(renderer, rendererCtx, bodyFunc)
	}
	
	** Renders the body of the enclosing efan template. Example, a 'layout.html' may be defined as: 
	** 
	** pre>
	** <html>
	** <head>
	**   <title><%= ctx.pageTitle %>
	** </html>
	** <body>
	**     <div class="wotever">
	**       <% renderBody() %>
	**     </div>
	** </html>
	** <pre
	virtual Void renderBody() {
		EfanRenderCtx.render.body
	}

	@NoDoc
	abstract Void _af_render(StrBuf _af_code, Obj? _ctx, |EfanRenderer t|? _bodyFunc, EfanRenderer? _bodyObj)

}
