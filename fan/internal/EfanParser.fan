using afPlastic::PlasticCompiler
using afPlastic::SrcCodeSnippet

internal const class EfanParser {

	private const PlasticCompiler	plasticCompiler
	
	// don't contribute these, as currently, there are a lot of assumptions around <%# starting with <%
	private static const Str tokenFanCodeStart	:= "<%"
	private static const Str tokenCommentStart	:= "<%#"
	private static const Str tokenEvalStart		:= "<%="
	private static const Str tokenEnd			:= "%>"
	
	** We pass the PlasticCompiler in so we always get the latest srcCodePadding
	new make(PlasticCompiler plasticCompiler) {
		this.plasticCompiler = plasticCompiler
	}
	
	Void parse(Uri srcLocation, Pusher pusher, Str efanCode) {
		efanIn	:= efanCode.toBuf
		
		buf		:= StrBuf(100)	// 100 being an average line length; it's better than 16 anyhow!
		data	:= ParserData() { it.buf = buf; it.pusher = pusher; it.efanCode = efanCode; it.srcLocation = srcLocation; it.srcCodePadding = plasticCompiler.srcCodePadding }
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

			newLine := (char == '\n')
			
			// normalise new lines in blocks (leave template text as is)
			if (char == '\r') {
				newLine = true
				if (data.inBlock) {
					if (peekEq(efanIn, "\n")) { }
					char = '\n'
				} else {
					if (peekEq(efanIn, "\n")) { 
						buf.addChar(char)
						char = '\n'
					}					
				}
			}

			buf.addChar(char)

			if (newLine) {
				if (!data.inBlock)
					data.push
				data.newLine
			}
		}
		
		if (data.inBlock) {
			errMsg	:= ErrMsgs.parserBlockNotClosed(data.blockType)
			srcCode	:= SrcCodeSnippet(srcLocation, efanCode)
			throw EfanParserErr(srcCode, efanCode.splitLines.size, errMsg, plasticCompiler.srcCodePadding)
		}

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
	Str			efanCode
	Uri 		srcLocation
	BlockType	blockType		:= BlockType.text
	Int			lineNo			:= 1
	Int			lineNoToSend	:= 1	// needed 'cos of multilines
	Int 		srcCodePadding	:= 5

	new make(|This|in) { in(this) }
	
	Void enteringFanCode() {
		if (inBlock) {
			errMsg	:= ErrMsgs.parserBlockInBlockNotAllowed(blockType, BlockType.fanCode)
			srcCode	:= SrcCodeSnippet(srcLocation, efanCode)
			throw EfanParserErr(srcCode, lineNo, errMsg, srcCodePadding)
		}
		blockType = BlockType.fanCode
	}
	Void enteringEval() {
		if (inBlock) {
			errMsg	:= ErrMsgs.parserBlockInBlockNotAllowed(blockType, BlockType.eval)
			srcCode	:= SrcCodeSnippet(srcLocation, efanCode)
			throw EfanParserErr(srcCode, lineNo, errMsg, srcCodePadding)
		}
		blockType = BlockType.eval
	}
	Void enteringComment() {
		if (inBlock) {
			errMsg	:= ErrMsgs.parserBlockInBlockNotAllowed(blockType, BlockType.comment)
			srcCode	:= SrcCodeSnippet(srcLocation, efanCode)
			throw EfanParserErr(srcCode, lineNo, errMsg, srcCodePadding)
		}
		blockType = BlockType.comment
	}
	Void exitingBlock() {
		pusher.onExit(lineNoToSend)
		lineNoToSend = lineNo
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
			pusher.onComment(lineNoToSend, buf.toStr)
		if (blockType == BlockType.fanCode)
			pusher.onFanCode(lineNoToSend, buf.toStr)
		if (blockType == BlockType.eval)
			pusher.onEval(lineNoToSend, buf.toStr)
		lineNoToSend = lineNo
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
	abstract Void onExit(Int lineNo)
}
