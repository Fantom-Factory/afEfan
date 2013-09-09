using afPlastic::PlasticCompilationErr
using afPlastic::PlasticClassModel
using afPlastic::PlasticPodCompiler
using afPlastic::SrcErrLocation

** Compiles efan templates into Fantom code; maybe used outside of [afIoc]`http://repo.status302.com/doc/afIoc/#overview`.
const class EfanCompiler {
	
	** The name given to the 'ctx' variable in the render method. 
	public const  Str					ctxVarName			:= "ctx"
	
	** When generating code snippets to report compilation Errs, this is the number of lines of src 
	** code the erroneous line should be padded with.  
	public const  Int 					srcCodePadding		:= 5 

	private const Str 					rendererClassName	:= "EfanRenderer"  
	private const PlasticPodCompiler	plasticCompiler		:= PlasticPodCompiler()
	private const EfanParser 			parser				:= EfanParser() 
		
	** Create an 'EfanCompiler'.
	new make(|This|? in := null) {
		in?.call(this)
	}

	** Standard compilation method.
	** Compiles a new renderer from the given efanTemplate.
	** This method compiles a new Fantom Type so use judiciously to avoid memory leaks.
	** 'srcLocation' is only used for Err msgs.
	EfanRenderer compile(Uri srcLocation, Str efanTemplate, Type? ctxType) {
		return compileWithHelpers(srcLocation, efanTemplate, ctxType)
	}

	** Compiles a new renderer from the given efanTemplate.
	** This method compiles a new Fantom Type so use judiciously to avoid memory leaks.
	** 'srcLocation' is only used for Err msgs.
	EfanRenderer compileWithHelpers(Uri srcLocation, Str efanTemplate, Type? ctxType, Type[] viewHelpers := Type#.emptyList) {
		model	:= PlasticClassModel(rendererClassName, true)
		viewHelpers.each { model.extendMixin(it) }
		return compileWithModel(srcLocation, efanTemplate, ctxType, model)
	}

	** Compiles a new renderer from the given efanTemplate.
	** This method compiles a new Fantom Type so use judiciously to avoid memory leaks.
	** 'srcLocation' is only used for Err msgs.
	EfanRenderer compileWithModel(Uri srcLocation, Str efanTemplate, Type? ctxType, PlasticClassModel model) {

		if (!model.isConst)
			throw Err("model is const!")	// FIXME: better Err msg

		type		:= (Type?) null
		ctxSig		:= (ctxType == null) ? "Obj?" : ctxType.signature
		renderCode	:= "${ctxSig} ctx := validateCtx(_ctx)\n\n"
		renderCode  += """renderEfan := |EfanRenderer renderer, Obj? rendererCtx, |EfanRenderer obj| bodyFunc| {
		                  	renderer._af_render(_af_code, rendererCtx, bodyFunc, this)
		                  }\n"""
		renderCode  += """renderBody := |->| {
		                  	_bodyFunc?.call(_bodyObj)
		                  }\n"""
		renderCode	+= parseIntoCode(srcLocation, efanTemplate)
		
		model.usingType(EfanRenderer#)
		model.extendMixin(EfanRenderer#)
		model.addField(Type?#, "_af_ctxType")
		model.overrideField(EfanRenderer#ctxType, "_af_ctxType", Str.defVal)	// TODO: throw Err
		model.overrideMethod(EfanRenderer#_af_render, renderCode)
		
		try {
			type	= plasticCompiler.compileModel(model)

		} catch (PlasticCompilationErr err) {
			efanLineNo	:= findEfanLineNo(err.srcErrLoc) ?: throw err
			efanErrLoc	:= SrcErrLocation(srcLocation, efanTemplate, efanLineNo, err.msg)
			throw EfanCompilationErr(efanErrLoc, srcCodePadding, err)
		}

		bob	:= CtorPlanBuilder(type)
		bob["_af_ctxType"] = ctxType
		return bob.makeObj
	}

	** Called by afbedSheetEfan - ensures all given ViewHelper types are valid. 
	@NoDoc
	static Type[] validateViewHelpers(Type[] viewHelpers) {
		viewHelpers.each { 
			if (!it.isMixin)
				throw EfanErr(ErrMsgs.viewHelperMixinIsNotMixin(it))
			if (!it.isConst)
				throw EfanErr(ErrMsgs.viewHelperMixinIsNotConst(it))
			if (!it.isPublic)
				throw EfanErr(ErrMsgs.viewHelperMixinIsNotPublic(it))
		}
		return viewHelpers
	}
	
	internal Str parseIntoCode(Uri srcLocation, Str efan) {
		data := EfanModel(efan.size)
		parser.parse(srcLocation, data, efan)
		code := data.toFantomCode
		
		return code
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
