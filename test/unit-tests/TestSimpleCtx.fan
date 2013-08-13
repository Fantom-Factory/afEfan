using afIoc

internal class TestSimpleCtx : EfanTest {
	
	Registry? 		reg
	EfanService?	service
	
	override Void setup() {
		reg 	= RegistryBuilder(["suppressLogging":true]).addModule(EfanModule#).build(["suppressStartupMsg":true]).startup
		service	= reg.dependencyByType(EfanService#)
	}
	
	Void testSimpleCtx1() {
		efan := Str<|<% for (i := 0; i < ctx; ++i) { %> ><%= i + 1 %>< <% } %>|>
		text := service.renderStr(efan, 3)
		verifyEq(text, " >1<  >2<  >3< ")
	}

	Void testSimpleCtxMultiline() {
		efan := 
Str<|
     <% for (i := 0; i < ctx; ++i) { %>
     	><%= i + 1 %><
     <% } %>
|>
		text := service.renderStr(efan, 3)
		verifyEq(text, "\n\n\t>1<\n\n\t>2<\n\n\t>3<\n\n")
	}

}
