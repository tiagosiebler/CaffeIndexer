//
//  AppDelegate.h
//  ImageManager
//
//  Created by Siebler, Tiago on 09/03/2017.
//  Copyright © 2017 TGS. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property (weak) IBOutlet NSImageView *imageView;
@property (weak) IBOutlet NSImageView *suitImageView;

@property (weak) IBOutlet NSButton *heartButton;
@property (weak) IBOutlet NSButton *diamondButton;
@property (weak) IBOutlet NSButton *spadeButton;
@property (weak) IBOutlet NSButton *clubButton;
@property (weak) IBOutlet NSTextField *overallHash;
@property (weak) IBOutlet NSTextField *suitHash;

@property (weak) IBOutlet NSTextField *AIStatusField;
@property (weak) IBOutlet NSTextField *AIStatusField2;


@end

