
internal class TestUsing : EfanTest {
	
	Void testBasicEscape() {
		c :="""<%? using sys::Int as Dude %>
		       <%= Dude("69") %>""" 
		text := efan.renderFromStr(c, null)
		verifyEq(text, "69")
	}
	
	Void testNotUsingErr() {
		c :="""<%? using sys::Str %>
		       <%? hello! %>"""
		try {
			type := compiler.compile(``, c, null)
			fail
		} catch (EfanParserErr err) {
			verifyEq(err.msg, ErrMsgs.unknownInstruction("hello!"))
			verifyEq(err.errLineNo, 2)
		}
	}

	Void testCompilationErr() {
		c :="""<%? using sys::Str %>
		       <%? using wotever %>"""
		try {
			type := compiler.compile(``, c, null)
			fail
		} catch (EfanCompilationErr err) {
			verifyEq(err.errLineNo, 2)
		}
	}

	Void testJava() {
		c :="""<%? using [java]java.util::Date as JDate %>
		       <%= JDate().toString %>"""
		type := compiler.compile(``, c, null)
		reb:=type.render(null)
	}
}
