Pod::Spec.new do |s|
s.name             = 'ZJPictureBrowser'
s.version          = '0.1.0'
s.summary          = 'A simple picture browser'
s.description      = <<-DESC
TODO: A simple picture browser.
DESC

s.homepage         = 'https://github.com/syik/ZJPictureBrowser'
s.license          = { :type => 'MIT', :file => 'LICENSE' }
s.author           = { '281925019@qq.com' => 'Jsoul1227@hotmail.com' }
s.source           = { :git => 'https://github.com/syik/ZJPictureBrowser.git', :tag => s.version.to_s }

s.ios.deployment_target = '8.0'

s.source_files = 'ZJPictureBrowser/Classes/**/*'

s.public_header_files = 'ZJPictureBrowser/Classes/ZJPictureBrowser.h'
s.dependency 'SDWebImage'
end
