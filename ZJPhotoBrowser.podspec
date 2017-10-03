Pod::Spec.new do |s|
  s.name             = 'ZJPhotoBrowser'
  s.version          = '0.1.0'
  s.summary          = 'A simple photo browser'
  s.description      = <<-DESC
TODO: A simple photo browser.
                       DESC

  s.homepage         = 'https://github.com/syik/ZJPhotoBrowser'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '281925019@qq.com' => 'Jsoul1227@hotmail.com' }
  s.source           = { :git => 'https://github.com/syik/ZJPhotoBrowser.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'ZJPhotoBrowser/Classes/**/*'

  s.public_header_files = 'ZJPhotoBrowser/Classes/ZJPhotoBrowser.h'
  s.dependency 'SDWebImage'
end
