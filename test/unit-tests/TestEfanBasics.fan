using afIoc

internal class TestEfanBasics : EfanTest {
	
	Registry? 	reg
	Efan?		efan
	
	override Void setup() {
		reg 	= RegistryBuilder(["suppressLogging":true]).addModule(EfanModule#).build(["suppressStartupMsg":true]).startup
		efan	= reg.dependencyByType(Efan#)
	}
	
	Void testOneLineText() {
		text := efan.renderStr("Hello!")
		verifyEq(text, "Hello!")
	}

	Void testOneLineEmptyBlock() {
		text := efan.renderStr("Hel<%  %>lo!")
		verifyEq(text, "Hello!")
	}

	Void testOneLineCommentBlock() {
		text := efan.renderStr("Hel<%# wotever %>lo!")
		verifyEq(text, "Hello!")
	}

	Void testOneLineEvalBlock() {
		text := efan.renderStr("Hel<%= \" BIGBOY \" %>lo!")
		verifyEq(text, "Hel BIGBOY lo!")
	}

	Void testFanCodeInBlockNotAllowedBlock() {
		verifyEfanErrMsg(ErrMsgs.parserBlockInBlockNotAllowed(BlockType.fanCode, BlockType.fanCode)) {
			text := efan.renderStr("Hel<% wot<%ever%> %>lo!")
		}
		verifyEfanErrMsg(ErrMsgs.parserBlockInBlockNotAllowed(BlockType.eval, BlockType.fanCode)) {
			text := efan.renderStr("Hel<%= wot<%ever%> %>lo!")
		}
		verifyEfanErrMsg(ErrMsgs.parserBlockInBlockNotAllowed(BlockType.comment, BlockType.fanCode)) {
			text := efan.renderStr("Hel<%# wot<%ever%> %>lo!")
		}
	}

	Void testEvalInBlockNotAllowedBlock() {
		verifyEfanErrMsg(ErrMsgs.parserBlockInBlockNotAllowed(BlockType.fanCode, BlockType.eval)) {
			text := efan.renderStr("Hel<% wot<%=ever%> %>lo!")
		}
		verifyEfanErrMsg(ErrMsgs.parserBlockInBlockNotAllowed(BlockType.eval, BlockType.eval)) {
			text := efan.renderStr("Hel<%= wot<%=ever%> %>lo!")
		}
		verifyEfanErrMsg(ErrMsgs.parserBlockInBlockNotAllowed(BlockType.comment, BlockType.eval)) {
			text := efan.renderStr("Hel<%# wot<%=ever%> %>lo!")
		}
	}

	Void testCommentInBlockNotAllowedBlock() {
		verifyEfanErrMsg(ErrMsgs.parserBlockInBlockNotAllowed(BlockType.fanCode, BlockType.comment)) {
			text := efan.renderStr("Hel<% wot<%#ever%> %>lo!")
		}
		verifyEfanErrMsg(ErrMsgs.parserBlockInBlockNotAllowed(BlockType.eval, BlockType.comment)) {
			text := efan.renderStr("Hel<%= wot<%#ever%> %>lo!")
		}
		verifyEfanErrMsg(ErrMsgs.parserBlockInBlockNotAllowed(BlockType.comment, BlockType.comment)) {
			text := efan.renderStr("Hel<%# wot<%#ever%> %>lo!")
		}
	}

	Void testEfanCanNotEndMidBlock() {
		verifyEfanErrMsg(ErrMsgs.parserBlockNotClosed(BlockType.fanCode)) {
			text := efan.renderStr("Hel<% lo!")
		}
		verifyEfanErrMsg(ErrMsgs.parserBlockNotClosed(BlockType.eval)) {
			text := efan.renderStr("Hel<%= lo!")
		}
		verifyEfanErrMsg(ErrMsgs.parserBlockNotClosed(BlockType.comment)) {
			text := efan.renderStr("Hel<%# lo!")
		}		
	}

	Void testCommentWithTrippleQuotes() {
		text := efan.renderStr("Hel<%# \"\"\" %>lo!")
		verifyEq(text, "Hello!")
	}

	Void testTextWithQuotes() {
		text := efan.renderStr("Hel\"lo!")
		verifyEq(text, "Hel\"lo!")
	}

	Void testTextWithTrippleQuotes() {
		text := efan.renderStr("Hel\"\"\"lo!")
		verifyEq(text, "Hel\"\"\"lo!")
	}

	Void testEvalWithQuotes() {
		text := efan.renderStr("""Hel<%= " \\\" " %>lo!""")
		verifyEq(text, "Hel \" lo!")
	}

	Void testEvalWithTrippleQuotes() {
		text := efan.renderStr("Hel<%= \" \\\"\\\"\\\" \" %>lo!")
		verifyEq(text, "Hel \"\"\" lo!")
	}
}
