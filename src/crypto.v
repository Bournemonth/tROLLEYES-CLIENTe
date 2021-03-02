module main

import rand
import crypto.rand as crypto_rand
import encoding.base64

pub const max_safe_unsigned_integer = u32(4_294_967_295)

pub fn set_rand_crypto_safe_seed() {
	first_seed := generate_crypto_safe_int_u32()
	second_seed := generate_crypto_safe_int_u32()

	rand.seed([first_seed, second_seed])
}

pub fn 