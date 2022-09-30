Pod::Spec.new do |s|

    s.name             = 'Courier'
    s.version          = '1.0.3'
    s.summary          = 'A short description of Courier.'

    s.homepage         = 'https://github.com/trycourier/courier-ios'
    s.license          = { :type => 'MIT', :file => 'LICENSE.md' }
    s.author           = { 'Mike Miller' => 'mike@courier.com' }
    s.source           = { :git => 'https://github.com/trycourier/courier-ios.git', :tag => s.version.to_s }
        
    s.ios.deployment_target = '13.0'
    s.swift_version = '5.6'
        
    s.source_files = 'Sources/Courier/**/*'
        
end
