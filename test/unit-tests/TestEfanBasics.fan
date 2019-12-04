
internal class TestEfanBasics : EfanTest {
	
	Void testOneLineText() {
		text := efan.render("Hello!", null)
		verifyEq(text, "Hello!")

		// again!
		text = efan.render("Hello!", null)
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
		verifyEfanErrMsg("Fan Code block not closed.") {
			text := efan.render("Hel<% lo!", null)
		}
		verifyEfanErrMsg("Eval block not closed.") {
			text := efan.render("Hel<%= lo!", null)
		}
		verifyEfanErrMsg("Comment block not closed.") {
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
