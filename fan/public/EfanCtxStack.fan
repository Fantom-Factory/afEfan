using concurrent::Actor

** Advanced API usage only!
@NoDoc
class EfanCtxStack {
	private Str		stackName
	private Obj[]	stack	:= [,]
		
	private new make(Str stackName) {
		this.stackName = stackName
	}

	static Obj? withCtx(Str ctxName, EfanRenderer rendering, Obj? ctx, |Str->Obj?| func) {
		ctxStack	:= getOrMakeCtxStack(ctxName, true)
		currentId	:= ((EfanCtxStackElement?) ctxStack?.stack?.peek)?.nestedId
		nestedId	:= goDeeper(currentId, rendering)
		element		:= EfanCtxStackElement(nestedId, ctx)

		ctxStack.stack.push(element)
		try {
			return func.call(nestedId)
			
		} finally {
			ctxStack.stack.pop
			if (ctxStack.stack.isEmpty)
				Actor.locals.remove(ctxName)			
		}
	}
	
	static EfanCtxStackElement peek(Str ctxName, Int i := -1) {
		getOrMakeCtxStack(ctxName)?.stack?.getSafe(i) ?: throw Err("Could not find EfanCtxStackElement '${ctxName}' on thread.")		
	}

	private static EfanCtxStack? getOrMakeCtxStack(Str ctxName, Bool make := true) {
		Actor.locals.getOrAdd(ctxName) { make ? EfanCtxStack(ctxName) : throw Err("Could not find EfanCtxStack '${ctxName}' on thread.") }		
	}

	private static Str goDeeper(Str? currentId, EfanRenderer rendering) {
		(currentId == null) ? "(${rendering.id})" : "${currentId}->(${rendering.id})"
	}
}

@NoDoc
class EfanCtxStackElement {
	Str 	nestedId
	Obj?	ctx
	
	new make(Str nestedId, Obj? ctx) {
		this.nestedId 	= nestedId 
		this.ctx		= ctx
	}
}
