#
# Be sure to run `pod lib lint Spark-Setup.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "Spark-Setup"
  s.version          = "0.1.0"
  s.summary          = "Spark soft AP setup library for integrating setup process of Spark devices in your app"
  s.description      = <<-DESC
                        Spark Soft AP setup module for integrating setup process of Spark devices in your app
                        This library will allow you to easily invoke a standalone setup wizard UI for setting up
                        Spark devices from within your app. Setup UI can be easily customized to the look & feel as well as
                        custom brand logos/colors and instructional video.
                       DESC
  s.homepage         = "https://github.com/spark/spark-setup-ios"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'LGPL v3'
  s.author           = { "Ido Kleinman" => "ido@spark.io" }
  s.source           = { :git => "https://github.com/spark/spark-setup-ios.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '7.0'
  s.requires_arc = true


  s.subspec 'User' do |ss|
    s.public_header_files = 'Pod/Classes/User/*.h'
    s.source_files = 'Pod/Classes/User/**/*'
  end


  s.subspec 'Comm' do |ss|
      ss.source_files = 'Pod/Classes/Comm/*.{h,m}'
      ss.frameworks = 'SystemConfiguration', 'Security'
  end

  s.subspec 'UI' do |ss|
      ss.source_files = 'Pod/Classes/UI/**/*'
      ss.dependency 'Spark-SDK'
      ss.dependency 'Spark-Setup/Comm'
      ss.dependency 'Spark-Setup/User'
      ss.resources    = 'Pod/Classes/UI/setup.storyboard'
      ss.resource_bundles = {
        'Spark-Setup' => ['Pod/Assets/*.*']
      }
      ss.frameworks = 'UIKit'
  end

  
  # s.frameworks = 'UIKit', 'SystemConfiguration', 'Security'
  # s.dependency 'Spark-SDK'
end
