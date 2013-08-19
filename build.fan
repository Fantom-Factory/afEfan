using build::BuildPod

class Build : BuildPod {

	new make() {
		podName = "afEfan"
//		summary = "A library for rendering Embedded Fantom (efan) templates"
		summary = "A library for integrating Embedded Fantom (efan) templates with the afBedSheet web framework."
		version = Version([0,0,5])

		meta	= [	"org.name"		: "Alien-Factory",
					"org.uri"		: "http://www.alienfactory.co.uk/",
					"vcs.uri"		: "https://bitbucket.org/AlienFactory/afefan",
					"proj.name"		: "AF-Efan",
					"license.name"	: "BSD 2-Clause License",
					"repo.private"	: "true",
			
					"afIoc.module"	: "afEfan::EfanModule"			
				]

		index	= [	"afIoc.module"	: "afEfan::EfanModule"
				]

		// TODO: remove web & bedsheet once we break efan in two
		depends = ["sys 1.0", "compiler 1.0", "web 1.0", "afBedSheet 1.0+",
					"afIoc 1.4.4+"]
		srcDirs = [`test/unit-tests/`, `fan/`, `fan/public/`, `fan/internal/`, `fan/internal/utils/`]
		resDirs = [`doc/`]

		docApi = true
		docSrc = true
		
		// exclude test code when building the pod - this means we can have public test classes!
		srcDirs = srcDirs.exclude { it.toStr.startsWith("test/") }
	}
}
