using concurrent::Actor

** Advanced API usage only!
@NoDoc
class EfanCtxStack {
	private static const Str stackId	:= "efan.renderCtx"

	static Obj? withCtx(Str id, |EfanCtxStackElement->Obj?| func) {		
		currentId	:= ((EfanCtxStackElement?) ThreadStack.peek(stackId, false))?.nestedId
		nestedId	:= goDeeper(currentId, id)
		element		:= EfanCtxStackElement(nestedId)
		return ThreadStack.push(stackId, element, func)
	}
	
	static EfanCtxStackElement peek() {
		ThreadStack.peek(stackId, false) ?: throw EfanErr("Could not find EfanCtxStackElement on thread.")
	}

	static EfanCtxStackElement peekParent(Str? errMsg := null) {
		ThreadStack.peekParent(stackId, false) ?: throw EfanErr(errMsg ?: "Could not a parent of EfanCtxStackElement")
	}

	private static Str goDeeper(Str? currentId, Str id) {
		(currentId == null) ? "(${id})" : "${currentId}->(${id})"
	}
}

@NoDoc
class EfanCtxStackElement {
	Str 		nestedId
	Str:Obj?	ctx
	
	new make(Str nestedId) {
		this.nestedId 	= nestedId 
		this.ctx		= Str:Obj?[:]
	}
	
	override Str toStr() {
		nestedId
	}
}
