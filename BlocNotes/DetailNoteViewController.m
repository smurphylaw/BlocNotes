//
//  DetailNoteViewController.m
//  BlocNotes
//
//  Created by Murphy on 5/30/15.
//  Copyright (c) 2015 Murphy. All rights reserved.
//

#import "DetailNoteViewController.h"
#import "Note.h"
#import "CoreDataStack.h"
#import "DataSource.h"
#import "NotesTableViewController.h"

@interface DetailNoteViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

@implementation DetailNoteViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    // NSDate *date;
    
    if (self.entry != nil) {
        self.noteBody.text = self.entry.body;
        self.titleTextField.text = self.entry.title;
        [self.noteImage setImage:[UIImage imageWithData:self.entry.image]];
    }
    
    // Bottom Toolbar
    [self.navigationController.toolbar setBarStyle:UIBarStyleDefault];
    UIBarButtonItem *cameraButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(cameraButtonPressed:)];
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareButtonPressed:)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [self setToolbarItems:@[shareButton, flexibleSpace, cameraButton]];
    
    // Navigation Bar
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneWasPressed)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelWasPressed)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    self.titleTextField.placeholder = @"Title";
    // self.noteBody.layer.borderWidth = 0.5;
    // [self.noteBody becomeFirstResponder];
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editTextRecognizerTapped:)];
    recognizer.numberOfTapsRequired = 1;
    [self.noteBody addGestureRecognizer:recognizer];
    
    self.noteBody.editable = NO;
    self.noteBody.dataDetectorTypes = UIDataDetectorTypeAll;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.navigationController setToolbarHidden:NO];
}

-(void)setEntry:(Note *)entry {
    if (_entry != entry) {
        _entry = entry;
        
        self.titleTextField.text = _entry.title;
        self.noteBody.text = _entry.body;
    }
}

-(void)setPickedImage:(UIImage *)pickedImage {
    if (_pickedImage != pickedImage) {
        _pickedImage = pickedImage;
        
        [self.noteImage setImage:pickedImage];
    }
}

#pragma mark - Tap Gesture Recognizer

-(void)editTextRecognizerTapped:(UIGestureRecognizer *) aRecognizer {
    self.noteBody.dataDetectorTypes = UIDataDetectorTypeNone;
    self.noteBody.editable = YES;
    [self.noteBody becomeFirstResponder];
}

#pragma mark - Camera

-(void)cameraButtonPressed:(id)sender {

    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

        [self presentViewController:picker animated:YES completion:nil];
        
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Device has no camera"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles: nil];
        
        [alertView show];
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    self.pickedImage = image;
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Helper methods

-(void)saveNoteEntry {
    Note *note = [NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:[DataSource sharedInstance].managedContext];
    
    if (self.titleTextField.text != nil) {
        note.title = self.titleTextField.text;
    } else {
        note.title = self.noteBody.text;
    }
    
    note.body = self.noteBody.text;
    note.image = UIImageJPEGRepresentation(self.pickedImage, 0.75);
    
    [[CoreDataStack defaultStack] saveContext];
    
    [DataSource sharedInstance].entries = [[DataSource sharedInstance].entries arrayByAddingObject:note];
    [self dismissSelf];
}

-(void)updateNoteEntry {
    self.entry.body = self.noteBody.text;
    self.entry.title = self.titleTextField.text;
    self.entry.image = UIImageJPEGRepresentation(self.pickedImage, 0.75);
    
    [[CoreDataStack defaultStack] saveContext];
}

-(void)doneWasPressed {
    if (self.entry != nil) {
        [self updateNoteEntry];
    } else {
        [self saveNoteEntry];
    }
    
    [self dismissSelf];
}

-(void)cancelWasPressed {
    [self dismissSelf];
}

-(void)dismissSelf {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)shareButtonPressed:(id)sender {
    NSMutableArray *itemsToShare = [NSMutableArray array];
    
    if (self.noteBody.text.length > 0 || self.titleTextField.text.length > 0) {
        [itemsToShare addObject:self.noteBody.text];
        [itemsToShare addObject:self.titleTextField.text];
    }
    
    if (itemsToShare.count > 0) {
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
        [self presentViewController:activityVC animated:YES completion:nil];
    }
}

@end
