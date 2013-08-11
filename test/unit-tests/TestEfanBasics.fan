using afIoc

internal class TestEfanBasics : EfanTest {
	
	Registry? 	reg
	Efan?		efan
	
	override Void setup() {
		reg 	= RegistryBuilder().addModule(EfanModule#).build.startup
		efan	= reg.dependencyByType(Efan#)
	}
	
	Void testOneLineText() {
		text := efan.renderStr("Hello!")
		verifyEq(text, "Hello!")
	}

	Void testOneLineEmptyBlock() {
		text := efan.renderStr("Hel<%  %>lo!")
		verifyEq(text, "Hello!")
	}

	Void testOneLineCommentBlock() {
		text := efan.renderStr("Hel<%# wotever %>lo!")
		verifyEq(text, "Hello!")
	}
	
}
