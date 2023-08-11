//
//  File.swift
//  
//
//  Created by Nick Kibysh on 04/08/2023.
//

import Foundation

// FixedWidthInteger

struct DataConverter {
    static func toData<T: FixedWidthInteger>(_ value: T) -> Data {
        var v = value
        return Data(bytes: &v, count: MemoryLayout<T>.size)
    }
}
