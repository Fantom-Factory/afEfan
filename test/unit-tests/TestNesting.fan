
internal class TestNesting : EfanTest {
	
	Void testNestedRendering() {
		index  	:= compiler.compile(`index.efan`,  File(`test/unit-tests/index.efan` ).readAllStr, Map#)
		layout 	:= compiler.compile(`layout.efan`, File(`test/unit-tests/layout.efan`).readAllStr, Obj#)
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
	override EfanMetaData efanMetaData {
		get { EfanMetaData() { it.ctxName=""; it.srcLocation=``; it.efanTemplate=""; it.efanSrcCode="" } }
		set { }
	}
	
	override Str _af_render(Obj? _ctx, |->|? _bodyFunc) {
		[Str:Obj] ctx := _ctx

//		_af_retVal := (StrBuf?) null
		_af_renderCtx := afEfan::EfanRenderCtx(this, StrBuf(), _bodyFunc)
		return EfanRenderCtx.withRenderCtx(_af_renderCtx) |->| {
//			_af_code  := afEfan::EfanRenderCtx.renderCtx.renderBuf
//			_af_retVal = _af_code
			
			_af_code.add("before\n")
			renderEfan(ctx["layout"], ctx["layoutCtx"]) |->| {
				_af_code.add("    body\n")
			}
			_af_code.add("after")
		}

//		return _af_code.toStr
	}		
}

internal const class T_Layout : EfanRenderer {
	override EfanMetaData efanMetaData {
		get { EfanMetaData() { it.ctxName=""; it.srcLocation=``; it.efanTemplate=""; it.efanSrcCode="" } }
		set { }
	}
	
	override Str _af_render(Obj? _ctx, |->|? _bodyFunc) {
		Int ctx := _ctx
		
//		_af_retVal := (StrBuf?) null
		_af_renderCtx := EfanRenderCtx(this, StrBuf(), _bodyFunc)
		return EfanRenderCtx.withRenderCtx(_af_renderCtx) |->| {
//			_af_code  := afEfan::EfanRenderCtx.renderCtx.renderBuf
//			_af_retVal = _af_code

			_af_code.add("  <html> ")
			_af_code.add(ctx)
			_af_code.add("\n")
			_af_code.add(renderBody)
			_af_code.add("  </html>\n")			
		}

//		return _af_code.toStr		
	}
}

internal const class T_Index2 : EfanRenderer {
	override EfanMetaData efanMetaData {
		get { EfanMetaData() { it.ctxName=""; it.srcLocation=``; it.efanTemplate=""; it.efanSrcCode="" } }
		set { }
	}
	
	override Str _af_render(Obj? _ctx, |->|? _bodyFunc) {
		[Str:Obj] ctx := _ctx
		
//		_af_retVal := (StrBuf?) null
		_af_renderCtx := EfanRenderCtx(this, StrBuf(), _bodyFunc)
		return EfanRenderCtx.withRenderCtx(_af_renderCtx) |->| {
//			_af_code  := afEfan::EfanRenderCtx.renderCtx.renderBuf
//			_af_retVal = _af_code
			
			_af_code.add("before\n")
			_af_code.add(renderEfan(ctx["layout"], ctx["layoutCtx"]))
			_af_code.add("after")
		}

//		return _af_code.toStr		
	}
}