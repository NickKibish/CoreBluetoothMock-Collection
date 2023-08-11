//
//  File.swift
//  
//
//  Created by Nick Kibysh on 07/08/2023.
//

import Foundation

extension Data {
    func read<R: FixedWidthInteger>(offset: Int = 0) -> R {
        let length = MemoryLayout<R>.size
        assert(offset + length <= count, "Out of range")
        return subdata(in: offset ..< offset + length).withUnsafeBytes { $0.load(as: R.self) }
    }

    func appendedValue<R: FixedWidthInteger>(_ value: R) -> Data {
        var value = value
        let d = Data(bytes: &value, count: MemoryLayout<R>.size)
        return self + d
    }
}
