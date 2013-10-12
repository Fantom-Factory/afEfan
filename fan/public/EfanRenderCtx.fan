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
	StrBuf 		renderBuf
	|->|? 		bodyFunc

	private new make(StrBuf renderBuf, |->|? bodyFunc) {
		this.renderBuf 	= renderBuf
		this.bodyFunc 	= bodyFunc
	}

	static Str renderEfan(|->|? bodyFunc, |->| renderFunc) {
		codeBuf := StrBuf()
		CallStack.pushAndRun("efan.renderCtx", EfanRenderCtx(codeBuf, bodyFunc), renderFunc)
		return codeBuf.toStr
	}

	static Str renderBody() {
		bodyFunc := peek.bodyFunc
		codeBuf := StrBuf()
		if (bodyFunc != null)
			CallStack.pushAndRun("efan.renderCtx", EfanRenderCtx(codeBuf, null), bodyFunc)
		return codeBuf.toStr
	}
	
	static EfanRenderCtx peek() {
		CallStack.peek("efan.renderCtx")
	}
}
