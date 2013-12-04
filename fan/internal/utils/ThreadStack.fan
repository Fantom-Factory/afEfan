using concurrent

** I've recently become a fan of threaded stacks - they get me outa a whole lot of trouble!
internal const class ThreadStack {

//	private EfanCtxStackElement[]	stack	:= EfanCtxStackElement[,]
//		
//	override Str toStr() {
//		str	:= "EfanCtxStack -> ($stack.size)"
//		stack.each { str += "\n  - $it" }
//		return str
//	}
//
// Obj getSafe(Int index) {...]

	** staic use only
	private new make() { }
	
	static Obj? push(Str stackId, Obj stackObj, |Obj->Obj?| func) {
		threadStack	:= getOrMakeStack(stackId)
		threadStack.push(stackObj)
		try {
			return func.call(stackObj)
			
		} finally {
			threadStack.pop
			if (threadStack.isEmpty)
				Actor.locals.remove(stackId)			
		}
	}

	static Obj? peek(Str stackId, Bool checked := true) {
		getStack(stackId, checked)?.getSafe(-1) ?: (checked ? throw EfanErr("ThreadStack with id '$stackId' was empty") : null)
	}

	static Obj? peekParent(Str stackId, Bool checked := true) {
		getStack(stackId, checked)?.getSafe(-2) ?: (checked ? throw EfanErr("ThreadStack with id '$stackId' was only has ${getStack(stackId, checked)?.size} elements") : null)	// if null && checked, getStack() will throw err 
	}

	private static Obj[]? getStack(Str stackId, Bool checked) {
		Actor.locals.get(stackId) ?: (checked ? throw EfanErr("Could not find ThreadStack on thread with id '$stackId'") : null)		
	}

	private static Obj[] getOrMakeStack(Str stackId) {
		Actor.locals.getOrAdd(stackId) { Obj[,] }
	}
}
