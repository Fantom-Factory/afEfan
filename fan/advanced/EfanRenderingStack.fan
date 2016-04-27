
** Advanced API usage only!
** Lets us associate data with the efan template currently being rendered.
** Required to keep track of stuff when rendering nested templates / components.
** Because don't forget we jump back up to render the body, then back down again...
@NoDoc
class EfanRenderingStack {
	private static const Str stackId	:= "efan.renderCtx"

	static Void withCtx(Str id, |EfanRenderingStackElement| func) {		
		currentId	:= peek(false)?.nestedId
		element		:= EfanRenderingStackElement(currentId, id)
		ThreadStack.pushAndRun(stackId, element, func)
	}
	
	static EfanRenderingStackElement? peek(Bool checked := true) {
		ThreadStack.peek(stackId, false) ?: (checked ? throw EfanErr("Could not find EfanCtxStackElement on thread.") : null)
	}

	static EfanRenderingStackElement? peekParent(Bool checked := true, Str? errMsg := null) {
		ThreadStack.peekParent(stackId, false) ?: (checked ? throw EfanErr(errMsg ?: "Could not a parent of EfanCtxStackElement") : null)
	}

	static EfanRenderingStackElement[]? getStack(Bool checked := true) {
		ThreadStack.elements(stackId, checked)
	}

}

@NoDoc
class EfanRenderingStackElement {
	Str 		simpleId
	Str 		nestedId
	Str:Obj?	ctx
	
	new make(Str? fullId, Str id) {
		this.simpleId	= id
		this.nestedId 	= goDeeper(fullId, id) 
		this.ctx		= Str:Obj?[:]
	}

	private static Str goDeeper(Str? currentId, Str id) {
		(currentId == null) ? "(${id})" : "${currentId}->(${id})"
	}
	
	override Str toStr() {
		nestedId
	}
}
