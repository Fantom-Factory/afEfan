using afIoc::Inject
using afIoc::ConcurrentCache

const class EfanService {
			private const ConcurrentCache	rendererCache	:= ConcurrentCache()
	@Inject	private const EfanCompiler 		compiler
	
	internal new make(|This|in) { in(this) }
	
	Str renderStr(Str efan, Obj? ctx := null) {
		renderType	:= compiler.compile(efan, ctx?.typeof)
		renderer 	:= renderType.make 
		return renderer->render(ctx)
	}
	
	Str renderFile(File efanFile, Obj? ctx := null) {
		key := key(efanFile, ctx)
		if (!rendererCache.containsKey(key)) {
			template 	:= efanFile.readAllStr
			renderType	:= compiler.compile(template, ctx?.typeof)
			renderer 	:= renderType.make
			rendererCache[key] = renderer
		}
		
		return rendererCache[key]->render(ctx)
	}
	
	private Str key(File efanFile, Obj? ctx) {
		"${efanFile.uri} -> ${ctx?.typeof}"
	}
}
