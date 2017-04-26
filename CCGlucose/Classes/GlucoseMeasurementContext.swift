//
//  GlucoseMeasurementContext.swift
//  Pods
//
//  Created by Kevin Tallevi on 7/18/16.
//
//

import Foundation


// Based on Bluetooth spec:
// https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.glucose_measurement_context.xml
@objc public enum CarbohydrateID : Int {
    case reserved = 0,
    breakfast,
    lunch,
    dinner,
    snack,
    drink,
    supper,
    brunch
  
    public var description: String {
        switch self {
        case .breakfast:
            return NSLocalizedString("Breakfast", comment:"")
        case .lunch:
            return NSLocalizedString("Lunch", comment:"")
        case .dinner:
            return NSLocalizedString("Dinner", comment:"")
        case .snack:
            return NSLocalizedString("Snack", comment:"")
        case .drink:
            return NSLocalizedString("Drink", comment:"")
        case .supper:
            return NSLocalizedString("Supper", comment:"")
        case .brunch:
            return NSLocalizedString("Brunch", comment:"")
        case .reserved:
            return NSLocalizedString("Reserved", comment:"")
        }
    }
    
}

/// the confusing name 'Meal' is from the Bluetooth spec. It concerns the timing *around* a meal
/// 'Meal' is too generic (app might have a Meal class), so an alias is required
public typealias Meal = GlucoseMeasurementContextMeal

@objc public enum GlucoseMeasurementContextMeal : Int {
    case reserved = 0,
    preprandialBeforeMeal,
    postprandialAfterMeal,
    fasting,
    casual,
    bedtime
    
    public var description: String {
        switch self {
        case .reserved:
            return NSLocalizedString("Reserved", comment:"")
        case .preprandialBeforeMeal:
            return NSLocalizedString("Preprandial (before meal)", comment:"")
        case .postprandialAfterMeal:
            return NSLocalizedString("Postprandial (after meal)", comment:"")
        case .fasting:
            return NSLocalizedString("Fasting", comment:"")
        case .casual:
            return NSLocalizedString("Casual", comment:"")
        case .bedtime:
            return NSLocalizedString("Bedtime", comment:"")
        }
    }
}


enum Tester : String {
    case reserved = "Reserved",
    isSelf = "Self",
    healthCareProfessional = "Health Care Professional",
    labTest = "Lab test",
    testerValueNotAvailable = "Tester value not available"
    
    static let allValues = [reserved, isSelf, healthCareProfessional, labTest, testerValueNotAvailable]
}

enum Health : String {
    case reserved = "Reserved",
    minorHealthIssues = "Minor Health Issues",
    majorHealthIssues = "Major Health Issues",
    duringMenses = "During menses",
    underStress = "Under stress",
    noHealthIssues = "No health issues",
    healthValueNotAvailable = "Health value not available"
    
    static let allValues = [reserved, minorHealthIssues, duringMenses, underStress, noHealthIssues, healthValueNotAvailable]
}

enum MedicationID : String {
    case reserved = "Reserved",
    rapidActingInsulin = "Rapid acting insulin",
    shortActingInsulin = "Short acting insulin",
    intermediateActingInsulin = "Intermediate acting insulin",
    longActingInsulin = "Long acting insulin",
    premixedInsulin = "Pre-mixed insulin"
    
    static let allValues = [reserved, rapidActingInsulin, shortActingInsulin, intermediateActingInsulin, longActingInsulin, premixedInsulin]
}

public enum MedicationValueUnit : Int {
    case kilograms = 0,
    liters
    
    public var description : String {
        switch self {
        case .kilograms:
            return NSLocalizedString("kilograms", comment: "")
        case .liters:
            return NSLocalizedString("liters", comment: "")
        }
    }
}


public class GlucoseMeasurementContext : NSObject {
    //raw data
    var data: NSData
    var indexCounter: Int = 0
    
    public var sequenceNumber: UInt16
    public var carbohydrateID: CarbohydrateID?
    public var carbohydrateWeight: Float?
    public var meal: Meal?
    public var tester: String?
    public var health: String?
    public var exerciseDuration: UInt16?
    public var exerciseIntensity: Int?
    public var medicationID: String?
    public var medication: Float?
    public var hbA1c: Float?
    
    // note: these methods are required to allow objc to access an optional enum

    public var objc_hasMeal: Bool {
        return self.meal == nil ? false : true;
    }
    
    public var objc_meal: GlucoseMeasurementContextMeal {
        return self.meal!
    }

    public var objc_hasCarbohydrateID: Bool {
        return self.carbohydrateID == nil ? false : true;
    }
    
    public var objc_carbohydrateID: CarbohydrateID {
        return self.carbohydrateID!
    }

    //flags
    var carbohydrateIDAndCarbohydratePresent: Bool
    var mealPresent: Bool
    var testerHealthPresent: Bool
    var exerciseDurationAndExerciseIntensityPresent: Bool
    var medicationIDAndMedicationPresent: Bool
    var medicationValueUnits: String
    var hbA1cPresent: Bool
    var extendedFlagsPresent: Bool
    
    class func parseSequenceNumber(data: NSData) -> UInt16 {
        let index = 1
        print("parseSequenceNumber [indexCounter:\(index)]")
        let sequenceNumberData = data.dataRange(index, Length: 2)
        let swappedSequenceNumberData = sequenceNumberData.swapUInt16Data()
        let swappedSequenceNumberString = swappedSequenceNumberData.toHexString()
        let sequenceNumber = UInt16(strtoul(swappedSequenceNumberString, nil, 16))
        print("sequenceNumber: \(sequenceNumber)")
        return sequenceNumber
    }

    init(data: NSData) {
        self.data = data
        
        let flags = GlucoseMeasurement.extractFlags(data: data)
        
        self.carbohydrateIDAndCarbohydratePresent = GlucoseMeasurement.extractBit(bit: 0, byte: flags)
        self.mealPresent = GlucoseMeasurement.extractBit(bit: 1, byte: flags)
        self.testerHealthPresent = GlucoseMeasurement.extractBit(bit: 2, byte: flags)
        self.exerciseDurationAndExerciseIntensityPresent = GlucoseMeasurement.extractBit(bit: 3, byte: flags)
        self.medicationIDAndMedicationPresent = GlucoseMeasurement.extractBit(bit: 4, byte: flags)
        
        let unit = MedicationValueUnit(rawValue: flags.bit(5))!
        self.medicationValueUnits = unit.description
        
        self.hbA1cPresent = GlucoseMeasurement.extractBit(bit: 6, byte: flags)
        self.extendedFlagsPresent = GlucoseMeasurement.extractBit(bit: 7, byte: flags)
        
        self.sequenceNumber = GlucoseMeasurementContext.parseSequenceNumber(data: data)
        
        super.init()

        self.indexCounter = 3; // parseFlags (1) + parseSequenceNumber (2)
        
        print("GlucoseMeasurementContext#init - \(self.data)")
        
        if(extendedFlagsPresent == true) {
            parseExtendedFlags()
        }
        
        if(carbohydrateIDAndCarbohydratePresent == true) {
            parseCarbohydrateID()
            parseCarbohydrateUnits()
        }
        
        if(mealPresent == true) {
            parseMeal()
        }
        
        if(testerHealthPresent == true) {
            parseTesterAndHealth()
        }
        
        if(exerciseDurationAndExerciseIntensityPresent == true) {
            parseExerciseDuration()
            parseExerciseIntensity()
        }
        
        if(medicationIDAndMedicationPresent == true) {
            parseMedicationID()
            parseMedication()
        }
        
        if(hbA1cPresent == true) {
            parseHbA1c()
        }
    }
    

    func parseExtendedFlags() {
        //indexCounter += 1
    }
    
    func parseCarbohydrateID() {
        print("parseCarbohydrateID")
        let carbohydrateIDData = data.dataRange(indexCounter, Length: 1)
        let carbohydrateIDByte = Int(strtoul(carbohydrateIDData.toHexString(), nil, 16))
        print("carbohydrateIDByte: \(carbohydrateIDByte)")
        if let carbohydrateID = CarbohydrateID(rawValue:carbohydrateIDByte) {
            self.carbohydrateID = carbohydrateID
        }
        print("carbohydrateID: \(String(describing: carbohydrateID))")
        
        indexCounter += 1
    }
    
    func parseCarbohydrateUnits() {
        print("parseCarbohydrateUnits")
        let carbohydrateUnitsData = data.dataRange(indexCounter, Length: 1)
        carbohydrateWeight = carbohydrateUnitsData.shortFloatToFloat()
        print("carbohydrateWeight: \(String(describing: carbohydrateWeight))")
        
        indexCounter += 1
    }
    
    func parseMeal() {
        print("parseMeal")
        let mealData = data.dataRange(indexCounter, Length: 1)
        let mealByte = Int(strtoul(mealData.toHexString(), nil, 16))
        print("mealByte: \(mealByte)")
        if let meal = Meal(rawValue: mealByte) {
            self.meal = meal
        }
        print("meal: \(String(describing: meal))")
        
        indexCounter += 1
    }
    
    func parseTesterAndHealth() {
        let testerData = data.dataRange(indexCounter, Length: 1)
        let tester = testerData.lowNibbleAtPosition()
        let health = testerData.highNibbleAtPosition()
        
        if(tester > 3) {
            print("tester is reserved for future use")
            self.tester = "Reserved"
        } else {
            print("tester: \(Tester.allValues[tester].rawValue)")
            self.tester = Tester.allValues[tester].rawValue
        }
        
        if(health > 5) {
            print("health is reserved for future use")
            self.health = "Reserved"
        } else {
            print("health: \(Health.allValues[health].rawValue)")
            self.health = Health.allValues[health].rawValue
        }
        
        indexCounter += 1
    }
    
    func parseExerciseDuration() {
        let exerciseDurationBytes = data.dataRange(indexCounter, Length: 2)
        let exerciseDurationInt : UInt16 = exerciseDurationBytes.readInteger(0);
        print("exerciseDurationInt: \(exerciseDurationInt)")
        self.exerciseDuration = exerciseDurationInt

        indexCounter += 2
    }
    
    func parseExerciseIntensity() {
        let exerciseIntensityData = data.dataRange(indexCounter, Length: 1)
        self.exerciseIntensity = Int(strtoul(exerciseIntensityData.toHexString(), nil, 16))
        
        indexCounter += 1
    }
    
    func parseMedicationID() {
        let medicationIDData = data.dataRange(indexCounter, Length: 1)
        let medicationIDByte = Int(strtoul(medicationIDData.toHexString(), nil, 16))
        
        if(medicationIDByte > 5) {
            self.medicationID = "Reserved"
        } else {
            print("medicationID: \(MedicationID.allValues[medicationIDByte].rawValue)")
            self.medicationID = MedicationID.allValues[medicationIDByte].rawValue
        }
        
        indexCounter += 1
    }
    
    func parseMedication() {
        let medicationData = data.dataRange(indexCounter, Length: 1)
        //TO-DO: is a conversion necessary here?
        if(self.medicationID == "kilograms") {
            //kilograms
            self.medication = medicationData.shortFloatToFloat()
        } else {
            //litres
            self.medication = medicationData.shortFloatToFloat()
        }
        
        indexCounter += 1
    }
    
    func parseHbA1c() {
        let hbA1cData = data.dataRange(indexCounter, Length: 1)
        self.hbA1c = hbA1cData.shortFloatToFloat()
    }
}
