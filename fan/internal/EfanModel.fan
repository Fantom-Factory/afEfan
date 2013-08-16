
internal class EfanModel : Pusher {
	StrBuf 	code
	Int		indentSize	:= 2
	
	new make(Int bufSize) {
		code = StrBuf(bufSize)
		code.add("_afCode := StrBuf(${bufSize})\n")
	}
	
	override Void onFanCode(Str text) {
		code := text.trim
		if (code.startsWith("}")) {
			indentSize--
			// guard against crazy code - this indenting logic ain't perfect!
			if (indentSize < 0) 
				indentSize = 0
		}
		
		if (code.isEmpty) return
		if (code.contains("\n"))
			addMultiline(code)
		else
			indent.add(code)
		
		if (code.endsWith("{"))
			indentSize++
	}
	
	override Void onComment(Str text) {
		comment := text.trim
		if (comment.isEmpty) return
		comment.split('\n').each |line| {
			if (line.isEmpty) return
			indent.add("""// ${line}""")
		}
	}

	override Void onEval(Str text) {
		code := text.trim
		if (code.isEmpty) return
		if (code.contains("\n")) {
			indent.add("_afCode.add(")
			addMultiline(code)
			indent.add(")")
		} else
			indent.add("""_afCode.add( ${code} )""")
	}

	override Void onText(Str text) {
		if (text.isEmpty) return
		if (text.contains("\n")) {
			first := true
			text.split('\n', false).each |line| {
				if (first) {
					indent
					code.add("_afCode.add(\"\"\"").add(escapeTripleQuotes(line)).addChar('\n')
					first = false
				} else
					indent(15).add(escapeTripleQuotes(line))
			}
			code.remove(-1).add("\"\"\")\n")
		} else {
			escaped := text.replace("\"", "\\\"")
			indent.add("""_afCode.add("${escaped}")""")
		}
	}

	Str toFantomCode() {
		indent.add("return _afCode.toStr")
		return code.toStr
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
		indentSize.times |i| { code.addChar('\t') }
		spaces.times { code.addChar(' ') }
		return this
	}

	private This indentStr(Int spaces := 0) {
		indentSize.times |i| { code.addChar('\t') }
		spaces.times { code.addChar(' ') }
		return this
	}
	
	private Str escapeTripleQuotes(Str text) {
		if (!text.contains("\"\"\""))
			return text
		// I know this is ugly - but, heck, it's what you get for putting triple quotes in your templates!
		in := "\"\"\" + Str<|\"\"\"|> +\n"
		indentSize.times { in = in + "\t" }
		12.times { in = in + " " }
		in += "\"\"\""
		return text.replace("\"\"\"", in)
	}
}