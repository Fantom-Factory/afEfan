using afIoc::PlasticClassModel
using afIoc::PlasticPodCompiler

** An Efan builder class for non-afIoc applications.
const class EfanBuilder {
	
	private const PlasticPodCompiler	podCompiler	:= PlasticPodCompiler() 
	private const EfanParser 			parser		:= EfanParser()
	
	new make(|This|? f := null) { f?.call(this) }

	Type compile(Str efan, Type? ctxType, Type[] mixins := Type#.emptyList) {
		model	:= PlasticClassModel("EfanRenderer", true)
		mixins.each { model.extendMixin(it) }
		code	:= parseIntoCode(efan)
		sig		:= (ctxType == null) ? "" : "${ctxType.qname} ctx"
		model.addMethod(Str#, "render", sig, code)

		pod		:= podCompiler.compile(model.toFantomCode)
		type	:= pod.type("EfanRenderer")

		return type		
	}

	Str parseIntoCode(Str efan) {
		data := EfanModel(efan.size)
		parser.parse(data, efan)
		return data.toFantomCode
	}
	
}
