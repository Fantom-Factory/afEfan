
internal class TestEscaping : EfanTest {
	
	Void testBasicEscape() {
		c := """<%% echo("dude") %>"""
		// test the code looks pretty
		code := efan.render(c)
		verifyEq(code, """<% echo("dude") %>""")
	}

	Void testMultiEscape() {
		c := """I say <%% <%% echo("dude") \n %>"""
		// test the code looks pretty
		code := efan.render(c)
		verifyEq(code, """I say <% <% echo("dude") \n %>""")
	}

	Void testBlocksArentEscaped() {
		c := """I say <%= "<%" %>"""
		// test the code looks pretty
		code := efan.render(c)
		verifyEq(code, """I say <%""")
	}

	Void testEscapingEndBlockBlock1() {
		text := efan.render("""Hel<%= "wot<%%=ever%%>" %>lo!""", null)
		verifyEq(text, """Helwot<%=ever%>lo!""")
	}

	Void testEscapingEndBlockBlock2() {
		text := efan.render("""Hel<%= "wot<%=ever%%>" %>lo!""", null)
		verifyEq(text, """Helwot<%=ever%>lo!""")
	}

}
