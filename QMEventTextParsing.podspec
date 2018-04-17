#
# Be sure to run `pod lib lint QMEventTextParsing.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'QMEventTextParsing'
  s.version          = '1.1.0'
  s.summary          = 'A framework to parse date, place and person from a sentence'
  
  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  
  s.description      = <<-DESC
  A framework to parse date, place and person from a sentence. It uses geocoding to provide a valid place. it uses relationships to provide valid person names from candidates.
  DESC
  
  s.homepage         = 'https://github.com/truebucha/QMEventTextParsing'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'truebucha' => 'truebucha@gmail.com' }
  s.source           = { :git => 'https://github.com/truebucha/QMEventTextParsing.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/truebucha'
  
  s.ios.deployment_target = '10.0'
  s.osx.deployment_target = '10.10'
  
  s.source_files = 'QMEventTextParsing/Classes/**/*'
  s.public_header_files = 'QMEventTextParsing/Classes/**/*.h'
  s.frameworks = 'Foundation'
  s.dependency 'QMGeocoder'
  s.dependency 'CDBKit'
end
