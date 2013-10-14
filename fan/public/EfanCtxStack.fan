using concurrent::Actor

** Advanced API usage only!
@NoDoc
class EfanCtxStack {
	private EfanCtxStackElement[]	stack	:= EfanCtxStackElement[,]
		
	override Str toStr() {
		str	:= "EfanCtxStack -> ($stack.size)"
		stack.each { str += "\n  - $it" }
		return str
	}

	static Obj? withCtx(Str id, |EfanCtxStackElement->Obj?| func) {
		ctxStack	:= getOrMakeCtxStack(true)
		currentId	:= ((EfanCtxStackElement?) ctxStack?.stack?.peek)?.nestedId
		nestedId	:= goDeeper(currentId, id)
		element		:= EfanCtxStackElement(nestedId)

		ctxStack.stack.push(element)
		try {
			return func.call(element)
			
		} finally {
			ctxStack.stack.pop
			if (ctxStack.stack.isEmpty)
				Actor.locals.remove("efan.renderCtx")			
		}
	}
	
	static EfanCtxStackElement peek() {
		getOrMakeCtxStack?.stack?.getSafe(-1) ?: throw EfanErr("Could not find EfanCtxStackElement on thread.")		
	}

	static EfanCtxStackElement peekParent(Str? errMsg := null) {
		getOrMakeCtxStack?.stack?.getSafe(-2) ?: throw EfanErr(errMsg ?: "Could not a parent of EfanCtxStackElement")
	}

	private static EfanCtxStack? getOrMakeCtxStack(Bool make := true) {
		Actor.locals.getOrAdd("efan.renderCtx") { make ? EfanCtxStack() : throw EfanErr("Could not find EfanCtxStack on thread.") }		
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
