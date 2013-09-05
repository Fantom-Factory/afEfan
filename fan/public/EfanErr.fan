using afPlastic::SrcErrLocation

** As thrown by Efan.
const class EfanErr : Err {
	new make(Str msg := "", Err? cause := null) : super(msg, cause) {}
}

@NoDoc
const class EfanParserErr : EfanErr {
	const SrcErrLocation srcErrLoc
	const Int noOfLinesOfPadding

	internal new make(SrcErrLocation srcErrLoc, Int noOfLinesOfPadding := 5) : super(srcErrLoc.errMsg) {
		this.srcErrLoc = srcErrLoc
		this.noOfLinesOfPadding = noOfLinesOfPadding
	}

	override Str toStr() {
		buf := StrBuf()
		buf.add("${typeof.qname}: ${msg}")
		buf.add("\nEfan Parser Err:\n")

		buf.add(srcErrLoc.srcCodeSnippet(noOfLinesOfPadding))

		buf.add("\nStack Trace:")
		return buf.toStr
	}
}

@NoDoc
const class EfanCompilationErr : EfanErr {
	const SrcErrLocation srcErrLoc
	const Int noOfLinesOfPadding

	internal new make(SrcErrLocation srcErrLoc, Int noOfLinesOfPadding := 5, Err? cause := null) : super(srcErrLoc.errMsg, cause) {
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

