#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint barcode_scan.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'barcode_scan'
  s.version          = '0.0.1'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'MTBBarcodeScanner'
  s.dependency 'SwiftProtobuf'
  s.platform = :ios, '10.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.swift_version = '5.0'

#  s.resource_bundle = {
##    'barcode_scan' => ['barcode_scan/ios/Assets/*.xcassets']#  https://www.jianshu.com/p/e772b0713f9a
#    'barcode_scan' => ['barcode_scan/**/*.{xib,png,xcassets}']
#
#  }

end
