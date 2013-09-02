
@NoDoc
class EfanBodyRenderer {
	private Obj? 			ctx
	private EfanRenderer 	renderer
	private StrBuf			codeBuf
	
	new make(EfanRenderer renderer, Obj? ctx, StrBuf codeBuf) {
		this.renderer 	= renderer
		this.ctx 		= ctx
		this.codeBuf 	= codeBuf
	}

	override This with(|This| bodyFunc) {
		renderer.nestedRender(bodyFunc, this, codeBuf, ctx)	
		return this
	}
}
