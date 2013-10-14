
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
	** The signature for 'bodyFunc' is actually '|->|? bodyFunc' - see source for an explanation of 
	** why '|Obj?|?' is used.   
	virtual Str render(Obj? ctx := null, |Obj?|? bodyFunc := null) {
		// TODO: Dodgy Fantom syntax!!!		
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
		_af_render(ctx, (|->|?) bodyFunc)
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

	** A unique ID for the efan template. Defaults to the fully qualified type name.
	virtual Str id() {
		// FQCN is pretty yucky, but for unique ids we don't have much to go on!
		// Thankfully only efanExtra needs it, and it provides its own impl.
		typeof.qname
	}
	
	override Str toStr() { id }
	
	** Where the compiled efan template code lives. 
	@NoDoc
	abstract Str _af_render(Obj? _ctx, |->|? _bodyFunc)
}
