using afIoc

internal class TestEfanBasics : EfanTest {
	
	@Inject EfanService?	efan
	
	Void testOneLineText() {
		text := efan.renderFromStr("Hello!")
		verifyEq(text, "Hello!")
	}

	Void testOneLineEmptyBlock() {
		text := efan.renderFromStr("Hel<%  %>lo!")
		verifyEq(text, "Hello!")
	}

	Void testOneLineCommentBlock() {
		text := efan.renderFromStr("Hel<%# wotever %>lo!")
		verifyEq(text, "Hello!")
	}

	Void testOneLineEvalBlock() {
		text := efan.renderFromStr("Hel<%= \" BIGBOY \" %>lo!")
		verifyEq(text, "Hel BIGBOY lo!")
	}

	Void testFanCodeInBlockNotAllowedBlock() {
		verifyEfanErrMsg(ErrMsgs.parserBlockInBlockNotAllowed(BlockType.fanCode, BlockType.fanCode)) {
			text := efan.renderFromStr("Hel<% wot<%ever%> %>lo!")
		}
		verifyEfanErrMsg(ErrMsgs.parserBlockInBlockNotAllowed(BlockType.eval, BlockType.fanCode)) {
			text := efan.renderFromStr("Hel<%= wot<%ever%> %>lo!")
		}
		verifyEfanErrMsg(ErrMsgs.parserBlockInBlockNotAllowed(BlockType.comment, BlockType.fanCode)) {
			text := efan.renderFromStr("Hel<%# wot<%ever%> %>lo!")
		}
	}

	Void testEvalInBlockNotAllowedBlock() {
		verifyEfanErrMsg(ErrMsgs.parserBlockInBlockNotAllowed(BlockType.fanCode, BlockType.eval)) {
			text := efan.renderFromStr("Hel<% wot<%=ever%> %>lo!")
		}
		verifyEfanErrMsg(ErrMsgs.parserBlockInBlockNotAllowed(BlockType.eval, BlockType.eval)) {
			text := efan.renderFromStr("Hel<%= wot<%=ever%> %>lo!")
		}
		verifyEfanErrMsg(ErrMsgs.parserBlockInBlockNotAllowed(BlockType.comment, BlockType.eval)) {
			text := efan.renderFromStr("Hel<%# wot<%=ever%> %>lo!")
		}
	}

	Void testCommentInBlockNotAllowedBlock() {
		verifyEfanErrMsg(ErrMsgs.parserBlockInBlockNotAllowed(BlockType.fanCode, BlockType.comment)) {
			text := efan.renderFromStr("Hel<% wot<%#ever%> %>lo!")
		}
		verifyEfanErrMsg(ErrMsgs.parserBlockInBlockNotAllowed(BlockType.eval, BlockType.comment)) {
			text := efan.renderFromStr("Hel<%= wot<%#ever%> %>lo!")
		}
		verifyEfanErrMsg(ErrMsgs.parserBlockInBlockNotAllowed(BlockType.comment, BlockType.comment)) {
			text := efan.renderFromStr("Hel<%# wot<%#ever%> %>lo!")
		}
	}

	Void testEfanCanNotEndMidBlock() {
		verifyEfanErrMsg(ErrMsgs.parserBlockNotClosed(BlockType.fanCode)) {
			text := efan.renderFromStr("Hel<% lo!")
		}
		verifyEfanErrMsg(ErrMsgs.parserBlockNotClosed(BlockType.eval)) {
			text := efan.renderFromStr("Hel<%= lo!")
		}
		verifyEfanErrMsg(ErrMsgs.parserBlockNotClosed(BlockType.comment)) {
			text := efan.renderFromStr("Hel<%# lo!")
		}		
	}

	Void testCommentWithTrippleQuotes() {
		text := efan.renderFromStr("Hel<%# \"\"\" %>lo!")
		verifyEq(text, "Hello!")
	}

	Void testTextWithQuotes() {
		text := efan.renderFromStr("Hel\"lo!")
		verifyEq(text, "Hel\"lo!")
	}

	Void testTextWithTrippleQuotes() {
		text := efan.renderFromStr("Hel\"\"\"lo!")
		verifyEq(text, "Hel\"\"\"lo!")
	}

	Void testEvalWithQuotes() {
		text := efan.renderFromStr("""Hel<%= " \\\" " %>lo!""")
		verifyEq(text, "Hel \" lo!")
	}

	Void testEvalWithTrippleQuotes() {
		text := efan.renderFromStr("Hel<%= \" \\\"\\\"\\\" \" %>lo!")
		verifyEq(text, "Hel \"\"\" lo!")
	}
}
