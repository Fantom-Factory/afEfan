
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
		code := compiler.parseIntoCode(``, c)
		verify( code.contains("\t60 +\t// (efan) --> 1"))
		verify( code.contains("\t9\t// (efan) --> 2"))
		verify( code.contains("_af_code.add(\" lo!\")\t// (efan) --> 3"))
	}

	Void testCodeWithMultiLines() {
		c :="""Hel <% s := 60 + 
		       9 
		       %> lo!""" 
		
		text := efan.renderFromStr(c, null)
		verifyEq(text, "Hel  lo!")

		// test the code looks pretty
		code := compiler.parseIntoCode(``, c)
		verify( code.contains("\ts := 60 +\t// (efan) --> 1"))
		verify( code.contains("\t9\t// (efan) --> 2"))
		verify( code.contains("_af_code.add(\" lo!\")\t// (efan) --> 3"))
	}

	Void testTextWithMulilines() {
		c :="""Hel
		       		6
		       		9	
		       lo!""" 
		text := efan.renderFromStr(c, null)
		verifyEq(text, "Hel\n\t\t6\n\t\t9\t\nlo!")
		
		// test the code looks pretty
		code := compiler.parseIntoCode(``, c).split('\n')
		verifyEq( code[0], """_af_code.add("Hel\\n")\t// (efan) --> 1""")
		verifyEq( code[1], """_af_code.add("\\t\\t6\\n")\t// (efan) --> 2""")
		verifyEq( code[2], """_af_code.add("\\t\\t9\\t\\n")\t// (efan) --> 3""")
	}

	Void testTextWithMulilines2() {
		c :="""Hel\r6\r9\rlo!""" 
		text := efan.renderFromStr(c, null)
		verifyEq(text, "Hel\r6\r9\rlo!")

		// test the code looks pretty - \r's make for ugly code - not a lot I can do about it
		code := compiler.parseIntoCode(``, c)
		verify( code.contains("""_af_code.add("6\\r")"""))
		verify( code.contains("""_af_code.add("9\\r")"""))
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
		verify( code.contains("""_af_code.add("6\\n")"""))
		verify( code.contains("""_af_code.add("\\"9\\"\\n")"""))
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
		verify( code.contains("""_af_code.add("6\\n")"""))
		verify( code.contains("""_af_code.add("\\"\\"\\"9\\"\\"\\"\\n")"""))
	}
}
