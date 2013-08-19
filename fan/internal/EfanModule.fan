using afIoc
using afBedSheet::FactoryDefaults
using web::WebOutStream

internal const class EfanModule {

	static Void bind(ServiceBinder binder) {
		binder.bindImpl(EfanTemplates#).withoutProxy	// has default method args
		binder.bindImpl(EfanCompiler#)
		binder.bindImpl(EfanParser#)
		binder.bindImpl(EfanViewHelpers#).withoutProxy
	}

	@Contribute { serviceId="ErrPrinterHtml" }
	static Void contributeErrPrinterHtml(OrderedConfig config) {
		printer := (EfanErrPrinter) config.autobuild(EfanErrPrinter#)		
		config.addOrdered("Efan", |WebOutStream out, Err? err| { printer.printHtml(out, err) }, ["Before: StackTrace", "After: IocOperationTrace"])
	}

	@Contribute { serviceId="ErrPrinterStr" }
	static Void contributeErrPrinterStr(OrderedConfig config) {
		printer := (EfanErrPrinter) config.autobuild(EfanErrPrinter#)
		config.addOrdered("Efan", |StrBuf out, Err? err| { printer.printStr(out, err) }, ["Before: StackTrace", "After: IocOperationTrace"])
	}

	@Contribute { serviceType=FactoryDefaults# }
	static Void contributeFactoryDefaults(MappedConfig config) {
		config[EfanConfigIds.templateTimeout]		= 10sec
		config[EfanConfigIds.linesOfSrcCodePadding]	= 5
	}
}
