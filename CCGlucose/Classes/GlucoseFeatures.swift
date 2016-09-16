//
//  GlucoseMeter.swift
//  Pods
//
//  Created by Kevin Tallevi on 7/13/16.
//
//

import Foundation
import CCToolbox

public class GlucoseFeatures : NSObject {
    var features: Int = 0
    
    public var lowBatterySupported: Bool?
    public var sensorMalfunctionDetectionSupported: Bool?
    public var sensorSampleSizeSupported: Bool?
    public var sensorStripInsertionErrorDetectionSupported: Bool?
    public var sensorStripTypeErrorDetectionSupported: Bool?
    public var sensorResultHighLowDetectionSupported: Bool?
    public var sensorTemperatureHighLowDetectionSupported: Bool?
    public var sensorReadInterruptDetectionSupported: Bool?
    public var generalDeviceFaultSupported: Bool?
    public var timeFaultSupported: Bool?
    public var multipleBondSupported: Bool?
    
    init(data: NSData?) {
        print("GlucoseFeatures#init - \(data)")
        let swappedFeatureData = data?.swapUInt16Data()
        var featureString = swappedFeatureData?.toHexString()
        var featureBytes = Int(strtoul(featureString, nil, 16))
        print("featureBytes: \(featureBytes)")
        
        lowBatterySupported = featureBytes.bit(0).toBool()
        sensorMalfunctionDetectionSupported = featureBytes.bit(1).toBool()
        sensorSampleSizeSupported = featureBytes.bit(2).toBool()
        sensorStripInsertionErrorDetectionSupported = featureBytes.bit(3).toBool()
        sensorStripTypeErrorDetectionSupported = featureBytes.bit(4).toBool()
        sensorResultHighLowDetectionSupported = featureBytes.bit(5).toBool()
        sensorTemperatureHighLowDetectionSupported = featureBytes.bit(6).toBool()
        sensorReadInterruptDetectionSupported = featureBytes.bit(7).toBool()
        generalDeviceFaultSupported = featureBytes.bit(8).toBool()
        timeFaultSupported = featureBytes.bit(9).toBool()
        multipleBondSupported = featureBytes.bit(10).toBool()
    }
}
