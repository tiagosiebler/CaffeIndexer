//
//  AppDelegate.m
//  ImageManager
//
//  Created by Siebler, Tiago on 09/03/2017.
//  Copyright © 2017 TGS. All rights reserved.
//

#import "AppDelegate.h"
#import "NSData+Adler32.h"
#import "NSImage+subImage.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate
typedef NS_ENUM(NSUInteger, CardSuit) {
    kHeart,
    kDiamond,
    kSpade,
    kClub,
    kUnknown
};
typedef NS_ENUM(NSUInteger, CardType) {
    kNoise,
    kTable,
    kButton,
    kCard
};

typedef NS_ENUM(NSUInteger, ButtonType){
    kButtonTypeAllIn,
    kButtonTypeCall,
    kButtonTypeRaise,
    kButtonTypeCheck,
    kButtonTypeFold,
    kButtonTypeNewTable,
    kButtonTypeStandUp,
    kButtonTypeInactive,
    kButtonTypeUnknown
};



static NSString *kCardTypeSuit      = @"cardSuit";
static NSString *kCardTypeCard      = @"card";
static NSString *kCardTypeTable     = @"table";
static NSString *kCardTypeNoise     = @"noise";
//static NSString *kCardTypeButton    = @"button";
static NSString *kCardTypeUnknown   = @"unkn";

static NSString *kGameStateKeyPath      = @"gameState";
static NSString *kLastOddsQueryKeyPath  = @"lastOddsQuery";
static NSString *kPlayersWithCardsKeyPath = @"numberOfPlayersWithCards";
static NSString *kWinningOddsPath       = @"winningOdds";
static NSString *kHasHandKeyPath        = @"hasHand";
static NSString *kUnknownImagesCount    = @"unknownImagesCount";

static NSString *kCardSuitHeart     = @"h";
static NSString *kCardSuitClub      = @"c";
static NSString *kCardSuitDiamond   = @"d";
static NSString *kCardSuitSpade     = @"s";

static NSString *kCardValue2        = @"2";
static NSString *kCardValue3        = @"3";
static NSString *kCardValue4        = @"4";
static NSString *kCardValue5        = @"5";
static NSString *kCardValue6        = @"6";
static NSString *kCardValue7        = @"7";
static NSString *kCardValue8        = @"8";
static NSString *kCardValue9        = @"9";
static NSString *kCardValue10       = @"T";
static NSString *kCardValueJ        = @"J";
static NSString *kCardValueQ        = @"Q";
static NSString *kCardValueK        = @"K";
static NSString *kCardValueA        = @"A";

static NSString *kPathImageRoot     = @"/Users/tsiebler/Desktop/pkr/images";
static NSString *kPathKnown         = @"known";
static NSString *kPathUnknown       = @"unknown";
static NSString *kPathCards         = @"cards";
static NSString *kPathUnknownCards  = @"card";
static NSString *kPathButtons       = @"buttons";
static NSString *kPathUnknownButtons= @"button";

static NSString *kPathTable         = @"_table";
static NSString *kPathNoise         = @"_noise";
static NSString *kPathSuits         = @"_suits";
static NSString *kPathPlayerHands   = @"playerHands";
static NSString *kPathdbgValue      = @"dbgValue";

static NSString *kButtonStringFold      = @"Fold";
static NSString *kButtonStringInactive  = @"Inactive";
static NSString *kButtonStringCheck     = @"Check";
static NSString *kButtonStringAllIn     = @"AllIn";
static NSString *kButtonStringNewTable  = @"NewTable";
static NSString *kButtonStringStandUp   = @"StandUp";

static NSString *kImageChip             = @"chip";
static NSString *kImageDealerChip       = @"dealerChip";
static NSString *kImageButtonChatSend   = @"buttonChatSend";
static NSString *kImageButtonNewTable   = @"buttonNewTable";
static NSString *kImageButtonStandUp    = @"buttonStandUp";
static NSString *kImageButtonToLobby    = @"buttonToLobby";
static NSString *kImageButtonFoldActive = @"buttonToLobby";
static NSString *kImageButtonBottomLeft = @"buttonActionBottomLeft";
static NSString *kImageButtonBottomRight= @"buttonActionBottomRight";
static NSString *kImageButtonTopLeft    = @"buttonActionTopLeft";
static NSString *kImageButtonTopRight   = @"buttonActionTopRight";

static NSString *kDictRect           = @"rect";
static NSString *kDictHash           = @"hash";
static NSString *kDictFound          = @"posFound";

NSUInteger cardSuit;
int i = 0;
NSArray *files;
NSString *currentPath;
NSString *resultFolder;
NSString *pathToUnknowns;
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    //pathToUnknowns = @"/Users/tsiebler/Desktop/pkr/images/card";
    pathToUnknowns = [NSString stringWithFormat:@"%@/%@/%@",kPathImageRoot,kPathUnknown,kPathUnknownButtons];;
    resultFolder = [NSString stringWithFormat:@"%@/%@",kPathImageRoot,kPathKnown];;
    
    //NSLog(@"array: %@",array);
    
    [self loadImages];
    [self loadNextCard];
}

- (void)loadImages{
    NSError *error;
    NSArray *properties = [NSArray arrayWithObjects: NSURLLocalizedNameKey,
                           NSURLCreationDateKey, NSURLLocalizedTypeDescriptionKey, nil];
    files = [[NSFileManager defaultManager]
             contentsOfDirectoryAtURL:[NSURL URLWithString:pathToUnknowns]
             includingPropertiesForKeys:properties
             options:(NSDirectoryEnumerationSkipsHiddenFiles)
             error:&error];
    i = 0;
    [self setCurrentImage];
}
NSImage *currentImage;
NSImage *currentSuitImage;
static BOOL looping = false;
- (void)setCurrentImage{
    //files is empty when all images are processed
    NSLog(@"setCurrentImage");
    if(files != nil && [files count] == 0){
        if(!looping) [self performSelector:@selector(loadNextCard) withObject:nil afterDelay:2];
        looping = true;
        return;
    }
    looping = false;
    
    if(i >= [files count]) return;
    
    NSString* imagePath = [files objectAtIndex:i];
    NSArray *pathComponents = [imagePath pathComponents];
    //NSString *type = [pathComponents objectAtIndex:([pathComponents count] -2)];
    //NSString *fileName = [[imagePath lastPathComponent] stringByDeletingPathExtension];
    //NSLog(@"image: %@, %@",type, fileName);
    
    currentPath = [[NSString stringWithFormat:@"%@",imagePath] stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    //NSLog(@"imagePath: %@",currentPath);
    if ([[NSFileManager defaultManager] fileExistsAtPath:currentPath]){
        currentImage =  [[NSImage alloc] initWithContentsOfFile:currentPath];
        [self.imageView setImage:currentImage];
    }else{
        [self loadImages];
        [self loadNextCard];
    }
}



- (void)setCurrentSuit:(NSString*)suit{

}
- (void)getSuitFromImage:(NSImage*)image{
    /*
    currentSuitImage = [image getSubImageWithRect:NSMakeRect(0, 35, image.size.width, 20)];
    [[self suitImageView] setImage:currentSuitImage];
    int suitHash = [[currentSuitImage TIFFRepresentation] adler32];
    [[self suitHash] setStringValue:[NSString stringWithFormat:@"%d",suitHash]];
    NSLog(@"suitHash: %d",suitHash);
    //if(suitHash == 0) [self loadNextCard];
    
    NSString *suit;
    // look for matching known suit hash
    int type = [self getKnownImageType:[NSString stringWithFormat:@"%d",suitHash]];
    switch(type){
        case kTable:
            NSLog(@"%@", kPathTable);
            [self table:nil];
            break;
            
        case kNoise:
            NSLog(@"%@", kPathNoise);
            //[self noise:nil];
            [self.heartButton   setState:0];
            [self.diamondButton setState:0];
            [self.spadeButton   setState:0];
            [self.clubButton    setState:0];
            break;
            
        case kCard:
            suit = [self getSuitForChecksum:[NSString stringWithFormat:@"%d",suitHash]];
            [self setCurrentSuit:suit];
            NSLog(@"card: %@",suit);
            
            break;
            
        case kUnknown:
            NSLog(@"not known");
            [self.heartButton   setState:0];
            [self.diamondButton setState:0];
            [self.spadeButton   setState:0];
            [self.clubButton    setState:0];
            cardSuit = kUnknown;
            break;
    }
    
    // parse suit, if not known, the uncheck the current suits:
    //*/
    
}


NSSet *knownNoise;
NSSet *knownTable;

NSMutableSet *knownSuitsSet;
NSArray *knownSuitsArray;
- (NSArray*)suitsFromPath:(NSString*)path{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *directoryURL = [NSURL URLWithString:path]; // URL pointing to the directory you want to browse
    NSArray *keys = [NSArray arrayWithObject:NSURLIsDirectoryKey];
    
    NSDirectoryEnumerator *enumerator = [fileManager
                                         enumeratorAtURL:directoryURL
                                         includingPropertiesForKeys:keys
                                         options:NSDirectoryEnumerationSkipsHiddenFiles
                                         errorHandler:^(NSURL *url, NSError *error) {
                                             // Handle the error.
                                             // Return YES if the enumeration should continue after the error.
                                             return YES;
                                         }];
    
    NSMutableArray *returnArray;
    if (!returnArray) returnArray = [[NSMutableArray alloc] init];
    
    for (NSURL *url in enumerator) {
        NSError *error;
        NSNumber *isDirectory = nil;
        if (! [url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:&error]) {
            // handle error
        }
        else if (! [isDirectory boolValue]) {
            // No error and it’s not a directory; do something with the file
            NSString *fullPath  = [[url absoluteString] stringByReplacingOccurrencesOfString:@"file://" withString:@""];
            
            //NSLog(@"found file: %@, last component: %@",fullPath, [[fullPath lastPathComponent] stringByDeletingPathExtension]);
            if(![fullPath containsString:kPathTable] && ![fullPath containsString:kPathNoise]){
                //NSLog(@"found card: %@, last component: %@",fullPath, [[fullPath lastPathComponent] stringByDeletingPathExtension]);
                [returnArray addObject:fullPath];
                [knownSuitsSet addObject:[fullPath lastPathComponent]];
            }else if([fullPath containsString:kPathTable]){
                //NSLog(@"table: %@", fullPath);
            }else if([fullPath containsString:kPathNoise]){
                //NSLog(@"noise: %@", fullPath);
            }else{
                NSLog(@"other? %@", fullPath);
            }
        }
    }
    
    return returnArray;
}
- (NSString*)suitsPath{
    //return @"/Users/tsiebler/Desktop/pkr/images/known/_suits/";
    return [NSString stringWithFormat:@"%@/%@/%@/",kPathImageRoot,kPathKnown,kPathSuits];
}
- (NSString*)knownNoisePath{
    return [NSString stringWithFormat:@"%@/%@/%@/",kPathImageRoot,kPathKnown,kPathNoise];
}
- (NSString*)knownTablePath{
    return [NSString stringWithFormat:@"%@/%@/%@/",kPathImageRoot,kPathKnown,kPathTable];
}

- (int)getKnownImageType:(NSString*)checksum{
    if([knownSuitsSet containsObject:[checksum stringByAppendingString:@".png"]]) return kCard;
    if([knownTable containsObject:[checksum stringByAppendingString:@".png"]]) return kTable;
    if([knownNoise containsObject:[checksum stringByAppendingString:@".png"]]) return kNoise;
    return kUnknown;
}
- (NSString*)getSuitForChecksum:(NSString*)checksum{
    for(NSString *currentPath in knownSuitsArray){
        if([currentPath containsString:checksum]){
            NSArray *pathComps = [currentPath pathComponents];
            // NSString *theSuit = [pathComps objectAtIndex:([pathComps count] - 3)];
            NSString *theSuit = [pathComps objectAtIndex:([pathComps count] - 2)];
            //NSLog(@"card %@, suit: %@", theValue, theSuit);
            return theSuit;
        }
    }
    return nil;
}
- (void)reloadKnownSuits{
    NSFileManager* fileManager = [[NSFileManager alloc] init];
    NSError *error;
    
    // known noise
    NSArray *knownNoiseArray = [fileManager contentsOfDirectoryAtPath:[self knownNoisePath] error:&error];
    knownNoise = [NSSet setWithArray:knownNoiseArray];
    
    // known table
    NSArray *knownTableArray = [fileManager contentsOfDirectoryAtPath:[self knownTablePath] error:&error];
    knownTable = [NSSet setWithArray:knownTableArray];
    
    // known suits
    if(knownSuitsSet) [knownSuitsSet removeAllObjects];
    knownSuitsSet = [NSMutableSet set];
    knownSuitsArray = [self suitsFromPath:[self suitsPath]];
    
    //NSLog(@"knownSuitsArray:%@ fromPath:%@",knownSuitsArray, [self suitsPath]);
}
- (void)loadNextCard{
    if(files != nil && [files count] != i){
        NSLog(@"count: %lu, %d",(unsigned long)[files count], i);
        [self setCurrentImage];
        i++;
    }else{
        [self.imageView setImage:nil];
        //[self.suitImageView setImage:nil];
        
        cardSuit = kUnknown;
        
        [self.hashField setStringValue:@"reloading..."];
        [self performSelector:@selector(loadImages) withObject:nil afterDelay:2];
        
        NSLog(@"reloading");
    }
    
}
- (IBAction)reload:(id)sender {
    i = 0;
    [self loadImages];
    [self loadNextCard];
}
- (void)alertWithString:(NSString*)text{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Error"];
    [alert setInformativeText:text];
    [alert addButtonWithTitle:@"Ok"];
    [alert runModal];
}
- (void)saveImageForSuit:(NSString*)suit{
    // currentSuitImage
    //    cardSuit
    NSString *suitPath;// = [NSString stringWithFormat:@"/Users/tsiebler/Desktop/pkr/images/known/cards/_suits%@%d.png",suit,[[currentSuitImage TIFFRepresentation] adler32]];
#warning clean up suit so it's not wrapped in slashes, so this is cleaner
    suitPath = [NSString stringWithFormat:@"%@/%@/%@/%@%d.png",kPathImageRoot,kPathKnown,kPathSuits,suit,[[currentSuitImage TIFFRepresentation] adler32]];
    [currentSuitImage saveAsPNGWithName:suitPath];
    
}
- (void)handleCardOfValue:(NSString*)value{
    NSString *suit;
    NSString *targetPath;
    switch(cardSuit){
        case kHeart:
            suit = [NSString stringWithFormat:@"/%@/",kCardSuitHeart];
            [self saveImageForSuit:suit];
            break;
            
        case kClub:
            suit = [NSString stringWithFormat:@"/%@/",kCardSuitClub];
            [self saveImageForSuit:suit];
            break;
            
        case kDiamond:
            suit = [NSString stringWithFormat:@"/%@/",kCardSuitDiamond];
            [self saveImageForSuit:suit];
            break;
            
        case kSpade:
            suit = [NSString stringWithFormat:@"/%@/",kCardSuitSpade];
            [self saveImageForSuit:suit];
            break;
            
        case kUnknown:
            NSLog(@"no suit selected!!");
            [self alertWithString:@"No suit selected!"];
            return;
            break;
    }
    
    // path to 'suit' subfolder
    //targetPath = [[resultFolder stringByAppendingString:@"/cards"] stringByAppendingString:suit];
    targetPath = [[NSString stringWithFormat:@"%@/%@",resultFolder,kPathCards] stringByAppendingString:suit];
    
    // path to 'value' subfolder
#warning probably don't need this, since the suit is already wrapped with /
    targetPath = [[targetPath stringByAppendingString:value] stringByAppendingString:@"/"];
    targetPath = [targetPath stringByAppendingString:[currentPath lastPathComponent]];
    
    NSLog(@"targetPath: %@",targetPath);
    [self moveFile:currentPath toTarget:targetPath];
    [self loadNextCard];
}
- (void)markAsNoise{
    [self saveImageForSuit:[NSString stringWithFormat:@"/%@/",kPathNoise]];
    
    
    NSString *targetPath;
    targetPath = [resultFolder stringByAppendingString:[NSString stringWithFormat:@"/%@/",kPathNoise]];
    targetPath = [targetPath stringByAppendingString:[currentPath lastPathComponent]];
    
    NSLog(@"movingToNoise: %@",targetPath);
    [self moveFile:currentPath toTarget:targetPath];
    [self loadNextCard];
    
}
- (void)moveFile:(NSString*)srcFile toTarget:(NSString*)target{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError* error;
    // move currentPath to targetPath
    [fileManager moveItemAtPath:srcFile
                         toPath:target
                          error:&error];
    
    if ([fileManager fileExistsAtPath:srcFile] == YES) {
        [fileManager removeItemAtPath:srcFile error:&error];
    }
}
- (void)markAsTable{
    [self saveImageForSuit:[NSString stringWithFormat:@"/%@/",kPathTable]];
    
    NSString *targetPath;
    targetPath = [NSString stringWithFormat:@"%@/%@/",resultFolder,kPathTable];
    //targetPath = [[resultFolder stringByAppendingString:@"/cards"] stringByAppendingString:[NSString stringWithFormat:@"/%@/",kPathTable]];
    targetPath = [targetPath stringByAppendingString:[currentPath lastPathComponent]];
    
    NSLog(@"movingToTable: %@",targetPath);
    [self moveFile:currentPath toTarget:targetPath];
    
    [self loadNextCard];
}
- (void)markImageAs:(int)type ofValue:(NSString*)value{
    if(type == kNoise){
        [self markAsNoise];
    }else if(type == kTable){
        [self markAsTable];
    }else if(type == kCard){
        [self handleCardOfValue:value];
    }
}
- (void)markImageAtPath:(NSString*)path As:(int)type ofValue:(NSString*)value{
    if(type == kNoise){
        [self markAsNoise:path];
    }else if(type == kTable){
        [self markAsTable:path];
    }else if(type == kCard){
        [self handleCardOfValue:value atPath:path];
    }
}
- (void)markImageAs:(int)type ofButtonType:(ButtonType)buttonType{
    if(type == kNoise){
        [self markAsNoise];
    }else if(type == kTable){
        [self markAsTable];
    }else if(type == kButton){
        [self handleButtonOfType:buttonType];
    }
}
- (void)handleButtonOfType:(ButtonType)type{
    NSString *targetPath;
    NSString *button;
    
    switch (type) {
        case kButtonTypeCall:
            button = @"Call";
            break;

        case kButtonTypeRaise:
            button = @"Raise";
            break;

        case kButtonTypeCheck:
            button = @"Check";
            break;

        case kButtonTypeFold:
            button = @"Fold";
            break;
            
        case kButtonTypeInactive:
            button = @"Inactive";
            break;
            
        case kButtonTypeAllIn:
            button = @"AllIn";
            break;
            
        case kButtonTypeNewTable:
            button = @"NewTable";
            break;
            
        case kButtonTypeStandUp:
            button = @"StandUp";
            break;
            
        case kButtonTypeUnknown:
            NSLog(@"handleButtonOfType: kButtonTypeUnknown");
            return;
            break;
    }
    
    targetPath = [NSString stringWithFormat:@"%@/%@/%@/",resultFolder,kPathButtons,button];
    targetPath = [targetPath stringByAppendingString:[currentPath lastPathComponent]];
    
    NSLog(@"targetPath: %@",targetPath);
    [self moveFile:currentPath toTarget:targetPath];
    [self loadNextCard];
    
}
- (IBAction)table:(id)sender {
    [self markImageAs:kTable ofValue:nil];
}
- (IBAction)noise:(id)sender {
    [self markImageAs:kNoise ofValue:nil];
}
- (IBAction)ace:(id)sender {
    [self markImageAs:kCard ofValue:kCardValueA];
}
- (IBAction)allIn:(id)sender {
    [self markImageAs:kButton ofButtonType:kButtonTypeAllIn];
}
- (IBAction)check:(id)sender {
    [self markImageAs:kButton ofButtonType:kButtonTypeCheck];
}
- (IBAction)call:(id)sender {
    [self markImageAs:kButton ofButtonType:kButtonTypeCall];
}
- (IBAction)raise:(id)sender {
    [self markImageAs:kButton ofButtonType:kButtonTypeRaise];
}


- (IBAction)fold:(id)sender {
    [self markImageAs:kButton ofButtonType:kButtonTypeFold];
}

- (IBAction)inactive:(id)sender {
    [self markImageAs:kButton ofButtonType:kButtonTypeInactive];

}
- (IBAction)newTable:(id)sender {
    [self markImageAs:kButton ofButtonType:kButtonTypeNewTable];
}
- (IBAction)standUp:(id)sender {
    [self markImageAs:kButton ofButtonType:kButtonTypeStandUp];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}
























@end
