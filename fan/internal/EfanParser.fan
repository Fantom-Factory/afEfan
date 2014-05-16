using afPlastic::PlasticCompiler
using afPlastic::SrcCodeSnippet

internal const class EfanParser {

	private const PlasticCompiler	plasticCompiler
	private const Bool				removeWhitespace
	
	// don't contribute these, as currently, there are a lot of assumptions around <%# starting with <%
	private static const Str tokenEscapeStart		:= "<%%"
	private static const Str tokenEscapeEnd			:= "%%>"
	private static const Str tokenFanCodeStart		:= "<%"
	private static const Str tokenCommentStart		:= "<%#"
	private static const Str tokenEvalStart			:= "<%="
	private static const Str tokenInstructionStart	:= "<%?"
	private static const Str tokenEnd				:= "%>"
	
	** We pass the PlasticCompiler in so we always get the latest srcCodePadding
	new make(PlasticCompiler plasticCompiler, Bool removeWhitespace) {
		this.plasticCompiler 	= plasticCompiler
		this.removeWhitespace	= removeWhitespace
	}

	Void parse(Uri srcLocation, Pusher pusher, Str efanCode) {
		efanIn	:= efanCode.toBuf
		data	:= ParserData(pusher, efanCode, removeWhitespace)
		while (efanIn.more) {
			// escape chars can be in both text and blocks
			if (peekEq(efanIn, tokenEscapeStart)) {
				data.addChar('<').addChar('%')
				continue
			}

			if (peekEq(efanIn, tokenEscapeEnd)) {
				data.addChar('%').addChar('>')
				continue
			}

			if (data.inText && peekEq(efanIn, tokenCommentStart)) {
				data.push
				data.enteringComment
				continue
			}

			if (data.inText && peekEq(efanIn, tokenEvalStart)) {
				data.push
				data.enteringEval
				continue
			}

			if (data.inText && peekEq(efanIn, tokenInstructionStart)) {
				data.push
				data.enteringInstruction
				continue
			}

			if (data.inText && peekEq(efanIn, tokenFanCodeStart)) {
				data.push
				data.enteringFanCode
				continue
			}

			if (data.inBlock && peekEq(efanIn, tokenEnd)) {
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
						data.addChar(char)
						char = '\n'
					}					
				}
			}

			data.addChar(char)

			if (newLine) {
				if (!data.inBlock) {
					data.push
					data.flush
				}
				data.newLine
			}
		}
		
		if (data.inBlock) {
			errMsg	:= ErrMsgs.parserBlockNotClosed(data.blockType)
			srcCode	:= SrcCodeSnippet(srcLocation, efanCode)
			throw EfanParserErr(srcCode, efanCode.splitLines.size, errMsg, plasticCompiler.srcCodePadding)
		}

		data.push
		data.flush
	}

	** If tag is next, consume it and return true
	Bool peekEq(Buf buf, Str tag) {
		if (buf.remaining < tag.size)
			return false

		peek := buf.readChars(tag.size)
		if (peek == tag) {
			return true
		} else {
			// BugFix: buf.seek doesn't take into account char encoding
			peek.eachr { buf.unreadChar(it) }
			return false
		}
	}
}

internal class ParserData {
	private Pusher 		pusher
	private StrBuf		buf
			BlockType	blockType		:= BlockType.text
	private Int			lineNo			:= 1
	private Int			lineNoToSend	:= 1	// needed 'cos of multilines
	private	Push[]		pushes			:= [,]
	private Bool		removeWs

	new make(Pusher pusher, Str efanCode, Bool removeWhitespace) {
		this.pusher 	= pusher
		this.buf 		= StrBuf(efanCode.size)
		this.removeWs	= removeWhitespace
	}
	
	This addChar(Int char) {
		buf.addChar(char)
		return this
	}
	
	Void enteringFanCode() {
		blockType = BlockType.fanCode
	}
	Void enteringEval() {
		blockType = BlockType.eval
	}
	Void enteringComment() {
		blockType = BlockType.comment
	}
	Void enteringInstruction() {
		blockType = BlockType.instruction
	}
	Void exitingBlock() {
		pusher.onExit(lineNoToSend, blockType)
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
		flush
		lineNo++
	}
	Void push() {
		switch (blockType) {
			case BlockType.text:
			    pushes.add(Push() { it.method = Pusher#onText; 		it.lineNo = this.lineNo })
			case BlockType.comment:
			    pushes.add(Push() { it.method = Pusher#onComment; 	it.lineNo = this.lineNoToSend })
			case BlockType.fanCode:
			    pushes.add(Push() { it.method = Pusher#onFanCode; 	it.lineNo = this.lineNoToSend })
			case BlockType.instruction:
			    pushes.add(Push() { it.method = Pusher#onInstruction;it.lineNo = this.lineNoToSend })
			case BlockType.eval:
			    pushes.add(Push() { it.method = Pusher#onEval; 		it.lineNo = this.lineNoToSend })
		}
		pushes.peek.blockType = blockType
		pushes.peek.line = buf.toStr
		
		lineNoToSend = lineNo
		buf.clear
	}
	Void flush() {
		// do dat intelligent whitespace removal - only clear lines WITH non-text blocks!
		if (removeWs && pushes.all { it.isEmpty || it.canClear } && pushes.any { it.canClear })
			pushes = pushes.exclude { it.isEmpty }
		pushes.each { it.push(pusher) }
		pushes.clear
	}
}

internal class Push {
	static const BlockType[]	clearables := [BlockType.comment, BlockType.fanCode, BlockType.instruction]
	Method		method
	Int			lineNo
	BlockType?	blockType
	Str?		line
	new make(|This|in) { in(this) }
	Bool isEmpty() {
		blockType == BlockType.text && line.trim.isEmpty
	}
	Bool canClear() {
		 clearables.contains(blockType)
	}
	Void push(Pusher pusher) {
		method.callOn(pusher, [lineNo, line])
	}
}

internal enum class BlockType {
	text, comment, fanCode, eval, instruction; 
}

internal mixin Pusher {
	abstract Void onFanCode(Int lineNo, Str fanCode)
	abstract Void onComment(Int lineNo, Str comment)
	abstract Void onText(Int lineNo, Str text)
	abstract Void onEval(Int lineNo, Str fanCode)
	abstract Void onInstruction(Int lineNo, Str instruction)
	abstract Void onExit(Int lineNo, BlockType blockType)
}
