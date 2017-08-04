//
//  GlucoseMeasurement.swift
//  Pods
//
//  Created by Kevin Tallevi on 7/12/16.
//
//

import Foundation
import CCBluetooth
import CCToolbox

// note: enums that are exported to objc cannot be nicely printed, so we have to add a description

@objc public enum SampleType : Int {
    case reserved = 0,
    capillaryWholeBlood,
    capillaryPlasma,
    venousWholeBlood,
    venousPlasma,
    arterialWholeBlood,
    arterialPlasma,
    undeterminedWholeBlood,
    undeterminedPlasma,
    interstitialFluid,
    controlSolution
    
    public var description : String {
        switch self {
        case .reserved: return "Reserved"
        case .capillaryWholeBlood: return "Capillary Whole Blood"
        case .capillaryPlasma: return "Capillary Plasma"
        case .venousWholeBlood: return "Venous Whole Blood"
        case .venousPlasma: return "Venous Plasma"
        case .arterialWholeBlood: return "Arterial Whole Blood"
        case .arterialPlasma: return "Arterial Plasma"
        case .undeterminedWholeBlood: return "Undetermined Whole Blood"
        case .undeterminedPlasma: return "Undetermined Plasma"
        case .interstitialFluid: return "Intersitial Fluid"
        case .controlSolution: return "Control Solution"
        }
    }
}

@objc public enum SampleLocation : Int {
    case reserved = 0,
    finger,
    alternateSiteTest,
    earlobe,
    controlSolution,
    notAvailable

    public var description : String {
        switch self {
        case .reserved: return "Reserved"
        case .finger: return "Finger"
        case .alternateSiteTest: return "Alternate Site Test"
        case .earlobe: return "Earlobe"
        case .controlSolution: return "Control Solution"
        case .notAvailable: return "Not Available"
        }
    }
}

@objc public enum GlucoseConcentrationUnits : Int, CustomStringConvertible {
    case kgL = 0,
    molL
    
    public var description : String {
        switch self {
        case .kgL: return NSLocalizedString("kg/L", comment: "concentration unit")
        case .molL: return NSLocalizedString("mol/L", comment: "concentration unit")
        }
    }
}

public class GlucoseMeasurement : NSObject {
    public var packetData: NSData!
    public var sequenceNumber: UInt16!
    public var dateTime: Date?
    public var timeOffset: Int16!
    public var glucoseConcentration: Float!
    public var unit : String!
    public var sampleType: SampleType?
    public var sampleLocation: SampleLocation?
    public var context: GlucoseMeasurementContext?
    var bluetoothDateTime: BluetoothDateTime!
    
    let flagsRange = NSRange(location:0, length: 1)
    let sequenceNumberRange = NSRange(location:1, length: 2)
    let dateTimeRange = NSRange(location:3, length: 7)
    
    //publicly accessible flag
    public var contextInformationFollows: Bool!
    
    // the following methods have been added to allow access optional types (e.g. Int, Float, Bool)
    // that have no equivalent in objective-c. They can be removed once we no longer require objective-c compatibility
    
    @objc public var objc_sampleType: SampleType {
        if let sampleType = self.sampleType {
            return sampleType
        }
        return .undeterminedWholeBlood
    }
    
    @objc public var objc_sampleLocation: SampleLocation {
        if let sampleLocation = self.sampleLocation {
            return sampleLocation
        }
        return .notAvailable
    }
    
    //Sensor Status Annunciations
    public var deviceBatteryLowAtTimeOfMeasurement: Bool!
    public var sensorMalfunctionOrFaultingAtTimeOfMeasurement: Bool!
    public var sampleSizeForBloodOrControlSolutionInsufficientAtTimeOfMeasurement: Bool!
    public var stripInsertionError: Bool!
    public var stripTypeIncorrectForDevice: Bool!
    public var sensorResultHigherThanTheDeviceCanProcess: Bool!
    public var sensorResultLowerThanTheDeviceCanProcess: Bool!
    public var sensorTemperatureTooHighForValidTest: Bool!
    public var sensorTemperatureTooLowForValidTest: Bool!
    public var sensorReadInterruptedBecauseStripWasPulledTooSoon: Bool!
    public var generalDeviceFault: Bool!
    public var timeFaultHasOccurred: Bool!

    enum indexOffsets: Int {
        case flags = 0,
        sequenceNumber = 1,
        dateTime = 3,
        timeOffset = 10,
        glucoseConcentration = 12,
        typeLocation = 14,
        annunciation
    }
    
    struct Flag {
        var position: Int?
        var value: Int?
        var dataLength: Int?
    }
    var flags: [Flag] = []
    
    enum FlagBytes: Int {
        case timeOffsetPresent, glucoseConcentrationTypeAndSampleLocationPresent, glucoseConcentrationUnits, sensorStatusAnnunciationPresent, contextInformationFollows, count
    }
    
    func parseFlags() {
        let flagsData = packetData.subdata(with: flagsRange) as NSData!
        let flagsString = flagsData?.toHexString()
        let flagsByte = Int(strtoul(flagsString, nil, 16))
        print("flags byte: \(flagsByte)")
        
        self.flags.append(Flag(position: FlagBytes.timeOffsetPresent.rawValue, value: flagsByte.bit(0), dataLength: 2))
        self.flags.append(Flag(position: FlagBytes.glucoseConcentrationTypeAndSampleLocationPresent.rawValue, value: flagsByte.bit(1), dataLength: 3))
        self.flags.append(Flag(position: FlagBytes.sensorStatusAnnunciationPresent.rawValue, value: flagsByte.bit(3), dataLength: 1))
        self.flags.append(Flag(position: FlagBytes.contextInformationFollows.rawValue, value: flagsByte.bit(4), dataLength: 1))
        
        self.unit = (GlucoseConcentrationUnits(rawValue: flagsByte.bit(2))?.description)!
        self.contextInformationFollows = flagsByte.bit(4).toBool()!
    }
    
    func getOffset(max: Int) -> Int {
        //first 10 bytes are mandatory
        var offset: Int = 9
        
        for flag in flags {
            offset += flag.dataLength!
        }
        
        if offset >= max {
            return max
        }
        
        return offset
    }
    
    func flagPresent(flagByte: Int) -> Int {
        for flag in flags {
            if flag.position == flagByte {
                return flag.value!
            }
        }
        
        return 0
    }
    
    func parseSequenceNumber() -> UInt16 {
        let sequenceNumberData: NSData! = packetData.subdata(with: sequenceNumberRange) as NSData!
        let swappedSequenceNumberData = sequenceNumberData.swapUInt16Data().toHexString()
        let sequenceNumber = UInt16(strtoul(swappedSequenceNumberData, nil, 16))
        print("sequenceNumber: \(sequenceNumber)")
        
        return sequenceNumber
    }
    
    func parseDateTime() -> Date {
        let dateTimeData = packetData.subdata(with: dateTimeRange) as NSData!
        print("parseDateTime: \(String(describing: dateTimeData))")
        let dateTimeResult = bluetoothDateTime.dateFromData(data: dateTimeData!)
        print("measurement date: \(String(describing: dateTimeResult))")
        
        return dateTimeResult
    }
    
    public init(data: NSData?) {
        super.init()
        print("GlucoseMeasurement#init - \(String(describing: data))")
        self.packetData = data
        
        self.bluetoothDateTime = BluetoothDateTime()
        
        parseFlags()
        self.sequenceNumber = parseSequenceNumber()
        self.dateTime = parseDateTime()
        if self.flagPresent(flagByte: FlagBytes.timeOffsetPresent.rawValue).toBool()! {
            self.timeOffset = parseTimeOffset()
            applyTimeOffset()
        }
        
        if self.flagPresent(flagByte: FlagBytes.glucoseConcentrationTypeAndSampleLocationPresent.rawValue).toBool()! {
            glucoseConcentration = parseGlucoseConcentration()
            parseSampleLocationAndType()
        }
        
        if self.flagPresent(flagByte: FlagBytes.sensorStatusAnnunciationPresent.rawValue).toBool()! {
            parseSensorStatusAnnunciation()
        }
    }
    
    func parseTimeOffset() -> Int16 {
        let offset: Int = getOffset(max: indexOffsets.timeOffset.rawValue)
        print("parseTimeOffset - offset: \(offset)")
        
        let timeBytes = packetData.subdata(with: NSRange(location:offset, length: 2)) as NSData!
        let timeOffset: Int16 = timeBytes!.readInteger(0);
        print("timeOffset (minutes): \(timeOffset)")
        
        return timeOffset
    }
    
    func applyTimeOffset() {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        
        let offsetDateComponents = NSDateComponents()
        offsetDateComponents.minute = Int(self.timeOffset)
        let offsetDate = calendar.date(byAdding: offsetDateComponents as DateComponents, to: self.dateTime!)
        print("offsetDate: \(String(describing: offsetDate))")
        
        self.dateTime = offsetDate
    }
    
    func parseGlucoseConcentration() -> Float{
        let offset: Int = getOffset(max: indexOffsets.glucoseConcentration.rawValue)
        print("parseGlucoseConcentration - offset: \(offset)")
        
        let concentrationData = packetData.subdata(with: NSRange(location:offset, length: 2)) as NSData!
        print("glucoseConcentration: \(String(describing: concentrationData?.shortFloatToFloat()))")
        
        return concentrationData!.shortFloatToFloat()
    }
    
    func parseSampleLocationAndType() {
        let offset: Int = getOffset(max: indexOffsets.typeLocation.rawValue)
        print("parseSampleLocationAndType - offset: \(offset)")
        
        let sampleLocationAndDataTypeData = packetData.subdata(with: NSRange(location:offset, length: 1)) as NSData!
        print("sampleLocationAndDataTypeData: \(String(describing: sampleLocationAndDataTypeData))")
        
        let type = sampleLocationAndDataTypeData?.lowNibbleAtPosition()
        let location = sampleLocationAndDataTypeData?.highNibbleAtPosition()
        
        self.sampleType = SampleType(rawValue: type!)
        print("type: \(String(describing: self.sampleType!.description))")
        
        if(location! > 4) {
            print("sample location is reserved for future use")
            self.sampleLocation = .reserved
        } else {
            self.sampleLocation = SampleLocation(rawValue: location!)
            print("sample location: \(String(describing: self.sampleLocation?.description))")
        }
    }
    
    func parseSensorStatusAnnunciation() {
        let offset: Int = getOffset(max: indexOffsets.annunciation.rawValue)
        print("parseSensorStatusAnnunciation - offset: \(offset)")
        
        let sensorStatusAnnunciationData = packetData.subdata(with: NSRange(location:offset, length: 2)) as NSData!
        
        let sensorStatusAnnunciationString = sensorStatusAnnunciationData?.toHexString()
        let sensorStatusAnnunciationBytes = Int(strtoul(sensorStatusAnnunciationString, nil, 16))
        print("sensorStatusAnnunciation bytes: \(sensorStatusAnnunciationBytes)")
        
        deviceBatteryLowAtTimeOfMeasurement = sensorStatusAnnunciationBytes.bit(0).toBool()!
        sensorMalfunctionOrFaultingAtTimeOfMeasurement = sensorStatusAnnunciationBytes.bit(1).toBool()!
        sampleSizeForBloodOrControlSolutionInsufficientAtTimeOfMeasurement = sensorStatusAnnunciationBytes.bit(2).toBool()!
        stripInsertionError = sensorStatusAnnunciationBytes.bit(3).toBool()!
        stripTypeIncorrectForDevice = sensorStatusAnnunciationBytes.bit(4).toBool()!
        sensorResultHigherThanTheDeviceCanProcess = sensorStatusAnnunciationBytes.bit(5).toBool()!
        sensorResultLowerThanTheDeviceCanProcess = sensorStatusAnnunciationBytes.bit(6).toBool()!
        sensorTemperatureTooHighForValidTest = sensorStatusAnnunciationBytes.bit(7).toBool()!
        sensorTemperatureTooLowForValidTest = sensorStatusAnnunciationBytes.bit(8).toBool()!
        sensorReadInterruptedBecauseStripWasPulledTooSoon = sensorStatusAnnunciationBytes.bit(9).toBool()!
        generalDeviceFault = sensorStatusAnnunciationBytes.bit(10).toBool()!
        timeFaultHasOccurred = sensorStatusAnnunciationBytes.bit(11).toBool()!
    }
    
    public func toMMOL() -> Float? {
        return ((self.glucoseConcentration * 100000) / 18);
    }
}
