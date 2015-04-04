//
//  SparkSetupViewController.h
//  mobile-sdk-ios
//
//  Created by Ido Kleinman on 12/13/14.
//  Copyright (c) 2014-2015 Spark. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SparkSetupUIViewController : UIViewController

-(BOOL)isValidEmail:(NSString *)checkString; // should be in NSString category
-(void)disableKeyboardMovesViewUp; // might not be needed when we remove all popups

@end
