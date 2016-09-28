//
//  GlucoseMeasurementDetails.swift
//  CCBluetooth
//
//  Created by Kevin Tallevi on 7/20/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import CCGlucose

class GlucoseMeasurementDetailsViewController: UITableViewController {
    let cellIdentifier = "DetailsCellIdentifier"
    var glucoseMeasurement: GlucoseMeasurement!
    var glucoseMeasurementContext: GlucoseMeasurementContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("GlucoseMeasurementDetailsViewController#viewDidLoad")
        print("glucoseMeasurement: \(glucoseMeasurement)")
        print("glucoseMeasurementContext: \(glucoseMeasurementContext)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Table data source methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0:
                return 7
            case 1:
                return 12
            case 2:
                return 11
            default:
                return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath as IndexPath) as UITableViewCell
        
        if(indexPath.section == 0) {
            switch indexPath.row {
            case 0:
                cell.textLabel!.text = glucoseMeasurement.sequenceNumber.description
                cell.detailTextLabel!.text = "Sequence number"
            case 1:
                cell.textLabel!.text = glucoseMeasurement.dateTime?.description
                cell.detailTextLabel!.text = "Date/time"
            case 2:
                cell.textLabel!.text = glucoseMeasurement.timeOffset.description
                cell.detailTextLabel!.text = "Time offset"
            case 3:
                cell.textLabel!.text = glucoseMeasurement.glucoseConcentration.description
                cell.detailTextLabel!.text = "Glucose concentration"
            case 4:
                cell.textLabel!.text = glucoseMeasurement.unit.description
                cell.detailTextLabel!.text = "Glucose concentration units"
            case 5:
                cell.textLabel!.text = glucoseMeasurement.sampleType?.description
                cell.detailTextLabel!.text = "Sample type"
            case 6:
                cell.textLabel!.text = glucoseMeasurement.sampleLocation?.description
                cell.detailTextLabel!.text = "Sample location"
            default :
                cell.textLabel!.text = ""
            }
        }

        if(indexPath.section == 1) {
            switch indexPath.row {
            case 0:
                cell.textLabel!.text = glucoseMeasurement.deviceBatteryLowAtTimeOfMeasurement.description
                cell.detailTextLabel!.text = "Device Battery Low At Time Of Measurement"
            case 1:
                cell.textLabel!.text = glucoseMeasurement.sensorMalfunctionOrFaultingAtTimeOfMeasurement.description
                cell.detailTextLabel!.text = "Sensor Malfunction Or Faulting At Time Of Measurement"
            case 2:
                cell.textLabel!.text = glucoseMeasurement.sampleSizeForBloodOrControlSolutionInsufficientAtTimeOfMeasurement.description
                cell.detailTextLabel!.text = "Sample Size For Blood Or Control Solution Insufficient At Time Of Measurement"
            case 3:
                cell.textLabel!.text = glucoseMeasurement.stripInsertionError.description
                cell.detailTextLabel!.text = "Strip Insertion Error"
            case 4:
                cell.textLabel!.text = glucoseMeasurement.stripTypeIncorrectForDevice.description
                cell.detailTextLabel!.text = "Strip Type Incorrect For Device"
            case 5:
                cell.textLabel!.text = glucoseMeasurement.sensorResultHigherThanTheDeviceCanProcess.description
                cell.detailTextLabel!.text = "Sensor Result Higher Than The Device Can Process"
            case 6:
                cell.textLabel!.text = glucoseMeasurement.sensorResultLowerThanTheDeviceCanProcess.description
                cell.detailTextLabel!.text = "Sensor Result Lower Than The Device Can Process"
            case 7:
                cell.textLabel!.text = glucoseMeasurement.sensorTemperatureTooHighForValidTest.description
                cell.detailTextLabel!.text = "Sensor Temperature Too High For Valid Test"
            case 8:
                cell.textLabel!.text = glucoseMeasurement.sensorTemperatureTooLowForValidTest.description
                cell.detailTextLabel!.text = "Sensor Temperature Too Low For Valid Test"
            case 9:
                cell.textLabel!.text = glucoseMeasurement.sensorReadInterruptedBecauseStripWasPulledTooSoon.description
                cell.detailTextLabel!.text = "Sensor Read Interrupted Because Strip Was Pulled Too Soon"
            case 10:
                cell.textLabel!.text = glucoseMeasurement.generalDeviceFault.description
                cell.detailTextLabel!.text = "General Device Fault"
            case 11:
                cell.textLabel!.text = glucoseMeasurement.timeFaultHasOccurred.description
                cell.detailTextLabel!.text = "Time Fault Has Occurred"
            default :
                cell.textLabel!.text = ""
            }
        }
        
        if(indexPath.section == 2) {
            switch indexPath.row {
            case 0:
                cell.textLabel!.text = glucoseMeasurementContext.sequenceNumber?.description
                cell.detailTextLabel!.text = "Sequence number"
            case 1:
                cell.textLabel!.text = glucoseMeasurementContext.carbohydrateID?.description
                cell.detailTextLabel!.text = "Carbohydrate"
            case 2:
                cell.textLabel!.text = glucoseMeasurementContext.carbohydrateWeight?.description
                cell.detailTextLabel!.text = "Carbohydrate weight"
            case 3:
                cell.textLabel!.text = glucoseMeasurementContext.meal?.description
                cell.detailTextLabel!.text = "Meal"
            case 4:
                cell.textLabel!.text = glucoseMeasurementContext.tester
                cell.detailTextLabel!.text = "Tester"
            case 5:
                cell.textLabel!.text = glucoseMeasurementContext.health
                cell.detailTextLabel!.text = "Health"
            case 6:
                cell.textLabel!.text = glucoseMeasurementContext.exerciseDuration?.description
                cell.detailTextLabel!.text = "Exercise duration"
            case 7:
                cell.textLabel!.text = glucoseMeasurementContext.exerciseIntensity?.description
                cell.detailTextLabel!.text = "Exercise intensity"
            case 8:
                cell.textLabel!.text = glucoseMeasurementContext.medicationID
                cell.detailTextLabel!.text = "Medication ID"
            case 9:
                cell.textLabel!.text = glucoseMeasurementContext.medication?.description
                cell.detailTextLabel!.text = "Medication"
            case 10:
                cell.textLabel!.text = glucoseMeasurementContext.hbA1c?.description
                cell.detailTextLabel!.text = "hbA1c"
            default :
                cell.textLabel!.text = ""
            }
        }
        
        return cell
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        if(glucoseMeasurementContext != nil) {
            //print("returning 3")
            return 3
        } else {
            //print("returning 2")
            return 2
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 75
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            if(glucoseMeasurementContext != nil) {
                return "Glucose Measurement"
            } else {
                return "Glucose Measurement  (No context)"
            }
        case 1:
            return "Sensor Status Annunciation"
        case 2:
            return "Glucose Context"
        default:
            return ""
        }
    }
}
