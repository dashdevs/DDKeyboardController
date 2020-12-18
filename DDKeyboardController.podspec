#
# Be sure to run `pod lib lint KeyboardController.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DDKeyboardController'
  s.version          = '0.0.1'
  s.summary          = 'A collection of keyboard-related utilities for Cocoa Touch and UIKit.'
  s.homepage         = 'https://dashdevs.com'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'dashdevs llc' => 'hello@dashdevs.com' }
  s.source           = { :git => 'https://github.com/dashdevs/DDKeyboardController.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'
  s.source_files = 'KeyboardController/Classes/**/*'
  s.swift_version = '5.0'
end
