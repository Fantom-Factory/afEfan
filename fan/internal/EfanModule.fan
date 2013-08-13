using afIoc

internal const class EfanModule {
	
	static Void bind(ServiceBinder binder) {
		binder.bindImpl(EfanService#)
		binder.bindImpl(EfanCompiler#)
		binder.bindImpl(EfanParser#)
	}

}
