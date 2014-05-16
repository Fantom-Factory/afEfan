using afPlastic::PlasticClassModel

internal class ErrMsgs {

	static Str viewHelperMixinIsNotMixin(Type vht) {
		"View Helper type ${vht.qname} should be a mixin."
	}
	
	static Str viewHelperMixinIsNotConst(Type vht) {
		"View Helper mixin ${vht.qname} should be const."
	}

	static Str viewHelperMixinIsNotPublic(Type vht) {
		"View Helper mixin ${vht.qname} should be public."
	}

	static Str parserBlockNotClosed(BlockType blockType) {
		"${blockType.name.toDisplayName} block not closed."
	}

	static Str compiler_ctxIsNull() {
		"ctx is null - but ctx type is not nullable:"
	}

	static Str compiler_ctxNoFit(Type? ctxType) {
		stripSys("does not fit ctx type ${ctxType?.signature}")
	}

	static Str unknownInstruction(Str instruction) {
		"Unknown processing instruction: ${instruction}"
	}

	private static Str stripSys(Str str) {
		str.replace("sys::", "")
	}
}
