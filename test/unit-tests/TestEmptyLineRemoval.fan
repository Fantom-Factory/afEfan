
internal class TestEmptyLineRemoval : EfanTest {

	// My unused regex: (?m)^\s*(<%[^=](?:(?!%>).)+%>)\s*$
	Void testBlankInstructionLinesAreRemoved() {
		template :=
"""--line 1--
     <%= null?.toStr %>  
   --line 2--
     <%# null?.toStr %>  
   --line 3--
     <% null?.toStr %>  
   --line 4--
     <%? using afEfan %>  
   --line 5--
     <%% null?.toStr %>  
   --line 6--
    [ <% null?.toStr %>  
   --line 7--
     <% null?.toStr %> -]
   --line 8--
     <% null?.toStr %> - <% null?.toStr %> ]
   --line 9--
     <%# null?.toStr %> - <%= null?.toStr %> ]
   --line 10--"""

		expected :=
"""--line 1--
     null  
   --line 2--
   --line 3--
   --line 4--
   --line 5--
     <% null?.toStr %>  
   --line 6--
    [   
   --line 7--
      -]
   --line 8--
      -  ]
   --line 9--
      - null ]
   --line 10--"""
		
		code := efan.render(template)
		verifyEq(expected, code)
	}

	Void testNonBlankInstructionLinesAreNotRemoved() {
		template :=
"""--line 1--
   - <%= null?.toStr %>- 
   --line 2--
   - <%# null?.toStr %>- 
   --line 3--
   - <% null?.toStr %>- 
   --line 4--
   - <%? using afEfan %>- 
   --line 5--
   - <%% null?.toStr %>- 
   --line 6--"""

		expected :=
"""--line 1--
   - null- 
   --line 2--
   - - 
   --line 3--
   - - 
   --line 4--
   - - 
   --line 5--
   - <% null?.toStr %>- 
   --line 6--"""
		
		code := efan.render(template)
		verifyEq(code, expected)
	}
		
	Void testWhitespaceIsStillPreserved() {
		template := """--line 1--  \n  <% null?.toStr %>  \n  --line 2-- """
		expected := """--line 1--  \n  --line 2-- """

		code := efan.render(template)
		verifyEq(expected, code)
	}
}
