using compiler::CompilerErr
using afIoc::Inject
using afIoc::PlasticClassModel
using afIoc::PlasticCompilationErr
using afIoc::PlasticPodCompiler
using afIoc::SrcErrLocation

** Compiles efan templates into Fantom code; maybe used outside of [afIoc]`http://repo.status302.com/doc/afIoc/#overview`.
const class EfanCompiler {
	// TODO: remove @Injects - turn into POFO
	@Inject	private const PlasticPodCompiler podCompiler
	@Inject	private const EfanParser parser
//	@Inject @Config privat const Int srcLineCode	// TODO: USE
	
	new make(|This|? in := null) {
		in?.call(this)
		
		// create new services for non-afIoc projects
		if (podCompiler == null)
			podCompiler = PlasticPodCompiler()
		if (parser == null)
			parser = EfanParser()
	}

	Obj compile(Str efanCode, Type? ctxType, Type[] viewHelpers := Type#.emptyList) {
		model	:= PlasticClassModel("EfanRenderer", true)
		viewHelpers.each { model.extendMixin(it) }

		model.addField(Type?#, "ctxType")

		renderCode	:= parseIntoCode(efanCode)
		renderSig	:= (ctxType == null) ? "" : "${ctxType.qname} ctx"
		model.addMethod(Str#, "render", renderSig, renderCode)

		type		:= (Type?) null
		
		try {
			type	= compileCode(model.toFantomCode, "EfanRenderer")

		} catch (PlasticCompilationErr err) {
			plasticErrLoc	:= (SrcErrLocation) err.srcErrLoc
			
			fanCodeLines	:= model.toFantomCode.splitLines
			fanLineNo		:= plasticErrLoc.errLineNo - 1	// from 1 to 0 based
			
			reggy 			:= Regex<|^\s+?// -> Line ([0-9])+$|>
			efanLineNo		:= 0
			
			while (fanLineNo > 0 && efanLineNo == 0) {
				code := fanCodeLines[fanLineNo]
				reg := reggy.matcher(code)
				if (reg.find) {
					efanLineNo = reg.group(1).toInt
				} else {
					fanLineNo--
				}
			}
			
			if (fanLineNo == 0)
				throw err
			
			efanErrLoc	:= SrcErrLocation(`FIXME`, efanCode, efanLineNo, err.msg)
			throw EfanCompilationErr(efanErrLoc)
		}		
		
		ctxField 	:= type.field("ctxType")
		ctorPlan	:= Field:Obj?[ctxField:ctxType]
		ctorFunc	:= Field.makeSetFunc(ctorPlan)

		return type.make([ctorFunc])
	}

	private Type compileCode(Str code, Str className) {
		pod		:= podCompiler.compile(code)
		type	:= pod.type("EfanRenderer")
		return type
	}
	
	internal Str parseIntoCode(Str efan) {
		data := EfanModel(efan.size)
		parser.parse(data, efan)
		return data.toFantomCode
	}
}
