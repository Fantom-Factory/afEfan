
** Contribute to 'EfanViewHelpers' to add view helper methods to your efan templates.
const mixin EfanViewHelpers { 
	abstract internal Type[] mixins()
}

internal const class EfanViewHelpersImpl : EfanViewHelpers {
	override internal const Type[]	mixins
	
	internal new make(Type[] mixins, |This|in) { 
		in(this)
		
		mixins.each { 
			if (!it.isMixin)
				throw EfanErr(ErrMsgs.viewHelperMixinIsNotMixin(it))
			if (!it.isConst)
				throw EfanErr(ErrMsgs.viewHelperMixinIsNotConst(it))
			if (!it.isPublic)
				throw EfanErr(ErrMsgs.viewHelperMixinIsNotPublic(it))
		}
		
		this.mixins = mixins.toImmutable
	}
}
