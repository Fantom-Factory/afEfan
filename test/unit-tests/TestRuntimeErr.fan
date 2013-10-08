
internal class TestRuntimeErr : EfanTest {
	
	Void testRuntimeErr() {
		c :="""<% ctx.times { %>
		       <%= 2+2+2+
		       2+2+it.div(0) %>
		       <% } %>"""

		try {
			renderer := compiler.compile(``, c, Int?#)
			renderer.render(6)
			fail
		} catch (EfanRuntimeErr err) {
			verifyEq(err.errLineNo, 3)
		}		
	}
	
	Void testRegex() {
		code := "  afPlastic001::EfanRenderer._af_render (afPlastic001:27)"
		rendering1:="afPlastic001::EfanRenderer"
		rendering2:="afPlastic001"
		reggy 	:= Regex.fromStr("^\\s*?${rendering1}\\._af_render\\s\\(${rendering2}:([0-9]+)\\)\$")
		reg := reggy.matcher(code)
		reg.find
		lineNo	:= reg.group(1).toInt
		verifyEq(lineNo, 27)
	}
}
