
internal class EfanModel : Pusher {
	
	Str 	addCode
	StrBuf 	code
	Int		indentSize	:= 2
	Str		evalBuf		:= ""
	
	new make(Int bufSize, Str addCode) {
		this.code 		= StrBuf(bufSize)
		this.addCode	= addCode
	}
	
	override Void onFanCode(Int lineNo, Str text) {
		code := text.trim
		if (code.isEmpty) return

		if (code.startsWith("}")) {
			indentSize--
			// guard against crazy code - this indenting logic ain't perfect!
			if (indentSize < 0) 
				indentSize = 0
		}

		addLine(lineNo)
		
		if (code.contains("\n"))
			addMultiline(code)
		else
			indent.add(code)
		
		if (code.endsWith("{"))
			indentSize++
	}
	
	override Void onComment(Int lineNo, Str text) {
		comment := text.trim
		if (comment.isEmpty) return

		addLine(lineNo)

		// add the '#' so no-one can confuse with "// --> Line XXX"
		indent.add("// # ${comment}")	
	}

	override Void onEval(Int lineNo, Str text) {
		code := text.trim
		if (code.isEmpty) return

		if (evalBuf.isEmpty) {
			addLine(lineNo)
		} else {
			evalBuf += (addLineStr(lineNo) + "\n")
		}
		evalBuf += (code + "\n")
	}
	
	override Void onExit(Int lineNo) {
		if (evalBuf.trim.isEmpty) return
		
		if (evalBuf.trim.containsChar('\n')) {
			indent.add("${addCode}(")
			addMultiline(evalBuf)
			indent.add(")")
		} else {
			indent.add("${addCode}( ${evalBuf.trim} )")
		}
		
		evalBuf = ""
	}

	override Void onText(Int lineNo, Str text) {
		if (text.isEmpty) return

		addLine(lineNo)
		indent.add("${addCode}(${text.toCode})")
	}

	Str toFantomCode() {
		indent.add("return _afCode.toStr")
		return code.toStr
	}

	private This addLine(Int lineNo) {
		add(addLineStr(lineNo))
		return this
	}
	private Str addLineStr(Int lineNo) {
		indentStr + "// --> ${lineNo}"
	}
	
	private This add(Str txt) {
		code.add(txt).addChar('\n')
		return this
	}

	private This addMultiline(Str code) {
		indentSize++
		code.split('\n').each |line| {
			if (line.isEmpty) return
			indent.add(line) 
		}
		indentSize--
		return this
	}
	
	private This indent(Int spaces := 0) {
		code.add(indentStr(spaces))
		return this
	}
	private Str indentStr(Int spaces := 0) {
		"".padl(indentSize, '\t') + "".padl(spaces, ' ')
	}
}