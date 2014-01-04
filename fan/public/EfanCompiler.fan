using afPlastic::PlasticCompilationErr
using afPlastic::PlasticClassModel
using afPlastic::PlasticCompiler
using afPlastic::SrcCodeSnippet

** Compiles efan templates into `EfanRenderer` classes. 
** Call 'render()' on the returned objects to render the efan template into a Str. 
** 
**    template := ...
**    renderer := EfanCompiler().compile(`index.efan`, template)
**    htmlStr  := renderer.render(...)
** 
const class EfanCompiler {

	private const EfanParser 		parser 
	
	** The name given to the 'ctx' variable in the render method. 
	const  Str				ctxVarName			:= "ctx"
	
	** The class name given to compiled efan renderer instances.
	const Str 				rendererClassName	:= "EfanRendererImpl"  
	
	** Expose 'PlasticCompiler' so it (and it's mutable srcCodePadding value) may be re-used by 
	** other projects, such as [afSlim]`http://repo.status302.com/doc/afSlim/#overview`.
	const PlasticCompiler	plasticCompiler

	** Create an 'EfanCompiler'.
	new make(|This|? in := null) {
		in?.call(this)
		this.plasticCompiler	= PlasticCompiler()
		this.parser				= EfanParser(plasticCompiler)
	}

	** For use by afIoc.
	new makeWithServices(PlasticCompiler plasticCompiler, |This|? in := null) {
		in?.call(this)
		this.plasticCompiler	= plasticCompiler
		this.parser				= EfanParser(plasticCompiler)
	}

	** Standard compilation usage; compiles and instantiates a new renderer from the given efanTemplate. 
	** The compiled renderer extends the given view helper mixins.
	** 
	** This method compiles a new Fantom Type so use judiciously to avoid memory leaks.
	** 'srcLocation' is only used for reporting Err msgs.
	EfanRenderer compile(Uri srcLocation, Str efanTemplate, Type? ctxType := null, Type[] viewHelpers := Type#.emptyList) {
		model	:= PlasticClassModel(rendererClassName, true)
		model.extendMixin(EfanRenderer#)
		viewHelpers.each { model.extendMixin(it) }
		return (EfanRenderer) compileWithModel(srcLocation, efanTemplate, ctxType, model)
	}

	** Advanced compiler usage; compiles and instantiates a new renderer from the given  
	** [Plastic]`http://repo.status302.com/doc/afPlastic/#overview` model.
	** 
	** The (optional) 'makeFunc' is used to create an 'EfanRenderer' instance from the supplied Type
	** and meta data. 
	** 
	** This method compiles a new Fantom Type so use judiciously to avoid memory leaks.
	** 'srcLocation' is only used for reporting Err msgs.
	Obj compileWithModel(Uri srcLocation, Str efanTemplate, Type? ctxType, PlasticClassModel model, |Type, EfanMetaData->BaseEfanImpl|? makeFunc := null) {
		if (!model.isConst)
			throw EfanErr(ErrMsgs.rendererModelMustBeConst(model))
 
		efanModel	:= parseIntoModel(srcLocation, efanTemplate)

		// check the ctx type here so it also works from renderEfan()  
		renderType	:= (Type?) null
		ctxTypeSig	:= (ctxType == null) ? "Obj?" : ctxType.signature
		renderCode	:= "ctxType := efanMetaData.ctxType\n"
		renderCode	+= "if (_ctx == null && ctxType != null && !ctxType.isNullable)\n"
		renderCode	+= "	throw afEfan::EfanErr(\"${ErrMsgs.rendererCtxIsNull} \${ctxType.typeof.signature}\")\n"
		renderCode	+= "if (_ctx != null && ctxType != null && !_ctx.typeof.fits(ctxType))\n"
		renderCode	+= "	throw afEfan::EfanErr(\"ctx \${_ctx.typeof.signature} ${ErrMsgs.rendererCtxBadFit(ctxType)}\")\n"
		renderCode	+= "${ctxTypeSig} ctx := _ctx\n"
		renderCode	+= "\n"
		renderCode	+=  efanModel.code

		// 'cos it'll be common to want to cast to it - I did! 
		// I spent half an hour tracking down why my cast didn't work! 
		model.usingType(EfanRenderer#)
		efanModel.usings.each { model.usingStr(it) }
		
		model.extendMixin(BaseEfanImpl#)
		model.addField(EfanMetaData#, "_af_efanMetaData")
		model.overrideField(BaseEfanImpl#efanMetaData, "_af_efanMetaData", """throw Err("efanMetaData is read only.")""")
		model.overrideMethod(BaseEfanImpl#_af_render, renderCode)
//		model.addMethod(StrBuf#, "_af_code", "", "afEfan::EfanRenderCtx.peek.renderBuf") 

		model.addField(Log#, "_af_log").withInitValue("afEfan::EfanRenderer#.pod.log")
		
		// we need the special syntax of "_af_code = XXXX" so we don't have to close any brackets with eval expressions
		model.addField(Obj?#, "_af_code", """throw Err("_af_code is write only.")""", 
			"""if (_af_log.isDebug)
			   	_af_log.debug("[_af_code] \${afEfan::EfanCtxStack.peek.nestedId} -> \${it?.toStr?.toCode}")
			   afEfan::EfanRenderCtx.peek.renderBuf.add(it)""")
		
		podName	:= plasticCompiler.generatePodName
		efanMetaData	:= EfanMetaData {
			it.srcLocation 	= srcLocation
			it.ctxName		= ctxVarName
			it.ctxType		= ctxType
			it.efanTemplate	= efanTemplate
			it.efanSrcCode	= model.toFantomCode
			it.srcCodePadding= plasticCompiler.srcCodePadding
			// FQCN is pretty yucky, but for unique ids we don't have much to go on!
			// Thankfully only efanExtra needs it, and it provides its own impl.
			it.templateId	= "${podName}::${model.className}"
		}

		try {
			renderType	= plasticCompiler.compileModel(model, podName)
		} catch (PlasticCompilationErr err) {
			efanMetaData.throwCompilationErr(err, err.errLineNo)
		}

		efan	:= (makeFunc != null)
				?  makeFunc(renderType, efanMetaData)
				:  CtorPlanBuilder(renderType).set("_af_efanMetaData", efanMetaData).makeObj

		return efan
	}

	** Called by afBedSheetEfan - ensures all given ViewHelper types are valid. 
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
	
	private EfanModel parseIntoModel(Uri srcLocation, Str efan) {
		data := EfanModel(SrcCodeSnippet(srcLocation, efan), plasticCompiler.srcCodePadding, efan.size)
		parser.parse(srcLocation, data, efan)
		return data
	}

	** used in testing
	internal Str parseIntoCode(Uri srcLocation, Str efan) {
		parseIntoModel(srcLocation, efan).toFantomCode
	}
}
