using afIoc

internal const class EfanModule {
	
	static Void bind(ServiceBinder binder) {
		binder.bindImpl(Efan#)
		binder.bindImpl(EfanCompiler#)
		binder.bindImpl(EfanParser#)
	}

}
