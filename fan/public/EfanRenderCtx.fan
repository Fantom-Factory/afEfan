using concurrent::Actor
using afPlastic::SrcCodeSnippet

//@NoDoc
//class EfanRenderStack {
//
//	static Void renderWithBuf(EfanRenderer rendering, |EfanRenderer|? bodyFunc, |->| renderFunc) {
//		
//		renderCtx := EfanRenderCtx(rendering, StrBuf(), bodyFunc)
//
//		try {
//			CallStack.call("efan.renderCtx", renderCtx, renderFunc)
//			
//		} catch (Err err) {
//			regex 	:= Regex.fromStr("^\\s*?${rendering.typeof.qname}\\._af_render\\s\\(${rendering.typeof.pod.name}:([0-9]+)\\)\$")
//			codeLineNo := err.traceToStr.splitLines.eachWhile |line -> Int?| {
//				reggy 	:= regex.matcher(line)
//				return reggy.find ? reggy.group(1).toInt : null
//			} ?: throw err
//
//			rendering.efanMetaData.throwRuntimeErr(err, codeLineNo)
//		}
//	}
//	
//	static EfanRenderCtx renderCtx() {
//		CallStack.stackable("efan.renderCtx")
//	}
//}


@NoDoc
class EfanRenderCtx {
	StrBuf 			renderBuf
	|->Str|? 		bodyFunc

	private new make(StrBuf renderBuf, |->Str|? bodyFunc) {
		this.renderBuf 	= renderBuf
		this.bodyFunc 	= bodyFunc
	}
	
	static Str renderEfan(|->Str|? bodyFunc, |->| renderFunc) {
		renderCtx := EfanRenderCtx(StrBuf(), bodyFunc)
		CallStack.call("efan.renderCtx", renderCtx, renderFunc)
		return renderCtx.renderBuf.toStr
	}

	static Str renderBody() {
		renderCtx := EfanRenderCtx(StrBuf(), null)
		if (renderCtx.bodyFunc != null)
			CallStack.call("efan.renderCtx", renderCtx, renderCtx.bodyFunc)
		return renderCtx.renderBuf.toStr
	}
	
	static EfanRenderCtx renderCtx() {
		CallStack.stackable("efan.renderCtx")
	}
}
