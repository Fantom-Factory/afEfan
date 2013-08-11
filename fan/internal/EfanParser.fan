
internal const class EfanParser {

	// TODO: maybe have these contributed?
	private static const Str tokenFanCodeStart	:= "<%"
	private static const Str tokenCommentStart	:= "<%#"
	private static const Str tokenEvalStart		:= "<%="
	private static const Str tokenEnd			:= "%>"
	
	new make(|This|in) { in(this) }
	
	// TODO: test that <% <% is illegal
	
	Void parse(Pusher pusher, Str efan) {
		efanIn	:= efan.toBuf
		
		buf			:= StrBuf(100)	// 100 being an average line length
		data		:= ParserData() { it.buf = buf; it.pusher = pusher }
		
		while (efanIn.more) {
			if (peekEq(efanIn, tokenCommentStart)) {
				data.push
				data.enteringComment
				continue
			}

			if (peekEq(efanIn, tokenEvalStart)) {
				data.push
				data.enteringEval
				continue
			}

			if (peekEq(efanIn, tokenFanCodeStart)) {
				data.push
				data.enteringFanCode
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
			// FIXME: text
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
	Pusher 		pusher
	StrBuf		buf
	BlockType	blockType	:= BlockType.text

	new make(|This|in) { in(this) }
	
	Void enteringComment() {
		// TODO: Err if already in block
		blockType = BlockType.comment
	}
	Void enteringEval() {
		// TODO: Err if already in block
		blockType = BlockType.eval
	}
	Void enteringFanCode() {
		// TODO: Err if already in block
		blockType = BlockType.fanCode
	}
	Void exitingBlock() {
		// TODO: Err if in text
		blockType = BlockType.text
	}
	Bool inBlock() {
		blockType != BlockType.text
	}
	Bool inText() {
		blockType == BlockType.text
	}
	Void push() {
		if (blockType == BlockType.text)
			pusher.onText(buf.toStr)
		if (blockType == BlockType.comment)
			pusher.onComment(buf.toStr)
		if (blockType == BlockType.fanCode)
			pusher.onFanCode(buf.toStr)
		if (blockType == BlockType.eval)
			pusher.onEval(buf.toStr)
		buf.clear
	}
}

internal enum class BlockType {
	text, comment, fanCode, eval; 
}

internal mixin Pusher {
	abstract Void onFanCode(Str fanCode)
	abstract Void onComment(Str comment)
	abstract Void onText(Str text)
	abstract Void onEval(Str text)
}
