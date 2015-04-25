using afPlastic

** Advanced API usage only!
@NoDoc
const class EfanEngine {
	
	private const EfanParser parser 
	
	** Expose 'PlasticCompiler' so it (and it's mutable srcCodePadding value) may be re-used by 
	** other projects, such as [afSlim]`http://repo.status302.com/doc/afSlim/#overview`.
	const PlasticCompiler	plasticCompiler
	
	** Controls whether 'code' only lines are trimmed to remove (usually) unwanted line breaks.  
	const Bool intelligentWhitespaceRemoval	:= true
	
	** For use by afIoc.
	new makeWithServices(PlasticCompiler plasticCompiler, |This|? in := null) {
		in?.call(this)
		this.plasticCompiler	= plasticCompiler
		this.parser				= EfanParser(plasticCompiler, intelligentWhitespaceRemoval)
	}

	** Advanced compiler usage; parses the efan template into fantom code and adds it as a 
	** render method in the given plastic model.
	** 
	** 'templateLoc' is only used for reporting Err msgs.
	PlasticClassModel parseTemplateIntoModel(Uri srcLocation, Str templateSrc, PlasticClassModel classModel) {
		srcSnippet	:= SrcCodeSnippet(srcLocation, templateSrc)
		efanModel	:= EfanModel(srcSnippet, plasticCompiler.srcCodePadding)
		parser.parse(srcLocation, efanModel, templateSrc)
		
		// we *need* to return a plastic model because of this!
		efanModel.usings.each { classModel.usingStr(it) }
		
		classModel.addMethod(Void#, "_efan_render", Str.defVal, efanModel.toFantomCode)
		
		classModel.addField(Log#, "_efan_log").withInitValue("afEfan::EfanTemplate#.pod.log")
		
		// we need the special syntax of "_efan_output = XXXX" so we don't have to close any brackets with eval expressions
		// peek(false) to prevent dodgy / nasty errs during an IoC autobuild when a provider thinks it can provide Obj
		// like what efanXtra did on upgrading to IoC 2.0.0!
		classModel.addField(Obj?#, "_efan_output", """throw Err("_efan_output is write only.")""", 
			"""if (_efan_log.isDebug)
			   	_efan_log.debug("[_efan_output] \${afEfan::EfanRenderingStack.peek(false)?.nestedId} -> \${it?.toStr?.toCode}")
			   afEfan::EfanRenderer.peek(false)?.renderBuf?.add(it)""")
		
		return classModel
	}

	** Advanced compiler usage; Compiles the plastic model into a Fantom type, re-throwing any 
	** compilation Errs with added efan information. All efan compilation info (including the type 
	** and the template src) is available in the returned 'EfanMetaData' object.
	**  
	** 'templateLoc' is only used for reporting Err msgs.
	EfanTemplateMeta compileModel(Uri templateLoc, Str templateSrc, PlasticClassModel classModel) {

		efanMetaData := |Type efanType->EfanTemplateMeta| { EfanTemplateMeta {
			it.type 		= efanType
			it.typeSrc		= classModel.toFantomCode
			it.templateLoc	= templateLoc
			it.templateSrc	= templateSrc
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
		efanModel	:= EfanModel(srcSnippet, plasticCompiler.srcCodePadding)
		parser.parse(srcLocation, efanModel, efanTemplate)
		return efanModel.toFantomCode
	}
}
