using afPlastic::SrcCodeSnippet

** Provides meta data for an efan template.
** 
** @see `EfanRenderer.efanMetaData`
const class EfanMetaData {

	** The 'ctx' type the renderer was compiled against.
	const Type? ctxType

	** The name of the 'ctx' variable the renderer was compiled with.
	const Str ctxName

	** Where the efan template originated from. Example, 'file://layout.efan'. 
	const Uri srcLocation

	** The efan template source code.
	const Str efanTemplate

	** The generated efan fantom code (for the inquisitive).
	const Str efanSrcCode

	internal const Int srcCodePadding

	internal new make(|This|in) { in(this) }

	internal Void throwCompilationErr(Err cause, Int srcCodeLineNo) {
		templateLineNo	:= findTemplateLineNo(srcCodeLineNo) ?: throw cause
		srcCode			:= SrcCodeSnippet(srcLocation, efanTemplate)
		throw EfanCompilationErr(srcCode, templateLineNo, cause.msg, srcCodePadding, cause)
	}
	
	internal Void throwRuntimeErr(Err cause, Int srcCodeLineNo) {
		templateLineNo	:= findTemplateLineNo(srcCodeLineNo) ?: throw cause
		srcCode			:= SrcCodeSnippet(srcLocation, efanTemplate)
		throw EfanRuntimeErr(srcCode, templateLineNo, cause.msg, srcCodePadding, cause)
	}
	
	private Int? findTemplateLineNo(Int srcCodeLineNo) {
		fanLineNo		:= srcCodeLineNo - 1	// from 1 to 0 based
		reggy 			:= Regex<|\s+?// \(efan\) --> ([0-9]+)$|>
		efanLineNo		:= (Int?) null
		fanCodeLines	:= efanSrcCode.splitLines
		
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
