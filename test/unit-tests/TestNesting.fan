
internal class TestNesting : EfanTest {
	
	Void testNestedRendering() {
		layout 	:= compiler.compile(`layout.efan`, `test/unit-tests/layout.efan`.toFile.readAllStr, Obj#)
		index  	:= compiler.compile(`index.efan`,  `test/unit-tests/index.efan` .toFile.readAllStr, Map#)
		html 	:= index.render(["layout":layout, "layoutCtx":69])		

		output := """before
		               <html> 69
		               
		                 body
		             
		               </html>
		             
		             after
		             """
		verifyEq(html, output)
	}
	
}
