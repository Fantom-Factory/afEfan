
internal const class EfanParser {

	// don't contribute these, as currently, there are a lot of assumptions around <%# starting with <%
	private static const Str tokenFanCodeStart	:= "<%"
	private static const Str tokenCommentStart	:= "<%#"
	private static const Str tokenEvalStart		:= "<%="
	private static const Str tokenEnd			:= "%>"
	
	new make(|This|? in := null) { in?.call(this) }
	
	Void parse(Pusher pusher, Str efan) {
		efanIn	:= efan.toBuf
		
		buf		:= StrBuf(100)	// 100 being an average line length
		data	:= ParserData() { it.buf = buf; it.pusher = pusher }
		line	:= 1
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
			
			// normalise new lines in blocks (leave template text as is) 
			if (data.inBlock && char == '\r') {
				char = '\n'
				// consume \r\n
				if (peekEq(efanIn, "\n")) { }
			}

			buf.addChar(char)
			
			newLine := (char == '\n')
			if (char == '\r') {
				newLine = true
				// consume \r\n
				if (peekEq(efanIn, "\n")) { 
					buf.addChar('\n')
				}
			}
			
			if (newLine)
				data.newLine
		}
		
		if (data.inBlock)
			throw EfanParserErr(ErrMsgs.parserBlockNotClosed(data.blockType))

		data.push
	}

	** If tag is next, consume it and return true
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
	Int			lineNo		:= 1

	new make(|This|in) { in(this) }
	
	Void enteringFanCode() {
		if (inBlock)
			throw EfanParserErr(ErrMsgs.parserBlockInBlockNotAllowed(blockType, BlockType.fanCode))
		blockType = BlockType.fanCode
	}
	Void enteringEval() {
		if (inBlock)
			throw EfanParserErr(ErrMsgs.parserBlockInBlockNotAllowed(blockType, BlockType.eval))
		blockType = BlockType.eval
	}
	Void enteringComment() {
		if (inBlock)
			throw EfanParserErr(ErrMsgs.parserBlockInBlockNotAllowed(blockType, BlockType.comment))
		blockType = BlockType.comment
	}
	Void exitingBlock() {
		blockType = BlockType.text
	}
	Bool inBlock() {
		blockType != BlockType.text
	}
	Bool inText() {
		blockType == BlockType.text
	}
	Void newLine() {
		lineNo++
	}
	Void push() {
		if (blockType == BlockType.text)
			pusher.onText(lineNo, buf.toStr)
		if (blockType == BlockType.comment)
			pusher.onComment(lineNo, buf.toStr)
		if (blockType == BlockType.fanCode)
			pusher.onFanCode(lineNo, buf.toStr)
		if (blockType == BlockType.eval)
			pusher.onEval(lineNo, buf.toStr)
		buf.clear
	}
}

internal enum class BlockType {
	text, comment, fanCode, eval; 
}

internal mixin Pusher {
	abstract Void onFanCode(Int lineNo, Str fanCode)
	abstract Void onComment(Int lineNo, Str comment)
	abstract Void onText(Int lineNo, Str text)
	abstract Void onEval(Int lineNo, Str text)
}
