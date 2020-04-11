
** Convenience methods for compiling and rendering efan templates.
** 
**   syntax: fantom
**   str := efan.render("Hello <%= ctx %>!", "Mum")  // --> "Hello Mum!"  
const class Efan {
	
	@NoDoc
	const EfanCompiler	efanCompiler

	** Standard it-block ctor.
	@NoDoc
	new make(|This|? in := null) {
		in?.call(this)
		if (efanCompiler == null)	efanCompiler = EfanCompiler()
	} 
	
	private new ctorForIoc(EfanCompiler efanCompiler, |This| in) {
		this.efanCompiler	 = efanCompiler
		in(this)
	}

	** Compiles the given efan template to a re-usable meta object.
	** 
	** The compiled template (not the returned Meta) extends the given view helper mixins.
	** 
	** 'templateLoc' may be anything - used for meta information only.
	EfanMeta compile(Str efanTemplate, Type? ctxType := null, Type[]? viewHelpers := null, Uri? templateLoc := null) {
		efanCompiler.compile(templateLoc ?: `from/efan/template`, efanTemplate, ctxType, viewHelpers ?: Type#.emptyList)
	}
	
	** Compiles and renders the given efan 'Str' template.
	** 
	**   syntax: fantom
	**   str := efan.render("Hello <%= ctx %>!", "Mum")  // --> "Hello Mum!"  
	** 
	** Convenience for:
	** 
	**   syntax: fantom
	**   str := efan.compile(...).render(ctx)
	Str render(Str efanTemplate, Obj? ctx := null, Type[]? viewHelpers := null, Uri? srcLocation := null) {
		compile(efanTemplate, ctx?.typeof, viewHelpers, srcLocation).render(ctx)
	}
}
