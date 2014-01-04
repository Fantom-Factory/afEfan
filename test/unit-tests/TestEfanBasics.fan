
internal class TestEfanBasics : EfanTest {
	
	Void testOneLineText() {
		text := efan.renderFromStr("Hello!", null)
		verifyEq(text, "Hello!")
	}

	Void testOneLineEmptyBlock() {
		text := efan.renderFromStr("Hel<%  %>lo!", null)
		verifyEq(text, "Hello!")
	}

	Void testOneLineCommentBlock() {
		text := efan.renderFromStr("Hel<%# wotever %>lo!", null)
		verifyEq(text, "Hello!")
	}

	Void testOneLineEvalBlock() {
		text := efan.renderFromStr("Hel<%= \" BIGBOY \" %>lo!", null)
		verifyEq(text, "Hel BIGBOY lo!")
	}

	Void testEfanCanNotEndMidBlock() {
		verifyEfanErrMsg(ErrMsgs.parserBlockNotClosed(BlockType.fanCode)) {
			text := efan.renderFromStr("Hel<% lo!", null)
		}
		verifyEfanErrMsg(ErrMsgs.parserBlockNotClosed(BlockType.eval)) {
			text := efan.renderFromStr("Hel<%= lo!", null)
		}
		verifyEfanErrMsg(ErrMsgs.parserBlockNotClosed(BlockType.comment)) {
			text := efan.renderFromStr("Hel<%# lo!", null)
		}		
	}

	Void testCommentWithTrippleQuotes() {
		text := efan.renderFromStr("Hel<%# \"\"\" %>lo!", null)
		verifyEq(text, "Hello!")
	}

	Void testTextWithQuotes() {
		text := efan.renderFromStr("Hel\"lo!", null)
		verifyEq(text, "Hel\"lo!")
	}

	Void testTextWithTrippleQuotes() {
		text := efan.renderFromStr("Hel\"\"\"lo!", null)
		verifyEq(text, "Hel\"\"\"lo!")
	}

	Void testEvalWithQuotes() {
		text := efan.renderFromStr("""Hel<%= " \\\" " %>lo!""", null)
		verifyEq(text, "Hel \" lo!")
	}

	Void testEvalWithTrippleQuotes() {
		text := efan.renderFromStr("Hel<%= \" \\\"\\\"\\\" \" %>lo!", null)
		verifyEq(text, "Hel \"\"\" lo!")
	}
}
