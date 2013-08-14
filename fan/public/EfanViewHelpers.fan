
** Contribute to 'EfanViewHelpers' to add view helper methods to your efan templates.
const class EfanViewHelpers {
	
	internal const Type[]	mixins
	
	// FIXME: test mixin helpers! (test multiple!)
	internal new make(Type[] mixins, |This|in) { 
		in(this)
		// TODO: check mixins are const
		this.mixins = mixins.toImmutable
	}
}
