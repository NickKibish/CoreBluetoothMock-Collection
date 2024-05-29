//
//  File.swift
//  
//
//  Created by Nick Kibysh on 26/10/2023.
//

import Foundation
import iOS_Bluetooth_Numbers_Database
import CoreBluetoothMock

public class HeartRateSensor {
    let services: [CBUUID] = [
        CBUUID(service: .heartRate),
        CBUUID(service: .deviceInformation)
    ]
}

public extension HeartRateSensor {
    enum OpCode {
        case unknown
        case resetEnergyExpended
        case updateSensorLocation
        case measurementInterval
        case enableNotifications
        case disableNotifications
    }
}

public extension HeartRateSensor {
    struct Flags: OptionSet {
        public let rawValue: UInt8
        
        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }
        
        public static let heartRate16Bit = Flags(rawValue: 1 << 0)
        public static let sensorContactStatus = Flags(rawValue: 1 << 1)
        public static let energyExtendedPresent = Flags(rawValue: 1 << 3)
        public static let rrIntervalPresent = Flags(rawValue: 1 << 4)
    }
}

public extension HeartRateSensor {
    struct Measurement {
        let flags: Flags
        let heartRate: UInt16
        let energyExtended: UInt16?
        let rrIntervals: UInt16?
        let transmissionInterval: UInt16?
        
        init(flags: Flags, heartRate: UInt16, energyExtended: UInt16?, rrIntervals: UInt16?, transmissionInterval: UInt16?) {
            self.flags = flags
            self.heartRate = heartRate
            self.energyExtended = energyExtended
            self.rrIntervals = rrIntervals
            self.transmissionInterval = transmissionInterval
        }
        
        init(data: Data) {
            var flagsValue: UInt8 = 0
            data.copyBytes(to: &flagsValue, count: 1)
            flags = Flags(rawValue: flagsValue)
            
            var offset: Int = 1
            
            if flags.contains(.heartRate16Bit) {
                let hrv: UInt16 = data.read(offset: offset)
                offset += 2
                heartRate = hrv
            } else {
                let hrv: UInt8 = data.read(offset: offset)
                offset += 1
                heartRate = UInt16(hrv)
            }
           
            // TODO: Test data sholud be found before parsing
            energyExtended = nil
            rrIntervals = nil
            transmissionInterval = nil
        }
    }
}
