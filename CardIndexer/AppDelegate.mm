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
    kCard
};

#warning adopt this in main app too, so it's easy to change the folder etc
static NSString *kCardTypeSuit      = @"cardSuit";
static NSString *kCardTypeCard      = @"card";
static NSString *kCardTypeTable     = @"table";
static NSString *kCardTypeNoise     = @"noise";
static NSString *kCardTypeUnknown   = @"unkn";

static NSString *kGameStateKeyPath      = @"gameState";
static NSString *kLastOddsQueryKeyPath  = @"lastOddsQuery";
static NSString *kPlayersWithCardsKeyPath = @"numberOfPlayersWithCards";
static NSString *kWinningOddsPath       = @"winningOdds";
static NSString *kHasHandKeyPath        = @"hasHand";

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
static NSString *kPathTable         = @"_table";
static NSString *kPathNoise         = @"_noise";
static NSString *kPathSuits         = @"_suits";

NSUInteger cardSuit;
int i = 0;
NSArray *files;
NSString *currentPath;
NSString *resultFolder;
NSString *pathToUnknowns;
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    //pathToUnknowns = @"/Users/tsiebler/Desktop/pkr/images/card";
    pathToUnknowns = [NSString stringWithFormat:@"%@/%@/%@",kPathImageRoot,kPathUnknown,kPathUnknownCards];;
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
    [self reloadKnownSuits];
    [self setCurrentImage];
}
NSImage *currentImage;
NSImage *currentSuitImage;

- (void)setCurrentImage{
    if(i >= [files count]) return;

    //files is empty when all images are processed
    NSString* imagePath = [files objectAtIndex:i];
    //NSArray *pathComponents = [imagePath pathComponents];
    //NSString *type = [pathComponents objectAtIndex:([pathComponents count] -2)];
    //NSString *fileName = [[imagePath lastPathComponent] stringByDeletingPathExtension];
    //NSLog(@"image: %@, %@",type, fileName);

    currentPath = [[NSString stringWithFormat:@"%@",imagePath] stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    //NSLog(@"imagePath: %@",currentPath);
    if ([[NSFileManager defaultManager] fileExistsAtPath:currentPath]){
        currentImage =  [[NSImage alloc] initWithContentsOfFile:currentPath];
        dispatch_async(dispatch_get_main_queue(), ^(void){
            //Run UI Updates
            [self.imageView setImage:currentImage];
        });
        [self getSuitFromImage:currentImage];
    }else{
        [self loadImages];
        [self loadNextCard];
    }
}



- (void)setCurrentSuit:(NSString*)suit{
    if([suit isEqualToString:kCardSuitHeart]){
        [self heart:nil];
    }else if([suit isEqualToString:kCardSuitDiamond]){
        [self diamond:nil];
    }else if([suit isEqualToString:kCardSuitClub]){
        [self club:nil];
    }else if([suit isEqualToString:kCardSuitSpade]){
        [self spade:nil];
    }
}
- (void)getSuitFromImage:(NSImage*)image{
    currentSuitImage = [image getSubImageWithRect:NSMakeRect(0, 35, image.size.width, 20)];
    
    dispatch_async(dispatch_get_main_queue(), ^(void){
        //Run UI Updates
        [[self suitImageView] setImage:currentSuitImage];
    });
    int suitHash = [[currentSuitImage TIFFRepresentation] adler32];
    [[self suitHash] setStringValue:[NSString stringWithFormat:@"%d",suitHash]];
    //NSLog(@"suitHash: %d",suitHash);
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
            //NSLog(@"card: %@",suit);
            
            break;
            
        case kUnknown:
            //NSLog(@"not known");
            [self.heartButton   setState:0];
            [self.diamondButton setState:0];
            [self.spadeButton   setState:0];
            [self.clubButton    setState:0];
            cardSuit = kUnknown;
            break;
    }
    
    // parse suit, if not known, the uncheck the current suits:

    
}
- (IBAction)heart:(id)sender {
    [self.heartButton   setState:1];
    [self.diamondButton setState:0];
    [self.spadeButton   setState:0];
    [self.clubButton    setState:0];
    cardSuit = kHeart;
}
- (IBAction)diamond:(id)sender {
    [self.heartButton   setState:0];
    [self.diamondButton setState:1];
    [self.spadeButton   setState:0];
    [self.clubButton    setState:0];
    cardSuit = kDiamond;
}
- (IBAction)spade:(id)sender {
    [self.heartButton   setState:0];
    [self.diamondButton setState:0];
    [self.spadeButton   setState:1];
    [self.clubButton    setState:0];
    cardSuit = kSpade;
}
- (IBAction)club:(id)sender {
    [self.heartButton   setState:0];
    [self.diamondButton setState:0];
    [self.spadeButton   setState:0];
    [self.clubButton    setState:1];
    cardSuit = kClub;
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
    [self reloadKnownSuits];
    
    if([files count] != i){
        i++;

        NSLog(@"count: %d, %lu", i,(unsigned long)[files count]);
        [self setCurrentImage];
    }else{
        [self.imageView setImage:nil];
        [self.suitImageView setImage:nil];
        
        [self.heartButton   setState:0];
        [self.diamondButton setState:0];
        [self.spadeButton   setState:0];
        [self.clubButton    setState:0];
        cardSuit = kUnknown;
        
        [[self suitHash] setStringValue:@"reloading..."];
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
- (void)handleCardOfValue:(NSString*)value atPath:(NSString*)path ofSuit:(CardSuit)targetSuit{
    NSString *suit;
    NSString *targetPath;
    switch(targetSuit){
        case kHeart:
            suit = [NSString stringWithFormat:@"/%@/",kCardSuitHeart];
            //[self saveImageForSuit:suit];
            break;
            
        case kClub:
            suit = [NSString stringWithFormat:@"/%@/",kCardSuitClub];
            //[self saveImageForSuit:suit];
            break;
            
        case kDiamond:
            suit = [NSString stringWithFormat:@"/%@/",kCardSuitDiamond];
            //[self saveImageForSuit:suit];
            break;
            
        case kSpade:
            suit = [NSString stringWithFormat:@"/%@/",kCardSuitSpade];
            //[self saveImageForSuit:suit];
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
    targetPath = [targetPath stringByAppendingString:[path lastPathComponent]];
    
    NSLog(@"movingToCard: %@",targetPath);
    [self moveFile:path toTarget:targetPath];
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
- (void)markAsNoise:(NSString*)path{
    [self saveImageForSuit:[NSString stringWithFormat:@"/%@/",kPathNoise]];
    
    
    NSString *targetPath;
    targetPath = [resultFolder stringByAppendingString:[NSString stringWithFormat:@"/%@/",kPathNoise]];
    targetPath = [targetPath stringByAppendingString:[path lastPathComponent]];
    
    NSLog(@"movingToNoise: %@",targetPath);
    [self moveFile:path toTarget:targetPath];
}
- (void)markAsNoise{
    [self saveImageForSuit:[NSString stringWithFormat:@"/%@/",kPathNoise]];
    
    [self markAsNoise:currentPath];
    [self loadNextCard];

}
- (void)markAsTable:(NSString*)path{
    NSString *targetPath;
    targetPath = [NSString stringWithFormat:@"%@/%@/",resultFolder,kPathTable];
    //targetPath = [[resultFolder stringByAppendingString:@"/cards"] stringByAppendingString:[NSString stringWithFormat:@"/%@/",kPathTable]];
    targetPath = [targetPath stringByAppendingString:[path lastPathComponent]];
    
    NSLog(@"movingToTable: %@",targetPath);
    [self moveFile:path toTarget:targetPath];
    
}
- (void)markAsTable{
    [self saveImageForSuit:[NSString stringWithFormat:@"/%@/",kPathTable]];
    [self markAsTable:currentPath];
    [self loadNextCard];

}
- (void)markImageAs:(int)type ofValue:(NSString*)value atPath:(NSString*)path ofSuit:(CardSuit)targetSuit{
    if(type == kNoise){
        [self markAsNoise:path];
    }else if(type == kTable){
        [self markAsTable:path];
    }else if(type == kCard){
        [self handleCardOfValue:value atPath:path ofSuit:targetSuit];
    }
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
- (IBAction)table:(id)sender {
    [self markImageAs:kTable ofValue:nil];
}
- (IBAction)noise:(id)sender {
    [self markImageAs:kNoise ofValue:nil];
}
- (IBAction)c2:(id)sender {
    [self markImageAs:kCard ofValue:kCardValue2];
}
- (IBAction)c3:(id)sender {
    [self markImageAs:kCard ofValue:kCardValue3];
}
- (IBAction)c4:(id)sender {
    [self markImageAs:kCard ofValue:kCardValue4];
}
- (IBAction)c5:(id)sender {
    [self markImageAs:kCard ofValue:kCardValue5];
}
- (IBAction)c6:(id)sender {
    [self markImageAs:kCard ofValue:kCardValue6];
}
- (IBAction)c7:(id)sender {
    [self markImageAs:kCard ofValue:kCardValue7];
}
- (IBAction)c8:(id)sender {
    [self markImageAs:kCard ofValue:kCardValue8];
}
- (IBAction)c9:(id)sender {
    [self markImageAs:kCard ofValue:kCardValue9];
}
- (IBAction)c10:(id)sender {
    [self markImageAs:kCard ofValue:kCardValue10];
}
- (IBAction)jack:(id)sender {
    [self markImageAs:kCard ofValue:kCardValueJ];
}
- (IBAction)queen:(id)sender {
    [self markImageAs:kCard ofValue:kCardValueQ];
}
- (IBAction)king:(id)sender {
    [self markImageAs:kCard ofValue:kCardValueK];
}
- (IBAction)ace:(id)sender {
    [self markImageAs:kCard ofValue:kCardValueA];
}

- (NSArray*)arrayFromString:(NSString*)string{
    //NSLog(@" getting JSON: %@", string);
    NSError *error;
    id object = [NSJSONSerialization
                 JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding]
                 options:0
                 error:&error];
    
    if(error) { /* JSON was malformed, act appropriately here */ }
    
    // the originating poster wants to deal with dictionaries;
    // assuming you do too then something like this is the first
    // validation step:
    if([object isKindOfClass:[NSDictionary class]])
    {
        //NSLog(@"results dict: %@", object);
        /* proceed with results as you like; the assignment to
         an explicit NSDictionary * is artificial step to get
         compile-time checking from here on down (and better autocompletion
         when editing). You could have just made object an NSDictionary *
         in the first place but stylistically you might prefer to keep
         the question of type open until it's confirmed */
    } else if([object isKindOfClass:[NSArray class]])
    {
        //NSLog(@"results array: %@", object);
        return object;
    }
    else
    {
        /* there's no guarantee that the outermost object in a JSON
         packet will be a dictionary; if we get here then it wasn't,
         so 'object' shouldn't be treated as an NSDictionary; probably
         you need to report a suitable error condition */
        NSLog(@"runAI: error unexpected format!! %@, %@, %@", [object className], object, error);
    }
    return nil;
}

- (void)handleCardString:(NSString*)string withSuit:(CardSuit)suit{
    
}
- (void)handleCardWithString:(NSString*)matchStr andAccuracy:(float)accuracy atPath:(NSString*)path{
    if(accuracy < 0.90){
        NSLog(@"== not sure, leave for user");
        // maybe have another folder for cards that ened manual processing
        
    }else{
        if([matchStr containsString:@"table"]){
            NSLog(@"=== table with confidence: %f", accuracy);
            
            [self markAsTable:path];
            
        }else if([matchStr containsString:@"noise"]){
            NSLog(@"=== noise with confidence: %f", accuracy);
            [self markAsNoise:path];
            
        }else{
            NSLog(@"=== card with confidence: %f - %@", accuracy, matchStr);
            
            unichar card = [matchStr characterAtIndex:0];
            unichar suit = [matchStr characterAtIndex:1];
            
            CardSuit targetSuit = kUnknown;
            if(suit == 'h') targetSuit = kHeart;
            else if(suit == 'c') targetSuit = kClub;
            else if(suit == 'd') targetSuit = kDiamond;
            else if(suit == 's') targetSuit = kSpade;
            
            [self markImageAs:kCard ofValue:[NSString stringWithFormat:@"%c", card] atPath:path ofSuit:targetSuit];
        }
    }
}
- (void)analyseImageAtPath:(NSString*)path{
    if(path == nil) return;
    
    NSString *caffeModelPath    = @"/Users/tsiebler/Documents/Projects/Mac/AI/ImageClassification/PokerCards/cardsCaffeModel/snapshot_iter_7200.caffemodel";
    NSString *deployProto       = @"/Users/tsiebler/Documents/Projects/Mac/AI/ImageClassification/PokerCards/cardsCaffeModel/deploy.prototxt";
    NSString *labels            = @"/Users/tsiebler/Documents/Projects/Mac/AI/ImageClassification/PokerCards/cardsCaffeModel/labels.txt";
    NSString *meanBinProto      = @"/Users/tsiebler/Documents/Projects/Mac/AI/ImageClassification/PokerCards/cardsCaffeModel/mean.binaryproto";
    
    //CaffeClassifier a/deploy.prototxt a/cards.caffemodel a/mean.binaryproto a/labels.txt /Users/tsiebler/Desktop/pkr/images/unknown/card/-837978291.png
    //NSLog(@"%@ %@ %@ %@ %@ %@",pathToCassifier, deployProto, caffeModelPath, meanBinProto, labels, path);

    //NSLog(@"== sending this to caffe: %@",path);
    NSArray *params = [NSArray arrayWithObjects:
                            deployProto,
                            caffeModelPath,
                            meanBinProto,
                            labels,
                            path,
                            nil];
    
    NSString *pathToCassifier   = [[NSBundle mainBundle] pathForResource:@"CaffeClassifier" ofType:nil];
    
    __block NSPipe *pipe = [NSPipe pipe];
    NSFileHandle *file = pipe.fileHandleForReading;
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = pathToCassifier;
    task.arguments = params;
    task.standardOutput = pipe;
    task.standardError = nil;

    
    [file waitForDataInBackgroundAndNotify];


    
    task.terminationHandler = ^(NSTask* task){
        NSData *data = [file readDataToEndOfFile];

        [file closeFile];
        
        NSString *commandOutput = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
        
        task = nil;
        pipe = nil;
        
        //NSLog(@"result: %@",commandOutput);
        
        NSArray *results = [self arrayFromString:commandOutput];
        
        NSString *matchStr  = [results objectAtIndex:0][@"match"];
        float accuracy      = [[results objectAtIndex:0][@"value"] floatValue];
        
        NSLog(@"== top result: %@",[results objectAtIndex:0]);
        
        [self handleCardWithString:matchStr andAccuracy:accuracy atPath:path];
        
        
    };
    
    [task launch];
    [task waitUntilExit];
    

}
- (IBAction)runAI:(id)sender {
    self.AIStatusField.stringValue = @"AI Running";

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // get total image count
        int count = [files count];
        __block int activeThreads = 0;
        int maxThreads = 16;
        NSLog(@"trying to run throuhg %d images", count);
        
        for(int curr = 0;curr < count;){
            
            if(activeThreads < maxThreads){
                activeThreads++;
                
                @autoreleasepool {

                    dispatch_group_t d_group = dispatch_group_create();
                    dispatch_queue_t bg_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

                    dispatch_group_async(d_group, bg_queue, ^{
                        // trigger this while total image count != i
                        [self analyseImageAtPath:currentPath];
                        
                        dispatch_group_notify(d_group, dispatch_get_main_queue(), ^{
                            activeThreads -= 1;
                            NSLog(@"thread finished");
                        });
                    });
                    [self loadNextCard];
                    curr++;
                    NSLog(@"=========");
                    
                    dispatch_async(dispatch_get_main_queue(), ^(void){
                        self.AIStatusField2.stringValue = [NSString stringWithFormat:@"%d/%d", curr, count];
                    });
                }
            }else{
                sleep(0.5);
            }

        
        }
        

        dispatch_async(dispatch_get_main_queue(), ^(void){
            //Run UI Updates
            self.AIStatusField.stringValue = @"AI Finished";
        });
    });
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}
























@end
