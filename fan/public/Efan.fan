using afIoc::Inject

const class Efan {
	
	@Inject	private const EfanCompiler compiler
	
	internal new make(|This|in) { in(this) }
	
	Str renderStr(Str efan) {
		renderer := compiler.compile(efan)
		return renderer.render
	}
	
}
