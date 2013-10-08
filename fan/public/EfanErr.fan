using afPlastic::SrcCodeErr
using afPlastic::SrcCodeSnippet

** As thrown by Efan.
const class EfanErr : Err {
	new make(Str msg := "", Err? cause := null) : super(msg, cause) {}
}

** Thrown when the efan template can not be parsed.
const class EfanParserErr : EfanErr, SrcCodeErr {
	const override SrcCodeSnippet 	srcCode
	const override Int 				errLineNo
	private const  Int 				linesOfPadding

	internal new make(SrcCodeSnippet srcCode, Int errLineNo, Str errMsg, Int linesOfPadding) : super(errMsg) {
		this.srcCode = srcCode
		this.errLineNo = errLineNo
		this.linesOfPadding = linesOfPadding
	}
	
	override Str toStr() {
		print(msg, linesOfPadding)
	}
}

** Thrown when the generated efan code can not be compiled.
const class EfanCompilationErr : EfanErr, SrcCodeErr {
	const override SrcCodeSnippet 	srcCode
	const override Int 				errLineNo
	private const  Int 				linesOfPadding

	internal new make(SrcCodeSnippet srcCode, Int errLineNo, Str errMsg, Int linesOfPadding, Err cause) : super(errMsg, cause) {
		this.srcCode = srcCode
		this.errLineNo = errLineNo
		this.linesOfPadding = linesOfPadding
	}
	
	override Str toStr() {
		print(msg, linesOfPadding)
	}
}

** Wraps any Errs thrown when rendering from an `EfanRenderer` instance. 
const class EfanRuntimeErr : EfanErr, SrcCodeErr {
	const override SrcCodeSnippet 	srcCode
	const override Int 				errLineNo
	private const  Int 				linesOfPadding

	internal new make(SrcCodeSnippet srcCode, Int errLineNo, Str errMsg, Int linesOfPadding, Err cause) : super(errMsg, cause) {
		this.srcCode = srcCode
		this.errLineNo = errLineNo
		this.linesOfPadding = linesOfPadding
	}
	
	override Str toStr() {
		print(msg, linesOfPadding)
	}
}


