
internal class TestDocExample : EfanTest {

	Void testExample() {
		template := "<% ctx.times |i| { %>Ho! <% } %>Merry Christmas!"
		output   := efan.render(template, 3)
		
		verifyEq("Ho! Ho! Ho! Merry Christmas!", output)
	}

}
