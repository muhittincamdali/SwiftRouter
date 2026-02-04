Pod::Spec.new do |s|
  s.name             = 'SwiftRouter'
  s.version          = '1.0.0'
  s.summary          = 'Type-safe routing framework for iOS applications.'
  s.description      = 'SwiftRouter provides type-safe routing with deep linking support.'
  s.homepage         = 'https://github.com/muhittincamdali/SwiftRouter'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Muhittin Camdali' => 'contact@muhittincamdali.com' }
  s.source           = { :git => 'https://github.com/muhittincamdali/SwiftRouter.git', :tag => s.version.to_s }
  s.ios.deployment_target = '15.0'
  s.swift_versions = ['5.9', '5.10', '6.0']
  s.source_files = 'Sources/**/*.swift'
end
