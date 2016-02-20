
internal class TestNesting : EfanTest {

	EfanTemplateMeta layout := efan.compileFromStr("""  <html> <%= ctx %>\n<%= renderBody %>  </html>\n""")
	
	Void testNestedRendering() {
		index  	:= compiler.compile(`index.efan`,  File(`test/unit-tests/index.efan` ).readAllStr, Map#)
		layout 	:= compiler.compile(`layout.efan`, File(`test/unit-tests/layout.efan`).readAllStr, Obj#)
		html 	:= index.render(["layout":layout, "layoutCtx":69])

		output := """index-before
		               layout-html 69
		               
		                 index-body
		             
		               layout-html
		             index-after
		             """
		verifyEq(html, output)
	}

	Void testNestedRendering2() {
		index  	:= efan.compileFromStr("""before\n<%= ((EfanTemplateMeta) ctx["layout"]).render(ctx["layoutCtx"]) { %>    body\n<% } %>after""", Map#)
		html 	:= index.render(["layout":layout, "layoutCtx":69])
		output := """before
		               <html> 69
		                 body
		               </html>
		             after"""
		verifyEq(html, output)
	}

	Void testNestedRenderingWithNoBody() {
		index  	:= efan.compileFromStr("""before\n<%= ctx["layout"]->render(ctx["layoutCtx"]) %>after""", Map#)
		html 	:= index.render(["layout":layout, "layoutCtx":69])		
		output := """before
		               <html> 69
		               </html>
		             after"""
		verifyEq(html, output)
	}

	Void testBodyRenderingWithNoBody() {
		html := layout.render(69)		
		output := """  <html> 69
		               </html>
		             """
		// Look! No Err!
		verifyEq(html, output)
	}
}
