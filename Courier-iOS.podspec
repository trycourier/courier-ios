Pod::Spec.new do |s|

    s.name             = 'Courier-iOS'
    s.version          = '2.0.02'
    s.summary          = 'Courier helps you build messaging infrastucture much faster!'

    s.homepage         = 'https://github.com/trycourier/courier-ios'
    s.license          = { :type => 'MIT', :text => <<-LICENSE
                           Copyright 2023 TryCourier

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

                         LICENSE
                       }
    s.author           = { 'Mike Miller' => 'mike@courier.com' }
    s.source           = { :git => 'https://github.com/trycourier/courier-ios.git', :tag => s.version.to_s }
        
    s.ios.deployment_target = '13.0'
    s.swift_version = '5.6'
    
    s.source_files = 'Sources/Courier/**/**'
    s.resource_bundles = {
        'Resources' => [
            'Sources/Courier/Inbox/*.xib',
            'Sources/Courier/*{.xcassets}'
        ]
    }
    
    s.dependency 'FirebaseMessaging', '10.6.0'
        
end
