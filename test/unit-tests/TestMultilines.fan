using afIoc::Inject

internal class TestMultiLines : EfanTest {

	@Inject	EfanService?	efan
	@Inject EfanCompiler?	compiler
	
	Void testCommentWithMultiLines() {
		c :="""Hel <%#
		       Line 1 
		           	Line 2 
		       %> lo!""" 
		text := efan.renderFromStr(c)
		verifyEq(text, "Hel  lo!")

		// test the code looks pretty
		code := compiler.parseIntoCode(c)
		verify(!code.contains("\t\t// \n"))		// check empty lines are removed
		verify( code.contains("\t\t// Line 1"))
		verify( code.contains("\t\t// Line 2"))	// test line trimming
	}
	
	Void testEvalWithMultiLines() {
		c :="""Hel <%= 60 + 
		       9 
		       %> lo!""" 
		text := efan.renderFromStr(c)
		verifyEq(text, "Hel 69 lo!")

		// test the code looks pretty
		code := compiler.parseIntoCode(c)		
		verify( code.contains("\t\t\t60 +"))
		verify( code.contains("\t\t\t9"))
	}
	
	Void testTextWithMulilines() {
		c :="""Hel
		       6
		       9
		       lo!""" 
		text := efan.renderFromStr(c)		
		verifyEq(text, "Hel\n6\n9\nlo!")
		
		// test the code looks pretty
		code := compiler.parseIntoCode(c)
		verify( code.contains("\t\t               6"))
		verify( code.contains("\t\t               9"))
	}

	Void testTextWithMulilines2() {
		c :="""Hel\r6\r9\rlo!""" 
		text := efan.renderFromStr(c)
		verifyEq(text, "Hel\r6\r9\rlo!")

		// test the code looks pretty - \r's make for ugly code - not a lot I can do about it
		code := compiler.parseIntoCode(c)
		verify( code.contains("\r6"))
		verify( code.contains("\r9"))
	}
	
	Void testTextWithMulilinesAndQuotes() {
		c :="""Hel
		       6
		       "9"
		       lo!""" 
		text := efan.renderFromStr(c)		
		verifyEq(text, "Hel\n6\n\"9\"\nlo!")
		
		// test the code looks pretty
		code := compiler.parseIntoCode(c)
		verify( code.contains("\t\t               6"))
		verify( code.contains("\t\t               \"9\""))
	}

	Void testTextWithMulilinesAndTrippleQuotes() {
		c := Str<|Hel
		          6
		          """9"""
		          lo!|>
		text := efan.renderFromStr(c)
		verifyEq(text, "Hel\n6\n\"\"\"9\"\"\"\nlo!")
		// the code is ugly - no need to test it!
	}

}
