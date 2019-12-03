
internal class TestMultiBlocks : EfanTest {
	
	Void testMulilBlocksAreIndended() {
		c :="""<% 3.times |i| { %>
		       <%= i+1 %>
		       <% } %>"""
		// test the code looks pretty
		code := parser.parse(``, c).fantomCode
		verify( code.contains("3.times |i| {"))
		verify( code.contains("\t_efan_output = i+1"))
	}

	Void testBlocksTrimmed() {
		c :="""<%     echo("dude")     %>"""
		// test the code looks pretty
		code := parser.parse(``, c).fantomCode
		verify( code.contains("echo(\"dude\")"))
	}

	Void testEmptyTextBlocksAreIgnored() {
		c :="""<% %><% %><% %>"""
		// test the code looks pretty
		code := parser.parse(``, c).fantomCode
		verify(!code.contains("_afCode.add("))
	}

	Void testEmptyCodeBlocksAreIgnored() {
		c :="""<% %>"""
		// test the code looks pretty
		code := parser.parse(``, c).fantomCode
		verify(!code.contains("_afCode.add("))
	}

	Void testEmptyEvalBlocksAreIgnored() {
		c :="""<%= %>"""
		// test the code looks pretty
		code := parser.parse(``, c).fantomCode
		verify(!code.contains("_afCode.add("))
	}
}
