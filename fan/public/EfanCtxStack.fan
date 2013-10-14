using concurrent::Actor

** Advanced API usage only!
@NoDoc
class EfanCtxStack {
	private Obj[]	stack	:= [,]
		
	override Str toStr() {
		str	:= "EfanCtxStack -> ($stack.size)"
		stack.each { str += "\n  - $it" }
		return str
	}
	
	static Obj? withCtx(EfanRenderer rendering, |EfanCtxStackElement->Obj?| func) {
		ctxStack	:= getOrMakeCtxStack(true)
		currentId	:= ((EfanCtxStackElement?) ctxStack?.stack?.peek)?.nestedId
		nestedId	:= goDeeper(currentId, rendering)
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
	
	static EfanCtxStackElement peek(Int i := -1) {
		getOrMakeCtxStack?.stack?.getSafe(i) ?: throw Err("Could not find EfanCtxStackElement on thread.")		
	}

	private static EfanCtxStack? getOrMakeCtxStack(Bool make := true) {
		Actor.locals.getOrAdd("efan.renderCtx") { make ? EfanCtxStack() : throw Err("Could not find EfanCtxStack on thread.") }		
	}

	private static Str goDeeper(Str? currentId, EfanRenderer rendering) {
		(currentId == null) ? "(${rendering.id})" : "${currentId}->(${rendering.id})"
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
}
