
internal class TestNesting : EfanTest {
	
	Void testNestedRendering() {
		index  	:= compiler.compile(`index.efan`,  File(`test/unit-tests/index.efan` ).readAllStr, Map#).make as EfanRenderer
		layout 	:= compiler.compile(`layout.efan`, File(`test/unit-tests/layout.efan`).readAllStr, Obj#).make as EfanRenderer
		html 	:= index.render(["layout":layout, "layoutCtx":69])		

		output := """before
		               <html> 69
		               
		                 body
		             
		               </html>
		             
		             after
		             """
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
	override Type? ctxType {
		get { [Str:Obj]# }
		set { }
	}
	
	override Void _af_render(StrBuf _af_code, Obj? _ctx, |EfanRenderer t|? _bodyFunc, EfanRenderer? _bodyObj) {
		[Str:Obj] ctx := _ctx

		_efanCtx := EfanRenderCtx.ctx(false) ?: EfanRenderCtx()
		_efanCtx.renderWithBuf(this, _af_code, _bodyFunc, _bodyObj) |->| {
			_af_code.add("before\n")
			renderEfan(ctx["layout"], ctx["layoutCtx"]) {
				_af_code.add("    body\n")
			}
			_af_code.add("after")
		}
	}
}

internal const class T_Layout : EfanRenderer {
	override Type? ctxType {
		get { Int# }
		set { }
	}
	
	override Void _af_render(StrBuf _af_code, Obj? _ctx, |EfanRenderer t|? _bodyFunc, EfanRenderer? _bodyObj) {
		Int ctx := _ctx
		
		_efanCtx := EfanRenderCtx.ctx(false) ?: EfanRenderCtx()
		_efanCtx.renderWithBuf(this, _af_code, _bodyFunc, _bodyObj) |->| {
			_af_code.add("  <html> ")
			_af_code.add(ctx)
			_af_code.add("\n")
			renderBody
			_af_code.add("  </html>\n")
		}
	}
}

internal const class T_Index2 : EfanRenderer {
	override Type? ctxType {
		get { [Str:Obj]# }
		set { }
	}
	
	override Void _af_render(StrBuf _af_code, Obj? _ctx, |EfanRenderer t|? _bodyFunc, EfanRenderer? _bodyObj) {
		[Str:Obj] ctx := _ctx
		
		_efanCtx := EfanRenderCtx.ctx(false) ?: EfanRenderCtx()
		_efanCtx.renderWithBuf(this, _af_code, _bodyFunc, _bodyObj) |->| {
			_af_code.add("before\n")
			renderEfan(ctx["layout"], ctx["layoutCtx"])
			_af_code.add("after")
		}
	}
}