using afPlastic::PlasticCompiler
using afPlastic::SrcCodeSnippet

** Parses efan template strings into Fantom code.
const class EfanParser {

	** When generating code snippets for parsing Errs, this is the number of src code lines 
	** the erroneous line will be padded with. 
	const Int		srcCodePadding		:= 5

	** Controls whether 'code' only lines are trimmed to remove (usually) unwanted line breaks.  
	const Bool		removeWhitespace	:= true
	
	** Name of the field that the generated template will be added to.
	const Str		fieldName			:= "_efan_output"
	
	// don't contribute these, as currently, there are a lot of assumptions around <%# starting with <%
	private static const Str tokenEscapeStart		:= "<%%"
	private static const Str tokenEscapeEnd			:= "%%>"
	private static const Str tokenFanCodeStart		:= "<%"
	private static const Str tokenCommentStart		:= "<%#"
	private static const Str tokenEvalStart			:= "<%="
	private static const Str tokenInstructionStart	:= "<%?"
	private static const Str tokenEnd				:= "%>"
	
	** Standard it-block ctor. Use to set field values:
	** 
	**   syntax: fantom
	**   parser := EfanParser {
	**       it.srcCodePadding   = 5
	**       it.removeWhitespace = true
	**       it.fieldName       = "_efan_output"
	**   }
	new make(|This|? f := null) { f?.call(this)	}

	** Parses the given 'efan' template to Fantom code.
	ParseResult parse(Uri srcLocation, Str efanTemplate) {
		srcSnippet	:= SrcCodeSnippet(srcLocation, efanTemplate)
		efanModel	:= EfanModel(srcSnippet, srcCodePadding, fieldName)
		doParse(srcLocation, efanModel, efanTemplate)
		return ParseResult {
			it.fantomCode 	= efanModel.toFantomCode
			it.usings	  	= efanModel.usings
			it.fieldName	= this.fieldName
		}
	}
	
	internal Void doParse(Uri srcLocation, Pusher pusher, Str efanCode) {
		efanIn	:= efanCode.in
		data	:= ParserData(pusher, efanCode, removeWhitespace)
		while (efanIn.peekChar != null) {
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
			throw EfanParserErr(srcCode, efanCode.splitLines.size, errMsg, srcCodePadding)
		}

		data.push
		data.flush
	}

	** If tag is next, consume it and return true
	private Bool peekEq(InStream in, Str tag) {
		p1 := in.readChar
		if (p1 == null) {
			return false
		}
		if (p1 != tag[0]) {
			in.unreadChar(p1)
			return false
		}
		if (tag.size == 1)
			return true

		p2 := in.readChar
		if (p2 == null) {
			in.unreadChar(p1)
			return false
		}
		if (p2 != tag[1]) {
			in.unreadChar(p2)
			in.unreadChar(p1)
			return false
		}
		if (tag.size == 2)
			return true
		
		p3 := in.readChar
		if (p3 == null) {
			in.unreadChar(p2)
			in.unreadChar(p1)
			return false
		}
		if (p3 != tag[2]) {
			in.unreadChar(p3)
			in.unreadChar(p2)
			in.unreadChar(p1)
			return false
		}
		if (tag.size == 3)
			return true
		
		throw UnsupportedErr("efan tags must be < 3 chars: $tag")

		// use the above hardcoded logic for speed
//		if (buf.avail < tag.size)
//			return false
//
//		peek := buf.readChars(tag.size)
//		if (peek == tag) {
//			return true
//		} else {
//			// BugFix: buf.seek doesn't take into account char encoding
//			peek.eachr { buf.unreadChar(it) }
//			return false
//		}
	}
}

** Contains Fantom code; the result of parsing efan templates.
const class ParseResult {
	
	** Fantom src code.
	const Str 	fantomCode
	
	** List of 'using' statements.
	const Str[]	usings
	
	** Name of the 'StrBuf' variable / field that the generated template will be added to.
	const Str fieldName
	
	internal new make(|This| in) { in(this) }
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
		push := null as Push
		switch (blockType) {
			case BlockType.text			: push = Push(lineNo,		Pusher#onText)
			case BlockType.comment		: push = Push(lineNoToSend, Pusher#onComment)
			case BlockType.fanCode		: push = Push(lineNoToSend, Pusher#onFanCode)
			case BlockType.instruction	: push = Push(lineNoToSend, Pusher#onInstruction)
			case BlockType.eval			: push = Push(lineNoToSend, Pusher#onEval)
			default						: throw Err("Unknown BlockType: $blockType")
		}
		push.blockType	= blockType
		push.line		= buf.toStr
		pushes.add(push)
		
		lineNoToSend = lineNo
		buf.clear
	}
	Void flush() {

		// do dat intelligent whitespace removal - only clear lines WITH non-text blocks!
		if (removeWs) {
			allEmptyOrClear := true
			anyCanClear	 	:= false
			i				:= 0
			while (i < pushes.size && allEmptyOrClear == true) {
				push := pushes[i++]
				if (!push.isEmpty && !push.canClear)
					allEmptyOrClear = false
				if (push.canClear)
					anyCanClear	= true
			}
			if (allEmptyOrClear && anyCanClear)
				pushes = pushes.exclude(Push#isEmpty.func)
		}
		// the un-optimised code for above
//		if (removeWs && pushes.all { it.isEmpty || it.canClear } && pushes.any { it.canClear })
//			pushes = pushes.exclude { it.isEmpty }
		
		for (i := 0; i < pushes.size; ++i) {
			pushes[i].push(pusher)
		}
		pushes.clear
	}
}

internal class Push {
	static const BlockType[]	clearables := [BlockType.comment, BlockType.fanCode, BlockType.instruction]
	Method		method
	Int			lineNo
	BlockType?	blockType
	Str?		line
	new make(Int lineNo, Method method) {
		this.lineNo	= lineNo
		this.method	= method
	}
	Bool isEmpty() {
		blockType == BlockType.text && line.all(Int#isSpace.func)
	}
	Bool canClear() {
		 clearables.contains(blockType)
	}
	Void push(Pusher pusher) {
		method.call(pusher, lineNo, line)
	}
}

internal enum class BlockType {
	text, comment, fanCode, eval, instruction; 
}

internal mixin Pusher {
	abstract Void onFanCode		(Int lineNo, Str fanCode)
	abstract Void onComment		(Int lineNo, Str comment)
	abstract Void onText		(Int lineNo, Str text)
	abstract Void onEval		(Int lineNo, Str fanCode)
	abstract Void onInstruction	(Int lineNo, Str instruction)
	abstract Void onExit		(Int lineNo, BlockType blockType)
}
