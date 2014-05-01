using build

class Build : BuildPod {

	new make() {
		podName = "afEfan"
		summary = "A library for rendering Embedded Fantom (efan) templates"
		version = Version("1.3.8")

		meta = [	
			"org.name"		: "Alien-Factory",
			"org.uri"		: "http://www.alienfactory.co.uk/",
			"proj.name"		: "efan",
			"proj.uri"		: "http://www.fantomfactory.org/pods/afEfan",
			"vcs.uri"		: "https://bitbucket.org/AlienFactory/afefan",
			"license.name"	: "The MIT Licence",
			"repo.private"	: "false"
		]

		depends = [
			"sys 1.0", 
			"concurrent 1.0", 

			"afPlastic 1.0.10+"
		]

		srcDirs = [`test/unit-tests/`, `fan/`, `fan/public/`, `fan/internal/`, `fan/internal/utils/`]
		resDirs = [`licence.txt`, `doc/`]

		docApi = true
		docSrc = true
	}
	
	@Target { help = "Compile to pod file and associated natives" }
	override Void compile() {
		// see "stripTest" in `/etc/build/config.props` to exclude test src & res dirs
		super.compile
		
		destDir := Env.cur.homeDir.plus(`src/${podName}/`)
		destDir.delete
		destDir.create		
		`fan/`.toFile.copyInto(destDir)
		
		log.indent
		log.info("Copied `fan/` to ${destDir.normalize}")
		log.unindent
	}	
}
