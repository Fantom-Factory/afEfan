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
		get { EfanMetaData() { it.ctxName=""; it.srcLocation=``; it.efanTemplate=""; it.efanSrcCode=""; it.templateId="" } }
		set { }
	}

	Obj? _af_code {
		get { null }
		set { EfanRenderCtx.peek.renderBuf.add(it) }
	}
	
	Obj? _af_eval {
		get { null }
		set { EfanRenderCtx.peek.renderBuf.add(it) }
	}
	
	override Void _af_render(Obj? _ctx) {
		[Str:Obj] ctx := _ctx

		_af_code = "before\n"
		_af_eval = ((EfanRenderer)ctx["layout"]).render(ctx["layoutCtx"]) {
			_af_code = "    body\n"
		}
		_af_code = "after"
	}		
}

internal const class T_Layout : EfanRenderer {
	override EfanMetaData efanMetaData {
		get { EfanMetaData() { it.ctxName=""; it.srcLocation=``; it.efanTemplate=""; it.efanSrcCode=""; it.templateId="" } }
		set { }
	}

	Obj? _af_code {
		get { null }
		set { EfanRenderCtx.peek.renderBuf.add(it) }
	}
	
	Obj? _af_eval {
		get { null }
		set { EfanRenderCtx.peek.renderBuf.add(it) }
	}

	override Void _af_render(Obj? _ctx) {
		Int ctx := _ctx
		
		_af_code = "  <html> "
		_af_code = ctx
		_af_code = "\n"
		_af_eval = renderBody
		_af_code = "  </html>\n"		
	}
}

internal const class T_Index2 : EfanRenderer {
	override EfanMetaData efanMetaData {
		get { EfanMetaData() { it.ctxName=""; it.srcLocation=``; it.efanTemplate=""; it.efanSrcCode=""; it.templateId="" } }
		set { }
	}

	Obj? _af_code {
		get { null }
		set { EfanRenderCtx.peek.renderBuf.add(it) }
	}
	
	Obj? _af_eval {
		get { null }
		set { EfanRenderCtx.peek.renderBuf.add(it) }
	}
	
	override Void _af_render(Obj? _ctx) {
		[Str:Obj] ctx := _ctx
		
		_af_code = "before\n"
		_af_eval = ((EfanRenderer)ctx["layout"]).render(ctx["layoutCtx"])
		_af_code = "after"
	}
}