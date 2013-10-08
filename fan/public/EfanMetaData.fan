
** Provides meta data for an efan template.
** 
** @see `EfanRenderer.efanMetaData`
const class EfanMetaData {
	
	** The 'ctx' type the renderer was compiled against.
	const Type? ctxType

	** The name of the 'ctx' variable the renderer was compiled with.
	const Str ctxName
	
	** Where the efan template originated from. Example, 'file://layout.efan'. 
	const Uri srcLocation
	
	** The efan template source code.
	const Str efanTemplate

	** The generated efan fantom code (for the inquisitive).
	const Str efanSrcCode
	
	internal new make(|This|in) { in(this) }	
}
