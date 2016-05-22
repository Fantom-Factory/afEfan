
@NoDoc	// advanced use only
const class EfanModule {
	
	Str:Obj nonInvasiveIocModule() {
		[
			"services"	: [
				[
					"id"	: Efan#.qname,
					"type"	: Efan#,
					"scopes": ["root"]
				],
				[
					"id"	: EfanCompiler#.qname,
					"type"	: EfanCompiler#,
					"scopes": ["root"]
				],
				[
					"id"	: EfanParser#.qname,
					"type"	: EfanParser#,
					"scopes": ["root"]
				]
			],
		]
	}
	
}