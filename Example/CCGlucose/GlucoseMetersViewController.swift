//
//  GlucoseMetersViewController.swift
//  CCBluetooth
//
//  Created by Kevin Tallevi on 7/28/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import CCBluetooth
import CCGlucose
import CoreBluetooth

class GlucoseMetersViewController: UITableViewController, GlucoseMeterDiscoveryProtocol {
    private var glucose : Glucose!
    let cellIdentifier = "GlucoseMetersCellIdentifier"
    var glucoseMeters: Array<CBPeripheral> = Array<CBPeripheral>()
    var peripheral : CBPeripheral!
    let rc = UIRefreshControl()
    var isScanning: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("GlucoseMetersViewController#viewDidLoad")
        
        //tableView.refreshControl = rc
        //rc.attributedTitle = NSAttributedString(string: "Pull to scan")
        //rc.addTarget(self, action: #selector(refresh(sender:)), for: UIControlEvents.valueChanged)
        isScanning = false
        glucose = Glucose()
        glucose.glucoseMeterDiscoveryDelegate = self
    }
    
    func refresh(sender:AnyObject) {
        if(isScanning == false) {
            glucose = Glucose()
            glucose.glucoseMeterDiscoveryDelegate = self
        }
        rc.endRefreshing()
        isScanning = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let gmvc =  segue.destination as! GlucoseMeterViewController
        gmvc.selectedMeter = self.peripheral
    }
    
    func glucoseMeterDiscovered(glucoseMeter:CBPeripheral) {
        print("GlucoseMeterViewControllers#glucoseMeterDiscovered")
        glucoseMeters.append(glucoseMeter)
        print("glucose meter: \(glucoseMeter.name)")
        
        self.refreshTable()
    }
    
    // MARK: Table data source methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return glucoseMeters.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath as IndexPath) as UITableViewCell
        
        let glucoseMeter = Array(self.glucoseMeters)[indexPath.row]
        cell.textLabel!.text = glucoseMeter.name
        
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 75
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Glucose Meters"
    }
    
    //MARK: table delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("didSelectRowAtIndexPath")
        
        let glucoseMeter = Array(self.glucoseMeters)[indexPath.row]
        
        self.peripheral = glucoseMeter
        performSegue(withIdentifier: "segueToGlucoseMeter", sender: self)
                
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func refreshTable() {
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }

}
