using concurrent

internal class TestNesting : EfanTest {
	
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
		Env.cur.err.printLine("[${html}]")
		Actor.sleep(20ms)
		verifyEq(html, output)
	}

	Void testNestedRendering2() {
		index  	:= T_Index()
		layout 	:= T_Layout()
		html 	:= index.render(["layout":layout, "layoutCtx":69])		
		output := """before
		               <html> 69
		                 body
		               </html>
		             after"""
//		Env.cur.err.printLine("[${html}]")
//		Actor.sleep(20ms)
		verifyEq(html, output)
	}

	Void testNestedRenderingWithNoBody() {
		index  	:= T_Index2()
		layout 	:= T_Layout()
		html 	:= index.render(["layout":layout, "layoutCtx":69])		
		output := """before
		               <html> 69
		               </html>
		             after"""
		verifyEq(html, output)
	}

	Void testBodyRenderingWithNoBody() {
		html := T_Layout().render(69)		
		output := """  <html> 69
		               </html>
		             """
		// Look! No Err!
		verifyEq(html, output)
	}
}

internal const class T_Index : EfanRenderer {
	override EfanMetaData efanMetaData {
		get { EfanMetaData() }
		set { }
	}

	Obj? _efan_output {
		get { null }
		set { EfanRenderCtx.peek.renderBuf.add(it) }
	}
	
	override Void _efan_render(Obj? _ctx) {
		[Str:Obj] ctx := _ctx

		_efan_output = "before\n"
		_efan_output = ((EfanRenderer)ctx["layout"]).render(ctx["layoutCtx"]) {
			_efan_output = "    body\n"
		}
		_efan_output = "after"
	}		
}

internal const class T_Layout : EfanRenderer {
	override EfanMetaData efanMetaData {
		get { EfanMetaData() }
		set { }
	}

	Obj? _efan_output {
		get { null }
		set { EfanRenderCtx.peek.renderBuf.add(it) }
	}
	
	override Void _efan_render(Obj? _ctx) {
		Int ctx := _ctx
		
		_efan_output = "  <html> "
		_efan_output = ctx
		_efan_output = "\n"
		_efan_output = renderBody
		_efan_output = "  </html>\n"		
	}
}

internal const class T_Index2 : EfanRenderer {
	override EfanMetaData efanMetaData {
		get { EfanMetaData() }
		set { }
	}

	Obj? _efan_output {
		get { null }
		set { EfanRenderCtx.peek.renderBuf.add(it) }
	}
	
	override Void _efan_render(Obj? _ctx) {
		[Str:Obj] ctx := _ctx
		
		_efan_output = "before\n"
		_efan_output = ((EfanRenderer)ctx["layout"]).render(ctx["layoutCtx"])
		_efan_output = "after"
	}
}