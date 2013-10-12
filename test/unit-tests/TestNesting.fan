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
//		Env.cur.err.printLine("[${html}]")
//		Actor.sleep(20ms)
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
		get { EfanMetaData() { it.ctxName=""; it.srcLocation=``; it.efanTemplate=""; it.efanSrcCode="" } }
		set { }
	}
	
	Obj? _af_eval {
		get { null }
		set { _af_code.add(it) }
	}
	
	override Str _af_render(Obj? _ctx, |->|? _bodyFunc) {
		[Str:Obj] ctx := _ctx

		return EfanRenderCtx.renderEfan(_bodyFunc) |->| {
			_af_code.add("before\n")
			_af_eval = renderEfan(ctx["layout"], ctx["layoutCtx"]) {
				_af_code.add("    body\n")
			}
			_af_code.add("after")
		}
	}		
}

internal const class T_Layout : EfanRenderer {
	override EfanMetaData efanMetaData {
		get { EfanMetaData() { it.ctxName=""; it.srcLocation=``; it.efanTemplate=""; it.efanSrcCode="" } }
		set { }
	}

	Obj? _af_eval {
		get { null }
		set { _af_code.add(it) }
	}

	override Str _af_render(Obj? _ctx, |->|? _bodyFunc) {
		Int ctx := _ctx
		
		return EfanRenderCtx.renderEfan(_bodyFunc) |->| {
			_af_code.add("  <html> ")
			_af_code.add(ctx)
			_af_code.add("\n")
			_af_eval = renderBody
			_af_code.add("  </html>\n")			
		}
	}
}

internal const class T_Index2 : EfanRenderer {
	override EfanMetaData efanMetaData {
		get { EfanMetaData() { it.ctxName=""; it.srcLocation=``; it.efanTemplate=""; it.efanSrcCode="" } }
		set { }
	}
	
	Obj? _af_eval {
		get { null }
		set { _af_code.add(it) }
	}
	
	override Str _af_render(Obj? _ctx, |->|? _bodyFunc) {
		[Str:Obj] ctx := _ctx
		
		return EfanRenderCtx.renderEfan(_bodyFunc) |->| {
			_af_code.add("before\n")
			_af_eval = renderEfan(ctx["layout"], ctx["layoutCtx"], null)
			_af_code.add("after")
		}
	}
}