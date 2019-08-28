using build

class Build : BuildPod {

	new make() {
		podName = "afEfan"
		summary = "A library for rendering Embedded Fantom templates"
		version = Version("2.0.0")

		meta = [
			"pod.dis"		: "efan",
			"afIoc.module"	: "afEfan::EfanModule",
			"repo.tags"		: "templating",
			"repo.public"	: "true",

			// ---- SkySpark ----
			"ext.name"		: "afEfan",
			"ext.icon"		: "afEfan",
			"ext.depends"	: "afConcurrent, afPlastic",
			"skyarc.icons"	: "true",
		]

		index	= [
			"skyarc.ext"	: "afEfan"
		]

		depends = [
			// ---- Fantom Core ----
			"sys          1.0.68 - 1.0",
			"concurrent   1.0.68 - 1.0",
			
			// ---- Fantom Factory ----
			"afConcurrent 1.0.22 - 1.0",	// use the SkySpark versions
			"afPlastic    1.1.4  - 1.1",	// use the SkySpark versions
		]

		srcDirs = [`fan/`, `fan/internal/`, `fan/public/`, `test/unit-tests/`]
		resDirs = [`doc/`, `svg/`]
	}
}
