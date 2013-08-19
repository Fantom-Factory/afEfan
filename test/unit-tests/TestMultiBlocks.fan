using afIoc::Inject

internal class TestMultiBlocks : EfanTest {
	
	@Inject	EfanTemplates?	efan
	@Inject EfanCompiler?	compiler
	
	Void testMulilBlocksAreIndended() {
		c :="""<% 3.times |i| { %>
		       <%= i+1 %>
		       <% } %>"""
		// test the code looks pretty
		code := compiler.parseIntoCode(``, c)
		verify( code.contains("\t\t3.times |i| {"))
		verify( code.contains("\t\t\t_afCode.add( i+1 )"))
	}

	Void testBlocksTrimmed() {
		c :="""<%     echo("dude")     %>"""
		// test the code looks pretty
		code := compiler.parseIntoCode(``, c)
		verify( code.contains("\t\techo(\"dude\")"))
	}

	Void testEmptyTextBlocksAreIgnored() {
		c :="""<% %><% %><% %>"""
		// test the code looks pretty
		code := compiler.parseIntoCode(``, c)
		verify(!code.contains("_afCode.add("))
	}

	Void testEmptyCodeBlocksAreIgnored() {
		c :="""<% %>"""
		// test the code looks pretty
		code := compiler.parseIntoCode(``, c)
		verify(!code.contains("_afCode.add("))
	}

	Void testEmptyEvalBlocksAreIgnored() {
		c :="""<%= %>"""
		// test the code looks pretty
		code := compiler.parseIntoCode(``, c)
		verify(!code.contains("_afCode.add("))
	}
}
