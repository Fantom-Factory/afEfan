using afIoc::Inject
using afIoc::ConcurrentCache

** Renders Embedded Fantom (efan) templates against a given context.
const mixin EfanTemplates {

	** Renders the given template with the ctx.
	** 
	** WARN: Overuse of this method could cause a memory leak! A new Fantom Type is created on 
	** every call. 
	abstract Str renderFromStr(Str efan, Obj? ctx)
	
	** Renders an '.efan' template file with the given ctx. 
	** The compiled '.efan' template is cached for re-use.   
	abstract Str renderFromFile(File efanFile, Obj? ctx)
	
}

internal const class EfanTemplatesImpl : EfanTemplates {
	private const static Log log := Utils.getLog(EfanTemplates#)
	private const FileCache fileCache
	
	@Inject	private const EfanCompiler 		compiler
	@Inject	private const EfanViewHelpers 	viewHelpers

	internal new make(|This|in) {
		in(this) 
		fileCache = FileCache(10sec)	// TODO: make config
	}

	override Str renderFromStr(Str efan, Obj? ctx) {
		renderer	:= compiler.compile(`rendered/from/str`, efan, ctx?.typeof, viewHelpers.mixins)
		return renderer->render(ctx)
	}

	override Str renderFromFile(File efanFile, Obj? ctx) {
		if (!efanFile.exists)
			throw IOErr(ErrMsgs.templatesFileNotFound(efanFile))

		renderer := fileCache.getOrAddOrUpdate(efanFile) |->Obj| {
			template 	:= efanFile.readAllStr
			renderer	:= compiler.compile(efanFile.normalize.uri, template, ctx?.typeof, viewHelpers.mixins)
			return renderer			
		}

		if (ctx != null) {
			ctxType := renderer->ctxType
			if (ctxType == null || !ctx.typeof.fits(ctxType)) {
				log.warn(LogMsgs.templatesCtxDoesNotFitRendererCts(ctx.typeof, renderer->ctxType, efanFile))
				template 	:= efanFile.readAllStr
				renderer	= compiler.compile(efanFile.normalize.uri, template, ctx?.typeof, viewHelpers.mixins)
				fileCache[efanFile] = renderer
			}
		}
		
		return renderer->render(ctx)
	}
}
