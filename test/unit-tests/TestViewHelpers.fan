
internal class TestViewHelpers : EfanTest {
	
	Void testConstHelpers() {
		template := "<%= a() %>"
		output	 := efan.renderFromStr(template, null, [T_Vh1#])
		verifyEq("Poo", output)
	}

	Void testClassHelpers() {
		template := "<%= a() %>"
		output	 := efan.renderFromStr(template, null, [T_Vh2#])
		verifyEq("Bar", output)
	}

	Void testHelpersMustBePublic() {
		verifyEfanErrMsg(ErrMsgs.viewHelperMixinIsNotPublic(T_Vh3#)) {
			EfanCompiler.validateViewHelpers([T_Vh3#])
		}		
	}

	Void testMultipleViewHelpers() {
		template := "<%= a() %> <%= b %>"
		output	 := efan.renderFromStr(template, null, [T_Vh4#, T_Vh5#])
		verifyEq("Judge Dredd", output)
	}
}

@NoDoc
mixin T_Vh1 {
	Str a() { "Poo" }
}

@NoDoc
abstract class T_Vh2 {
	Str a() { "Bar" }
}

internal const mixin T_Vh3 {}

@NoDoc
const mixin T_Vh4 {
	Str a() { "Judge" }
}

@NoDoc
const mixin T_Vh5 {
	Str b() { "Dredd" }
}
