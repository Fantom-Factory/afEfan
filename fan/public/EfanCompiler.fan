using compiler::CompilerErr
using afIoc::Inject
using afIoc::PlasticClassModel
using afIoc::PlasticCompilationErr
using afIoc::PlasticPodCompiler
using afIoc::SrcErrLocation

** Compiles efan templates into Fantom code; maybe used outside of [afIoc]`http://repo.status302.com/doc/afIoc/#overview`.
const class EfanCompiler {
	
	private const Str rendererClassName	:= "EfanRenderer"  
	
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

	Obj compile(Uri srcLocation, Str efanCode, Type? ctxType, Type[] viewHelpers := Type#.emptyList) {
		model	:= PlasticClassModel(rendererClassName, true)
		viewHelpers.each { model.extendMixin(it) }

		model.addField(Type?#, "ctxType")

		renderCode	:= parseIntoCode(srcLocation, efanCode)
		renderSig	:= (ctxType == null) ? "" : "${ctxType.qname} ctx"
		model.addMethod(Str#, "render", renderSig, renderCode)

		type		:= (Type?) null
		
		try {
			type	= compileCode(model.toFantomCode, rendererClassName)

		} catch (PlasticCompilationErr err) {
			efanLineNo	:= findEfanLineNo(err.srcErrLoc) ?: throw err
			efanErrLoc	:= SrcErrLocation(srcLocation, efanCode, efanLineNo, err.msg)
			throw EfanCompilationErr(efanErrLoc)
		}		
		
		ctxField 	:= type.field("ctxType")
		ctorPlan	:= Field:Obj?[ctxField:ctxType]
		ctorFunc	:= Field.makeSetFunc(ctorPlan)

		return type.make([ctorFunc])
	}
	
	internal Str parseIntoCode(Uri srcLocation, Str efan) {
		data := EfanModel(efan.size)
		parser.parse(srcLocation, data, efan)
		return data.toFantomCode
	}

	private Type compileCode(Str fanCode, Str className) {
		pod		:= podCompiler.compile(fanCode)
		type	:= pod.type(className)
		return type
	}
	
	private Int? findEfanLineNo(SrcErrLocation plasticErrLoc) {
		fanCodeLines	:= plasticErrLoc.srcCode
		fanLineNo		:= plasticErrLoc.errLineNo - 1	// from 1 to 0 based
		reggy 			:= Regex<|^\s+?// --> ([0-9]+)$|>
		efanLineNo		:= (Int?) null
		
		while (fanLineNo > 0 && efanLineNo == null) {
			code := fanCodeLines[fanLineNo]
			reg := reggy.matcher(code)
			if (reg.find) {
				efanLineNo = reg.group(1).toInt
			} else {
				fanLineNo--
			}
		}
		
		return efanLineNo
	}
}
