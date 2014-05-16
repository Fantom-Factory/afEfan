
internal class TestRuntimeErr : EfanTest {
	
	Void testRuntimeErr() {
		c :="""<% ctx.times { %>
		       <%= 2+2+2+
		       2+2+it.div(0) %>
		       <% } %>"""

		try {
			template := compiler.compile(``, c, Int?#)
			template.render(6)
			fail
		} catch (EfanRuntimeErr err) {
			verifyEq(err.errLineNo, 3)
		}		
	}

	Void testRuntimeErrInBody() {
		o :="""outer-before
		       --
		       -- padding
		       --
		       <%= ctx.render(null) { %>
		       --
		       --
		       --
		           <% 5.div(0) %>
		       <% } %>
		       outer-after"""
		i :="""inner-before
		       <%= renderBody %>
		       inner-after"""

		try {
			outer := compiler.compile(`outer`, o, EfanTemplate#)
			inner := compiler.compile(`inner`, i)
			outer.render(inner)
			fail
		} catch (EfanRuntimeErr err) {
			verifyEq(err.errLineNo, 9)
		}		
	}
	
	Void testRegex() {
		code := "  afPlastic001::EfanTemplate._efan_render (afPlastic001:27)"
		rendering1:="afPlastic001::EfanTemplate"
		rendering2:="afPlastic001"
		reggy 	:= Regex.fromStr("^\\s*?${rendering1}\\._efan_render\\s\\(${rendering2}:([0-9]+)\\)\$")
		reg := reggy.matcher(code)
		reg.find
		lineNo	:= reg.group(1).toInt
		verifyEq(lineNo, 27)
	}
}
