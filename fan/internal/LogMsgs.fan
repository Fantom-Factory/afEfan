
internal class LogMsgs {
	
	static Str templatesCtxDoesNotFitRendererCts(Type ctx, Type rendererCtx, File file) {
		"Ctx type ${ctx.qname} does not fit existing renderer ctx ${rendererCtx.qname} - Recompiling ${file.normalize.osPath}"
	}

}
