
** A compiled efan template, ready for rendering! 
const mixin EfanTemplate {

	** Meta data about this efan template.
	abstract EfanTemplateMeta templateMeta

	** The main render method. 
	** 
	** The 'bodyFunc' is executed when 'renderBody()' is called. Use it when enclosing content in 
	** *Layout* templates. Example:
	** 
	** pre>
	** ...
	** <%= ctx.layout.render(ctx.layoutCtx) { %>
	**   ... my body content ...
	** <% } %>
	** ...
	** <pre
	** 
	** 'ctx' must be provided. This prevents you from accidently passing in 'bodyFunc' as the 'ctx'.
	** Example: 
	** 
	**   layout.render() { ... }      // --> WRONG!
	**   layout.render(null) { ... }  // --> CORRECT!
	** 
	** The signature for 'bodyFunc' is actually '|->|? bodyFunc' - see source for an explanation of 
	** why '|Obj?|?' is used.
	virtual Str render(Obj? ctx, |Obj?|? bodyFunc := null) {
		
		// much better than the default capacity of 16 bytes!
		renderBuf := StrBuf(templateMeta.templateSrc.size)
		
		// FIXME: try using |This|, (see Locale.use) and then we could write: it.renderBody()
		// Locale("zh-CN").use {  echo(Locale.cur) }
		
		// TODO: Dodgy Fantom Syntax!!!		
		// if we change "|Obj?|? bodyFunc" to "|->| bodyFunc" then the following: 
		//    render(ctx) { ... }
		// is actually executed as:
		//    render(ctx).with { ... }
		// ARGH!!! It works if you declare the func properly, as in: 
		//    render(ctx) |->| { ... }
		// But then it looks naff, is extra stuff to type, and you get very confusing side effects 
		// if you forget to type it.
		// Bizarrely enough, this DOES still work...?
		//    render() { ... }
		EfanRenderer.renderTemplate(templateMeta, this, renderBuf, (|->|?) bodyFunc) |->| {
			_efan_render(ctx)
		}
		return renderBuf.toStr
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
		renderBuf := StrBuf(templateMeta.templateSrc.size)
		EfanRenderer.renderBody(renderBuf)
		return renderBuf.toStr
	}
	
	** Returns efanMetaData.templateId()
	@NoDoc
	override Str toStr() { templateMeta.templateId }
	
	** Where the compiled efan template code lives. 
	@NoDoc
	abstract Void _efan_render(Obj? _ctx)
}
