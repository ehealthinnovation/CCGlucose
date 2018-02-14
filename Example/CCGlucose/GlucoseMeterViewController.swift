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
    let cellIdentifier = "GlucoseMeterCellIdentifier"
    var glucoseFeatures: GlucoseFeatures!
    var glucoseMeasurementCount: UInt16 = 0
    var glucoseMeasurements: Array<GlucoseMeasurement> = Array<GlucoseMeasurement>()
    var glucoseMeasurementsContexts: Array<GlucoseMeasurementContext> = Array<GlucoseMeasurementContext>()
    var selectedGlucoseMeasurement: GlucoseMeasurement!
    var selectedGlucoseMeasurementContext: GlucoseMeasurementContext!
    
    var meterConnected: Bool!
    
    var selectedMeter: CBPeripheral! {
        didSet {
            Glucose.sharedInstance().connectToGlucoseMeter(glucoseMeter: selectedMeter)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("GlucoseMeterViewController#viewDidLoad")
        print("selectedMeter: \(selectedMeter)")
        meterConnected = false
        Glucose.sharedInstance().glucoseDelegate = self
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)
        
        if(meterConnected == true) {
           Glucose.sharedInstance().disconnectGlucoseMeter()
        }
    }
    
    func getMeasurement(sequenceNumber: UInt16) -> GlucoseMeasurement? {
        for measurement: GlucoseMeasurement in glucoseMeasurements {
            if measurement.sequenceNumber == sequenceNumber {
                return measurement
            }
        }
        
        return nil
    }
    
    func getMeasurementContext(sequenceNumber: UInt16) -> GlucoseMeasurementContext? {
        for measurementContext: GlucoseMeasurementContext in glucoseMeasurementsContexts {
            if measurementContext.sequenceNumber == sequenceNumber {
                return measurementContext
            }
        }
        
        return nil
    }
    
    // MARK: - GlucoseProtocol
    func glucoseMeterConnected(meter: CBPeripheral) {
        print("GlucoseMeterViewController#glucoseMeterConnected")
        meterConnected = true
    }
    
    public func glucoseMeterDisconnected(meter: CBPeripheral) {
        print("GlucoseMeterViewController#glucoseMeterDisconnected")
        meterConnected = false
    }
    
    func numberOfStoredRecords(number: UInt16) {
        print("GlucoseMeterViewController#numberOfStoredRecords - \(number)")
        glucoseMeasurementCount = number
        self.refreshTable()
        
        Glucose.sharedInstance().downloadAllRecords()
    }
    
    func glucoseMeasurement(measurement:GlucoseMeasurement) {
        print("glucoseMeasurement")
        
        if let measurementContext = getMeasurementContext(sequenceNumber: measurement.sequenceNumber) {
            print("glucoseMeasurement: attaching context to measurement")
            measurement.context = measurementContext
        }
        
        glucoseMeasurements.append(measurement)
        self.refreshTable()
    }
    
    func glucoseMeasurementContext(measurementContext:GlucoseMeasurementContext) {
        print("glucoseMeasurementContext - id: \(measurementContext.sequenceNumber)")
        
        if let measurement = getMeasurement(sequenceNumber: measurementContext.sequenceNumber) {
            print("glucoseMeasurementContext: attaching context to measurement")
            measurement.context = measurementContext
        }
        
        glucoseMeasurementsContexts.append(measurementContext)
        self.refreshTable()
    }
    
    func glucoseFeatures(features:GlucoseFeatures) {
        print("GlucoseMeterViewController#glucoseFeatures")
        glucoseFeatures = features
        
        self.refreshTable()
    }
    
    func glucoseMeterDidTransferMeasurements(error: NSError?) {
        print("GlucoseMeterViewController#glucoseMeterDidTransferMeasurements")
        
        if (nil != error) {
            print(error as Any)
        } else {
            print("transfer successful")
        }
    }
    
    public func glucoseError(error: NSError) {
        print("GlucoseMeterViewController#glucoseError")
        print(error.localizedDescription)
    }

    // MARK: - Storyboard
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let detailsViewController =  segue.destination as! GlucoseMeasurementDetailsViewController
        detailsViewController.glucoseMeasurement = selectedGlucoseMeasurement
    }
    
    // MARK: - UITableViewDataSource
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
                let contextWillFollow : Bool = (measurement.contextInformationFollows)
                
                cell.textLabel!.text = "[\(contextWillFollow.description)] (\(measurement.sequenceNumber!)) \(measurement.glucoseConcentration!) \(measurement.unit.description) (\(mmolString) mmol/L)"
                
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

    //MARK: - table delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if(indexPath.section == 2) {
            selectedGlucoseMeasurement = Array(glucoseMeasurements)[indexPath.row]
            performSegue(withIdentifier: "segueToMeasurementDetails", sender: self)
        }
    }
    
    // MARK: -
    func refreshTable() {
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
}
