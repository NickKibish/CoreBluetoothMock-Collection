//
//  File.swift
//  
//
//  Created by Nick Kibysh on 02/08/2023.
//

import Foundation
import CoreBluetoothMock
import iOS_Bluetooth_Numbers_Database

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

extension CBMUUID {
    static let runningSpeedCadence  = CBMUUID(service: .runningSpeedAndCadence)
    
    static let rscMeasurement = CBMUUID(characteristic: .rscMeasurement)
    
    static let rscFeature = CBMUUID(characteristic: .rscFeature)
    static let sensorLocation = CBMUUID(characteristic: .sensorLocation)
    
    static let scControlPoint = CBMUUID(characteristic: .scControlPoint)
    static let clientCharacteristicConfiguration = CBMUUID(descriptor: .gattClientCharacteristicConfiguration)
}

extension CBMDescriptorMock {
    static let clientCharacteristicConfiguration = CBMDescriptorMock(type: .clientCharacteristicConfiguration)
}

extension CBMCharacteristicMock {
    static let rscMeasurement = CBMCharacteristicMock(
        type: .rscMeasurement,
        properties: .notify,
        descriptors: .clientCharacteristicConfiguration
    )
    
    static let rscFeature = CBMCharacteristicMock(
        type: .rscFeature,
        properties: .read
    )
    
    static let sensorLocation = CBMCharacteristicMock(
        type: .sensorLocation,
        properties: .read
    )
    
    static let scControlPoint = CBMCharacteristicMock(
        type: .scControlPoint,
        properties: [.write, .indicate],
        descriptors: .clientCharacteristicConfiguration
    )
}

extension CBMServiceMock {
    static let runningSpeedCadence = CBMServiceMock(
        type: .runningSpeedCadence,
        primary: true,
        characteristics: .rscMeasurement, .rscFeature, .sensorLocation, .scControlPoint
    )
}

public struct RunningSpeedAndCadence {
    public enum ErrorCode: UInt8, LocalizedError {
        case procedureAlreadyInProgress = 0x80
        case descriptorImproperlyConfigured = 0x81
        
        public var errorDescription: String? {
            switch self {
            case .procedureAlreadyInProgress:
                return "A SC Control Point request cannot be serviced because a previously triggered SC Control Point operation is still in progress."
            case .descriptorImproperlyConfigured:
                return "The Client Characteristic Configuration descriptor is not configured according to the requirements of the service."
            }
        }
    }
    
    public struct RSCFeature: OptionSet {
        public let rawValue: UInt8
        
        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }
        
        public static let instantaneousStrideLengthMeasurement = RSCFeature(rawValue: 1 << 0)
        public static let totalDistanceMeasurement             = RSCFeature(rawValue: 1 << 1)
        public static let walkingOrRunningStatus               = RSCFeature(rawValue: 1 << 2)
        public static let sensorCalibrationProcedure           = RSCFeature(rawValue: 1 << 3)
        public static let multipleSensorLocation               = RSCFeature(rawValue: 1 << 4)
        
        public static let all: RSCFeature = [.instantaneousStrideLengthMeasurement, .totalDistanceMeasurement, .walkingOrRunningStatus, .sensorCalibrationProcedure, .multipleSensorLocation]
    }

    public struct RSCMeasurementFlags: OptionSet {
        public let rawValue: UInt8
        
        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }

        public static let instantaneousStrideLengthPresent = RSCMeasurementFlags(rawValue: 1 << 0)
        public static let totalDistancePresent             = RSCMeasurementFlags(rawValue: 1 << 1)
        public static let walkingOrRunningStatus           = RSCMeasurementFlags(rawValue: 1 << 2)
        
        public static let all: RSCMeasurementFlags = [.instantaneousStrideLengthPresent, .totalDistancePresent, .walkingOrRunningStatus]
    }
    
    public enum OpCode: UInt8, CustomStringConvertible {
        case setCumulativeValue = 0x01
        case startSensorCalibration
        case updateSensorLocation
        case requestSupportedSensorLocations
        case responseCode = 0x10

        public var description: String {
            switch self {
            case .setCumulativeValue:
                return "Set Cumulative Value"
            case .startSensorCalibration:
                return "Start Sensor Calibration"
            case .updateSensorLocation:
                return "Update Sensor Location"
            case .requestSupportedSensorLocations:
                return "Request Supported Sensor Locations"
            case .responseCode:
                return "Response Code"
            }
        }
    }
    
    public enum ResponseValue: UInt8, CustomStringConvertible {
        case success = 0x01
        case opCodeNotSupported = 0x02
        case invalidParameter = 0x03
        case operationFailed = 0x04

        public var description: String {
            switch self {
            case .success:
                return "Success"
            case .opCodeNotSupported:
                return "Op Code Not Supported"
            case .invalidParameter:
                return "Invalid Parameter"
            case .operationFailed:
                return "Operation Failed"
            }
        }
    }
    
    public static let peripheral = CBMPeripheralSpec
        .simulatePeripheral(proximity: .far)
        .advertising(
            advertisementData: [
                CBAdvertisementDataIsConnectable : true as NSNumber,
                CBAdvertisementDataLocalNameKey : "Running Speed and Cadence sensor",
                CBAdvertisementDataServiceUUIDsKey : [CBMUUID.runningSpeedCadence]
            ],
            withInterval: 2.0,
            delay: 5.0,
            alsoWhenConnected: false
        )
        .connectable(
            name: "Running Sensor",
            services: [.runningSpeedCadence],
            delegate: RSCSCBMPeripheralSpecDelegate() // TODO: Change
        )
        .build()
}


/// The delegate implements the behavior of the mocked device.
private class RSCSCBMPeripheralSpecDelegate: CBMPeripheralSpecDelegate {
    let enabledFeatures: RunningSpeedAndCadence.RSCFeature = .all
    
    enum MockError: Error {
        case notifyIsNotSupported
    }
    
    private var notifyMeasurement: Bool = false {
        didSet {
            guard notifyMeasurement else {
                measurementTimer?.invalidate()
                measurementTimer = nil
                return
            }
            
            // Simulate RSCS Measurement
            measurementTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
                
            })
        }
    }
    
    weak var peripheral: CBMPeripheralSpec?
    
    private var notifySCControlPoint: Bool = false
    
    private var measurementTimer: Timer?
    
    func peripheral(_ peripheral: CBMPeripheralSpec,
                    didReceiveReadRequestFor characteristic: CBMCharacteristicMock)
    -> Result<Data, Error> {
        if characteristic.uuid == CBMUUID.rscFeature {
            return .success(Data([0xff, enabledFeatures.rawValue])) // Support all feautures
        } else if characteristic.uuid == CBMUUID.sensorLocation {
            return .success(Data([0xff]))
        } else {
            fatalError()
        }
    }
    
    func peripheral(_ peripheral: CBMPeripheralSpec,
                    didReceiveWriteRequestFor characteristic: CBMCharacteristicMock,
                    data: Data) -> Result<Void, Error> {
        
        return .success(())
    }
    
    func peripheral(_ peripheral: CBMPeripheralSpec, didReceiveSetNotifyRequest enabled: Bool, for characteristic: CBMCharacteristicMock) -> Result<Void, Error> {
        switch characteristic.uuid {
        case .rscMeasurement:
            notifyMeasurement = enabled
        case .scControlPoint:
            notifySCControlPoint = enabled
        default:
            return .failure(MockError.notifyIsNotSupported)
        }
        
        return .success(())
    }
}


