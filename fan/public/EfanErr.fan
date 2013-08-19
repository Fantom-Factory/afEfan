using afIoc::SrcErrLocation

** As thrown by Efan.
const class EfanErr : Err {
	new make(Str msg := "", Err? cause := null) : super(msg, cause) {}
}

// FIXME: add SrcErrLocation
internal const class EfanParserErr : EfanErr {
	new make(Str msg := "", Err? cause := null) : super(msg, cause) {}
}

internal const class EfanCompilationErr : EfanErr {
	internal const SrcErrLocation srcErrLoc
	internal const Int noOfLinesOfPadding

	internal new make(SrcErrLocation srcErrLoc, Int noOfLinesOfPadding := 5) : super(srcErrLoc.errMsg) {
		this.srcErrLoc = srcErrLoc
		this.noOfLinesOfPadding = noOfLinesOfPadding
	}

	override Str toStr() {
		buf := StrBuf()
		buf.add("${typeof.qname}: ${msg}")
		buf.add("\nEfan Compilation Err:\n")

		buf.add(srcErrLoc.srcCodeSnippet(noOfLinesOfPadding))

		buf.add("\nStack Trace:")
		return buf.toStr
	}
}

