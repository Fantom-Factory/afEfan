using afPlastic::PlasticCompilationErr
using afPlastic::PlasticClassModel
using afPlastic::PlasticCompiler
using afPlastic::SrcCodeSnippet

** Advanced API usage only!
** Used by afBedSheetEfan
@NoDoc
const class EfanCompiler {
	** Vroom vroom!!!
	const EfanEngine engine
	
	** The name given to the 'ctx' variable in the render method. 
	const Str	ctxVarName			:= "ctx"

	** The class name given to compiled efan template instances.
	const Str 	templateClassName	:= "EfanTemplateImpl"  
	
	** Create an 'EfanCompiler'.
	new make(EfanEngine efanEngine, |This|? in := null) {
		in?.call(this)
		this.engine = efanEngine
	}

	** Compiles and instantiates a new 'EfanTemplateMeta' from the given efan string. 
	** The compiled template extends the given view helper mixins.
	** 
	** This method compiles a new Fantom Type so use judiciously to avoid memory leaks.
	** 'templateLoc' is only used for reporting Err msgs.
	EfanTemplateMeta compile(Uri templateLoc, Str template, Type? ctxType := null, Type[] viewHelpers := Type#.emptyList) {
		validateViewHelpers(viewHelpers)

		isConst	:= viewHelpers.first?.isConst ?: true	// const by default
		model	:= engine.parseTemplateIntoModel(templateLoc, template, PlasticClassModel(templateClassName, isConst))
		viewHelpers.each { model.extend(it) }

		viewHelpers.first?.methods?.findAll { it.isCtor }?.each {
			model.overrideCtor(it, "")
		}
		
		// remove the existing render() method so we can re-add it with moar src code...
		renderMethod := model.methods.find { it.name == "_efan_render" }
		model.methods.remove(renderMethod)

		// 'cos it'll be common to want to cast to it - I did! 
		// I spent half an hour tracking down why my cast didn't work! 
		model.usingType(EfanTemplateMeta#)

		// check the ctx type here so it also works from renderEfan()  
		ctxTypeSig	:= (ctxType == null) ? "Obj?" : ctxType.signature
		renderCode	:= ""
		if (ctxType != null && !ctxType.isNullable) {
			renderCode	+= "if (_ctx == null)\n"
			renderCode	+= "	throw afEfan::EfanErr(\"${ErrMsgs.compiler_ctxIsNull} ${ctxType.typeof.signature}\")\n"
		}
		if (ctxType != null) {
			renderCode	+= "if (_ctx != null && !_ctx.typeof.fits(${ctxType.qname}#))\n"
			renderCode	+= "	throw afEfan::EfanErr(\"ctx \${_ctx.typeof.signature} ${ErrMsgs.compiler_ctxNoFit(ctxType)}\")\n"
		}		
		renderCode	+= "${ctxTypeSig} ctx := _ctx\n"
		renderCode	+= "\n"
		renderCode	+=  renderMethod.body

		model.addMethod(Str#, "renderBody", "", 
		"renderBuf := StrBuf(${template.size})
		 afEfan::EfanRenderer.renderBody(renderBuf)
		 return renderBuf.toStr")
		
		model.addMethod(Void#, "_efan_render", "Obj? _ctx", renderCode)

		efanMetaData := engine.compileModel(templateLoc, template, model)
		myEfanMeta	 := efanMetaData.clone([
			EfanTemplateMeta#ctxName : ctxVarName,
			EfanTemplateMeta#ctxType : ctxType
		])
		
		return myEfanMeta
	}
	
	** Called by afBedSheetEfan - ensures all given ViewHelper types are valid. 
	static Type[] validateViewHelpers(Type[] viewHelpers) {
		viewHelpers.each {
			if (!it.isPublic)
				throw EfanErr(ErrMsgs.viewHelperMixinIsNotPublic(it))
		}
		return viewHelpers
	}
}
