using build

class Build : BuildPod {

	new make() {
		podName = "afEfan"
		summary = "A library for rendering Embedded Fantom (efan) templates"
		version = Version("1.4.1")

		meta = [	
			"proj.name"		: "efan",
			"tags"			: "templating",
			"repo.private"	: "true"	
		]

		depends = [
			"sys 1.0", 
			"concurrent 1.0", 

			"afPlastic 1.0.10+"
		]

		srcDirs = [`test/unit-tests/`, `fan/`, `fan/public/`, `fan/internal/`, `fan/internal/utils/`, `fan/advanced/`]
		resDirs = [`doc/about.fdoc`]

		docApi = true
		docSrc = true
	}
}
