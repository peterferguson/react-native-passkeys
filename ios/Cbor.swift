import Foundation

enum CBORDecodeError: Error {
    case invalidData
    case unsupportedType
    case unexpectedEndOfData
}

class SimpleCBORDecoder {
    static func decode(_ data: Data) throws -> Any {
        var iterator = data.makeIterator()
        return try decodeItem(from: &iterator)
    }

    static func decode(_ bytes: [UInt8]) throws -> Any {
        var iterator = bytes.makeIterator()
        return try decodeItem(from: &iterator)
    }

    private static func decodeItem<T: IteratorProtocol>(from iterator: inout T) throws -> Any
    where T.Element == UInt8 {
        guard let firstByte = iterator.next() else {
            throw CBORDecodeError.unexpectedEndOfData
        }

        let majorType = firstByte >> 5
        let minorBits = firstByte & 0x1F

        let decodedMinorBits = try decodeUnsignedInteger(minorBits, from: &iterator)

        switch majorType {
        case 0:  // Unsigned integer
            return decodedMinorBits
        case 1:  // Negative integer
            return -1 - Int(decodedMinorBits)
        case 2:  // Byte string
            return try decodeByteString(length: Int(decodedMinorBits), from: &iterator)
        case 3:  // Text string
            return try decodeTextString(length: Int(decodedMinorBits), from: &iterator)
        case 4:  // Array
            return try decodeArray(count: Int(decodedMinorBits), from: &iterator)
        case 5:  // Map
            return try decodeMap(count: Int(decodedMinorBits), from: &iterator)
        default:
            throw CBORDecodeError.unsupportedType
        }
    }

    private static func decodeUnsignedInteger<T: IteratorProtocol>(
        _ additionalInfo: UInt8, from iterator: inout T
    ) throws -> UInt64 where T.Element == UInt8 {
        switch additionalInfo {
        case 0...23:
            return UInt64(additionalInfo)
        case 24:
            guard let byte = iterator.next() else { throw CBORDecodeError.unexpectedEndOfData }
            return UInt64(byte)
        case 25:
            guard let byte1 = iterator.next(), let byte2 = iterator.next() else {
                throw CBORDecodeError.unexpectedEndOfData
            }
            return UInt64(byte1) << 8 | UInt64(byte2)
        case 26:
            guard let byte1 = iterator.next(), let byte2 = iterator.next(),
                let byte3 = iterator.next(), let byte4 = iterator.next()
            else { throw CBORDecodeError.unexpectedEndOfData }
            return UInt64(byte1) << 24 | UInt64(byte2) << 16 | UInt64(byte3) << 8 | UInt64(byte4)
        case 27:
            guard let byte1 = iterator.next(), let byte2 = iterator.next(),
                let byte3 = iterator.next(), let byte4 = iterator.next(),
                let byte5 = iterator.next(), let byte6 = iterator.next(),
                let byte7 = iterator.next(), let byte8 = iterator.next()
            else { throw CBORDecodeError.unexpectedEndOfData }
            return UInt64(byte1) << 56 | UInt64(byte2) << 48 | UInt64(byte3) << 40 | UInt64(byte4)
                << 32 | UInt64(byte5) << 24 | UInt64(byte6) << 16 | UInt64(byte7) << 8
                | UInt64(byte8)
        default:
            throw CBORDecodeError.unsupportedType
        }
    }

    private static func decodeByteString<T: IteratorProtocol>(length: Int, from iterator: inout T)
        throws -> Data where T.Element == UInt8
    {
        var bytes = [UInt8]()
        for _ in 0..<length {
            guard let byte = iterator.next() else { throw CBORDecodeError.unexpectedEndOfData }
            bytes.append(byte)
        }
        return Data(bytes)
    }

    private static func decodeTextString<T: IteratorProtocol>(length: Int, from iterator: inout T)
        throws -> String where T.Element == UInt8
    {
        let data = try decodeByteString(length: length, from: &iterator)
        guard let string = String(data: data, encoding: .utf8) else {
            throw CBORDecodeError.invalidData
        }
        return string
    }

    private static func decodeArray<T: IteratorProtocol>(count: Int, from iterator: inout T) throws
        -> [Any] where T.Element == UInt8
    {
        var array = [Any]()
        for _ in 0..<count {
            let item = try decodeItem(from: &iterator)
            array.append(item)
        }
        return array
    }

    private static func decodeMap<T: IteratorProtocol>(
        count: Int, from iterator: inout T
    ) throws -> [AnyHashable: Any] where T.Element == UInt8 {
        var map = [AnyHashable: Any]()
        for _ in 0..<count {
            let key = try decodeItem(from: &iterator)
            let value = try decodeItem(from: &iterator)
            if let hashableKey = makeHashable(key) {
                map[hashableKey] = value
            } else {
                throw CBORDecodeError.invalidData
            }
        }
        return map
    }

    private static func makeHashable(_ item: Any) -> AnyHashable? {
        if let string = item as? String {
            return AnyHashable(string)
        } else if let int = item as? Int {
            return AnyHashable(int)
        } else if let uint = item as? UInt {
            return AnyHashable(uint)
        } else if let int64 = item as? Int64 {
            return AnyHashable(int64)
        } else if let uint64 = item as? UInt64 {
            return AnyHashable(uint64)
        } else if let double = item as? Double {
            return AnyHashable(double)
        } else if let bool = item as? Bool {
            return AnyHashable(bool)
        }
        return nil
    }
}
