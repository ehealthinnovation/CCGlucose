//
//  GlucoseMeasurement.swift
//  Pods
//
//  Created by Kevin Tallevi on 7/12/16.
//
//

import Foundation

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
    //raw data
    let data: NSData
    var indexCounter: Int = 0
    
    public var sequenceNumber: UInt16
    public var dateTime: Date?
    public var timeOffset: Int16
    public var glucoseConcentration: Float
    public var unit : GlucoseConcentrationUnits
    public var sampleType: SampleType?
    public var sampleLocation: SampleLocation?
    
    //flags
    var timeOffsetPresent: Bool
    var glucoseConcentrationTypeAndSampleLocationPresent: Bool
    var sensorStatusAnnunciationPresent: Bool
    public var contextInformationFollows: Bool
    
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
    public var deviceBatteryLowAtTimeOfMeasurement: Bool
    public var sensorMalfunctionOrFaultingAtTimeOfMeasurement: Bool
    public var sampleSizeForBloodOrControlSolutionInsufficientAtTimeOfMeasurement: Bool
    public var stripInsertionError: Bool
    public var stripTypeIncorrectForDevice: Bool
    public var sensorResultHigherThanTheDeviceCanProcess: Bool
    public var sensorResultLowerThanTheDeviceCanProcess: Bool
    public var sensorTemperatureTooHighForValidTest: Bool
    public var sensorTemperatureTooLowForValidTest: Bool
    public var sensorReadInterruptedBecauseStripWasPulledTooSoon: Bool
    public var generalDeviceFault: Bool
    public var timeFaultHasOccurred: Bool

    class func parseSequenceNumber(data: NSData) -> UInt16 {
        let index = 1
        let sequenceNumberData = data.dataRange(index, Length: 2)
        let swappedSequenceNumberData = sequenceNumberData.swapUInt16Data()
        let swappedSequenceNumberString = swappedSequenceNumberData.toHexString()
        let sequenceNumber = UInt16(strtoul(swappedSequenceNumberString, nil, 16))
        print("sequenceNumber: \(sequenceNumber)")
        return sequenceNumber
    }
    
    class func extractFlags(data: NSData) -> Int {
        let index = 0
        let flagsData = data.dataRange(index, Length: 1)
        let flagsString = flagsData.toHexString()
        let flagsByte = Int(strtoul(flagsString, nil, 16))
        print("flags byte: \(flagsByte)")
        return flagsByte
    }
    
    class func extractBit(bit: Int, byte: Int) -> Bool {
        if let value = byte.bit(bit).toBool() {
            return value
        }
        print("Unable to parse byte: \(byte)")
        return false
    }

    class func parseUnits(byte: Int) -> GlucoseConcentrationUnits {
        let raw = byte.bit(2)
        if let unit = GlucoseConcentrationUnits(rawValue: raw) {
            return unit
        }
        print("Unable to parse unit: \(raw)")
        return .kgL
    }
    
    public init(data: NSData) {
        print("GlucoseMeasurement#init - \(data)")
        self.data = data
        self.unit = .kgL

        let flags = GlucoseMeasurement.extractFlags(data: data)
        self.timeOffsetPresent = GlucoseMeasurement.extractBit(bit: 0, byte: flags)
        self.glucoseConcentrationTypeAndSampleLocationPresent = GlucoseMeasurement.extractBit(bit: 1, byte: flags)
        self.unit = GlucoseMeasurement.parseUnits(byte: flags)
        self.sensorStatusAnnunciationPresent = GlucoseMeasurement.extractBit(bit: 3, byte: flags)
        self.contextInformationFollows = GlucoseMeasurement.extractBit(bit: 4, byte: flags)
        
        self.sequenceNumber = GlucoseMeasurement.parseSequenceNumber(data: data)
        self.timeOffset = 0
        
        indexCounter = 3; // skip flags (1) sequence number (2)
        
        self.glucoseConcentration = 0
        
        self.deviceBatteryLowAtTimeOfMeasurement = false
        self.sensorMalfunctionOrFaultingAtTimeOfMeasurement = false;
        self.sampleSizeForBloodOrControlSolutionInsufficientAtTimeOfMeasurement = false
        self.stripInsertionError = false
        self.stripTypeIncorrectForDevice = false
        self.sensorResultHigherThanTheDeviceCanProcess = false
        self.sensorResultLowerThanTheDeviceCanProcess = false
        self.sensorTemperatureTooLowForValidTest = false
        self.sensorTemperatureTooHighForValidTest = false
        self.sensorReadInterruptedBecauseStripWasPulledTooSoon = false
        self.generalDeviceFault = false
        self.timeFaultHasOccurred = false
        
        super.init()
        parseDateTime()
        
        if (timeOffsetPresent) {
            parseTimeOffset()
            applyTimeOffset()
        }
        
        if (glucoseConcentrationTypeAndSampleLocationPresent) {
            parseGlucoseConcentration()
            parseSampleLocationAndType()
        }
        if (sensorStatusAnnunciationPresent) {
            parseSensorStatusAnnunciation()
        }
    }
    
    func parseDateTime() {
        print("parseDateTime [indexCounter:\(indexCounter)]")
        
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let dateComponents = NSDateComponents()
        
        let yearData = data.dataRange(indexCounter, Length: 2)
        print("yearData: \(yearData)")
        let swappedYearData = yearData.swapUInt16Data()
        print("swappedYearData: \(swappedYearData)")
        
        let swappedYearString = swappedYearData.toHexString()
        dateComponents.year = Int(strtoul(swappedYearString, nil, 16))
        indexCounter += 2
        
        // Month
        let monthData = data.dataRange(indexCounter, Length: 1)
        print("monthData: \(monthData)")
        dateComponents.month = Int(strtoul(monthData.toHexString(), nil, 16))
        indexCounter += 1
        
        // Day
        let dayData = data.dataRange(indexCounter, Length: 1)
        print("dayData: \(dayData)")
        dateComponents.day = Int(strtoul(dayData.toHexString(), nil, 16))
        indexCounter += 1
        
        // Hours
        let hoursData = data.dataRange(indexCounter, Length: 1)
        print("hoursData: \(hoursData)")
        dateComponents.hour = Int(strtoul(hoursData.toHexString(), nil, 16))
        indexCounter += 1
        
        // Minutes
        let minutesData = data.dataRange(indexCounter, Length: 1)
        print("minutesData: \(minutesData)")
        dateComponents.minute = Int(strtoul(minutesData.toHexString(), nil, 16))
        indexCounter += 1
        
        // Seconds
        let secondsData = data.dataRange(indexCounter, Length: 1)
        print("secondsData: \(secondsData)")
        dateComponents.second = Int(strtoul(secondsData.toHexString(), nil, 16))
        indexCounter += 1
        
        print("dateComponents: \(dateComponents)")
        
        let measurementDate = calendar.date(from: dateComponents as DateComponents)
        print("measurementDate: \(String(describing: measurementDate))")
        self.dateTime = measurementDate
    }
    
    func parseTimeOffset() {
        print("parseTimeOffset [indexCounter:\(indexCounter)]")
        let timeBytes = data.dataRange(indexCounter, Length: 2)
        let timeOffset: Int16 = timeBytes.readInteger(0);
        print("timeOffset(minutes): \(timeOffset)")
        self.timeOffset = timeOffset
        
        indexCounter += 2
    }
    
    func applyTimeOffset() {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        
        let offsetDateComponents = NSDateComponents()
        offsetDateComponents.minute = Int(self.timeOffset)
        let offsetDate = calendar.date(byAdding: offsetDateComponents as DateComponents, to: self.dateTime!)
        print("offsetDate: \(String(describing: offsetDate))")
        
        self.dateTime = offsetDate
    }
    
    func parseGlucoseConcentration() {
        print("parseGlucoseConcentration [indexCounter:\(indexCounter)]")
        let concentrationData = data.dataRange(indexCounter, Length: 2)
        print("concentrationData: \(concentrationData)")
        glucoseConcentration = concentrationData.shortFloatToFloat()
        print("glucoseConcentration: \(glucoseConcentration)")
        
        indexCounter += 2
    }
    
    func parseSampleLocationAndType() {
        print("parseSampleLocationAndType [indexCounter:\(indexCounter)]")
        let sampleLocationAndDataTypeData = data.dataRange(indexCounter, Length: 1)
        print("sampleLocationAndDataTypeData: \(sampleLocationAndDataTypeData)")
        let type = sampleLocationAndDataTypeData.lowNibbleAtPosition()
        let location = sampleLocationAndDataTypeData.highNibbleAtPosition()
        
        self.sampleType = SampleType(rawValue: type)
        print("type: \(String(describing: self.sampleType?.description))")
        
        if(location > 4) {
            print("sample location is reserved for future use")
            self.sampleLocation = .reserved
        } else {
            self.sampleLocation = SampleLocation(rawValue: location)
            print("sample location: \(String(describing: self.sampleLocation?.description))")
        }
        
        indexCounter += 1
    }
    
    func parseSensorStatusAnnunciation() {
        print("parseSensorStatusAnnunciation [indexCounter:\(indexCounter)]")
        let sensorStatusAnnunciationData = data.dataRange(indexCounter, Length: 2).swapUInt16Data()
        let sensorStatusAnnunciationString = sensorStatusAnnunciationData.toHexString()
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
