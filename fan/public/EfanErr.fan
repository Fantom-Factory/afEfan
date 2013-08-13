
** As thrown by Efan.
const class EfanErr : Err {
	new make(Str msg := "", Err? cause := null) : super(msg, cause) {}
}

internal const class EfanParserErr : EfanErr {
	new make(Str msg := "", Err? cause := null) : super(msg, cause) {}
}
