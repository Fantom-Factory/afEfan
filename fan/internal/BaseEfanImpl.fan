
** What every efan renderer implements.
@NoDoc
const mixin BaseEfanImpl {

	** Meta data about the compiled efan templates
	abstract EfanMetaData efanMetaData

	** Where the compiled efan template code lives. 
	@NoDoc
	abstract Void _af_render(Obj? _ctx)
}
