using afIoc::Inject
using afIoc::ConcurrentCache

// TODO: hide behind a mixin
** Renders Embedded Fantom (efan) templates against a given context.
const class EfanService {
			private const ConcurrentCache	rendererCache	:= ConcurrentCache()
	@Inject	private const EfanCompiler 		compiler
	@Inject	private const EfanHelpers 		helpers

	internal new make(|This|in) { in(this) }

	** Renders the given template with the a ctx. 
	Str renderFromStr(Str efan, Obj? ctx := null) {
		renderType	:= compiler.compile(efan, ctx?.typeof, helpers.helpers)
		renderer 	:= renderType.make 
		return renderer->render(ctx)
	}

	** Renders an '.efan' template file with the given ctx. 
	** The compiled '.efan' template is cached for re-use.   
	Str renderFromFile(File efanFile, Obj? ctx := null) {
		key := key(efanFile, ctx)
		if (!rendererCache.containsKey(key)) {
			template 	:= efanFile.readAllStr
			renderType	:= compiler.compile(template, ctx?.typeof, helpers.helpers)
			renderer 	:= renderType.make
			rendererCache[key] = renderer
		}

		return rendererCache[key]->render(ctx)
	}

	private Str key(File efanFile, Obj? ctx) {
		"${efanFile.uri} -> ${ctx?.typeof}"
	}
}
