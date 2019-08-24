
internal class TestViewHelpers : EfanTest {
	
	Void testConstHelpers() {
		template := "<%= a() %>"
		output	 := efan.render(template, null, [T_Vh1#])
		verifyEq("Poo", output)
	}

	Void testClassHelpers() {
		template := "<%= a() %>"
		output	 := efan.render(template, null, [T_Vh2#])
		verifyEq("Bar", output)
	}

	Void testMultipleViewHelpers() {
		template := "<%= a() %> <%= b %>"
		output	 := efan.render(template, null, [T_Vh4#, T_Vh5#])
		verifyEq("Judge Dredd", output)
	}

	Void testClassCtor() {
		source		:= "Judge <%= judge %>"
		meta		:= efan.compile(source, null, [T_Vh6#])

		template	:= meta.type.make(["Anderson"])
		verifyEq("Judge Anderson", meta.renderFrom(template, null))

		// test default params
		template	= meta.type.make
		verifyEq("Judge poo", meta.renderFrom(template, null))
	}
}

@NoDoc
mixin T_Vh1 {
	Str a() { "Poo" }
}

@NoDoc
abstract class T_Vh2 {
	Str a() { "Bar" }
}

internal const mixin T_Vh3 {}

@NoDoc
const mixin T_Vh4 {
	Str a() { "Judge" }
}

@NoDoc
const mixin T_Vh5 {
	Str b() { "Dredd" }
}

@NoDoc
const class T_Vh6 {
	const Str judge
	new make(Str judge := "poo") {
		this.judge = judge
	}
}
