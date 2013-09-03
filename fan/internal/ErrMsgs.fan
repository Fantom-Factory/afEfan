
internal class ErrMsgs {

	static Str viewHelperMixinIsNotMixin(Type vht) {
		"View Helper type ${vht.qname} should be a mixin."
	}
	
	static Str viewHelperMixinIsConst(Type vht) {
		"View Helper mixin ${vht.qname} should NOT be const."
	}

	static Str viewHelperMixinIsNotPublic(Type vht) {
		"View Helper mixin ${vht.qname} should be public."
	}

	static Str parserBlockInBlockNotAllowed(BlockType blockTypeOuter, BlockType blockTypeInner) {
		"${blockTypeInner.name.toDisplayName} blocks are not allowed inside ${blockTypeOuter.name.toDisplayName} blocks."
	}

	static Str parserBlockNotClosed(BlockType blockType) {
		"${blockType.name.toDisplayName} block not closed."
	}

}
