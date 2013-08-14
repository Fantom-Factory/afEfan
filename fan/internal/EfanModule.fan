using afIoc

internal const class EfanModule {

	static Void bind(ServiceBinder binder) {
		binder.bindImpl(EfanTemplates#)
		binder.bindImpl(EfanCompiler#)
		binder.bindImpl(EfanParser#)
		binder.bindImpl(EfanHelpers#)
	}

}
