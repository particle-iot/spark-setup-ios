<p align="center" >
<img src="http://oi60.tinypic.com/116jd51.jpg" alt="Particle" title="Particle">
</p>

# Particle Device Setup library (beta)

[![Platform](https://img.shields.io/badge/platform-iOS-10a4fa.svg)]() [![license](https://img.shields.io/hexpm/l/plug.svg)]() [![version](https://img.shields.io/badge/pod-0.2.1-green.svg)]() 

The Particle Device Setup library is meant for integrating the initial setup process of Particle devices in your app.
This library will enable you to easily invoke a standalone setup wizard UI for setting up internet-connected products
powered by a Particle device (Photon, P0, P1). The setup UI can be easily customized by a customization proxy class,
that includes: look & feel, colors, texts and fonts as well as custom brand logos and custom instructional video for your product. There are good defaults in place if you don’t set these properties, but you can override the look and feel as needed to suit the rest of your app.

The wireless setup process for the Photon uses very different underlying technology from the Core. Where the Core used TI SmartConfig, the Photon uses what we call “soft AP” — i.e.: the Photon advertises a Wi-Fi network, you join that network from your mobile app to exchange credentials, and then the Photon connects using the Wi-Fi credentials you supplied.

With the Device Setup library, you make one simple call from your app, for example when the user hits a “Setup my device” button, and a whole series of screens then guide the user through the setup process. When the process finishes, the app user is back on the screen where she hit the “setup my device” button, and your code has been passed an instance of the device she just setup and claimed.

**Rebranding notice**

Spark has been recently rebranded as Particle. 
Code currently contains `SparkSetup` keyword as classes prefixes. this will soon be replaced with `ParticleDeviceSetup`. A new Cocoapod library will be published and current one will be depracated and point to the new one. This should not bother or affect your code in any way.

## Usage

Official documentation can be found in [Particle docs website](http://docs.particle.io/photon/ios/).

### Basic

Import `SparkSetup.h` in your view controller implementation file, and invoke the device setup wizard by:

**Objective-C**

```objc
SparkSetupMainController *setupController = [[SparkSetupMainController alloc] init];
setupController.delegate = self; // why? see "Advanced" section below 
[self presentViewController:setupController animated:YES completion:nil];
```

**Swift**

```swift
if let setupController = SparkSetupMainController()
{
    setupController.delegate = self
    self.presentViewController(setupController, animated: true, completion: nil)
}
```

Alternatively if your app requires separation between the Particle cloud authentication process and the device setup process you can call:

**Objective-C**

```objc
SparkSetupMainController *setupController = [[SparkSetupMainController alloc] initWithAuthenticationOnly:YES];
[self presentViewController:setupController animated:YES completion:nil];
```

**Swift**
```swift
if let setupController = SparkSetupMainController(authenticationOnly: true)
{
    self.presentViewController(setupController, animated: true, completion: nil)
}
```

This will invoke Particle Cloud authentication (login/signup/password recovery screens) only 
after user has successfully logged in or signed up, control will be returned to the calling app. 
If an active user session already exists control will be returned immediately.

####Configure device Wi-Fi credentials without claiming it

If your app requires the ability to let users configure device Wi-Fi credentials without changing its ownership you can also do that via `initWithSetupOnly`, 
and by allowing your users to skip authentication (see `allowSkipAuthentication` flag in customization section) if you present the authentication stage.
If an active user session exists - it'll be used and device will be claimed, otherwise it won't. 
So invoking setup without an active user session will go thru the setup steps required for configuring device Wi-Fi credentials but not for claiming it. 
However, calling `-initWithSetupOnly:` method with an active user session is essentially the same as calling `-init:`.
Usage:

```objc
SparkSetupMainController *setupController = [[SparkSetupMainController alloc] initWithSetupOnly:YES];
[self presentViewController:setupController animated:YES completion:nil];
```

**Swift**
```swift
if let setupController = SparkSetupMainController(setupOnly: true)
{
    self.presentViewController(setupController, animated: true, completion: nil)
}
```


### Customization

Customize setup look and feel by accessing the `SparkSetupCustomization` singleton appearance proxy `[SparkSetupCustomization sharedInstance]`
and modify its default properties. Setting the properties in this class is optional. *(Replace NSString with String for Swift projects)*

#### Product/brand info:

```objc
 NSString *deviceName;                  // Device/product name 
 UIImage *productImage;                 // Custom product image to display in "Get ready" screen *new*
 NSString *brandName;                   // Your brand name
 UIImage *brandImage;                   // Your brand logo to fit in header of setup wizard screens
 UIColor *brandImageBackgroundColor;    // brand logo background color
 NSString *instructionalVideoFilename;  // Instructional video shown when "show me how" button pressed
```

#### Technical data:

```objc
 NSString *modeButtonName;              // The mode button name on your product
 NSString *listenModeLEDColorName;      // The color of the LED when product is in listen mode
 NSString *networkNamePrefix;           // The SSID prefix of the Soft AP Wi-Fi network of your product while in listen mode
```

#### Links for legal/technical info:

```objc
 NSURL *termsOfServiceLinkURL;      // URL for terms of service of the app/device usage
 NSURL *privacyPolicyLinkURL;       // URL for privacy policy of the app/device usage
 NSURL *forgotPasswordLinkURL;      // URL for user password reset (non-organization setup app only) - to be disabled soon
 NSURL *troubleshootingLinkURL;     // URL for troubleshooting text of the app/device usage

 NSString *termsOfServiceHTMLFile;  // Static HTML file for terms of service of the app/device usage
 NSString *privacyPolicyHTMLFile;   // Static HTML file for privacy policy of the app/device usage
 NSString *forgotPasswordHTMLFile;  // Static HTML file for user password reset (non-organization setup app only) - to be disabled soon
 NSString *troubleshootingHTMLFile; // Static HTML file for troubleshooting text of the app/device usage
```

#### Look & feel:

```objc
 UIColor *pageBackgroundColor;     // setup screens background color
 UIImage *pageBackgroundImage;     // optional background image for setup screens
 UIColor *normalTextColor;         // normal text color
 UIColor *linkTextColor;           // link text color (will be underlined)
 UIColor *elementBackgroundColor;  // Buttons/spinners background color
 UIColor *elementTextColor;        // Buttons text color
 NSString *normalTextFontName;     // Customize setup font - include OTF/TTF file in project
 NSString *boldTextFontName;       // Customize setup font - include OTF/TTF file in project
 CGFloat fontSizeOffset;           // Set offset of font size so small/big fonts can be fine-adjusted
 BOOL tintSetupImages;             // This will tint the checkmark/warning/wifi symbols in the setup process to match text color (useful for dark backgrounds)
```

#### Organization:

Setting `organization=YES` will enable organization mode which uses different API endpoints and requires special permissions (See Particle Dashboard).
*New fields since v0.2.2*

If you set `organization` to `YES` be sure to also provide the `organizationSlug` and `productSlug` your created in [Particle Dashboard](https://docs.particle.io/guide/tools-and-features/dashboard/).
Make sure you inject the `SparkCloud` class with scoped OAuth credentials for creating customers (so app users could create an account), [read here](https://docs.particle.io/reference/ios/#oauth-client-configuration) on how to do it correctly.
To learn how to create those credentials for your organization [read here](https://docs.particle.io/guide/how-to-build-a-product/authentication/#creating-an-oauth-client).

```objc
 BOOL organization;             // enable organizational mode
 NSString *organizationName;    // organization display name
 NSString *organizationSlug;    // organizational name for API endpoint URL - must specify for orgMode *new*
 NSString *productName;         // product display name *new*
 NSString *productSlug;         // product string for API endpoint URL - must specify for orgMode *new*
```

#### Skipping authentication:

*New since v0.3.0*

```objc
 BOOL allowSkipAuthentication;          // Allow user to skip authentication (skip button will appear on signup and login screens)
 NSString *skipAuthenticationMessage;   // Message to display to user when she's requesting to skip authentication (Yes/No question)
```

### Advanced

You can get an active instance of `SparkDevice` by making your viewcontroller conform to protocol `<SparkSetupMainControllerDelegate>` when setup wizard completes:

```objc
-(void)sparkSetupViewController:(SparkSetupMainController *)controller didFinishWithResult:(SparkSetupMainControllerResult)result device:(SparkDevice *)device;
```

```swift
func sparkSetupViewController(controller: SparkSetupMainController!, didFinishWithResult result: SparkSetupMainControllerResult, device: SparkDevice!);
```

method will be called, if `(result == SparkSetupMainControllerResultSuccess)` or (or simply `(result == .Success)` in Swift) the device parameter will contain an active `SparkDevice` instance you can interact with
using the [iOS Cloud SDK](https://cocoapods.org/pods/Spark-SDK). 

#### Support for Swift projects
To use Particle Device Setup library from within Swift based projects [read here](http://swiftalicio.us/2014/11/using-cocoapods-from-swift/), 
also be sure the check out [Apple documentation](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/BuildingCocoaApps/InteractingWithObjective-CAPIs.html) on this matter.

### Example
Usage example app (in Swift) can be found [here](https://www.github.com/spark/spark-setup-ios-example/). Example app demonstates - invoking the setup wizard, customizing its UI and using the returned SparkDevice instance once 
setup wizard completes (delegate). Feel free to contribute to the example by submitting pull requests.

### Reference

Check out the [Reference in Cocoadocs website](http://cocoadocs.org/docsets/SparkSetup/) or consult the javadoc style comments in `SparkSetupCustomization.h` and `SparkSetupMainController.h` for each public method or property.
If the Device Setup library installation completed successfully - you should be able to press `Esc` to get an auto-complete hints from XCode for each public method or property in the library.

## Requirements / limitations

- iOS 8.0 and up supported
- Currently setup wizard displays on portait mode only.
- XCode 6.0 and up is required

## Installation

Particle Device Setup library is available through [CocoaPods](http://cocoapods.org) under the pod name `SparkSetup`. 
To install it, simply add the following line to your Podfile:

```ruby
pod "SparkSetup"
```

## Communication

- If you **need help**, use [Our community website](http://community.spark.io)
- If you **found a bug**, _and can provide steps to reliably reproduce it_, open an issue.
- If you **have a feature request**, open an issue.
- If you **want to contribute**, submit a pull request.


## Maintainers

- [Ido Kleinman](https://www.github.com/idokleinman)

## License

Particle Device Setup library is available under the Apache license 2.0. See the LICENSE file for more info.
