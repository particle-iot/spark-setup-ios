//
//  ParticleSetupUILabel.m
//  teacup-ios-app
//
//  Created by Ido on 1/16/15.
//  Copyright (c) 2015 particle. All rights reserved.
//

#import "ParticleSetupUILabel.h"
#import "ParticleSetupCustomization.h"
@implementation ParticleSetupUILabel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)replacePredefinedText
{
    self.text = [self.text stringByReplacingOccurrencesOfString:@"{device}" withString:[ParticleSetupCustomization sharedInstance].deviceName];
    self.text = [self.text stringByReplacingOccurrencesOfString:@"{brand}" withString:[ParticleSetupCustomization sharedInstance].brandName];
    self.text = [self.text stringByReplacingOccurrencesOfString:@"{color}" withString:[ParticleSetupCustomization sharedInstance].listenModeLEDColorName];
    self.text = [self.text stringByReplacingOccurrencesOfString:@"{mode button}" withString:[ParticleSetupCustomization sharedInstance].modeButtonName];
    self.text = [self.text stringByReplacingOccurrencesOfString:@"{network prefix}" withString:[ParticleSetupCustomization sharedInstance].networkNamePrefix];
    self.text = [self.text stringByReplacingOccurrencesOfString:@"{product}" withString:[ParticleSetupCustomization sharedInstance].productName];

    //    self.text = [self.text stringByReplacingOccurrencesOfString:@"{app name}" withString:[ParticleSetupCustomization sharedInstance].appName];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
//        [self replacePredefinedText];
        [self setType:self.type];
        return self;
    }
    return nil;
    
}

-(void)setType:(NSString *)type
{
    if ((type) && ([type isEqualToString:@"bold"]))
    {
        self.font = [UIFont fontWithName:[ParticleSetupCustomization sharedInstance].boldTextFontName size:self.font.pointSize+[ParticleSetupCustomization sharedInstance].fontSizeOffset];
        self.textColor = [ParticleSetupCustomization sharedInstance].normalTextColor;
    }
    else if ((type) && ([type isEqualToString:@"header"]))
    {
        self.font = [UIFont fontWithName:[ParticleSetupCustomization sharedInstance].headerTextFontName size:self.font.pointSize+[ParticleSetupCustomization sharedInstance].fontSizeOffset];
        self.textColor = [ParticleSetupCustomization sharedInstance].normalTextColor;
    }
    else
    {
        self.font = [UIFont fontWithName:[ParticleSetupCustomization sharedInstance].normalTextFontName size:self.font.pointSize+[ParticleSetupCustomization sharedInstance].fontSizeOffset];
        self.textColor = [ParticleSetupCustomization sharedInstance].normalTextColor;
        
    }
    [self replacePredefinedText];
    
    [self setNeedsDisplay];
    [self layoutIfNeeded];
  
}

@end
