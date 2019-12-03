using afPlastic::SrcCodeSnippet

internal class EfanModel : Pusher {
	
	StrBuf 	code
	Str[]	usings	:= [,]
	
	private Int				indentSize	:= 1
	private SrcCodeSnippet	snippet
	private Int				linesOfPadding
	private Str				bufFieldName

	new make(SrcCodeSnippet snippet, Int linesOfPadding, Str bufFieldName) {
		this.code 			= StrBuf(snippet.srcCode.size)
		this.snippet		= snippet
		this.linesOfPadding	= linesOfPadding
		this.bufFieldName	= bufFieldName
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
			indent.append(bufFieldName).append(" = ")	// no need to end this line
			appendMulti(eval, lineNo)
		} else {
			indent.append(bufFieldName).append(" = ").append(eval).appendLineNo(lineNo).endLine
		}
		
		if (eval.endsWith("{"))
			indentSize++		
	}

	override Void onComment(Int lineNo, Str text) {
		comment := text.trim
		if (comment.isEmpty) return

		// add the '#' so it can not be confused with "// (efan) --> XXX"
		if (comment.contains("\n")) {
			appendMulti(comment, lineNo, "// # ")
		} else {
			indent.append("// # ").append(comment).appendLineNo(lineNo).endLine
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
		indent.append(bufFieldName).append(" = ").append(text.toCode).appendLineNo(lineNo).endLine
	}

	override Void onExit(Int lineNo, BlockType blockType) { }

	Str toFantomCode() {
		return code.toStr
	}

	// ---- Private Methods ----
	
	private This indent() {
		for (i := 0; i < indentSize; ++i) {
			code.addChar('\t')
		}
		return this
	}
	
	private This appendLineNo(Int lineNo) {
		append("\t// (efan) --> ").append(lineNo.toStr)
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

	private This appendMulti(Str code, Int lineNo, Str linePrefix := "") {
		indentSize++
		lineNo--
		lines := code.split('\n')
		for (i := 0; i < lines.size; ++i) {
			line := lines[i]
			lineNo++
			if (line.size > 0) {
				indent.append(linePrefix).append(line).appendLineNo(lineNo).endLine
			}
		}
		indentSize--
		return this
	}
}