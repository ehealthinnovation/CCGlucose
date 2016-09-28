#
# Be sure to run `pod lib lint CCGlucose.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CCGlucose'
  s.version          = '0.2.5'
  s.summary          = 'A short description of CCGlucose.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC

Changelog

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
