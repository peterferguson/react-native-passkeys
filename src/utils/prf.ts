import { base64URLStringToBuffer } from './base64'
import type {
	PublicKeyCredentialCreationOptionsJSON,
	PublicKeyCredentialRequestOptionsJSON
} from '../ReactNativePasskeys.types'

export function normalizePRFInputs(request: PublicKeyCredentialCreationOptionsJSON | PublicKeyCredentialRequestOptionsJSON) {
	const { prf } = request.extensions ?? {}

	if (!prf) {
		return
	}

	if (!prf.eval) {
		return {}
	}

	return {
		eval: {
			first: base64URLStringToBuffer(prf.eval.first),
			second: prf.eval.second ? base64URLStringToBuffer(prf.eval?.second) : undefined
		}
	}
}