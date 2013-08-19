
** Config values as used by Efan. 
** To change their value, override them in your 'AppModule'. Example:
** 
** pre>
** @Contribute { serviceType=ApplicationDefaults# } 
** static Void configureAppDefaults(MappedConfig conf) {
** 
**   conf[EfanConfigIds.templateTimeout] = 1min
** 
** }
** <pre
const mixin EfanConfigIds {

	** The time before the file system is checked for template updates.
	** Defaults to '10sec'
	static const Str templateTimeout		:= "afBedSheet.efan.templateTimeout"

	** When printing a `EfanErr`s, this is the number of lines of code to print before and 
	** after the line in error. 
	** Defaults to '5'
	static const Str linesOfSrcCodePadding		:= "afBedSheet.efan.linesOfSrcCodePadding"

}
