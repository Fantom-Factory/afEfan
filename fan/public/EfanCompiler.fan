using afPlastic::PlasticCompilationErr
using afPlastic::PlasticClassModel
using afPlastic::PlasticCompiler
using afPlastic::SrcCodeSnippet
using afConcurrent::LocalRef

** Compiles an efan template into a method on a Fantom type.
** 
** [Plastic]`pod:afPlastic` is used to generate and compile the Fantom source.
const class EfanCompiler {
	private const PlasticCompiler	plasticCompiler
	private const EfanParser 		efanParser 
	
	** The name of created render methods.
	const Str	renderMethodName	:= "_efanRender"

	** The name given to the 'ctx' variable in the render method.
	const Str	ctxName				:= "ctx"

	// FIXME extend viewhelper class name
	** The class name given to compiled efan template instances.
	const Str 	templateClassName	:= "EfanTemplate"
	
	** Standard it-block ctor for setting fields.
	new make(|This|? in := null) {
		in?.call(this)
		this.plasticCompiler = PlasticCompiler()
		this.efanParser 	 = EfanParser()
	}
	
	private new ctorForIoc(EfanParser efanParser, PlasticCompiler plasticCompiler, |This| in) {
		this.efanParser		 = efanParser
		this.plasticCompiler = plasticCompiler
		in(this)
	}

	** Compiles and instantiates a new 'EfanMeta' instance from the given efan template. 
	** The compiled template extends the given view helper mixins.
	** 
	** This method compiles a new Fantom Type so use judiciously to avoid memory leaks.
	** 
	** Note that 'templateLoc' is only used for reporting Err msgs.
	EfanMeta compile(Uri templateLoc, Str templateSrc, Type? ctxType := null, Type[] viewHelpers := Type#.emptyList) {
		viewHelpers.each {
			if (!it.isPublic)
				throw EfanErr(ErrMsgs.viewHelperMixinIsNotPublic(it))
		}
	
		// the important efan parsing
		parseResult	:= efanParser.parse(templateLoc, templateSrc)


		isConst	:= viewHelpers.first?.isConst ?: true	// const by default
		model := PlasticClassModel(templateClassName, isConst)
		
		
		parseResult.usings.each { model.usingStr(it) }
		model.usingType(EfanMeta#)

		
		viewHelpers.each { model.extend(it) }
		viewHelpers.first?.methods?.findAll { it.isCtor }?.each {
			model.overrideCtor(it, "")
		}
		

		// we need the special syntax of "_efan_output = XXXX" so we don't have to close any brackets with eval expressions
		fieldName := efanParser.fieldName
		model.addField(LocalRef#,	fieldName + "_ref").withInitValue("afConcurrent::LocalRef(\"${fieldName}\") |->Obj| { StrBuf() }")
		model.addField(Obj?#,		fieldName, """((StrBuf) ${fieldName}_ref.val).toStr""", """((StrBuf) ${fieldName}_ref.val).add(it)""")

		
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
		renderCode	+= "${ctxTypeSig} ${ctxName} := _ctx\n"
		renderCode	+= "\n"
		renderCode	+= parseResult.fantomCode
		renderCode	+= "\t\t${fieldName} := this.${fieldName}\n"
		renderCode	+= "\t\t${fieldName}_ref.cleanUp\n"
		renderCode	+= "\t\treturn ${fieldName}\n"

		model.addMethod(Str#, renderMethodName, "Obj? _ctx", renderCode)

		efanType := compileModel(model, templateSrc, templateLoc)
		
		return EfanMeta {
			it.type 			= efanType
			it.typeSrc			= model.toFantomCode
			it.templateLoc		= templateLoc
			it.templateSrc		= templateSrc
			it.srcCodePadding	= plasticCompiler.srcCodePadding
			it.ctxType			= ctxType
			it.ctxName			= this.ctxName
			it.renderMethod		= efanType.method(renderMethodName, true)
		}
	}

	** Compiles the given Plastic model, converting any compilation errors to 'EfanCompilationErrs' 
	** that shows where in the efan template the error occurred.
	@NoDoc
	Type compileModel(PlasticClassModel model, Str templateSrc, Uri templateLoc) {
		try {
			return plasticCompiler.compileModel(model)
			
		} catch (PlasticCompilationErr cause) {
			templateLineNo	:= EfanMeta.findTemplateLineNo(model.toFantomCode, cause.errLineNo) ?: throw cause
			srcCodeSnippet	:= SrcCodeSnippet(templateLoc, templateSrc)
			throw EfanCompilationErr(srcCodeSnippet, templateLineNo, cause.msg, cause.linesOfPadding, cause)
		}
	}
}

