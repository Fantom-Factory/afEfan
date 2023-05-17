using build

class Build : BuildPod {

	new make() {
		podName = "afEfan"
		summary = "A library for rendering Embedded Fantom templates"
		version = Version("2.0.7")

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
			"sys          1.0.69 - 1.0",
			"concurrent   1.0.69 - 1.0",

			// ---- Fantom Factory ----
			"afPlastic    1.1.6  - 1.1",
		]

		srcDirs = [`fan/`, `fan/internal/`, `fan/public/`, `test/unit-tests/`]
		resDirs = [`doc/`, `svg/`]

		meta["afBuild.uberPod"] = "afPlastic"
	}
}
