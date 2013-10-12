using concurrent::Actor

internal class CallStack {
	private const 	Str 	stackName
	private 		Obj[] 	stack := [,]
	
	private new make(Str stackName) {
		this.stackName = stackName
	}
	
	private Void _call(Obj stackable, |->| func) {
		stack.push(stackable)

		try {
			// TODO: Dodgy Fantom syntax!!! See EfanRenderer.renderEfan()
			((|Obj?|) func).call(69)

		} finally {
			stack.pop
			if (stack.isEmpty)
				Actor.locals.remove(stackName)
		}
	}

	static Void pushAndRun(Str stackName, Obj stackable, |->| func) {
		get(stackName, true)._call(stackable, func)
	}
	
	static Obj peek(Str stackName) {
		get(stackName, false).stack.peek
	}	

	private static CallStack get(Str stackName, Bool make := false) {
		Actor.locals.getOrAdd(stackName) { make ? CallStack(stackName) : throw Err("Could not find a CallStack for '${stackName}' on thread.") }
	}	
}
