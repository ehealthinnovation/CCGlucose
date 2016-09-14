//
//  GlucoseMeasurement.swift
//  Pods
//
//  Created by Kevin Tallevi on 7/12/16.
//
//

import Foundation

enum SampleType : String {
    case reserved = "Reserved",
    capillaryWholeBlood = "Capillary whole blood",
    capillaryPlasma = "Capillary plasma",
    venousWholeBlood = "Venous whole blood",
    venousPlasma = "Venous plasma",
    arterialWholeBlood = "Arterial whole blood",
    arterialPlasma = "Arterial plasma",
    undeterminedWholeBlood = "Undetermined whole blood",
    undeterminedPlasma = "Undetermined plasma",
    interstitialFluid  = "Interstitial fluid",
    controlSolution = "Control solution"
    
    static let allValues = [reserved, capillaryWholeBlood, capillaryPlasma, venousWholeBlood, venousPlasma, arterialWholeBlood, arterialPlasma, undeterminedWholeBlood, undeterminedPlasma, interstitialFluid, controlSolution]
}

enum SampleLocation : String {
    case reserved = "Reserved",
    finger = "finger",
    alternateSiteTest = "Alternate site test",
    earlobe = "Earlobe",
    controlSolution = "Control solution",
    SampleLocationNotAvailable = "Sample location not available"
    
    static let allValues = [reserved, finger, alternateSiteTest, earlobe, controlSolution, SampleLocationNotAvailable]
}

enum GlucoseConcentrationUnits : String {
    case kgL = "kg/L",
    molL = "mol/L"
    
    static let allValues = [kgL, molL]
}


public class GlucoseMeasurement {
    //raw data
    var data: NSData
    var indexCounter: Int = 0
    
    //publicly accessible properties
    public var sequenceNumber: UInt16?
    public var dateTime: Date?
    public var timeOffset: UInt16?
    public var glucoseConcentration: Float?
    public var glucoseConcentrationUnits: String?
    public var sampleType: String?
    public var sampleLocation: String?
    
    //flags
    var timeOffsetPresent: Bool?
    var glucoseConcentrationTypeAndSampleLocationPresent: Bool?
    var sensorStatusAnnunciationPresent: Bool?
    var contextInformationFollows: Bool?
    
    //Sensor Status Annunciations
    public var deviceBatteryLowAtTimeOfMeasurement: Bool?
    public var sensorMalfunctionOrFaultingAtTimeOfMeasurement: Bool?
    public var sampleSizeForBloodOrControlSolutionInsufficientAtTimeOfMeasurement: Bool?
    public var stripInsertionError: Bool?
    public var stripTypeIncorrectForDevice: Bool?
    public var sensorResultHigherThanTheDeviceCanProcess: Bool?
    public var sensorResultLowerThanTheDeviceCanProcess: Bool?
    public var sensorTemperatureTooHighForValidTest: Bool?
    public var sensorTemperatureTooLowForValidTest: Bool?
    public var sensorReadInterruptedBecauseStripWasPulledTooSoon: Bool?
    public var generalDeviceFault: Bool?
    public var timeFaultHasOccurred: Bool?
    
    
    init(data: NSData?) {
        self.data = data!
        print("GlucoseMeasurement#init - \(self.data)")
        parseFlags()
        parseSequenceNumber()
        
        if(timeOffsetPresent == true) {
            parseDateTime()
            parseTimeOffset()
            applyTimeOffset()
        }
        if(glucoseConcentrationTypeAndSampleLocationPresent == true) {
            parseGlucoseConcentration()
            parseSampleLocationAndType()
        }
        if(sensorStatusAnnunciationPresent == true) {
            parseSensorStatusAnnunciation()
        }
    }
    
    func parseFlags() {
        print("parseFlags [indexCounter:\(indexCounter)]")
        let flagsData = data.dataRange(indexCounter, Length: 1)
        var flagsString = flagsData.toHexString()
        var flagsByte = Int(strtoul(flagsString, nil, 16))
        print("flags byte: \(flagsByte)")
        
        timeOffsetPresent = flagsByte.bit(0).toBool()
        glucoseConcentrationTypeAndSampleLocationPresent = flagsByte.bit(1).toBool()
        glucoseConcentrationUnits = GlucoseConcentrationUnits.allValues[flagsByte.bit(2)].rawValue
        sensorStatusAnnunciationPresent = flagsByte.bit(3).toBool()
        contextInformationFollows = flagsByte.bit(4).toBool()
        
        indexCounter += 1
    }
    
    func parseSequenceNumber() {
        print("parseSequenceNumber [indexCounter:\(indexCounter)]")
        let sequenceNumberData = data.dataRange(indexCounter, Length: 2)
        let swappedSequenceNumberData = sequenceNumberData.swapUInt16Data()
        let swappedSequenceNumberString = swappedSequenceNumberData.toHexString()
        sequenceNumber = UInt16(strtoul(swappedSequenceNumberString, nil, 16))
        print("sequenceNumber: \(sequenceNumber)")
        
        indexCounter += 2
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
        
        let date = calendar.date(from: dateComponents as DateComponents)
        
        let measurementDate = calendar.date(from: dateComponents as DateComponents)
        print("measurementDate: \(measurementDate)")
        self.dateTime = measurementDate
    }
    
    func parseTimeOffset() {
        print("parseTimeOffset [indexCounter:\(indexCounter)]")
        let timeBytes = data.dataRange(indexCounter, Length: 2)
        let timeOffset : UInt16 = timeBytes.readInteger(0);
        print("timeOffset(minutes): \(timeOffset)")
        self.timeOffset = timeOffset
        
        indexCounter += 2
    }
    
    func applyTimeOffset() {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        
        let offsetDateComponents = NSDateComponents()
        offsetDateComponents.minute = Int(self.timeOffset!)
        //let offsetDate = calendar.date(byAdding: offsetDateComponents as DateComponents, to: self.dateTime!, options: [])
        let offsetDate = calendar.date(byAdding: offsetDateComponents as DateComponents, to: self.dateTime!)
        print("offsetDate: \(offsetDate)")
        
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
        let sample = sampleLocationAndDataTypeData.highNibbleAtPosition()
        
        print("type: \(SampleType.allValues[type].rawValue)")
        self.sampleType = SampleType.allValues[type].rawValue
        
        if(sample > 4) {
            print("sample location is reserved for future use")
            self.sampleLocation = "Reserved"
        } else {
            print("sample location: \(SampleLocation.allValues[sample].rawValue)")
            self.sampleLocation = SampleLocation.allValues[sample].rawValue
        }
        
        indexCounter += 1
    }
    
    func parseSensorStatusAnnunciation() {
        print("parseSensorStatusAnnunciation [indexCounter:\(indexCounter)]")
        let sensorStatusAnnunciationData = data.dataRange(indexCounter, Length: 2)
        var sensorStatusAnnunciationString = sensorStatusAnnunciationData.toHexString()
        var sensorStatusAnnunciationBytes = Int(strtoul(sensorStatusAnnunciationString, nil, 16))
        print("sensorStatusAnnunciation bytes: \(sensorStatusAnnunciationBytes)")
        
        deviceBatteryLowAtTimeOfMeasurement = sensorStatusAnnunciationBytes.bit(0).toBool()
        sensorMalfunctionOrFaultingAtTimeOfMeasurement = sensorStatusAnnunciationBytes.bit(1).toBool()
        sampleSizeForBloodOrControlSolutionInsufficientAtTimeOfMeasurement = sensorStatusAnnunciationBytes.bit(2).toBool()
        stripInsertionError = sensorStatusAnnunciationBytes.bit(3).toBool()
        stripTypeIncorrectForDevice = sensorStatusAnnunciationBytes.bit(4).toBool()
        sensorResultHigherThanTheDeviceCanProcess = sensorStatusAnnunciationBytes.bit(5).toBool()
        sensorResultLowerThanTheDeviceCanProcess = sensorStatusAnnunciationBytes.bit(6).toBool()
        sensorTemperatureTooHighForValidTest = sensorStatusAnnunciationBytes.bit(7).toBool()
        sensorTemperatureTooLowForValidTest = sensorStatusAnnunciationBytes.bit(8).toBool()
        sensorReadInterruptedBecauseStripWasPulledTooSoon = sensorStatusAnnunciationBytes.bit(9).toBool()
        generalDeviceFault = sensorStatusAnnunciationBytes.bit(10).toBool()
        timeFaultHasOccurred = sensorStatusAnnunciationBytes.bit(11).toBool()
    }
}
