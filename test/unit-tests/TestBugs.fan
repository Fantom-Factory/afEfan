
internal class TestBugs : EfanTest {
	
	// found in Dekxa 
	Void testUtf8() {
		temp := """<footer class="fatFooter hidden-print"><%# %><div class="quote">'Self correction begins with self-knowledge' - Balthasar Gracián</div><%# %></footer>"""
		text := efan.renderFromStr(temp, null)
		verify(text.contains("Gracián"))
	}
}
