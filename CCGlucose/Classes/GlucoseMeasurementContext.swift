//
//  GlucoseMeasurementContext.swift
//  Pods
//
//  Created by Kevin Tallevi on 7/18/16.
//
//

import Foundation


enum CarbohydrateID : String {
    case reserved = "Reserved",
    breakfast = "breakfast",
    lunch = "lunch",
    dinner = "dinner",
    snack = "snack",
    drink = "drink",
    supper = "supper",
    brunch = "brunch"
    
    static let allValues = [reserved, breakfast, lunch, dinner, snack, drink, supper, brunch]
}

enum Meals : String {
    case reserved = "Reserved",
    preprandialBeforeMeal = "Preprandial (before meal)",
    preprandialAfterMeal = "Preprandial (after meal)",
    fasting = "Fasting",
    casual = "Casual",
    bedtime = "Bedtime"
    
    static let allValues = [reserved, preprandialBeforeMeal, preprandialAfterMeal, fasting, casual, bedtime]
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

enum MedicationValueUnits : String {
    case kilograms = "kilograms",
    liters = "liters"
    
    static let allValues = [kilograms, liters]
}


public class GlucoseMeasurementContext : NSObject {
    //raw data
    var data: NSData
    var indexCounter: Int = 0
    
    public var sequenceNumber: UInt16?
    public var carbohydrateID: String?
    public var carbohydrateWeight: Float?
    public var meal: String?
    public var tester: String?
    public var health: String?
    public var exerciseDuration: UInt16?
    public var exerciseIntensity: Int?
    public var medicationID: String?
    public var medication: Float?
    public var hbA1c: Float?
    
    //flags
    var carbohydrateIDAndCarbohydratePresent: Bool?
    var mealPresent: Bool?
    var testerHealthPresent: Bool?
    var exerciseDurationAndExerciseIntensityPresent: Bool?
    var medicationIDAndMedicationPresent: Bool?
    var medicationValueUnits: String?
    var hbA1cPresent: Bool?
    var extendedFlagsPresent: Bool?
    
    
    init(data: NSData?) {
        self.data = data!
        super.init()
        print("GlucoseMeasurementContext#init - \(self.data)")
        parseFlags()
        parseSequenceNumber()
        
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
    
    func parseFlags() {
        let flagsData = data.dataRange(indexCounter, Length: 1)
        var flagsString = flagsData.toHexString()
        var flagsByte = Int(strtoul(flagsString, nil, 16))
        print("flags byte: \(flagsByte)")
        
        carbohydrateIDAndCarbohydratePresent = flagsByte.bit(0).toBool()
        mealPresent = flagsByte.bit(1).toBool()
        testerHealthPresent = flagsByte.bit(2).toBool()
        exerciseDurationAndExerciseIntensityPresent = flagsByte.bit(3).toBool()
        medicationIDAndMedicationPresent = flagsByte.bit(4).toBool()
        medicationValueUnits = MedicationValueUnits.allValues[flagsByte.bit(5)].rawValue
        hbA1cPresent = flagsByte.bit(6).toBool()
        extendedFlagsPresent = flagsByte.bit(7).toBool()
        
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

    func parseExtendedFlags() {
        //indexCounter += 1
    }
    
    func parseCarbohydrateID() {
        print("parseCarbohydrateID")
        let carbohydrateIDData = data.dataRange(indexCounter, Length: 1)
        let carbohydrateIDByte = Int(strtoul(carbohydrateIDData.toHexString(), nil, 16))
        print("carbohydrateIDByte: \(carbohydrateIDByte)")
        carbohydrateID = (CarbohydrateID.allValues[carbohydrateIDByte].rawValue)
        print("carbohydrateID: \(carbohydrateID)")
        
        indexCounter += 1
    }
    
    func parseCarbohydrateUnits() {
        print("parseCarbohydrateUnits")
        let carbohydrateUnitsData = data.dataRange(indexCounter, Length: 1)
        carbohydrateWeight = carbohydrateUnitsData.shortFloatToFloat()
        print("carbohydrateWeight: \(carbohydrateWeight)")
        
        indexCounter += 1
    }
    
    func parseMeal() {
        print("parseMeal")
        let mealData = data.dataRange(indexCounter, Length: 1)
        let mealByte = Int(strtoul(mealData.toHexString(), nil, 16))
        print("mealByte: \(mealByte)")
        meal = (Meals.allValues[mealByte].rawValue)
        print("meal: \(meal)")
        
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
