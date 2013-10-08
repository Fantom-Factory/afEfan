using afPlastic::PlasticCompilationErr
using afPlastic::PlasticClassModel
using afPlastic::PlasticCompiler
using afPlastic::SrcCodeSnippet

** Compiles efan templates into `EfanRenderer`s. 
** Call 'render()' to render the efan template into a Str. 
** 
**    template := ...
**    renderer := EfanCompiler().compile(`index.efan`, template)
**    htmlStr  := renderer.render(...)
** 
const class EfanCompiler {

	** The name given to the 'ctx' variable in the render method. 
	public const  Str				ctxVarName			:= "ctx"
	
	** When generating code snippets to report compilation Errs, this is the number of lines of src 
	** code the erroneous line should be padded with.  
	public const  Int 				srcCodePadding		:= 5 

	private const Str 				rendererClassName	:= "EfanRenderer"  
	private const EfanParser 		parser 
	private const PlasticCompiler	plasticCompiler

	** Create an 'EfanCompiler'.
	new make(|This|? in := null) {
		in?.call(this)
		parser			= EfanParser() 		{ it.srcCodePadding = this.srcCodePadding }
		plasticCompiler	= PlasticCompiler() { it.srcCodePadding = this.srcCodePadding }
	}

	** Standard compilation usage; compiles a new renderer from the given efanTemplate. 
	** 
	** This method compiles a new Fantom Type so use judiciously to avoid memory leaks.
	** 'srcLocation' is only used for Err msgs.
	EfanRenderer compile(Uri srcLocation, Str efanTemplate, Type? ctxType := null) {
		model	:= PlasticClassModel(rendererClassName, true)
		return compileWithModel(srcLocation, efanTemplate, ctxType, model)
	}

	** Intermediate compilation usage; the compiled renderer extends the given view helper mixins.
	** 
	** This method compiles a new Fantom Type so use judiciously to avoid memory leaks.
	** 'srcLocation' is only used for Err msgs.
	EfanRenderer compileWithHelpers(Uri srcLocation, Str efanTemplate, Type? ctxType := null, Type[] viewHelpers := Type#.emptyList) {
		model	:= PlasticClassModel(rendererClassName, true)
		viewHelpers.each { model.extendMixin(it) }
		return compileWithModel(srcLocation, efanTemplate, ctxType, model)
	}

	** Advanced compiler usage; the efan render methods are added to the given afPlastic model.
	** 
	** This method compiles a new Fantom Type so use judiciously to avoid memory leaks.
	** 'srcLocation' is only used for Err msgs.
	EfanRenderer compileWithModel(Uri srcLocation, Str efanTemplate, Type? ctxType, PlasticClassModel model) {
		if (!model.isConst)
			throw EfanErr(ErrMsgs.rendererModelMustBeConst(model))
 
		renderType	:= (Type?) null
		ctxTypeSig	:= (ctxType == null) ? "Obj?" : ctxType.signature
		renderCode	:= "ctxType := efanMetaData.ctxType\n"
		renderCode	+= "if (_ctx == null && ctxType != null && !ctxType.isNullable)\n"
		renderCode	+= "	throw afEfan::EfanErr(\"${ErrMsgs.rendererCtxIsNull} \${ctxType.typeof.signature}\")\n"
		renderCode	+= "if (_ctx != null && ctxType != null && !_ctx.typeof.fits(ctxType))\n"
		renderCode	+= "	throw afEfan::EfanErr(\"ctx \${_ctx.typeof.signature} ${ErrMsgs.rendererCtxBadFit(ctxType)}\")\n"
		renderCode	+= "\n"
		renderCode	+= "${ctxTypeSig} ctx := _ctx\n"
		renderCode	+= "\n"
		renderCode	+= "_efanCtx := afEfan::EfanRenderCtx.ctx(false) ?: afEfan::EfanRenderCtx()\n"
		renderCode	+= "_efanCtx.renderWithBuf(this, _af_code, _bodyFunc, _bodyObj) |->| {\n"
		renderCode	+= parseIntoCode(srcLocation, efanTemplate)
		renderCode	+= "}\n"

		model.extendMixin(EfanRenderer#)
		model.addField(EfanMetaData#, "_af_efanMetaData")
		model.overrideField(EfanRenderer#efanMetaData, "_af_efanMetaData", """throw Err("efanMetaData is read only.")""")
		model.overrideMethod(EfanRenderer#_af_render, renderCode)
	
		try {
			renderType	= plasticCompiler.compileModel(model)

		} catch (PlasticCompilationErr err) {
			efanLineNo	:= findEfanLineNo(err.srcCode.srcCode, err.errLineNo) ?: throw err
			srcCode	:= SrcCodeSnippet(srcLocation, efanTemplate)
			throw EfanCompilationErr(srcCode, efanLineNo, err.msg, srcCodePadding, err)
		}

		efanMetaData	:= EfanMetaData {
			it.srcLocation 	= srcLocation
			it.ctxName		= ctxVarName
			it.ctxType		= ctxType
			it.efanTemplate	= efanTemplate
		}
		renderer		:= CtorPlanBuilder(renderType).set("_af_efanMetaData", efanMetaData).makeObj
		return renderer
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

	private Int? findEfanLineNo(Str[] fanCodeLines, Int errLineNo) {
		fanLineNo		:= errLineNo - 1	// from 1 to 0 based
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
