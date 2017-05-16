#Change Log
All notable changes to this project will be documented in this file.
Particle iOS Device Setup library adheres to [Semantic Versioning](http://semver.org/).

---
## [0.8.0](https://github.com/spark/spark-setup-ios/releases/tag/0.8.0) (2017-3-28)

* Grand rename Spark->Particle accross Pod name, classes, files etc

## [0.7.0](https://github.com/spark/spark-setup-ios/releases/tag/0.7.0) (2017-3-28)

* Change: XCode 8 compatibility fixes

* Change: Force 8 characters passwords in signup

* Change: Added account info signup fields in UI and API request (name, company name, business account)

* Bugfix: Reset password button issue

* Change: "Product mode" deprecates "Organization mode" and fixes API requests

* Change: Wording of change ownership message during setup

* Change: Clean up some NSLogs

* Change: Updated and improved documentation

* Bugfix: Fix a bug that would sometimes cause a device to not get named after setup even if user wanted to name it

* Bugfix: Prevent multiple signup viewcontroller spawns by blocking signup button after first tap

* Change: Updated Pods and Carthage

## [0.6.1](https://github.com/spark/spark-setup-ios/releases/tag/0.6.1) (2016-9-12)

* Bugfix: Privacy policy and TOS will not cause app crash now

* Change: Moved from mixpanel to Segment analytics

* Added: lightStatusAndNavBar customization point

* Change: Instructional video is now always displayed landscape full screen

* Change: MODE button has been renamed to SETUP button (for Photon devices)

* Bugfix: Removed some obsolete NSLogs

## [0.6.0](https://github.com/spark/spark-setup-ios/releases/tag/0.6.0) (2016-7-22)

* Bugfix: didNotSucceedWithDeviceId - will only be called if delegate supports that (@optional)

* Added: 1Password integration for authentication

* Added: Listen to system events at last stage of setup to detect a device came online (even if it went straight to OTA)

* Change: Org/product error messages

## [0.5.0](https://github.com/spark/spark-setup-ios/releases/tag/0.5.0) (2016-5-19)

* New delegate function didFailWithDeviceID - will report the device ID that setup failed setting up

* Main setup delegate function will now report detailed failture codes via the ParticleSetupMainControllerResult enum (updated)

## [0.4.1](https://github.com/spark/spark-setup-ios/releases/tag/0.4.1) (2016-5-19)

* Missing setup assets bug fix (podspec issue)

## [0.4.0](https://github.com/spark/spark-setup-ios/releases/tag/0.4.0) (2016-4-5)

* Library now published as dynamic framework through Carthage

* Supress depraction warnings for iOS 9

* Operate with the iOS Cloud SDK 0.4.0

* Do not tint the success/warning/fail icon on last setup screen

## [0.3.3](https://github.com/spark/spark-setup-ios/releases/tag/0.3.3) (2015-11-25)

* Show a 'warning state' setup result if device has been setup successfully but does not come online

* Fix duplicate network names in scanned list - show only strongest RSSI network

## [0.3.2](https://github.com/spark/spark-setup-ios/releases/tag/0.3.2) (2015-09-27)

* Fix UI issues caused by XCode 7

* Fix resource bundle to include PNG files only so those can be resolved when integrating library in user app

* Change source to manual reference resources from library resource bundle

* UI/screen sizes bug fixes

* CHANGELOG added

## [0.3.1](https://github.com/spark/spark-setup-ios/releases/tag/0.3.1) (2015-09-15)

* Resource bundle changes

* iOS 9 fixes

## [0.3.0](https://github.com/spark/spark-setup-ios/releases/tag/0.3.0) (2015-08-27)

* Skip authentication mode

## [0.2.2](https://github.com/spark/spark-setup-ios/releases/tag/0.2.2) (2015-08-08)

* Optional app analytics

* Organizational/Product setup flow changes (match to iOS Cloud SDK changes)

## [0.2.1](https://github.com/spark/spark-setup-ios/releases/tag/0.2.1) (2015-07-26)

* Fix issues email upper/lowercase signing up/logging in

* Clearer errors on signup issues

* Add page background color view to background of each screen (new customization point)

* Alert user about update zero on end of setup process

* Local notification to return to setup app after connecting to photon network

* Pop back to device discovery behaviour when losing signal from device while in Wifi list

## [0.2.0](https://github.com/spark/spark-setup-ios/releases/tag/0.2.0) (2015-06-20)

* Many UI improvements and bugfixes

* Added customization points

* Instuctional setup video support

* Photon communication bugfixes

## [0.1.4](https://github.com/spark/spark-setup-ios/releases/tag/0.1.4) (2015-05-06)

* Documentation changes for beta SDK release

## [0.1.3](https://github.com/spark/spark-setup-ios/releases/tag/0.1.3) (2015-04-22)

* Authentication-only mode

* Match iOS Cloud SDK version changes

## [0.1.2](https://github.com/spark/spark-setup-ios/releases/tag/0.1.2) (2015-04-10)

* Swift compatibily fixes and bridging headers

* Documentation

## [0.1.1](https://github.com/spark/spark-setup-ios/releases/tag/0.1.1) (2015-04-07)

* Documentation changes

## [0.1.0](https://github.com/spark/spark-setup-ios/releases/tag/0.1.0) (2015-04-07)

* Initial release
