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

	static Str rendererCtxIsNull() {
		"ctx is null - but renderer ctx type is not nullable:"
	}

	static Str rendererCtxBadFit(Type? ctxType) {
		"does not fit ctx renderer type ${ctxType?.signature}"
	}

	static Str unknownInstruction(Str instruction) {
		"Unknown processing instruction: ${instruction}"
	}

}
