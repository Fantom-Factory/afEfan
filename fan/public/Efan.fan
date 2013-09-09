
** Service methods for compiling and rendering efan templates.
const class Efan {
	
	const private EfanCompiler	compiler	:= EfanCompiler()
	
	** Renders the given efan 'Str' template.
	Str renderFromStr(Str efan, Obj? ctx := null, Type[] viewHelpers := Type#.emptyList) {
		renderType	:= compiler.compileWithHelpers(`rendered/from/str`, efan, ctx?.typeof, viewHelpers)
		renderer	:= (EfanRenderer) renderType.make
		return renderer.render(ctx)
	}

	** Renders the given efan 'File' template.
	Str renderFromFile(File efan, Obj? ctx := null, Type[] viewHelpers := Type#.emptyList) {
		renderType	:= compiler.compileWithHelpers(efan.normalize.uri, efan.readAllStr, ctx?.typeof, viewHelpers)
		renderer	:= (EfanRenderer) renderType.make
		return renderer.render(ctx)
	}

}
