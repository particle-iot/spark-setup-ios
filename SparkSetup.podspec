Pod::Spec.new do |s|
    s.name             = "SparkSetup"
    s.version          = "0.3.1"
    s.summary          = "Particle iOS Device Setup library for easy integration of setup process for Particle devices in your app"
    s.description      = <<-DESC
                        Particle (formerly Spark) Device Setup library for integrating setup process of Particle devices in your app
                        This library will allow you to easily invoke a standalone setup wizard UI for setting up
                        Particle devices (photon) from within your app. Setup UI look & feel can be easily customized with custom brand
                        logos/colors/fonts/texts and instructional video.
                        DESC
    s.homepage         = "https://github.com/spark/spark-setup-ios"
    s.screenshots      = "http://i58.tinypic.com/15yhdeb.jpg"
    s.license          = 'Apache 2.0'
    s.author           = { "Particle" => "ido@particle.io" }
    s.source           = { :git => "https://github.com/spark/spark-setup-ios.git", :tag => s.version.to_s }
    s.social_media_url = 'https://twitter.com/particle'

    s.platform     = :ios, '8.0'
    s.requires_arc = true

    s.public_header_files = 'Classes/*.h'
    s.source_files  = 'Classes/*.h'
    
    s.subspec 'Resources' do |resources|
        resources.resource_bundle = {'SparkSetup' => ['Resources/**/*.{xcassets,storyboard}']}
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
