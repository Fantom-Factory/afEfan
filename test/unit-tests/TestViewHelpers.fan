
internal class TestViewHelpers : EfanTest {
	
	Void testHelpersAreMixins() {
		verifyEfanErrMsg(ErrMsgs.viewHelperMixinIsNotMixin(Int#)) {
			EfanCompiler.validateViewHelpers([Int#])
		}
	}
	
	Void testHelpersAreConst() {
		verifyEfanErrMsg(ErrMsgs.viewHelperMixinIsNotConst(T_Vh1#)) {
			EfanCompiler.validateViewHelpers([T_Vh1#])
		}		
	}

	Void testHelpersArePublic() {
		verifyEfanErrMsg(ErrMsgs.viewHelperMixinIsNotPublic(T_Vh2#)) {
			EfanCompiler.validateViewHelpers([T_Vh2#])
		}		
	}

	Void testMultipleViewHelpers() {
		template := "<%= a() %> <%= b %>"
		output	 := efan.renderFromStr(template, null, [T_Vh3#, T_Vh4#])
		verifyEq("Judge Dredd", output)
	}
}

@NoDoc
mixin T_Vh1 {}

internal const mixin T_Vh2 {}

@NoDoc
const mixin T_Vh3 {
	Str a() { "Judge" }
}

@NoDoc
const mixin T_Vh4 {
	Str b() { "Dredd" }
}
