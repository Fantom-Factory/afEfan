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
@NoDoc	// still public 'cos afBedSheetEfan references validateViewHelpers()
const class EfanCompiler {
	** Vroom vroom!!!
	const EfanEngine engine
	
	** The name given to the 'ctx' variable in the render method. 
	const Str	ctxVarName			:= "ctx"

	** The class name given to compiled efan renderer instances.
	const Str 	rendererClassName	:= "EfanRendererImpl"  

	** Create an 'EfanCompiler'.
	new make(|This|? in := null) {
		in?.call(this)
		this.engine = EfanEngine(PlasticCompiler())
	}
	
	** For use by afBedSheetEfan.
	new makeWithServices(PlasticCompiler plasticCompiler, |This|? in := null) {
		in?.call(this)
		this.engine = EfanEngine(plasticCompiler)
	}

	** Standard compilation usage; compiles and instantiates a new 'EfanRenderer' from the given efan template. 
	** The compiled renderer extends the given view helper mixins.
	** 
	** This method compiles a new Fantom Type so use judiciously to avoid memory leaks.
	** 'templateLoc' is only used for reporting Err msgs.
	EfanRenderer compile(Uri templateLoc, Str template, Type? ctxType := null, Type[] viewHelpers := Type#.emptyList) {
		
		model := engine.parseTemplateIntoModel(templateLoc, template, PlasticClassModel(rendererClassName, true))

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

		efanMetaData := engine.compileModel(templateLoc, template, model)
		myEfanMeta	 := efanMetaData.clone([
			EfanMetaData#ctxName : ctxVarName,
			EfanMetaData#ctxType : ctxType
		])
		
		return CtorPlanBuilder(efanMetaData.type).set("_efan_metaData", myEfanMeta).makeObj
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
