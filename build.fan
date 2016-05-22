using build

class Build : BuildPod {

	new make() {
		podName = "afEfan"
		summary = "A library for rendering Embedded Fantom (efan) templates"
		version = Version("2.0.0")

		meta = [	
			"proj.name"		: "efan",
			"afIoc.module"	: "afEfan::EfanModule",
			"repo.tags"		: "templating",
			"repo.public"	: "false"	
		]

		depends = [
			"sys          1.0.68 - 1.0", 
			"concurrent   1.0.68 - 1.0", 
			"afConcurrent 1.0.12 - 1.0",
			"afPlastic    1.1.0  - 1.1"
		]

		srcDirs = [`fan/`, `fan/internal/`, `fan/public/`, `test/unit-tests/`]
		resDirs = [`doc/`]
	}
}
