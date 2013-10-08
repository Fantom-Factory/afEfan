using concurrent::Actor
using afPlastic::SrcCodeSnippet

@NoDoc
class EfanRenderCtx {

	static const Str localsName	:= "efan.renderCtx"

	EfanRender efanRender {
		get { efanRenders.peek }
		private set { }
	}
	
	private EfanRender[] efanRenders := [,]
	
	Void renderWithBuf(EfanRenderer rendering, StrBuf renderBuf, |EfanRenderer|? bodyFunc, EfanRenderer? bodyObj, |->| renderFunc) {
		Actor.locals[localsName] = this
		
		render := EfanRender(rendering, renderBuf, bodyFunc, bodyObj)
		efanRenders.push(render)
		
		try {
			// FIXME: catch Runtime exceptions and report srcErr
			renderFunc()
		} catch (Err err) {
	
			regex 	:= Regex.fromStr("^\\s*?${rendering.typeof.qname}\\._af_render\\s\\(${rendering.typeof.pod.name}:([0-9]+)\\)\$")
			Env.cur.err.printLine(regex)
			codeLineNo := err.traceToStr.splitLines.eachWhile |line -> Int?| {
				reggy 	:= regex.matcher(line)
				Env.cur.err.printLine(line)
				return reggy.find ? reggy.group(1).toInt : null
			} ?: throw err
			
			efanLineNo	:= findEfanLineNo(rendering.efanMetaData.efanSrcCode.splitLines, codeLineNo) ?: throw err
			
			srcCode	:= SrcCodeSnippet(rendering.efanMetaData.srcLocation, rendering.efanMetaData.efanTemplate)
			throw EfanRuntimeErr(srcCode, efanLineNo, err.msg, 5, err)			
			
		} finally {
			efanRenders.pop
			if (efanRenders.isEmpty) {
				Actor.locals.remove(localsName)
			}			
		}
	}
	
	static EfanRenderCtx? ctx(Bool checked := true) {
		((EfanRenderCtx?) Actor.locals[localsName]) ?: (checked ? throw Err("EfanRenderCtx does not exist") : null) 
	}	

	static EfanRender? render() {
		ctx.efanRender
	}
	
	
	// TODO: moce it!
	private Int? findEfanLineNo(Str[] fanCodeLines, Int errLineNo) {
		fanLineNo		:= errLineNo - 1	// from 1 to 0 based
		reggy 			:= Regex<|\s+?// \(efan\) --> ([0-9]+)$|>
		efanLineNo		:= (Int?) null
		
		while (fanLineNo > 0 && efanLineNo == null) {
			code := fanCodeLines[fanLineNo]
			reg := reggy.matcher(code)
			if (reg.find) {
				efanLineNo = reg.group(1).toInt
			} else {
				fanLineNo--
			}
		}
		
		return efanLineNo
	}	
}


@NoDoc
class EfanRender {
			StrBuf 			renderBuf
	private EfanRenderer	rendering
	private |EfanRenderer|? bodyFunc
	private EfanRenderer? 	bodyObj

	new make(EfanRenderer rendering, StrBuf renderBuf, |EfanRenderer|? bodyFunc, EfanRenderer? bodyObj) {
		this.rendering 	= rendering
		this.renderBuf 	= renderBuf
		this.bodyFunc 	= bodyFunc
		this.bodyObj 	= bodyObj
	}
	
	Void efan(EfanRenderer renderer, Obj? rendererCtx, |EfanRenderer obj|? bodyFunc) {
		renderer._af_render(renderBuf, rendererCtx, bodyFunc, rendering)
	}

	Void body() {
		bodyFunc?.call(bodyObj)
	}
}
