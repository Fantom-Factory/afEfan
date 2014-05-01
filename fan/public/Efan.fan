
** Non-caching service methods for compiling and rendering efan templates.
const class Efan {
	
	const private EfanCompiler	efanCompiler	:= EfanCompiler()
	
	** Compiles a new renderer from the given efan 'Str' template. 
	** 
	** The compiled renderer extends the given view helper mixins.
	** 
	** 'srcLocation' may be anything - used for meta information only.
	EfanRenderer compileFromStr(Str efanTemplate, Type? ctxType := null, Type[]? viewHelpers := null, Uri? srcLocation := null) {
		srcLocation	= srcLocation ?: `from/efan/template`
		return efanCompiler.compile(srcLocation, efanTemplate, ctxType, viewHelpers ?: Type#.emptyList)
	}	

	** Compiles a new renderer from the given efan 'File' template. 
	** 
	** The compiled renderer extends the given view helper mixins.
	EfanRenderer compileFromFile(File efanFile, Type? ctxType := null, Type[]? viewHelpers := null) {
		srcLocation	:= efanFile.normalize.uri
		return efanCompiler.compile(efanFile.normalize.uri, efanFile.readAllStr, ctxType, viewHelpers ?: Type#.emptyList)
	}	
	
	** Compiles and renders the given efan 'Str' template.
	** 
	** 'srcLocation' may be anything - used for meta information only.
	Str renderFromStr(Str efanTemplate, Obj? ctx := null, Type[]? viewHelpers := null, Uri? srcLocation := null) {
		renderer := compileFromStr(efanTemplate, ctx?.typeof, viewHelpers, srcLocation)
		return renderer.render(ctx)
	}

	** Compiles and renders the given efan 'File' template.
	Str renderFromFile(File efanFile, Obj? ctx := null, Type[]? viewHelpers := null) {
		renderer := compileFromFile(efanFile, ctx?.typeof, viewHelpers)
		return renderer.render(ctx)
	}
}
