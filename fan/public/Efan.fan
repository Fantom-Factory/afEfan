
const class Efan {
	
	const private EfanCompiler	compiler	:= EfanCompiler()
	
	Str renderFromStr(Str efan, Obj? ctx := null, Type[] viewHelpers := Type#.emptyList) {
		renderer := compiler.compile(`rendered/from/str`, efan, ctx?.typeof, viewHelpers)
		return renderer.render(ctx)
	}

	Str renderFromFile(File efan, Obj? ctx := null, Type[] viewHelpers := Type#.emptyList) {
		renderer := compiler.compile(efan.normalize.uri, efan.readAllStr, ctx?.typeof, viewHelpers)
		return renderer.render(ctx)
	}

}
