using afPlastic

** Methods for compiling and rendering efan templates.
** Note these methods are non-caching.
const class Efan {
	
	@NoDoc
	const EfanCompiler	efanCompiler	:= EfanCompiler(EfanEngine(PlasticCompiler()))
	
	@NoDoc
	new make(|This|? in := null) { in?.call(this) } 
	
	** Compiles a new efan template from the given efan 'Str'. 
	** 
	** The compiled template extends the given view helper mixins.
	** 
	** 'srcLocation' may be anything - used for meta information only.
	EfanTemplateMeta compileFromStr(Str efanTemplate, Type? ctxType := null, Type[]? viewHelpers := null, Uri? srcLocation := null) {
		srcLocation	= srcLocation ?: `from/efan/template`
		return efanCompiler.compile(srcLocation, efanTemplate, ctxType, viewHelpers ?: Type#.emptyList)
	}	

	** Compiles a new template from the given efan 'File'. 
	** 
	** The compiled template extends the given view helper mixins.
	EfanTemplateMeta compileFromFile(File efanFile, Type? ctxType := null, Type[]? viewHelpers := null) {
		srcLocation	:= efanFile.normalize.uri
		return efanCompiler.compile(efanFile.normalize.uri, efanFile.readAllStr, ctxType, viewHelpers ?: Type#.emptyList)
	}	
	
	** Compiles and renders the given efan 'Str' template.
	** 
	** 'srcLocation' may be anything - used for meta information only.
	Str renderFromStr(Str efanTemplate, Obj? ctx := null, Type[]? viewHelpers := null, Uri? srcLocation := null) {
		template := compileFromStr(efanTemplate, ctx?.typeof, viewHelpers, srcLocation)
		return template.render(ctx)
	}

	** Compiles and renders the given efan 'File' template.
	Str renderFromFile(File efanFile, Obj? ctx := null, Type[]? viewHelpers := null) {
		template := compileFromFile(efanFile, ctx?.typeof, viewHelpers)
		return template.render(ctx)
	}

	** Returns a stack of nested templates that are currently being rendered. 
	** Returns an empty list if nothing is being rendered.
	** 
	** The first item in the list is the top level template, and subsequent items represent nested templates.
	static RenderingElement[] renderingStack() {
		EfanRenderingStack.getStack(false)?.map |element| {
			ctx := (EfanRendererCtx) element.ctx["efan.renderCtx"]
			return RenderingElement {
				it.templateInstance = ctx.rendering
				it.templateMeta		= ctx.efanMeta
			}
		} ?: RenderingElement#.emptyList
	}
}

** An item in the [rendering stack]`Efan.renderingStack`. 
class RenderingElement {
	
	** The efan template instance being rendered.
	Obj					templateInstance
	
	** Associated meta for the template instance.
	EfanTemplateMeta	templateMeta
	
	internal new make(|This|in) { in(this) }
}