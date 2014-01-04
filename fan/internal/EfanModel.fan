using afPlastic::SrcCodeSnippet

internal class EfanModel : Pusher {
	
	StrBuf 	code
	Str[]	usings	:= [,]
	
	private Int				indentSize	:= 1
	private SrcCodeSnippet	snippet
	private Int				linesOfPadding
	
	new make(SrcCodeSnippet snippet, Int linesOfPadding, Int bufSize) {
		this.code 			= StrBuf(bufSize)
		this.snippet		= snippet
		this.linesOfPadding	= linesOfPadding
	}
	
	override Void onFanCode(Int lineNo, Str text) {
		code := text.trim
		if (code.isEmpty) return

		// this also closes eval blocks
		if (code.endsWith("}")) {
			indentSize--
			// guard against crazy code - this indenting logic ain't perfect!
			if (indentSize < 0) 
				indentSize = 0
		}

		if (code.contains("\n")) {
			appendMulti(code, lineNo)
		} else {
			indent.append(code).appendLineNo(lineNo).endLine
		}

		if (code.endsWith("{"))
			indentSize++
	}

	override Void onEval(Int lineNo, Str code) {
		eval := code.trim
		if (eval.isEmpty) return
		
		if (eval.contains("\n")) {
			indent.append("_af_code = ")	// no need to end this line
			appendMulti(eval, lineNo)
		} else {
			indent.append("_af_code = ${eval}").appendLineNo(lineNo).endLine
		}
		
		if (eval.endsWith("{"))
			indentSize++		
	}

	override Void onComment(Int lineNo, Str text) {
		comment := text.trim
		if (comment.isEmpty) return

		// add the '#' so it can not be confused with "// (efan) --> XXX"
		if (comment.contains("\n")) {
			appendMulti(comment, lineNo) { "// # " + it }
		} else {
			indent.append("// # ${comment}").appendLineNo(lineNo).endLine
		}
	}

	override Void onInstruction(Int lineNo, Str code) {
		instruction := code.trim
		if (instruction.isEmpty) return

		if (instruction.lower.startsWith("using ")) {
			usings.add(instruction["using ".size..-1] + "\t// (efan) --> ${lineNo}")
		} else {
			throw EfanParserErr(snippet, lineNo, ErrMsgs.unknownInstruction(instruction), linesOfPadding)
		}
	}
	
	override Void onText(Int lineNo, Str text) {
		if (text.isEmpty) return
		indent.append("_af_code = ${text.toCode}").appendLineNo(lineNo).endLine
	}

	override Void onExit(Int lineNo, BlockType blockType) { }

	Str toFantomCode() {
		return code.toStr
	}

	// ---- Private Methods ----
	
	private This indent() {
		append("".padl(indentSize, '\t'))
	}
	
	private This appendLineNo(Int lineNo) {
		append("\t// (efan) --> ${lineNo}")
		return this
	}

	private This append(Str txt) {
		code.add(txt)
		return this
	}

	private This endLine() {
		code.addChar('\n')
		return this
	}

	private This appendMulti(Str code, Int lineNo, |Str, Int -> Str|? c := null) {
		indentSize++
		lineNo--
		code.split('\n').each |line| {
			lineNo++
			if (line.isEmpty) return
			str := c?.call(line, lineNo) ?: line
			indent.append(str).appendLineNo(lineNo).endLine
		}
		indentSize--
		return this
	}
}