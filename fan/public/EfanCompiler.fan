using afPlastic::PlasticCompilationErr
using afPlastic::PlasticClassModel
using afPlastic::PlasticCompiler
using afPlastic::SrcCodeSnippet

** Compiles an efan template into a method on a Fantom type.
** 
** [Plastic]`pod:afPlastic` is used to generate and compile the Fantom source.
const class EfanCompiler {
	private const PlasticCompiler	plasticCompiler
	private const EfanParser 		efanParser 
	
	** The name of created render methods.
	const Str	renderMethodName	:= "_efan_render"

	** The name given to the 'ctx' variable in the render method.
	const Str	ctxName				:= "ctx"

	** Generates the type name given to compiled efan template instances.
	const |Type[]->Str| templateTypeNameFn	:= |Type[] viewHelpers->Str| { (viewHelpers.first?.name ?: "") + "EfanTemplate" }
	
	** Callbacks are called for each compiled model.
	const |Type, PlasticClassModel|[]	compilerCallbacks

	
	** Standard it-block ctor for setting fields.
	new make(|This|? in := null) {
		this.plasticCompiler 	= PlasticCompiler { it.podBaseName = "afEfanTemplate" }
		this.efanParser 	 	= EfanParser()
		this.compilerCallbacks	= Obj#.emptyList
		in?.call(this)
	}
	
	private new ctorForIoc(|Type, PlasticClassModel|[] compilerCallbacks, EfanParser efanParser, PlasticCompiler plasticCompiler, |This| in) {
		this.compilerCallbacks	= compilerCallbacks
		this.efanParser		 	= efanParser
		this.plasticCompiler 	= plasticCompiler
		in(this)
	}

	** Compiles and instantiates a new 'EfanMeta' instance from the given efan template. 
	** The compiled template extends the given view helper mixins.
	** 
	** This method compiles a new Fantom Type so use judiciously to avoid memory leaks.
	** 
	** Note that 'templateLoc' is only used for reporting Err msgs.
	EfanMeta compile(Uri templateLoc, Str templateSrc, Type? ctxType := null, Type[] viewHelpers := Type#.emptyList) {
		try {
			viewHelpers.each {
				if (!it.isPublic)
					throw EfanErr("View Helper mixin ${it.qname} must be public")
			}
		
			// the important efan parsing
			parseResult	:= efanParser.parse(templateLoc, templateSrc)


			isConst	:= viewHelpers.first?.isConst ?: true	// const by default
			model := PlasticClassModel(templateTypeNameFn(viewHelpers), isConst)
			
			
			parseResult.usings.each { model.usingStr(it) }
			model.usingType(EfanMeta#)

			
			viewHelpers.each { model.extend(it) }
			viewHelpers.first?.methods?.findAll { it.isCtor }?.each {
				model.overrideCtor(it, "")
			}
			

			// we need the special syntax of "_efan_output = XXXX" so we don't have to close any brackets with eval expressions
			fieldName := efanParser.fieldName
			model.addMethod(StrBuf#, "${fieldName}Ref", "", """concurrent::Actor.locals[${fieldName.toCode}]""")
			model.addField(Obj?#,		fieldName, """${fieldName}Ref.toStr""", """${fieldName}Ref.add(it)""")

			
			// give callbacks a chance to add to our model - added for efanXtra and Pillow
			compilerCallbacks.each { it.call(viewHelpers.first ?: Obj#, model) }

			beforeRender := model.methods.find { it.name == "efan_beforeRender" }
			afterRender  := model.methods.find { it.name == "efan_afterRender"  }
			
			// check the ctx type here so it also works from renderEfan()  
			renderCode	:= ""
			if (ctxType != null) {
				if (!ctxType.isNullable) {
					renderCode	+= "if (_ctx == null)\n"
					renderCode	+= "	throw ${EfanErr#.qname}(\"ctx is null - but ctx type is not nullable: ${ctxType.typeof.signature}\")\n"
				}
				renderCode	+= "if (_ctx != null && !_ctx.typeof.fits(${ctxType.qname}#))\n"
				renderCode	+= "	throw ${EfanErr#.qname}(\"ctx \${_ctx.typeof.signature} does not fit ctx type " + ctxType.signature.replace("sys::", "") + "\")\n"
				renderCode	+= "${ctxType.signature} ${ctxName} := _ctx\n"
				renderCode	+= "\n"
			} else
				// some code (in my tests at least!) do want a null ctx to exist!
				renderCode	+= "Obj? ${ctxName} := _ctx\n"

			// render some render hooks
			if (beforeRender != null)
				if (beforeRender.signature.isEmpty)
					renderCode	+= beforeRender.name + "()\n"
				else
					// assume any parameters are for the ctx - not that I need this myself in any library
					renderCode	+= beforeRender.name + "(_ctx)\n"
			
			renderCode	+= parseResult.fantomCode

			// render some render hooks - this one is used by efanXtra
			if (afterRender != null)
				if (afterRender.signature.isEmpty)
					renderCode	+= afterRender.name + "()\n"
				else
					// assume any parameters are for the ctx - not that I need this myself in any library
					renderCode	+= afterRender.name + "(_ctx)\n"

			renderCode	+= "return this.${fieldName}"

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
				// there's no reason to keep this the same - but may as well for consistency
				it.strBufKey		= fieldName
			}
		} catch (Err err) {
			// allow afxEfan to convert EfanErrs to AfxErrs
			newErr := Env.cur.index("afEfan.errFn").eachWhile |qname| {
				try	return Method.findMethod(qname, false)?.call(err) as Err
				catch { /* Meh */ return null }
			} ?: err
			throw newErr
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
