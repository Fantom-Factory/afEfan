using build::BuildPod

class Build : BuildPod {

	new make() {
		podName = "afEfan"
		summary = "Embedded Fantom (efan) Templates"
		version = Version([0,0,1])

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

		depends = ["sys 1.0",  
					"afIoc 1.3+", "afBedSheet 1.0+"]
		srcDirs = [`test/unit-tests/`, `fan/`, `fan/public/`, `fan/internal/`]
		resDirs = [`doc/`]

		docApi = true
		docSrc = true
	}
}
