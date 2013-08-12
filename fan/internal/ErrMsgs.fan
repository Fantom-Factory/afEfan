
internal class ErrMsgs {

	static Str parserBlockInBlockNotAllowed(BlockType blockTypeOuter, BlockType blockTypeInner) {
		"${blockTypeInner.name.toDisplayName} blocks are not allowed inside ${blockTypeOuter.name.toDisplayName} blocks."
	}

	static Str parserBlockNotClosed(BlockType blockType) {
		"${blockType.name.toDisplayName} block not closed."
	}
	
}
