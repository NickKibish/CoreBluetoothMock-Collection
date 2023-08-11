//
//  File.swift
//  
//
//  Created by Nick Kibysh on 04/08/2023.
//

import Foundation
import iOS_Bluetooth_Numbers_Database
import CoreBluetoothMock

extension CBMUUID {
    convenience init(service: Service) {
        self.init(string: service.uuidString)
    }
    
    convenience init(characteristic: Characteristic) {
        self.init(string: characteristic.uuidString)
    }
    
    convenience init(descriptor: Descriptor) {
        self.init(string: descriptor.uuidString)
    }
}
