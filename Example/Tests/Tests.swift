import UIKit
import XCTest
import CCGlucose
import CCToolbox

class Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    //#1
    func testGlucoseMeasurementWithoutAnnunciation() {
        let measurementString = "030100E007091507000000005AB011"
        let r = GlucoseMeasurement(data: measurementString.dataFromHexadecimalString()!)
        
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let dateComponents = NSDateComponents()
        dateComponents.year = 2016
        dateComponents.month = 9
        dateComponents.day = 21
        dateComponents.hour = 7
        dateComponents.minute = 0
        dateComponents.second = 0
        let expectedDate = calendar.date(from: dateComponents as DateComponents)
        
        XCTAssertEqual(1, r.sequenceNumber)
        XCTAssertEqual(expectedDate, r.dateTime)
        XCTAssertEqual(0, r.timeOffset)
        XCTAssertEqual(0.0009, r.glucoseConcentration)
        XCTAssertEqual("Capillary Whole Blood", r.sampleType?.description)
        XCTAssertEqual("Finger", r.sampleLocation?.description)
        XCTAssertEqual(false, r.deviceBatteryLowAtTimeOfMeasurement)
        XCTAssertEqual(false, r.sensorMalfunctionOrFaultingAtTimeOfMeasurement)
        XCTAssertEqual(false, r.sampleSizeForBloodOrControlSolutionInsufficientAtTimeOfMeasurement)
        XCTAssertEqual(false, r.stripInsertionError)
        XCTAssertEqual(false, r.stripTypeIncorrectForDevice)
        XCTAssertEqual(false, r.sensorResultHigherThanTheDeviceCanProcess)
        XCTAssertEqual(false, r.sensorResultLowerThanTheDeviceCanProcess)
        XCTAssertEqual(false, r.sensorTemperatureTooHighForValidTest)
        XCTAssertEqual(false, r.sensorTemperatureTooLowForValidTest)
        XCTAssertEqual(false, r.sensorReadInterruptedBecauseStripWasPulledTooSoon)
        XCTAssertEqual(false, r.generalDeviceFault)
        XCTAssertEqual(false, r.timeFaultHasOccurred)
    }
    
    //#3
    func testGlucoseMeasurementWithTimeoffsetWithoutAnnunciation() {
        let measurementString = "030300E007091507000000805AB011"
        let r = GlucoseMeasurement(data: measurementString.dataFromHexadecimalString()!)
        
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let dateComponents = NSDateComponents()
        dateComponents.year = 2016
        dateComponents.month = 9
        dateComponents.day = 21
        dateComponents.hour = 7
        dateComponents.minute = 0
        dateComponents.second = 0
        let baseDate = calendar.date(from: dateComponents as DateComponents)
        
        //apply the expected time offset
        let offsetDateComponents = NSDateComponents()
        offsetDateComponents.minute = Int(-32768)
        let expectedDate = calendar.date(byAdding: offsetDateComponents as DateComponents, to: baseDate!)
        
        XCTAssertEqual(3, r.sequenceNumber)
        XCTAssertEqual(expectedDate, r.dateTime)
        XCTAssertEqual(-32768, r.timeOffset)
        XCTAssertEqual(0.0009, r.glucoseConcentration)
        XCTAssertEqual("Capillary Whole Blood", r.sampleType?.description)
        XCTAssertEqual("Finger", r.sampleLocation?.description)
        XCTAssertEqual(false, r.deviceBatteryLowAtTimeOfMeasurement)
        XCTAssertEqual(false, r.sensorMalfunctionOrFaultingAtTimeOfMeasurement)
        XCTAssertEqual(false, r.sampleSizeForBloodOrControlSolutionInsufficientAtTimeOfMeasurement)
        XCTAssertEqual(false, r.stripInsertionError)
        XCTAssertEqual(false, r.stripTypeIncorrectForDevice)
        XCTAssertEqual(false, r.sensorResultHigherThanTheDeviceCanProcess)
        XCTAssertEqual(false, r.sensorResultLowerThanTheDeviceCanProcess)
        XCTAssertEqual(false, r.sensorTemperatureTooHighForValidTest)
        XCTAssertEqual(false, r.sensorTemperatureTooLowForValidTest)
        XCTAssertEqual(false, r.sensorReadInterruptedBecauseStripWasPulledTooSoon)
        XCTAssertEqual(false, r.generalDeviceFault)
        XCTAssertEqual(false, r.timeFaultHasOccurred)
    }
    
    //#34
    func testGlucoseMeasurementWithAnnunciation() {
        let measurementString = "0B2200E007091507000000005AB0110002"
        let r = GlucoseMeasurement(data: measurementString.dataFromHexadecimalString()!)
        
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let dateComponents = NSDateComponents()
        dateComponents.year = 2016
        dateComponents.month = 9
        dateComponents.day = 21
        dateComponents.hour = 7
        dateComponents.minute = 0
        dateComponents.second = 0
        let expectedDate = calendar.date(from: dateComponents as DateComponents)
        
        XCTAssertEqual(34, r.sequenceNumber)
        XCTAssertEqual(expectedDate, r.dateTime)
        XCTAssertEqual(0, r.timeOffset)
        XCTAssertEqual(0.0009, r.glucoseConcentration)
        XCTAssertEqual("Capillary Whole Blood", r.sampleType?.description)
        XCTAssertEqual("Finger", r.sampleLocation?.description)
        XCTAssertEqual(false, r.deviceBatteryLowAtTimeOfMeasurement)
        XCTAssertEqual(false, r.sensorMalfunctionOrFaultingAtTimeOfMeasurement)
        XCTAssertEqual(false, r.sampleSizeForBloodOrControlSolutionInsufficientAtTimeOfMeasurement)
        XCTAssertEqual(false, r.stripInsertionError)
        XCTAssertEqual(false, r.stripTypeIncorrectForDevice)
        XCTAssertEqual(false, r.sensorResultHigherThanTheDeviceCanProcess)
        XCTAssertEqual(false, r.sensorResultLowerThanTheDeviceCanProcess)
        XCTAssertEqual(false, r.sensorTemperatureTooHighForValidTest)
        XCTAssertEqual(false, r.sensorTemperatureTooLowForValidTest)
        XCTAssertEqual(true, r.sensorReadInterruptedBecauseStripWasPulledTooSoon)
        XCTAssertEqual(false, r.generalDeviceFault)
        XCTAssertEqual(false, r.timeFaultHasOccurred)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
