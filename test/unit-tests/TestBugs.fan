
internal class TestBugs : EfanTest {
	
	// found in Dekxa 
	Void testUtf8() {
		temp := """<footer class="fatFooter hidden-print"><%# %><div class="quote">'Self correction begins with self-knowledge' - Balthasar Gracián</div><%# %></footer>"""
		text := efan.renderFromStr(temp, null)
		verify(text.contains("Gracián"))
	}

	Void testDebugNull() {
		// Yes! Debugging caused an Err! Brilliant!
		typeof.pod.log.level = LogLevel.debug
		
		temp := """ctx = <%= ctx %>"""
		text := efan.renderFromStr(temp, null)
		verifyEq(text, "ctx = null")
		
		typeof.pod.log.level = LogLevel.info
	}
}
