Pod::Spec.new do |s|
    s.name             = "SparkSetup"
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

    s.platform     = :ios, '7.1'
    s.requires_arc = true

    s.subspec 'Core' do |core|
        core.resource_bundle = {'SparkSetup' => ['Resources/**/*']}
        core.source_files  = 'Classes/**/*'
        core.frameworks    = 'SystemConfiguration', 'Security'
        core.dependency 'Spark-SDK'
    end


end
