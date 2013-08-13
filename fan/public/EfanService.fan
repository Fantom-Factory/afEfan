using afIoc::Inject

const class EfanService {
	
	@Inject	private const EfanCompiler compiler
	
	internal new make(|This|in) { in(this) }
	
	Str renderStr(Str efan, Obj? ctx := null) {
		renderType	:= compiler.compile(efan, ctx?.typeof)
		renderer 	:= renderType.make 
		return renderer->render(ctx)
	}
	
}
