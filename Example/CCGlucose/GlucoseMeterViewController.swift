//
//  GlucoseMeterViewController.swift
//  CCBluetooth
//
//  Created by Kevin Tallevi on 7/8/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth
import CCGlucose

class GlucoseMeterViewController: UITableViewController, GlucoseProtocol {
    private var glucose : Glucose!
    let cellIdentifier = "GlucoseMeterCellIdentifier"
    var glucoseFeatures: GlucoseFeatures!
    var glucoseMeasurementCount: UInt16 = 0
    var glucoseMeasurements: Array<GlucoseMeasurement> = Array<GlucoseMeasurement>()
    var glucoseMeasurementContexts: Array<GlucoseMeasurementContext> = Array<GlucoseMeasurementContext>()
    var selectedGlucoseMeasurement: GlucoseMeasurement!
    var selectedGlucoseMeasurementContext: GlucoseMeasurementContext!
    var selectedMeter: CBPeripheral!
    var meterConnected: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("GlucoseMeterViewController#viewDidLoad")
        print("selectedMeter: \(selectedMeter)")
        meterConnected = false
        glucose = Glucose(cbPeripheral: selectedMeter)
        glucose.glucoseDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)
        
        if(meterConnected == true) {
           glucose.disconnectGlucoseMeter()
        }
    }
    
    func glucoseMeterConnected(meter: CBPeripheral) {
        print("GlucoseMeterViewController#glucoseMeterConnected")
        meterConnected = true
    }
    
    func numberOfStoredRecords(number: UInt16) {
        print("GlucoseMeterViewController#numberOfStoredRecords - \(number)")
        glucoseMeasurementCount = number
        glucose.readGlucoseFeatures()
        self.refreshTable()
    }
    
    func glucoseMeasurement(measurement:GlucoseMeasurement) {
        print("glucoseMeasurement")
        glucoseMeasurements.append(measurement)
        
        self.refreshTable()
    }
    
    func glucoseMeasurementContext(measurementContext:GlucoseMeasurementContext) {
        print("glucoseMeasurementContext")
        glucoseMeasurementContexts.append(measurementContext)
    }
    
    func glucoseFeatures(features:GlucoseFeatures) {
        print("GlucoseMeterViewController#glucoseFeatures")
        glucoseFeatures = features
        
        self.refreshTable()
        glucose.downloadAllRecords()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let detailsViewController =  segue.destination as! GlucoseMeasurementDetailsViewController
        detailsViewController.glucoseMeasurement = selectedGlucoseMeasurement
        selectedGlucoseMeasurementContext = getContextFromArray(sequenceNumber: selectedGlucoseMeasurement.sequenceNumber!)
        detailsViewController.glucoseMeasurementContext = selectedGlucoseMeasurementContext
    }
    
    // MARK: Table data source methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0:
                if(glucoseFeatures != nil) {
                    return 11
                } else {
                    return 0
                }
            case 1:
                if(glucoseMeasurementCount > 0) {
                    return 1
                } else {
                    return 0
                }
            case 2:
                return glucoseMeasurements.count
            default:
                return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath as IndexPath) as UITableViewCell
        
        switch indexPath.section {
            case 0:
                if(glucoseFeatures != nil) {
                    switch indexPath.row {
                        case 0:
                            cell.textLabel!.text = glucoseFeatures.lowBatterySupported?.description
                            cell.detailTextLabel!.text = "Low Battery Supported"
                        case 1:
                            cell.textLabel!.text = glucoseFeatures.sensorMalfunctionDetectionSupported?.description
                            cell.detailTextLabel!.text = "Sensor Malfunction Detection Supported"
                        case 2:
                            cell.textLabel!.text = glucoseFeatures.sensorSampleSizeSupported?.description
                            cell.detailTextLabel!.text = "Sensor Sample Size Supported"
                        case 3:
                            cell.textLabel!.text = glucoseFeatures.sensorStripInsertionErrorDetectionSupported?.description
                            cell.detailTextLabel!.text = "Sensor Strip Insertion Error Detection Supported"
                        case 4:
                            cell.textLabel!.text = glucoseFeatures.sensorStripTypeErrorDetectionSupported?.description
                            cell.detailTextLabel!.text = "Sensor Strip Type Error Detection Supported"
                        case 5:
                            cell.textLabel!.text = glucoseFeatures.sensorResultHighLowDetectionSupported?.description
                            cell.detailTextLabel!.text = "Sensor Result High Low Detection Supported"
                        case 6:
                            cell.textLabel!.text = glucoseFeatures.sensorTemperatureHighLowDetectionSupported?.description
                            cell.detailTextLabel!.text = "Sensor Temperature High Low Detection Supported"
                        case 7:
                            cell.textLabel!.text = glucoseFeatures.sensorReadInterruptDetectionSupported?.description
                            cell.detailTextLabel!.text = "Sensor Read Interrupt Detection Supported"
                        case 8:
                            cell.textLabel!.text = glucoseFeatures.generalDeviceFaultSupported?.description
                            cell.detailTextLabel!.text = "General Device Fault Supported"
                        case 9:
                            cell.textLabel!.text = glucoseFeatures.timeFaultSupported?.description
                            cell.detailTextLabel!.text = "Time Fault Supported"
                        case 10:
                            cell.textLabel!.text = glucoseFeatures.multipleBondSupported?.description
                            cell.detailTextLabel!.text = "MultipleBond Supported"
                        default:
                            cell.textLabel!.text = ""
                            cell.detailTextLabel!.text = ""
                    }
                }
            case 1:
                if (glucoseMeasurementCount > 0) {
                    cell.textLabel!.text = "Number of records: " + " " + glucoseMeasurementCount.description
                    cell.detailTextLabel!.text = ""
                }
            case 2:
                let measurement = Array(glucoseMeasurements)[indexPath.row]
                let mmolString : String = (measurement.toMMOL()?.description)!
                
                cell.textLabel!.text = "(" + measurement.sequenceNumber!.description + ") " + (measurement.glucoseConcentration?.description)! + " " + measurement.glucoseConcentrationUnits! +
                    " (" + mmolString + " mmol/L)"
                
                cell.detailTextLabel!.text = measurement.dateTime?.description
            default:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = ""
        }
        
        return cell
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 75
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            case 0:
                return "Glucose Meter Features"
            case 1:
                return "Glucose Record Count"
            case 2:
                return "Glucose Records"
            default:
                return ""
        }
    }

    //MARK: table delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("didSelectRowAtIndexPath")
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if(indexPath.section == 2) {
            selectedGlucoseMeasurement = Array(glucoseMeasurements)[indexPath.row]
            performSegue(withIdentifier: "segueToMeasurementDetails", sender: self)
        }
    }
    
    func refreshTable() {
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    
    func getContextFromArray(sequenceNumber:UInt16) -> GlucoseMeasurementContext? {
        for context: GlucoseMeasurementContext in glucoseMeasurementContexts {
            if(context.sequenceNumber == sequenceNumber) {
                return context
            }
        }
    
        return nil
    }
}
