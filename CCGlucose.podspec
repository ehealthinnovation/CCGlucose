#
# Be sure to run `pod lib lint CCGlucose.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CCGlucose'
  s.version          = '0.3.9'
  s.summary          = 'Support for the Bluetooth Glucose Profile'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC

Changelog

0.3.9: fixed bug that attempted to read all characteristics instead of just those that supported reading

0.3.8: swift4 compatibility

0.3.7: fixed measurement and context parsing issues

0.3.6: added support for software and hardware revision characteristics

0.3.5: assigning context to measurement in example applicaton

0.3.4: using CCGlucose as a singleton

0.3.3: fixed build warnings

0.3.2: dateTime was not being parsed if timeOffSet bit was set to zero

0.3.1: fix for null values when reading characteristics

0.3.0: glucoseMeterDidTransferMeasurements callback when transfer is complete

0.2.9: expose peripheral name

0.2.8: fix for peripheral being prematurely released

0.2.7: added GlucoseMeasurementContextMeal for Meal

0.2.6: more objc support for GlucoseMeasurementContext

0.2.5: added objc support for GlucoseMeasurementContext

0.2.4: added reconnect

                       DESC

  s.homepage         = 'https://github.ehealthinnovation.org/PHIT/CCGlucose'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Kevin Tallevi' => 'ktallevi@ehealthinnovation.org' }
  s.source           = { :git => 'https://github.ehealthinnovation.org/PHIT/CCGlucose.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'CCGlucose/Classes/**/*'

  # s.resource_bundles = {
  #   'CCGlucose' => ['CCGlucose/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'CCBluetooth'
  s.dependency 'CCToolbox'
end
