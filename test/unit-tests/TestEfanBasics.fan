
internal class TestEfanBasics : EfanTest {
	
//	Void testOneLineText() {
//		text := efan.renderFromStr("Hello!", null)
//		verifyEq(text, "Hello!")
//	}
//
//	Void testOneLineEmptyBlock() {
//		text := efan.renderFromStr("Hel<%  %>lo!", null)
//		verifyEq(text, "Hello!")
//	}
//
//	Void testOneLineCommentBlock() {
//		text := efan.renderFromStr("Hel<%# wotever %>lo!", null)
//		verifyEq(text, "Hello!")
//	}

	Void testOneLineEvalBlock() {
		text := efan.renderFromStr("Hel<%= \" BIGBOY \" %>lo!", null)
		verifyEq(text, "Hel BIGBOY lo!")
	}

//	Void testFanCodeInBlockNotAllowedBlock() {
//		verifyEfanErrMsg(ErrMsgs.parserBlockInBlockNotAllowed(BlockType.fanCode, BlockType.fanCode)) {
//			text := efan.renderFromStr("Hel<% wot<%ever%> %>lo!", null)
//		}
//		verifyEfanErrMsg(ErrMsgs.parserBlockInBlockNotAllowed(BlockType.eval, BlockType.fanCode)) {
//			text := efan.renderFromStr("Hel<%= wot<%ever%> %>lo!", null)
//		}
//		verifyEfanErrMsg(ErrMsgs.parserBlockInBlockNotAllowed(BlockType.comment, BlockType.fanCode)) {
//			text := efan.renderFromStr("Hel<%# wot<%ever%> %>lo!", null)
//		}
//	}
//
//	Void testEvalInBlockNotAllowedBlock() {
//		verifyEfanErrMsg(ErrMsgs.parserBlockInBlockNotAllowed(BlockType.fanCode, BlockType.eval)) {
//			text := efan.renderFromStr("Hel<% wot<%=ever%> %>lo!", null)
//		}
//		verifyEfanErrMsg(ErrMsgs.parserBlockInBlockNotAllowed(BlockType.eval, BlockType.eval)) {
//			text := efan.renderFromStr("Hel<%= wot<%=ever%> %>lo!", null)
//		}
//		verifyEfanErrMsg(ErrMsgs.parserBlockInBlockNotAllowed(BlockType.comment, BlockType.eval)) {
//			text := efan.renderFromStr("Hel<%# wot<%=ever%> %>lo!", null)
//		}
//	}
//
//	Void testCommentInBlockNotAllowedBlock() {
//		verifyEfanErrMsg(ErrMsgs.parserBlockInBlockNotAllowed(BlockType.fanCode, BlockType.comment)) {
//			text := efan.renderFromStr("Hel<% wot<%#ever%> %>lo!", null)
//		}
//		verifyEfanErrMsg(ErrMsgs.parserBlockInBlockNotAllowed(BlockType.eval, BlockType.comment)) {
//			text := efan.renderFromStr("Hel<%= wot<%#ever%> %>lo!", null)
//		}
//		verifyEfanErrMsg(ErrMsgs.parserBlockInBlockNotAllowed(BlockType.comment, BlockType.comment)) {
//			text := efan.renderFromStr("Hel<%# wot<%#ever%> %>lo!", null)
//		}
//	}
//
//	Void testEfanCanNotEndMidBlock() {
//		verifyEfanErrMsg(ErrMsgs.parserBlockNotClosed(BlockType.fanCode)) {
//			text := efan.renderFromStr("Hel<% lo!", null)
//		}
//		verifyEfanErrMsg(ErrMsgs.parserBlockNotClosed(BlockType.eval)) {
//			text := efan.renderFromStr("Hel<%= lo!", null)
//		}
//		verifyEfanErrMsg(ErrMsgs.parserBlockNotClosed(BlockType.comment)) {
//			text := efan.renderFromStr("Hel<%# lo!", null)
//		}		
//	}
//
//	Void testCommentWithTrippleQuotes() {
//		text := efan.renderFromStr("Hel<%# \"\"\" %>lo!", null)
//		verifyEq(text, "Hello!")
//	}
//
//	Void testTextWithQuotes() {
//		text := efan.renderFromStr("Hel\"lo!", null)
//		verifyEq(text, "Hel\"lo!")
//	}
//
//	Void testTextWithTrippleQuotes() {
//		text := efan.renderFromStr("Hel\"\"\"lo!", null)
//		verifyEq(text, "Hel\"\"\"lo!")
//	}
//
//	Void testEvalWithQuotes() {
//		text := efan.renderFromStr("""Hel<%= " \\\" " %>lo!""", null)
//		verifyEq(text, "Hel \" lo!")
//	}
//
//	Void testEvalWithTrippleQuotes() {
//		text := efan.renderFromStr("Hel<%= \" \\\"\\\"\\\" \" %>lo!", null)
//		verifyEq(text, "Hel \"\"\" lo!")
//	}
}
