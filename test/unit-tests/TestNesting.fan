
internal class TestNesting : EfanTest {
	
	Void testNestedRendering() {
		index  	:= compiler.compile(`index.efan`,  `test/unit-tests/index.efan` .toFile.readAllStr, Map#).make as EfanRenderer
		layout 	:= compiler.compile(`layout.efan`, `test/unit-tests/layout.efan`.toFile.readAllStr, Obj#).make as EfanRenderer
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
		index  	:= T_Index(Void#)
		layout 	:= T_Layout(Void#)
		html 	:= index.render(["layout":layout, "layoutCtx":69])		
		output := """before
		               <html> 69
		                 body
		               </html>
		             after"""
		echo(html)
		verifyEq(html, output)
	}

}

const class T_Index : EfanRenderer {
	
	override Type? ctxType {
		get { [Str:Obj]# }
		set { }
	}
	
	internal new make(Type? ctxType) {
		this.ctxType 		= ctxType
	}

	override Void _af_render(StrBuf _af_code, Obj? _ctx, |EfanRenderer t|? _bodyFunc, EfanRenderer? _bodyObj) {
		[Str:Obj] ctx := _af_validateCtx(_ctx)
		
		renderEfan := |EfanRenderer renderer, Obj? rendererCtx, |EfanRenderer obj| bodyFunc| {
			renderer._af_render(_af_code, rendererCtx, bodyFunc, this)
		}
		
		renderBody := |->| {
			_bodyFunc?.call(_bodyObj)
		}
	
		_af_code.add("before\n")
		renderEfan(ctx["layout"], ctx["layoutCtx"]) {
			_af_code.add("    body\n")
		}
		_af_code.add("after")
	}
}

const class T_Layout : EfanRenderer {
	
	override Type? ctxType {
		get { Int# }
		set { }
	}
	
	internal new make(Type? ctxType) {
		this.ctxType 		= ctxType
	}

	override Void _af_render(StrBuf _af_code, Obj? _ctx, |EfanRenderer t|? _bodyFunc, EfanRenderer? _bodyObj) {
		Int ctx := _af_validateCtx(_ctx)
		
		renderEfan := |EfanRenderer renderer, Obj? rendererCtx, |EfanRenderer obj| bodyFunc| {
			renderer._af_render(_af_code, rendererCtx, bodyFunc, this)
		}
		
		renderBody := |->| {
			_bodyFunc?.call(_bodyObj)
		}
	
		_af_code.add("  <html> ")
		_af_code.add(ctx)
		_af_code.add("\n")
		renderBody()
		_af_code.add("  </html>\n")
	}
}
