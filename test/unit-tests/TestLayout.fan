
class TestLayout : Test {

	Efan			efan		:= Efan()
	
	Void testLayout() {
		layout	:= "1 <%= ctx.renderBody %> 3"
		output	:= efan.render(layout, this)
		
		verifyEq("1 2 3", output)
	}

	// for layout
	Str renderBody() {
		return efan.render("2", this)
	}	
}
