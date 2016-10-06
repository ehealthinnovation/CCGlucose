//
//  ObjectiveCViewController.m
//  CCGlucose
//
//  Created by Jay Moore on 2016-09-20.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

#import "ObjectiveCViewController.h"
#import "CCGlucose-Swift.h"

@interface ObjectiveCViewController () <GlucoseProtocol, GlucoseMeterDiscoveryProtocol>
@property (nonatomic, strong) Glucose *glucose;
@end

@implementation ObjectiveCViewController

// note: view controller is just for testing that methods can compile in obj

- (void)viewDidLoad;
{
    [super viewDidLoad];
    
    self.glucose = [[Glucose alloc] init];
    
    NSString *uuid = self.glucose.uuid;
    NSString *name = self.glucose.name;
    
    NSLog(@"uuid: %@ name: %@", uuid, name);
    
    GlucoseMeasurementContext *context = nil;
    
    if (context.objc_hasCarbohydrateID) {
        CarbohydrateID carb = context.objc_carbohydrateID;
        NSLog(@"carb: %d", (int)carb);
    }
    
    if (context.objc_hasMeal) {
        GlucoseMeasurementContextMeal meal = context.objc_meal;
        NSLog(@"meal: %d", (int)meal);
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - GlucoseMeterDiscoveryProtocol
- (void)glucoseMeterDiscoveredWithGlucoseMeter:(CBPeripheral * _Nonnull)glucoseMeter;
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

#pragma mark - GlucoseProtocol

- (void)numberOfStoredRecordsWithNumber:(uint16_t)number;
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)glucoseMeasurementWithMeasurement:(GlucoseMeasurement * _Nonnull)measurement;
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
//    GlucoseConcentrationUnits unit;
//    = measurement.glucoseConcentrationUnits;
    
}

- (void)glucoseMeasurementContextWithMeasurementContext:(GlucoseMeasurementContext * _Nonnull)measurementContext;
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)glucoseFeaturesWithFeatures:(GlucoseFeatures * _Nonnull)features;
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)glucoseMeterConnectedWithMeter:(CBPeripheral * _Nonnull)meter;
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)glucoseMeterDisconnectedWithMeter:(CBPeripheral * _Nonnull)meter;
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

@end
