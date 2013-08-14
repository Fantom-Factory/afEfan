using afIoc

internal class TestViewHelpers : EfanTest {
	
	@Inject private EfanTemplates? efan
	
	override Void setup() {
		modules = [EfanModule#, T_Mod01#]
		super.setup
	}
	
	Void testMixinsAreMixins() {
		verifyEfanErrMsg(ErrMsgs.viewHelperMixinIsNotMixin(Int#)) {
			vh := EfanViewHelpers([Int#]) { }
		}		
	}
	
	Void testMixinsAreConst() {
		verifyEfanErrMsg(ErrMsgs.viewHelperMixinIsNotConst(T_Vh1#)) {
			vh := EfanViewHelpers([T_Vh1#]) { }
		}		
	}

	Void testMixinsArePublic() {
		verifyEfanErrMsg(ErrMsgs.viewHelperMixinIsNotPublic(T_Vh2#)) {
			vh := EfanViewHelpers([T_Vh2#]) { }
		}		
	}
	
	Void testMultipleViewHelpers() {
		template := "<%= a() %> <%= b %>"
		output	 := efan.renderFromStr(template, null)
		verifyEq("Judge Dredd", output)
	}
}

mixin T_Vh1 {}
internal const mixin T_Vh2 {}

const mixin T_Vh3 {
	Str a() { "Judge" }
}

const mixin T_Vh4 {
	Str b() { "Dredd" }
}

internal class T_Mod01 {
	@Contribute { serviceType=EfanViewHelpers# }
	static Void contrib(OrderedConfig config) {
		config.add(T_Vh3#)
		config.add(T_Vh4#)
	}
}