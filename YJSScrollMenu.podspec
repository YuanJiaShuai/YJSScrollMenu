#
# Be sure to run `pod lib lint YJSScrollMenu.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'YJSScrollMenu'
  s.version          = '0.0.1'
  s.summary          = '类似美团淘宝的icon menu菜单'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: 类似美团淘宝的icon menu菜单
                       DESC

  s.homepage         = 'https://github.com/YuanJiaShuai/YJSScrollMenu'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'YuanJiaShuai' => '1361253662@qq.com' }
  s.source           = { :git => 'https://github.com/YuanJiaShuai/YJSScrollMenu.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'YJSScrollMenu/Classes/**/*'
  
  # s.resource_bundles = {
  #   'YJSScrollMenu' => ['YJSScrollMenu/Assets/*.png']
  # }

  s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'
  s.dependency 'YYWebImage', '~> 1.0.5'
  s.dependency 'Masonry', '~> 1.1.0'
end
