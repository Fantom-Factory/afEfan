using compiler::CompilerErr

** Compiles efan templates into Fantom code; maybe used outside of [afIoc]`http://repo.status302.com/doc/afIoc/#overview`.
const class EfanCompiler {
	
	** The name given to the 'ctx' variable in the render method. 
	public const  Str					ctxVarName			:= "ctx"
	public const  Int 					srcCodePadding		:= 5 
	
	private const Str 					addCode 			:= "_afCode.add"	
	private const Str 					rendererClassName	:= "EfanRenderer"  
	private const PlasticPodCompiler	podCompiler			:= PlasticPodCompiler() 
	private const EfanParser 			parser				:= EfanParser() 
	
	new make(|This|? in := null) {
		in?.call(this)
		
		// create new services for non-afIoc projects
		if (podCompiler == null)
			podCompiler = PlasticPodCompiler()
		if (parser == null)
			parser = EfanParser()
	}

	EfanRenderer compile(Uri srcLocation, Str efanCode, Type? ctxType, Type[] viewHelpers := Type#.emptyList) {
		model	:= PlasticClassModel(rendererClassName, false)
		viewHelpers.each { model.extendMixin(it) }

		model.usingType(EfanRenderer#)
		model.usingType(EfanBodyRenderer#)
		
		model.addField(Type?#, 		"ctxType")
		model.addField(|EfanBodyRenderer t|?#, 	"bodyFunc")
		model.addField(EfanBodyRenderer?#, 		"bodyObj")
		model.addField(StrBuf#, "_afCode")
		
		model.addMethod(EfanBodyRenderer#, "renderEfan", "EfanRenderer renderer, Obj? ctx", "EfanBodyRenderer(renderer, ctx, _afCode)")
		model.addMethod(Void#, "renderBody", Str.defVal, "bodyFunc?.call(bodyObj)")
		
//		model.addMethod(Void#, "_afAddCode", "Str code", "_afCode.add(code)")
		
		renderCode	:= parseIntoCode(srcLocation, efanCode)
		renderSig	:= (ctxType == null) ? "" : "${ctxType.qname} ${ctxVarName}"
		model.addMethod(Str#, "render", renderSig, renderCode)

		type		:= (Type?) null
		
		try {
			type	= compileCode(model.toFantomCode, rendererClassName)

		} catch (PlasticCompilationErr err) {
			efanLineNo	:= findEfanLineNo(err.srcErrLoc) ?: throw err
			efanErrLoc	:= SrcErrLocation(srcLocation, efanCode, efanLineNo, err.msg)
			throw EfanCompilationErr(efanErrLoc, srcCodePadding, err)
		}

		return EfanRenderer(type, ctxType, efanCode.size)		
	}

	internal Str parseIntoCode(Uri srcLocation, Str efan) {
		data := EfanModel(efan.size, addCode)
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
