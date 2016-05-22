
internal class TestEfanBasics : EfanTest {
	
	Void testOneLineText() {
		text := efan.render("Hello!", null)
		verifyEq(text, "Hello!")
	}

	Void testOneLineEmptyBlock() {
		text := efan.render("Hel<%  %>lo!", null)
		verifyEq(text, "Hello!")
	}

	Void testOneLineCommentBlock() {
		text := efan.render("Hel<%# wotever %>lo!", null)
		verifyEq(text, "Hello!")
	}

	Void testOneLineEvalBlock() {
		text := efan.render("Hel<%= \" BIGBOY \" %>lo!", null)
		verifyEq(text, "Hel BIGBOY lo!")
	}

	Void testEfanCanNotEndMidBlock() {
		verifyEfanErrMsg(ErrMsgs.parserBlockNotClosed(BlockType.fanCode)) {
			text := efan.render("Hel<% lo!", null)
		}
		verifyEfanErrMsg(ErrMsgs.parserBlockNotClosed(BlockType.eval)) {
			text := efan.render("Hel<%= lo!", null)
		}
		verifyEfanErrMsg(ErrMsgs.parserBlockNotClosed(BlockType.comment)) {
			text := efan.render("Hel<%# lo!", null)
		}		
	}

	Void testCommentWithTrippleQuotes() {
		text := efan.render("Hel<%# \"\"\" %>lo!", null)
		verifyEq(text, "Hello!")
	}

	Void testTextWithQuotes() {
		text := efan.render("Hel\"lo!", null)
		verifyEq(text, "Hel\"lo!")
	}

	Void testTextWithTrippleQuotes() {
		text := efan.render("Hel\"\"\"lo!", null)
		verifyEq(text, "Hel\"\"\"lo!")
	}

	Void testEvalWithQuotes() {
		text := efan.render("""Hel<%= " \\\" " %>lo!""", null)
		verifyEq(text, "Hel \" lo!")
	}

	Void testEvalWithTrippleQuotes() {
		text := efan.render("Hel<%= \" \\\"\\\"\\\" \" %>lo!", null)
		verifyEq(text, "Hel \"\"\" lo!")
	}
}
