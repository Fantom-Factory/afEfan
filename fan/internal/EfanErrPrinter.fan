using afIoc::Inject
using afIoc::SrcErrLocation
using afBedSheet::Config
using web::WebOutStream

internal const class EfanErrPrinter {
	
	@Inject	@Config { id="afBedSheet.efan.linesOfSrcCodePadding" } 	
	private const Int linesOfSrcCodePadding
	
	new make(|This|in) { in(this) }
	
	Void printHtml(WebOutStream out, Err? err) {
		if (err != null && err is EfanParserErr) 
			printHtmlErr(out, "Efan Parser Err", ((EfanParserErr) err).srcErrLoc)

		if (err != null && err is EfanCompilationErr) 
			printHtmlErr(out, "Efan Compilation Err", ((EfanCompilationErr) err).srcErrLoc)		
	}

	Void printHtmlErr(WebOutStream out, Str title, SrcErrLocation srcErrLoc) {
		out.h2.w(title).h2End
		
		out.p.w(srcErrLoc.srcLocation).w(" : Line ${srcErrLoc.errLineNo}").br
		out.w("&nbsp&nbsp;-&nbsp;").writeXml(srcErrLoc.errMsg).pEnd
		
		out.div("class=\"srcLoc\"")
		out.table
		srcErrLoc.srcCodeSnippetMap(linesOfSrcCodePadding).each |src, line| {
			if (line == srcErrLoc.errLineNo) { out.tr("class=\"errLine\"") } else { out.tr }
			out.td.w(line).tdEnd.td.w(src.toXml).tdEnd
			out.trEnd
		}
		out.tableEnd
		out.divEnd
	}

	Void printStr(StrBuf buf, Err? err) {
		if (err != null && err is EfanParserErr) 
			printStrErr(buf, "Efan Parser Err", ((EfanParserErr) err).srcErrLoc)

		if (err != null && err is EfanCompilationErr) 
			printStrErr(buf, "Efan Compilation Err", ((EfanCompilationErr) err).srcErrLoc)		
	}	

	Void printStrErr(StrBuf buf, Str title, SrcErrLocation srcErrLoc) {
		buf.add("\n${title}:\n")
		buf.add(srcErrLoc.srcCodeSnippet(linesOfSrcCodePadding))		
	}

}
