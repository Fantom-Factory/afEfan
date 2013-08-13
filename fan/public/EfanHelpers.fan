
** Contribute to 'EfanHelpers' to add view helper methods to your efan templates.
const class EfanHelpers {
	
	internal const Type[]	helpers
	
	// FIXME: test mixin helpers! (test multiple!)
	internal new make(Type[] helpers, |This|in) { 
		in(this)
		// TODO: check mixins are const
		this.helpers = helpers.toImmutable
	}
}
