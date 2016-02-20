using afPlastic::SrcCodeSnippet

** Meta data about an efan template. 
** 
** Generated by the efan compiler.
const class EfanTemplateMeta {

	** The 'Type' of the compiled efan template.
	const Type type

	** The generated fantom code of the efan template (for the inquisitive).
	const Str typeSrc

	** A unique ID for the template. Defaults to the fully qualified type name.
	const Str templateId
	
	** Where the template originated from. Example, 'file://layout.efan'. 
	const Uri templateLoc

	** The original efan template source string.
	const Str templateSrc
	
	// ctx variables used by BedSheetEfan and Genesis - they recompile the template if they change.
	
	** The 'ctx' type the template was compiled against.
	** Returns 'null' if a ctx variable was not used.
	const Type? ctxType

	** The name of the 'ctx' variable the template was compiled with. 
	** Returns 'null' if a ctx variable was not used.
	const Str? ctxName
	
	internal const Int srcCodePadding

	@NoDoc
	new make(|This|? in := null) {
		in?.call(this)
		if (null == this.type)			this.type			= Void#
		if (null == this.typeSrc)		this.typeSrc		= ""
		if (null == this.templateId)	this.templateId		= genId
		if (null == this.templateLoc)	this.templateLoc	= `wherever`
		if (null == this.templateSrc)	this.templateSrc	= ""
	}

	** The main render method. 
	** 
	** 'ctx' must be provided. This prevents you from accidently passing in 'bodyFunc' as the 'ctx'.
	** Example: 
	** 
	**   syntax: fantom
	** 
	**   layout.render() { ... }      // --> WRONG!
	**   layout.render(null) { ... }  // --> CORRECT!
	** 
	** The 'bodyFunc' is executed when 'renderBody()' is called. Use it when enclosing content in 
	** *Layout* templates. Example:
	** 
	** pre>
	** syntax: html
	** ...
	** <%= ctx.layout.render(ctx.layoutCtx) { %>
	**   ... my body content ...
	** <% } %>
	** ...
	** <pre
	** 
	** The signature for 'bodyFunc' is actually '|->|? bodyFunc' - see source for an explanation of 
	** why '|Obj?|?' is used.
	Str render(Obj? ctx, |Obj?|? bodyFunc := null) {
		instance	:= type.make
		renderBuf	:= StrBuf(templateSrc.size)
		EfanRenderer.renderTemplate(this, instance, renderBuf, (|->|?) bodyFunc) |->| {
			type.method("_efan_render").call(instance, ctx)
		}
		return renderBuf.toStr
	}
	
	** Renders the body of the enclosing efan template. Should only be called from within templates.
	**  
	** Example, a simple 'layout.html' may be defined as: 
	** 
	** pre>
	** syntax: html
	** 
	** <html>
	** <head>
	**   <title><%= ctx.pageTitle %>
	** </html>
	** <body>
	**     <%= renderBody() %>
	** </html>
	** <pre
	virtual Str renderBody() {
		renderBuf := StrBuf(templateSrc.size)
		EfanRenderer.renderBody(renderBuf)
		return renderBuf.toStr
	}

	internal Void throwCompilationErr(Err cause, Int srcCodeLineNo) {
		templateLineNo	:= findTemplateLineNo(srcCodeLineNo) ?: throw cause
		srcCodeSnippet	:= SrcCodeSnippet(templateLoc, templateSrc)
		throw EfanCompilationErr(srcCodeSnippet, templateLineNo, cause.msg, srcCodePadding, cause)
	}
	
	internal Void throwRuntimeErr(Err cause, Int srcCodeLineNo) {
		templateLineNo	:= findTemplateLineNo(srcCodeLineNo) ?: throw cause
		srcCodeSnippet	:= SrcCodeSnippet(templateLoc, templateSrc)
		throw EfanRuntimeErr(srcCodeSnippet, templateLineNo, cause.msg, srcCodePadding, cause)
	}

	private Int? findTemplateLineNo(Int srcCodeLineNo) {
		fanLineNo		:= srcCodeLineNo - 1	// from 1 to 0 based
		reggy 			:= Regex<|\s+?// \(efan\) --> ([0-9]+)$|>
		efanLineNo		:= (Int?) null
		fanCodeLines	:= typeSrc.splitLines
		
		while (fanLineNo > 0 && efanLineNo == null) {
			code := fanCodeLines[fanLineNo]
			reg := reggy.matcher(code)
			if (reg.find) {
				efanLineNo = reg.group(1).toInt
			} else {
				fanLineNo--
			}
		}
		
		return efanLineNo
	}
	
	// Used by afEfanXtra::ComponentCompiler
	** Clones this object, setting the given values.
	@NoDoc
	EfanTemplateMeta clone([Field:Obj?]? overrides := null) {
		Utils.cloneObj(this) |[Field:Obj?] plan| { plan.setAll(overrides) }
	}
	
	private static Str genId() {
		// format as: "tttttttt-rrrrrrrr"
		time := (DateTime.nowTicks / 1sec.ticks).and(0xffff_ffff)
		rand := (Int.random).and(0xffff_ffff)
		return StrBuf(20).add(time.toHex(8)).addChar('-').add(rand.toHex(8)).toStr
	}
}