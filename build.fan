using build

class Build : BuildPod {

	new make() {
		podName = "afEfan"
		summary = "A library for rendering Embedded Fantom (efan) templates"
		version = Version("1.5.0")

		meta = [	
			"proj.name"		: "efan",
			"repo.tags"		: "templating",
			"repo.public"	: "true"	
		]

		depends = [
			"sys        1.0.68 - 1.0", 
			"concurrent 1.0.68 - 1.0", 
			"afPlastic  1.1.0  - 1.1"
		]

		srcDirs = [`fan/`, `fan/advanced/`, `fan/internal/`, `fan/internal/utils/`, `fan/public/`, `test/unit-tests/`]
		resDirs = [`doc/`]
	}
}
