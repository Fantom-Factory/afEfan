using compiler::CompilerErr

** Compiles efan templates into Fantom code; maybe used outside of [afIoc]`http://repo.status302.com/doc/afIoc/#overview`.
const class EfanCompiler {
	
	** The name given to the 'ctx' variable in the render method. 
	public const  Str					ctxVarName			:= "ctx"
	
	** When generating code snippets to report compilation Errs, this is the number of lines of src 
	** code the erroneous line should be padded with.  
	public const  Int 					srcCodePadding		:= 5 
	
	private const Str 					rendererClassName	:= "EfanRenderer"  
	private const PlasticPodCompiler	podCompiler			:= PlasticPodCompiler() 
	private const EfanParser 			parser				:= EfanParser() 
	
	** Create an 'EfanCompiler'.
	new make(|This|? in := null) {
		in?.call(this)

		// create new services for non-afIoc projects
		if (podCompiler == null)
			podCompiler = PlasticPodCompiler()
		if (parser == null)
			parser = EfanParser()
	}

	** Compiles a new renderer from the given efanTemplate.
	** This method compiles a new Fantom Type so use judiciously to avoid memory leaks.
	** 'srcLocation' is only used for Err msgs.
	EfanRenderer compile(Uri srcLocation, Str efanTemplate, Type? ctxType, Type[] viewHelpers := Type#.emptyList) {
		model	:= PlasticClassModel(rendererClassName, false)
		viewHelpers.each { model.extendMixin(it) }

		model.usingType(EfanRenderer#)
		model.usingType(EfanBodyRenderer#)
		
		model.addField(|EfanBodyRenderer t|?#, 	"_bodyFunc")
		model.addField(EfanBodyRenderer?#, 		"_bodyObj")
		model.addField(StrBuf#, 				"_afCode")
		
		model.addMethod(EfanBodyRenderer#, "renderEfan", "EfanRenderer renderer, Obj? ctx", "EfanBodyRenderer(renderer, ctx, _afCode)")
		model.addMethod(Void#, "renderBody", Str.defVal, "_bodyFunc?.call(_bodyObj)")
		
		type		:= (Type?) null
		renderCode	:= parseIntoCode(srcLocation, efanTemplate)
		renderSig	:= (ctxType == null) ? "" : "${ctxType.qname} ${ctxVarName}"
		model.addMethod(Str#, "render", renderSig, renderCode)
		
		try {
			type	= compileCode(model.toFantomCode, rendererClassName)

		} catch (PlasticCompilationErr err) {
			efanLineNo	:= findEfanLineNo(err.srcErrLoc) ?: throw err
			efanErrLoc	:= SrcErrLocation(srcLocation, efanTemplate, efanLineNo, err.msg)
			throw EfanCompilationErr(efanErrLoc, srcCodePadding, err)
		}

		return EfanRenderer(type, ctxType, efanTemplate.size)		
	}

	** Called by afbedSheetEfan - ensures all given ViewHelper types are valid. 
	@NoDoc
	static Type[] validateViewHelpers(Type[] viewHelpers) {
		viewHelpers.each { 
			if (!it.isMixin)
				throw EfanErr(ErrMsgs.viewHelperMixinIsNotMixin(it))
			if (it.isConst)
				throw EfanErr(ErrMsgs.viewHelperMixinIsConst(it))
			if (!it.isPublic)
				throw EfanErr(ErrMsgs.viewHelperMixinIsNotPublic(it))
		}
		return viewHelpers
	}
	
	internal Str parseIntoCode(Uri srcLocation, Str efan) {
		data := EfanModel(efan.size, "_afCode.add")
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
