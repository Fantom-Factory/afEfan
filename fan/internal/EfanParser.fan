
internal const class EfanParser {

	private static const Str tokenFanCodeStart	:= "<%"
	private static const Str tokenCommentStart	:= "<%#"
	private static const Str tokenEqualStart	:= "<%="
	private static const Str tokenEnd			:= "%>"
	
	new make(|This|in) { in(this) }
	
	// TODO: test that <% <% is illegal
	
	Void parse(Pusher pusher, Str efan) {
		efanIn	:= efan.toBuf
		
		buf			:= StrBuf(100)
		data		:= ParserData() { it.buf = buf; it.pusher = pusher }
		
		while (efanIn.more) {
			
			if (peekEq(efanIn, tokenCommentStart)) {
				data.push
				data.enteringComment
				continue
			}

			if (peekEq(efanIn, tokenEnd)) {
				data.push
				data.exitingBlock
				continue
			}

			char := efanIn.readChar
			buf.addChar(char)
		}
		
		if (data.inText) {
			data.push
		} else {
			throw Err()
		}
	}
	
	Bool peekEq(Buf buf, Str tag) {
		if (buf.remaining < tag.size)
			return false

		peek := buf.readChars(tag.size)
		
		if (peek == tag) {
			return true
		} else {
			buf.seek(buf.pos - tag.size)
			return false
		}
	}	
}

internal class ParserData {
	Pusher 	pusher
	StrBuf	buf
	
	private Bool inComment

	new make(|This|in) { in(this) }
	
	Void enteringComment() {
		// TODO: Err if already in block
		inComment = true
	}
	Void exitingBlock() {
		// TODO: Err if in text
		inComment = false
	}
	Bool inBlock() {
		inComment
	}
	Bool inText() {
		!inBlock
	}
	Void push() {
		if (inComment)
			pusher.onComment(buf.toStr)
		buf.clear
	}
}

internal mixin Pusher {
	abstract Void onCode(Str code)
	abstract Void onComment(Str comment)
	abstract Void onText(Str text)
	abstract Void onEval(Str text)
}
