//
//  ShareViewController.m
//  NotesUpload
//
//  Created by Murphy on 6/5/15.
//  Copyright (c) 2015 Murphy. All rights reserved.
//

#import "ShareViewController.h"
#import "DataSource.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface ShareViewController ()

@property (nonatomic, strong) SLComposeSheetConfigurationItem *item;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic) id <NSURLSessionDelegate> delegate;

@end

@implementation ShareViewController

-(void)viewDidLoad {
    [super viewDidLoad];
}

- (BOOL)isContentValid {
    // Do validation of contentText and/or NSExtensionContext attachments here
    NSInteger messageLength = [[self.contentText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length];
    NSInteger charactersRemaining = 200 - messageLength;
    self.charactersRemaining = @(charactersRemaining);
    
    if (charactersRemaining >= 0) {
        return YES;
    }
    
    return NO;
}

- (void)didSelectPost {
    // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    
//    for (NSExtensionItem *item in self.extensionContext.inputItems) {
//        for (NSItemProvider *itemProvider in item.attachments) {
//            if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeImage]) {
//                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeImage options:nil completionHandler:^(UIImage *image, NSError *error) {
//                    if (image) {
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            self.image = image;
//                        });
//                    }
//                }];
//                break;
//            }
//        }
//    }
    
    NSExtensionItem *inputItem = self.extensionContext.inputItems.firstObject;
    NSExtensionItem *outputItem = [inputItem copy];
    outputItem.attributedContentText = [[NSAttributedString alloc] initWithString:self.contentText attributes:nil];
    NSArray *outputItems = @[outputItem];
    [self.extensionContext completeRequestReturningItems:outputItems completionHandler:nil];
    
    // NSData *photoData = UIImageJPEGRepresentation(self.image, 1.0);
    NSManagedObjectContext *context = [DataSource sharedInstance].managedContext;
    self.entry = [NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:context];
    
    if (!self.title) {
        self.entry.title = self.contentText;
    } else {
        self.entry.title = self.title;

    }
    self.entry.body = self.contentText;
    
    [context save:NULL];
    
    // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
    [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
}

- (NSArray *)configurationItems {
    // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.    
    return @[];
}

@end
