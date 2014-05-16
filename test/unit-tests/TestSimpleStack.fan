
internal class TestSimpleCtx : EfanTest {
	
	Void testSimpleCtx1() {
		str := Str<|<% for (i := 0; i < ctx; ++i) { %> ><%= i + 1 %>< <% } %>|>
		text := efan.renderFromStr(str, 3)
		verifyEq(text, " >1<  >2<  >3< ")
	}

	Void testSimpleCtxMultiline() {
		str := 
Str<|
     <% for (i := 0; i < ctx; ++i) { %>
     	><%= i + 1 %><
     <% } %>
|>
		text := efan.renderFromStr(str, 3)
		verifyEq(text, "\n\t>1<\n\t>2<\n\t>3<\n")
	}

}
