
internal class TestDocExample : EfanTest {

	Void testExample() {
		template := "<% ctx.times |i| { %>Ho! <% } %>Merry Christmas!"

		output   := efan.render(template, 3)
		verifyEq("Ho! Ho! Ho! Merry Christmas!", output)


		// test compiling and multiple meta rendering
		meta := efan.compile(template, Int#)
		inst := meta.instance
		out1 := meta.renderFrom(inst, 3)
		verifyEq("Ho! Ho! Ho! Merry Christmas!", out1)

		out2 := meta.renderFrom(inst, 3)
		verifyEq("Ho! Ho! Ho! Merry Christmas!", out2)
	}

}
