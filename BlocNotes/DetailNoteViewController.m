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

@implementation DetailNoteViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    // NSDate *date;
    
    if (self.entry != nil) {
        self.noteBody.text = self.entry.body;
        self.titleTextField.text = self.entry.title;
    }
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneWasPressed)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelWasPressed)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    self.titleTextField.placeholder = @"Title";
    // self.noteBody.layer.borderWidth = 0.5;
    // [self.noteBody becomeFirstResponder];
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

#pragma mark - Helper methods

-(void)saveNoteEntry {
    Note *note = [NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:[DataSource sharedInstance].managedContext];
    
    if (self.titleTextField.text != nil) {
        note.title = self.titleTextField.text;
    } else {
        note.title = self.noteBody.text;
    }
    
    note.body = self.noteBody.text;
    
    [[CoreDataStack defaultStack] saveContext];
    
    [DataSource sharedInstance].entries = [[DataSource sharedInstance].entries arrayByAddingObject:note];
    [self dismissSelf];
}

-(void)updateNoteEntry {
    self.entry.body = self.noteBody.text;
    self.entry.title = self.titleTextField.text;
    
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

#pragma mark - IBActions

- (IBAction)share:(id)sender {
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
