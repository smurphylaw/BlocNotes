//
//  ShareViewController.h
//  NotesUpload
//
//  Created by Murphy on 6/5/15.
//  Copyright (c) 2015 Murphy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import <CoreData/CoreData.h>
#import "Note.h"

@interface ShareViewController : SLComposeServiceViewController

@property (nonatomic, strong) Note *entry;

@end
