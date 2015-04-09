Pod::Spec.new do |s|
    s.name             = "SparkSetup"
    s.version          = "0.1.2"
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

    s.platform     = :ios, '7.1'
    s.requires_arc = true

    s.public_header_files = 'Classes/*.h'
    s.source_files  = 'Classes/*.h'
    
    s.subspec 'Resources' do |resources|
        resources.resource_bundle = {'SparkSetup' => ['Resources/**/*']}
    end

    s.subspec 'Core' do |core|
        core.source_files  = 'Classes/User/**/*.{h,m}', 'Classes/UI/**/*'
        core.dependency 'Spark-SDK'
        core.dependency 'SparkSetup/Comm'
        core.dependency 'SparkSetup/Resources'
        core.ios.frameworks    = 'UIKit'
    end

    s.subspec 'Comm' do |comm|
        comm.source_files  = 'Classes/Comm/**/*'
        comm.ios.frameworks    = 'SystemConfiguration', 'Security'
    end



end
