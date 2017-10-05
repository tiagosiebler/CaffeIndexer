//
//  AppDelegate.h
//  ButtonImageManager
//
//  Created by Siebler, Tiago on 09/04/2017.
//  Copyright © 2017 TGS. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property (weak) IBOutlet NSImageView *imageView;

@property (weak) IBOutlet NSTextField *hashField;
@property (weak) IBOutlet NSButton *isActive;

@end

