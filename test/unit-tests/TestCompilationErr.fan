using afIoc

internal class TestCompilationErr : EfanTest {
	
	@Inject	EfanTemplates?	efan
	@Inject EfanCompiler?	compiler

	Void testCompilationErr() {
		c :="""<% 3.times |i| { %>
		       <%= 2+2+2+2+2b+1 %>
		       <% } %>"""

		try {
			type := compiler.compile(``, c, null)
			fail
		} catch (EfanCompilationErr err) {
			srcErrLoc := err.srcErrLoc
			verifyEq(srcErrLoc.errLineNo, 2)
		}
	}

}
