using afPlastic::PlasticCompilationErr
using afPlastic::PlasticClassModel
using afPlastic::PlasticCompiler

** Compiles efan templates into `EfanRenderer`s. 
** Call 'render()' to render the efan template into a Str. 
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

	** Standard compilation usage; compiles a new renderer from the given efanTemplate. 
	** 
	** This method compiles a new Fantom Type so use judiciously to avoid memory leaks.
	** 'srcLocation' is only used for reporting Err msgs.
	EfanRenderer compile(Uri srcLocation, Str efanTemplate, Type? ctxType := null) {
		model	:= PlasticClassModel(rendererClassName, true)
		return compileWithModel(srcLocation, efanTemplate, ctxType, model)
	}

	** Intermediate compilation usage; the compiled renderer extends the given view helper mixins.
	** 
	** This method compiles a new Fantom Type so use judiciously to avoid memory leaks.
	** 'srcLocation' is only used for reporting Err msgs.
	EfanRenderer compileWithHelpers(Uri srcLocation, Str efanTemplate, Type? ctxType := null, Type[] viewHelpers := Type#.emptyList) {
		model	:= PlasticClassModel(rendererClassName, true)
		viewHelpers.each { model.extendMixin(it) }
		return compileWithModel(srcLocation, efanTemplate, ctxType, model)
	}

	** Advanced compiler usage; the efan render methods are added to the given afPlastic model.
	** 
	** The (optional) 'makeFunc' is used to create an 'EfanRenderer' instance from the supplied Type
	** and meta data. 
	** 
	** This method compiles a new Fantom Type so use judiciously to avoid memory leaks.
	** 'srcLocation' is only used for reporting Err msgs.
	EfanRenderer compileWithModel(Uri srcLocation, Str efanTemplate, Type? ctxType, PlasticClassModel model, |Type, EfanMetaData->EfanRenderer|? makeFunc := null) {
		if (!model.isConst)
			throw EfanErr(ErrMsgs.rendererModelMustBeConst(model))
 
		renderType	:= (Type?) null
		ctxTypeSig	:= (ctxType == null) ? "Obj?" : ctxType.signature
		renderCode	:= "${ctxTypeSig} ctx := _ctx\n"
		renderCode	+= "\n"
		renderCode	+= "return afEfan::EfanRenderCtx.renderEfan(_bodyFunc) |->| {\n"
		renderCode	+=    parseIntoCode(srcLocation, efanTemplate)
		renderCode	+= "}"

		model.extendMixin(EfanRenderer#)
		model.addField(EfanMetaData#, "_af_efanMetaData")
		model.overrideField(EfanRenderer#efanMetaData, "_af_efanMetaData", """throw Err("efanMetaData is read only.")""")
		model.overrideMethod(EfanRenderer#_af_render, renderCode)
		// we need the special syntax of "_af_eval = XXXX" so we don't have to close any brackets
		model.addField(Obj?#, "_af_eval", """throw Err("_af_eval is write only.")""", "_af_code.add(it)")
	
		efanMetaData	:= EfanMetaData {
			it.srcLocation 	= srcLocation
			it.ctxName		= ctxVarName
			it.ctxType		= ctxType
			it.efanTemplate	= efanTemplate
			it.efanSrcCode	= model.toFantomCode
			it.srcCodePadding= plasticCompiler.srcCodePadding
		}
		
		try {
			renderType	= plasticCompiler.compileModel(model)
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
	
	internal Str parseIntoCode(Uri srcLocation, Str efan) {
		data := EfanModel(efan.size)
		parser.parse(srcLocation, data, efan)
		return data.toFantomCode
	}
}
