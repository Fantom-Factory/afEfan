using build::BuildPod

class Build : BuildPod {

	new make() {
		podName = "afEfan"
		summary = "A library for rendering Embedded Fantom (efan) templates"
		version = Version([1,0,0])

		meta	= [	"org.name"		: "Alien-Factory",
					"org.uri"		: "http://www.alienfactory.co.uk/",
					"vcs.uri"		: "https://bitbucket.org/AlienFactory/afefan",
					"proj.name"		: "AF-Efan",
					"license.name"	: "BSD 2-Clause License",
					"repo.private"	: "false"	// Eeek!
				]

		// TODO: remove concurrent once afPlastic is split out
		depends = ["sys 1.0", "compiler 1.0", "concurrent 1.0"]
		srcDirs = [`test/unit-tests/`, `test/unit-tests/plastic/`, `fan/`, `fan/public/`, `fan/plastic/`, `fan/internal/`, `fan/internal/utils/`]
		resDirs = [`doc/`]

		docApi = true
		docSrc = true
		
		// exclude test code when building the pod - this means we can have public test classes!
		srcDirs = srcDirs.exclude { it.toStr.startsWith("test/") }
	}
}
