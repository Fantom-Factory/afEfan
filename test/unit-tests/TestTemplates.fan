using afIoc::Inject

internal class TestTemplates : EfanTest {

	@Inject private EfanTemplates? efan
	
	Void testWarning() {
		// okay, so I can't 'test' the warning, but I can test stuff doesn't break
		
		file := `test/unit-tests/hohoho.efan`.toFile
		output   := efan.renderFromFile(file, Val2() { it.val = 3 } )
		verifyEq("Ho! Ho! Ho! Merry Christmas!", output)

		// now force a recompile with a more specific ctx
		output   = efan.renderFromFile(file, Val1() { it.val = 2 } )
		verifyEq("Ho! Ho! Merry Christmas!", output)
	}
}

class Val1 {
	virtual Int val
}

class Val2 : Val1 {
	override Int val
}