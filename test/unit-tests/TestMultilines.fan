
internal class TestMultiLines : EfanTest {

	Void testCommentWithMultiLines() {
		c :="""Hel <%# blah
		       blah blah
		           	b-b-b-b-blah
		
		        \$\$boobs %> lo!""" 
		text := efan.renderFromStr(c, null)
		verifyEq(text, "Hel  lo!")

		// test the code looks pretty
		code := compiler.parseIntoCode(``, c)
		verify(!code.contains("\t\t// \n"))		// check empty lines are removed
		verify( code.contains("\t\t// --> 1\n\t\t// # blah"))
		verify( code.contains("\t\t// --> 3\n\t\t// # b-b-b-b-blah")) // test line trimming
	}
	
	Void testEvalWithMultiLines() {
		c :="""Hel <%= 60 + 
		       9 
		       %> lo!""" 
		
		text := efan.renderFromStr(c, null)
		verifyEq(text, "Hel 69 lo!")

		// test the code looks pretty
		code := compiler.parseIntoCode(``, c)
		verify( code.contains("\t\t\t60 +"))
		verify( code.contains("\t\t\t9"))
	}

	Void testTextWithMulilines() {
		c :="""Hel
		       		6
		       		9	
		       lo!""" 
		text := efan.renderFromStr(c, null)
		verifyEq(text, "Hel\n\t\t6\n\t\t9\t\nlo!")
		
		// test the code looks pretty
		code := compiler.parseIntoCode(``, c)
		verify( code.contains("""_afCode.add("\\t\\t6\\n")"""))
		verify( code.contains("""_afCode.add("\\t\\t9\\t\\n")"""))
	}

	Void testTextWithMulilines2() {
		c :="""Hel\r6\r9\rlo!""" 
		text := efan.renderFromStr(c, null)
		verifyEq(text, "Hel\r6\r9\rlo!")

		// test the code looks pretty - \r's make for ugly code - not a lot I can do about it
		code := compiler.parseIntoCode(``, c)
		verify( code.contains("""_afCode.add("6\\r")"""))
		verify( code.contains("""_afCode.add("9\\r")"""))
	}
	
	Void testTextWithMulilinesAndQuotes() {
		c :="""Hel
		       6
		       "9"
		       lo!""" 
		text := efan.renderFromStr(c, null)
		verifyEq(text, "Hel\n6\n\"9\"\nlo!")
		
		// test the code looks pretty
		code := compiler.parseIntoCode(``, c)
		verify( code.contains("""_afCode.add("6\\n")"""))
		verify( code.contains("""_afCode.add("\\"9\\"\\n")"""))
	}

	Void testTextWithMulilinesAndTrippleQuotes() {
		c := Str<|Hel
		          6
		          """9"""
		          lo!|>
		text := efan.renderFromStr(c, null)
		verifyEq(text, "Hel\n6\n\"\"\"9\"\"\"\nlo!")
		
		// test the code STILL looks pretty!
		code := compiler.parseIntoCode(``, c)
		verify( code.contains("""_afCode.add("6\\n")"""))
		verify( code.contains("""_afCode.add("\\"\\"\\"9\\"\\"\\"\\n")"""))
	}

}
