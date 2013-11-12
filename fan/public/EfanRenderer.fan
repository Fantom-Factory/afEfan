
** Represents a compiled efan template. Returned from `EfanCompiler`.
const mixin EfanRenderer {

	** Meta data about the compiled efan templates
	abstract EfanMetaData efanMetaData

	** The main render method. The 'bodyFunc' is executed when 'renderBody()' is called. Use it for
	** enclosing content in *Layout* templates. Example:
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
	**   layout.render() { ... } - WRONG!
	**   layout.render(null) { ... } - CORRECT!
	** 
	** The signature for 'bodyFunc' is actually '|->|? bodyFunc' - see source for an explanation of 
	** why '|Obj?|?' is used.
	virtual Str render(Obj? ctx, |Obj?|? bodyFunc := null) {
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
		EfanRenderCtx.renderEfan(this, (|->|?) bodyFunc) |->| {
			_af_render(ctx)
		}
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
	
	** Returns efanMetaData.templateId()
	override Str toStr() { efanMetaData.templateId }
	
	** Where the compiled efan template code lives. 
	@NoDoc
	abstract Void _af_render(Obj? _ctx)
}
