//
//  DetailNoteViewController.h
//  BlocNotes
//
//  Created by Murphy on 5/30/15.
//  Copyright (c) 2015 Murphy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Note.h"

@interface DetailNoteViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextView *noteBody;
@property (weak, nonatomic) IBOutlet UIImageView *noteImage;

@property(weak, nonatomic) UIImage *pickedImage;

@property (nonatomic, strong) Note *entry;

- (IBAction)share:(id)sender;

@end
