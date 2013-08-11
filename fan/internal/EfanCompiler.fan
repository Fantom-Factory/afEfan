using afIoc::Inject
using afIoc::PlasticPodCompiler
using afIoc::PlasticClassModel

internal const class EfanCompiler {

	@Inject	private const PlasticPodCompiler podCompiler
	@Inject	private const EfanParser parser
	
	new make(|This|in) { in(this) }

	EfanRenderer compile(Str efan) {

		model := PlasticClassModel("EfanRenderer", true)
		model.extendMixin(EfanRenderer#)

		data	:= EfanModel(efan.size)
		parser.parse(data, efan)

		model.overrideMethod(EfanRenderer#render, data.toFantomCode)

		pod		:= podCompiler.compile(model.toFantomCode)
		type	:= pod.type("EfanRenderer")

		return type.make([null])	// TODO: remove [null] when afIoc 1.4.2 released		
	}
	
}


internal class EfanModel : Pusher {

	StrBuf code
	
	new make(Int bufSize) {
		code = StrBuf(bufSize)
		code.add("\t\tcode := StrBuf(${bufSize})\n")
	}
	
	override Void onCode(Str code) {
		
	}
	
	override Void onComment(Str comment) {
		// FIXME: handle multiline comments
		add("""// ${comment}""")
	}

	override Void onText(Str text) {
		add("""code.add("${text}")""")
	}

	override Void onEval(Str text) {
		
	}

	Str toFantomCode() {
		add("return code.toStr")
		return code.toStr
	}

	@Operator
	private This add(Str txt) {
		code.addChar('\t').addChar('\t').add(txt).addChar('\n')
		return this
	}
}