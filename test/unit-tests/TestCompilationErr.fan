
internal class TestCompilationErr : EfanTest {
	
	Void testCompilationErr() {
		c :="""<% 3.times |i| { %>
		       <%= 2+2+2+2+2b+1 %>
		       <% } %>"""
		try {
			type := compiler.compile(``, c, null)
			fail
		} catch (EfanCompilationErr err) {
			verifyEq(err.errLineNo, 2)
		}
	}
}
