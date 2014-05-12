using afPlastic::PlasticCompilationErr
using afPlastic::PlasticClassModel
using afPlastic::PlasticCompiler
using afPlastic::SrcCodeSnippet

** Compiles efan templates into `EfanRenderer` classes. 
** Call 'render()' on the returned objects to render the efan template into a Str. 
** 
**    template := ...
**    renderer := EfanCompiler().compile(`index.html.efan`, template)
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

	** Standard compilation usage; compiles and instantiates a new 'EfanRenderer' from the given efan template. 
	** The compiled renderer extends the given view helper mixins.
	** 
	** This method compiles a new Fantom Type so use judiciously to avoid memory leaks.
	** 'templateLoc' is only used for reporting Err msgs.
	EfanRenderer compile(Uri templateLoc, Str template, Type? ctxType := null, Type[] viewHelpers := Type#.emptyList) {
		
		model := parseTemplateIntoModel(templateLoc, template, PlasticClassModel(rendererClassName, true))

		model.extend(EfanRenderer#)
		viewHelpers.each { model.extend(it) }
		
		// 'cos it'll be common to want to cast to it - I did! 
		// I spent half an hour tracking down why my cast didn't work! 
		model.usingType(EfanRenderer#)

		renderMethod := model.methods.find { it.name == "_efan_render" }
		model.methods.remove(renderMethod)
		
		// check the ctx type here so it also works from renderEfan()  
		ctxTypeSig	:= (ctxType == null) ? "Obj?" : ctxType.signature
		renderCode	:= ""
		if (ctxType != null && !ctxType.isNullable) {
			renderCode	+= "if (_ctx == null)\n"
			renderCode	+= "	throw afEfan::EfanErr(\"${ErrMsgs.rendererCtxIsNull} ${ctxType.typeof.signature}\")\n"
		}
		if (ctxType != null) {
			renderCode	+= "if (_ctx != null && !_ctx.typeof.fits(${ctxType.qname}#))\n"
			renderCode	+= "	throw afEfan::EfanErr(\"ctx \${_ctx.typeof.signature} ${ErrMsgs.rendererCtxBadFit(ctxType)}\")\n"
		}		
		renderCode	+= "${ctxTypeSig} ctx := _ctx\n"
		renderCode	+= "\n"
		renderCode	+=  renderMethod.body
		
		model.addField(EfanMetaData#, "_efan_metaData")
		model.overrideField(EfanRenderer#efanMetaData, "_efan_metaData", """throw Err("efanMetaData is read only.")""")
		model.overrideMethod(EfanRenderer#_efan_render, renderCode)

		efanMetaData := compileModel(templateLoc, template, model)
		myEfanMeta	 := efanMetaData.clone([
			EfanMetaData#ctxName : ctxVarName,
			EfanMetaData#ctxType : ctxType
		])
		
		return CtorPlanBuilder(efanMetaData.type).set("_efan_metaData", myEfanMeta).makeObj
	}
	
	** Advanced compiler usage; parses the efan template into fantom code and adds it as a 
	** render method in the given plastic model.
	** 
	** 'templateLoc' is only used for reporting Err msgs.
	PlasticClassModel parseTemplateIntoModel(Uri srcLocation, Str efanTemplate, PlasticClassModel classModel) {
		srcSnippet	:= SrcCodeSnippet(srcLocation, efanTemplate)
		efanModel	:= EfanModel(srcSnippet, plasticCompiler.srcCodePadding, efanTemplate.size)
		parser.parse(srcLocation, efanModel, efanTemplate)
		
		// we *need* to return a plastic model because of this!
		efanModel.usings.each { classModel.usingStr(it) }
		
		classModel.addMethod(Void#, "_efan_render", Str.defVal, efanModel.toFantomCode)
		
		classModel.addField(Log#, "_efan_log").withInitValue("afEfan::EfanRenderer#.pod.log")
		
		// we need the special syntax of "_efan_output = XXXX" so we don't have to close any brackets with eval expressions
		classModel.addField(Obj?#, "_efan_output", """throw Err("_efan_output is write only.")""", 
			"""if (_efan_log.isDebug)
			   	_efan_log.debug("[_efan_output] \${afEfan::EfanCtxStack.peek.nestedId} -> \${it?.toStr?.toCode}")
			   afEfan::EfanRenderCtx.peek.renderBuf.add(it)""")
		
		return classModel
	}

	** Advanced compiler usage; Compiles the plastic model into a Fantom type, re-throwing any 
	** compilation Errs with added efan information. All efan compilation info (including the type 
	** and the template src) is available in the returned 'EfanMetaData' object.
	**  
	** 'templateLoc' is only used for reporting Err msgs.
	EfanMetaData compileModel(Uri templateLoc, Str efanTemplate, PlasticClassModel classModel) {

		efanMetaData := |Type efanType->EfanMetaData| { EfanMetaData {
			it.type 		= efanType
			it.typeSrc		= classModel.toFantomCode
			it.templateLoc	= templateLoc
			it.template		= efanTemplate
			// FQCN is pretty yucky, but for unique ids we don't have much to go on!
			// Thankfully only efanExtra needs it, and it provides its own impl.
			it.templateId	= type.qname
			it.srcCodePadding = plasticCompiler.srcCodePadding
		}}
		
		try {
			efanType := plasticCompiler.compileModel(classModel)
			return efanMetaData(efanType)
			
		} catch (PlasticCompilationErr err) {
			efanMetaData(Void#).throwCompilationErr(err, err.errLineNo)
			throw Err("WTF!?")
		}
	}

	internal Str parseIntoCode(Uri srcLocation, Str efanTemplate) {
		srcSnippet	:= SrcCodeSnippet(srcLocation, efanTemplate)
		efanModel	:= EfanModel(srcSnippet, plasticCompiler.srcCodePadding, efanTemplate.size)
		parser.parse(srcLocation, efanModel, efanTemplate)
		return efanModel.toFantomCode
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
}
