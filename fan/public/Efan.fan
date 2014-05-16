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
	EfanTemplate compileFromStr(Str efanTemplate, Type? ctxType := null, Type[]? viewHelpers := null, Uri? srcLocation := null) {
		srcLocation	= srcLocation ?: `from/efan/template`
		return efanCompiler.compile(srcLocation, efanTemplate, ctxType, viewHelpers ?: Type#.emptyList)
	}	

	** Compiles a new template from the given efan 'File'. 
	** 
	** The compiled template extends the given view helper mixins.
	EfanTemplate compileFromFile(File efanFile, Type? ctxType := null, Type[]? viewHelpers := null) {
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
}
