
class TestLayout : Test {

	Efan			efan		:= Efan()
	
	Void testLayout() {
		layout	:= "1 <%= ctx.renderBody %> 3"
		output	:= efan.renderFromStr(layout, this)
		
		verifyEq("1 2 3", output)
	}

	Str renderBody() {
		return efan.renderFromStr("2", this)
	}
	
}
