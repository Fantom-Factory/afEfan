using afIoc::Inject
using afIoc::PlasticClassModel
using afIoc::PlasticPodCompiler

** Compiles efan templates into Fantom code; maybe used outside of [afIoc]`http://repo.status302.com/doc/afIoc/#overview`.
const class EfanCompiler {
	@Inject	private const PlasticPodCompiler podCompiler
	@Inject	private const EfanParser parser
	
	new make(|This|? in := null) {
		in?.call(this)
		
		// create new services for non-afIoc projects
		if (podCompiler == null)
			podCompiler = PlasticPodCompiler()
		if (parser == null)
			parser = EfanParser()
	}

	Obj compile(Str efan, Type? ctxType, Type[] viewHelpers := Type#.emptyList) {
		model	:= PlasticClassModel("EfanRenderer", true)
		viewHelpers.each { model.extendMixin(it) }

		model.addField(Type?#, "ctxType")

		code	:= parseIntoCode(efan)
		sig		:= (ctxType == null) ? "" : "${ctxType.qname} ctx"
		model.addMethod(Str#, "render", sig, code)

		pod		:= podCompiler.compile(model.toFantomCode)
		type	:= pod.type("EfanRenderer")

		ctxField 	:= type.field("ctxType")
		ctorPlan	:= Field:Obj?[ctxField:ctxType]
		ctorFunc	:= Field.makeSetFunc(ctorPlan)

		return type.make([ctorFunc])
	}

	internal Str parseIntoCode(Str efan) {
		data := EfanModel(efan.size)
		parser.parse(data, efan)
		return data.toFantomCode
	}
}
