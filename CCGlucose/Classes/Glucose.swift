//
//  Glucose.swift
//  Pods
//
//  Created by Kevin Tallevi on 7/8/16.
//
//

import Foundation
import CoreBluetooth
import CCBluetooth
import CCToolbox

var thisGlucose : Glucose?

public protocol GlucoseProtocol {
    func numberOfStoredRecords(number: UInt16)
    func glucoseMeasurement(measurement:GlucoseMeasurement)
    func glucoseMeasurementContext(measurementContext:GlucoseMeasurementContext)
    func glucoseFeatures(features:GlucoseFeatures)
    func glucoseMeterConnected(meter: CBPeripheral)
}

public protocol GlucoseMeterDiscoveryProtocol {
    func glucoseMeterDiscovered(glucoseMeter:CBPeripheral)
}

public class Glucose : NSObject {
    public var glucoseDelegate : GlucoseProtocol!
    public var glucoseMeterDiscoveryDelegate: GlucoseMeterDiscoveryProtocol!
    public var peripheral : CBPeripheral!
    public var serviceUUIDString:String = "1808"
    public var autoEnableNotifications:Bool = true
    public var allowDuplicates:Bool = false
    var peripheralName : String!
    var servicesAndCharacteristics : [String: [CBCharacteristic]] = [:]
    
    public override init() {
        super.init()
        print("Glucoser#init")
        self.configureBluetoothParameters()
    }
    
    public init(cbPeripheral:CBPeripheral!) {
        super.init()
        print("Glucoser#init[cbPeripheral]")
        self.peripheral = cbPeripheral
        self.configureBluetoothParameters()
        self.connectToGlucoseMeter(glucoseMeter: self.peripheral)
    }
    
    public init(peripheralName:String) {
        super.init()
        print("Glucose#init")
        self.peripheralName = peripheralName
        self.configureBluetoothParameters()
    }
    
    func configureBluetoothParameters() {
        Bluetooth.sharedInstance().serviceUUIDString = "1808"
        Bluetooth.sharedInstance().allowDuplicates = false
        Bluetooth.sharedInstance().autoEnableNotifications = true
        Bluetooth.sharedInstance().bluetoothDelegate = self
        Bluetooth.sharedInstance().bluetoothPeripheralDelegate = self
        Bluetooth.sharedInstance().bluetoothServiceDelegate = self
        Bluetooth.sharedInstance().bluetoothCharacteristicDelegate = self
    }

    public func connectToGlucoseMeter(glucoseMeter: CBPeripheral) {
        Bluetooth.sharedInstance().stopScanning()
        Bluetooth.sharedInstance().connectPeripheral(glucoseMeter)
    }
    
    public func disconnectGlucoseMeter() {
        Bluetooth.sharedInstance().disconnectPeripheral(self.peripheral)
    }
    
    func parseFeaturesResponse(data: NSData) {
        let glucoseFeatures = GlucoseFeatures(data: data)
        glucoseDelegate.glucoseFeatures(features: glucoseFeatures)
    }
    
    func parseRACPReponse(data:NSData) {
        print("parsing RACP response: \(data)")
        var hexString = data.toHexString()
        var hexStringHeader = hexString.subStringWithRange(0, to: 2)
        print("hexStringHeader: \(hexStringHeader)")
        
        if(hexStringHeader == numberOfStoredRecordsResponse) {
            print("numberOfStoredRecordsResponse")
            let numberOfStoredRecordsStr = data.swapUInt16Data().toHexString().subStringWithRange(4, to: 8)
            let numberOfStoredRecords = UInt16(strtoul(numberOfStoredRecordsStr, nil, 16))
            glucoseDelegate.numberOfStoredRecords(number: numberOfStoredRecords)
        }
        if(hexStringHeader == responseCode) {
            print("responseCode")
            var hexStringData = hexString.subStringWithRange(4, to: hexString.characters.count)
            print("hexStringData: \(hexStringData)")
        }
    }
    
    func parseGlucoseMeasurement(data:NSData) {
        let glucoseMeasurement = GlucoseMeasurement(data: data)
        glucoseDelegate.glucoseMeasurement(measurement: glucoseMeasurement)
    }
    
    func parseGlucoseMeasurementContext(data:NSData) {
        let glucoseMeasurementContext = GlucoseMeasurementContext(data: data)
        glucoseDelegate.glucoseMeasurementContext(measurementContext: glucoseMeasurementContext)
    }
    
    public func readNumberOfRecords() {
        print("Glucose#readNumberOfRecords")
        let data = readNumberOfStoredRecords.dataFromHexadecimalString()
        Bluetooth.sharedInstance().writeCharacteristic(self.peripheral.findCharacteristicByUUID(recordAccessControlPointCharacteristic)!, data: data! as Data)
    }
    
    public func downloadAllRecords() {
        print("Glucose#downloadAllRecords")
        let data = readAllStoredRecords.dataFromHexadecimalString()
        Bluetooth.sharedInstance().writeCharacteristic(self.peripheral.findCharacteristicByUUID(recordAccessControlPointCharacteristic)!, data: data! as Data)
    }
    
    public func downloadRecordNumber(recordNumber: Int) {
        let commandPrefix = "010401"
        var recordNumberInt = recordNumber
        let recordNumberData = NSData(bytes: &recordNumberInt, length: MemoryLayout<UInt16>.size)
        var recordNumberHex = String(recordNumberData.toHexString())
        
        let command = commandPrefix +
            (recordNumberHex?.subStringWithRange(0, to: 2))! +
            (recordNumberHex?.subStringWithRange(2, to: 4))! +
            (recordNumberHex?.subStringWithRange(0, to: 2))! +
            (recordNumberHex?.subStringWithRange(2, to: 4))!
        
        print("command: \(command)")
        let commandData = command.dataFromHexadecimalString()
        Bluetooth.sharedInstance().writeCharacteristic(self.peripheral.findCharacteristicByUUID(recordAccessControlPointCharacteristic)!, data: commandData! as Data)
    }
    
    public func downloadRecordsWithRange(from: Int , to: Int) {
        let commandPrefix = "010401"
        var recordNumberFromInt = from
        let recordNumberFromData = NSData(bytes: &recordNumberFromInt, length: MemoryLayout<UInt16>.size)
        var recordNumberFromHex = String(recordNumberFromData.toHexString())
        
        var recordNumberToInt = to
        let recordNumberToData = NSData(bytes: &recordNumberToInt, length: MemoryLayout<UInt16>.size)
        var recordNumberToHex = String(recordNumberToData.toHexString())
        
        let command = commandPrefix +
            (recordNumberFromHex?.subStringWithRange(0, to: 2))! +
            (recordNumberFromHex?.subStringWithRange(2, to: 4))! +
            (recordNumberToHex?.subStringWithRange(0, to: 2))! +
            (recordNumberToHex?.subStringWithRange(2, to: 4))!
        
        print("command: \(command)")
        let commandData = command.dataFromHexadecimalString()
        Bluetooth.sharedInstance().writeCharacteristic(self.peripheral.findCharacteristicByUUID(recordAccessControlPointCharacteristic)!, data: commandData! as Data)
    }
    
    public func downloadRecordsGreaterThanAndEqualTo(recordNumber: Int) {
        let commandPrefix = "010301"
        var recordNumberInt = recordNumber
        let recordNumberData = NSData(bytes: &recordNumberInt, length: MemoryLayout<UInt16>.size)
        var recordNumberHex = String(recordNumberData.toHexString())
        
        let command = commandPrefix +
            (recordNumberHex?.subStringWithRange(0, to: 2))! +
            (recordNumberHex?.subStringWithRange(2, to: 4))!

        print("command: \(command)")
        let commandData = command.dataFromHexadecimalString()
        Bluetooth.sharedInstance().writeCharacteristic(self.peripheral.findCharacteristicByUUID(recordAccessControlPointCharacteristic)!, data: commandData! as Data)
    }
    
    public func downloadRecordsLessThanAndEqualTo(recordNumber: Int) {
        let commandPrefix = "010201"
        var recordNumberInt = recordNumber
        let recordNumberData = NSData(bytes: &recordNumberInt, length: MemoryLayout<UInt16>.size)
        var recordNumberHex = String(recordNumberData.toHexString())
        
        let command = commandPrefix +
            (recordNumberHex?.subStringWithRange(0, to: 2))! +
            (recordNumberHex?.subStringWithRange(2, to: 4))!
        
        print("command: \(command)")
        let commandData = command.dataFromHexadecimalString()
        Bluetooth.sharedInstance().writeCharacteristic(self.peripheral.findCharacteristicByUUID(recordAccessControlPointCharacteristic)!, data: commandData! as Data)
    }
    
    public func downloadFirstRecord() {
        let command = "0105"
        print("command: \(command)")
        let commandData = command.dataFromHexadecimalString()
        Bluetooth.sharedInstance().writeCharacteristic(self.peripheral.findCharacteristicByUUID(recordAccessControlPointCharacteristic)!, data: commandData! as Data)
    }
    
    public func downloadLastRecord() {
        let command = "0106"
        print("command: \(command)")
        let commandData = command.dataFromHexadecimalString()
        Bluetooth.sharedInstance().writeCharacteristic(self.peripheral.findCharacteristicByUUID(recordAccessControlPointCharacteristic)!, data: commandData! as Data)
    }
    
    public func readGlucoseFeatures() {
        print("Glucose#readGlucoseFeatures")
        Bluetooth.sharedInstance().readCharacteristic(self.peripheral.findCharacteristicByUUID(glucoseFeatureCharacteristic)!)
    }
}

extension Glucose: BluetoothProtocol {
    public func bluetoothIsAvailable() {
        if(self.peripheral != nil) {
            Bluetooth.sharedInstance().connectPeripheral(self.peripheral)
        } else {
            Bluetooth.sharedInstance().startScanning(self.allowDuplicates)
        }
    }
    
    public func bluetoothIsUnavailable() {
        
    }
    
    public func bluetoothError(_ error:Error?) {
        
    }
}

extension Glucose: BluetoothPeripheralProtocol {
    public func didDiscoverPeripheral(_ cbPeripheral:CBPeripheral) {
        print("Glucose#didDiscoverPeripheral")
        if(self.peripheralName != nil) {
            if(cbPeripheral.name == self.peripheralName) {
                self.peripheral = cbPeripheral
                Bluetooth.sharedInstance().connectPeripheral(self.peripheral)
            }
        } else if(self.peripheral != nil) {
            Bluetooth.sharedInstance().connectPeripheral(self.peripheral)
        } else {
            glucoseMeterDiscoveryDelegate.glucoseMeterDiscovered(glucoseMeter: cbPeripheral)
        }
    }
    
    public func didConnectPeripheral(_ cbPeripheral:CBPeripheral) {
        print("Glucose#didConnectPeripheral")
        self.peripheral = cbPeripheral
        glucoseDelegate.glucoseMeterConnected(meter: cbPeripheral)
        
        Bluetooth.sharedInstance().discoverAllServices(cbPeripheral)
    }
}

extension Glucose: BluetoothServiceProtocol {
    public func didDiscoverService(_ service:CBService) {
        print("Glucose#didDiscoverService")
    }
     
    public func didDiscoverServiceWithCharacteristics(_ service:CBService) {
        print("Glucose#didDiscoverServiceWithCharacteristics")
        servicesAndCharacteristics[service.uuid.uuidString] = service.characteristics
    }
}

extension Glucose: BluetoothCharacteristicProtocol {
    public func didUpdateValueForCharacteristic(_ cbPeripheral: CBPeripheral, characteristic: CBCharacteristic) {
       print("Glucose#didUpdateValueForCharacteristic: \(characteristic) value:\(characteristic.value)")
        if(characteristic.uuid.uuidString == glucoseFeatureCharacteristic) {
            self.parseFeaturesResponse(data: characteristic.value! as NSData)
        }
        if(characteristic.uuid.uuidString == recordAccessControlPointCharacteristic) {
            self.parseRACPReponse(data: characteristic.value! as NSData)
        }
        if(characteristic.uuid.uuidString == glucoseMeasurementCharacteristic) {
            self.parseGlucoseMeasurement(data: characteristic.value! as NSData)
        }
        if(characteristic.uuid.uuidString == glucoseMeasurementContextCharacteristic) {
            self.parseGlucoseMeasurementContext(data: characteristic.value! as NSData)
        }
    }
    
    public func didUpdateNotificationStateFor(_ characteristic:CBCharacteristic) {
        print("Glucose#didUpdateNotificationStateFor")
        if(characteristic.uuid.uuidString == recordAccessControlPointCharacteristic) {
            readNumberOfRecords()
        }
    }
    
    public func didWriteValueForCharacteristic(_ cbPeripheral: CBPeripheral, didWriteValueFor descriptor:CBDescriptor) {
        
    }
}