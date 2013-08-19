using afIoc
using afBedSheet::BedSheetWebMod

internal class TestViewHelpers : EfanTest {
	
	@Inject private EfanTemplates? efan
	
	override Void setup() {
		modules = [EfanModule#, T_Mod01#, BedSheetWebMod#.pod.type("BedSheetModule")]
		super.setup
	}
	
	Void testHelpersAreMixins() {
		verifyEfanErrMsg(ErrMsgs.viewHelperMixinIsNotMixin(Int#)) {
			vh := EfanViewHelpersImpl([Int#]) { }
		}		
	}
	
	Void testHelpersAreConst() {
		verifyEfanErrMsg(ErrMsgs.viewHelperMixinIsNotConst(T_Vh1#)) {
			vh := EfanViewHelpersImpl([T_Vh1#]) { }
		}		
	}

	Void testHelpersArePublic() {
		verifyEfanErrMsg(ErrMsgs.viewHelperMixinIsNotPublic(T_Vh2#)) {
			vh := EfanViewHelpersImpl([T_Vh2#]) { }
		}		
	}
	
	Void testMultipleViewHelpers() {
		template := "<%= a() %> <%= b %>"
		output	 := efan.renderFromStr(template, null)
		verifyEq("Judge Dredd", output)
	}
}

@NoDoc
mixin T_Vh1 {}

@NoDoc
internal const mixin T_Vh2 {}

@NoDoc
const mixin T_Vh3 {
	Str a() { "Judge" }
}

@NoDoc
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