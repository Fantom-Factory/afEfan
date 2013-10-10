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
			func()

		} finally {
			stack.pop
			if (stack.isEmpty)
				Actor.locals.remove(stackName)
		}
	}

	static Void call(Str stackName, Obj stackable, |->| func) {
		get(stackName, true)._call(stackable, func)
	}
	
	static Obj stackable(Str stackName) {
		get(stackName, false).stack.peek
	}	

	private static CallStack get(Str stackName, Bool make := false) {
		Actor.locals.getOrAdd(stackName) { make ? CallStack(stackName) : throw Err("Could not find a CallStack instance on thread.") }
	}	
}
