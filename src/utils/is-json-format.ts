class ArrayBufferFoundError extends Error {
  constructor() {
    super("ArrayBuffer found");
    this.name = "ArrayBufferFoundError";
  }
}

/**
 * Helper to detect if input is JSON format (base64url strings) vs binary format (ArrayBuffers).
 *
 * This determines whether we can use the static method `parseCreationOptionsFromJSON`
 *
 * Uses JSON.stringify with a custom replacer to efficiently detect nested ArrayBuffers or TypedArrays.
 * Throws early when binary data is found to avoid traversing the entire object tree.
 *
 * @param input - The credential options object to check
 * @returns true if the input is in JSON format (no ArrayBuffers), false if it contains binary data
 */
export function isJSONFormat(input: unknown): boolean {
  if (typeof input !== 'object' || input === null) return true;

  try {
    JSON.stringify(input, (_key, value) => {
      if (value instanceof ArrayBuffer || ArrayBuffer.isView(value)) 
        throw new ArrayBufferFoundError();
      return value;
    });
    return true;
  } catch (e) {
    if (e instanceof ArrayBufferFoundError) return false;
    // Re-throw any other error
    throw e; 
  }
}
