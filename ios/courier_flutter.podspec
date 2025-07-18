#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint courier_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|

  s.name             = 'courier_flutter'
  s.version          = '0.0.1'
  s.summary          = 'Courier Flutter SDK'
  s.description      = <<-DESC
Inbox, Push Notification & Preferences for Flutter by Courier
                       DESC
  s.homepage         = 'http://courier.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Courier' => 'mike@courier.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'Courier_iOS', '5.7.14'
  s.platform = :ios, '15.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.6'

end
