
internal class TestMultiLines : EfanTest {

	Void testCommentWithMultiLines() {
		c :="""Hel <%# blah
		       blah blah
		           	b-b-b-b-blah
		
		        \$\$boobs %> lo!""" 
		text := efan.renderFromStr(c, null)
		verifyEq(text, "Hel  lo!")

		// test the code looks pretty
		code := engine.parseIntoCode(``, c)
		verify(!code.contains("\t// \n"))		// check empty lines are removed
		verify( code.contains("\t// # blah\t// (efan) --> 1\n"))
		verify( code.contains("\t// # b-b-b-b-blah\t// (efan) --> 3\n")) // test line trimming
	}
	
	Void testEvalWithMultiLines() {
		c :="""Hel <%= 60 + 
		       9 
		       %> lo!""" 
		
		text := efan.renderFromStr(c, null)
		verifyEq(text, "Hel 69 lo!")

		// test the code looks pretty
		code := engine.parseIntoCode(``, c)
		verify( code.contains("\t60 +\t// (efan) --> 1"))
		verify( code.contains("\t9\t// (efan) --> 2"))
		verify( code.contains("_efan_output = \" lo!\"\t// (efan) --> 3"))
	}

	Void testCodeWithMultiLines() {
		c :="""Hel <% s := 60 + 
		       9 
		       %> lo!""" 
		
		text := efan.renderFromStr(c, null)
		verifyEq(text, "Hel  lo!")

		// test the code looks pretty
		code := engine.parseIntoCode(``, c)
		verify( code.contains("\ts := 60 +\t// (efan) --> 1"))
		verify( code.contains("\t9\t// (efan) --> 2"))
		verify( code.contains("_efan_output = \" lo!\"\t// (efan) --> 3"))
	}

	Void testTextWithMulilines() {
		c :="""Hel
		       		6
		       		9	
		       lo!""" 
		text := efan.renderFromStr(c, null)
		verifyEq(text, "Hel\n\t\t6\n\t\t9\t\nlo!")
		
		// test the code looks pretty
		code := engine.parseIntoCode(``, c).split('\n')
		verifyEq( code[0], """_efan_output = "Hel\\n"\t// (efan) --> 1""")
		verifyEq( code[1], """_efan_output = "\\t\\t6\\n"\t// (efan) --> 2""")
		verifyEq( code[2], """_efan_output = "\\t\\t9\\t\\n"\t// (efan) --> 3""")
	}

	Void testTextWithMulilines2() {
		c :="""Hel\r6\r9\rlo!""" 
		text := efan.renderFromStr(c, null)
		verifyEq(text, "Hel\r6\r9\rlo!")

		// test the code looks pretty - \r's make for ugly code - not a lot I can do about it
		code := engine.parseIntoCode(``, c)
		verify( code.contains("""_efan_output = "6\\r" """.trim))
		verify( code.contains("""_efan_output = "9\\r" """.trim))
	}
	
	Void testTextWithMulilinesAndQuotes() {
		c :="""Hel
		       6
		       "9"
		       lo!""" 
		text := efan.renderFromStr(c, null)
		verifyEq(text, "Hel\n6\n\"9\"\nlo!")
		
		// test the code looks pretty
		code := engine.parseIntoCode(``, c)
		verify( code.contains("""_efan_output = "6\\n" """.trim))
		verify( code.contains("""_efan_output = "\\"9\\"\\n" """.trim))
	}

	Void testTextWithMulilinesAndTrippleQuotes() {
		c := Str<|Hel
		          6
		          """9"""
		          lo!|>
		text := efan.renderFromStr(c, null)
		verifyEq(text, "Hel\n6\n\"\"\"9\"\"\"\nlo!")
		
		// test the code STILL looks pretty!
		code := engine.parseIntoCode(``, c)
		verify( code.contains("""_efan_output = "6\\n" """.trim))
		verify( code.contains("""_efan_output = "\\"\\"\\"9\\"\\"\\"\\n" """.trim))
	}
}
