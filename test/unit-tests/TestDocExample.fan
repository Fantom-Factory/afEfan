using afIoc::Inject

internal class TestDocExample : EfanTest {

	@Inject EfanTemplates? efan

	Void testExample() {
		template := "<% ctx.times |i| { %>Ho! <% } %>Merry Christmas!"
		output   := efan.renderFromStr(template, 3)
		
		verifyEq("Ho! Ho! Ho! Merry Christmas!", output)
	}

	Void testNonAfIoc() {
		template := "<% ctx.times |i| { %>Ho! <% } %>Merry Christmas!"
		output   := EfanCompiler().compile(``, template, Int#)->render(3)
		
		verifyEq("Ho! Ho! Ho! Merry Christmas!", output)
	}
}
