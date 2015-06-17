//
//  NotesTableViewController.h
//  BlocNotes
//
//  Created by Murphy on 5/30/15.
//  Copyright (c) 2015 Murphy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CoreDataStack.h"
#import "Note.h"

extern NSString *const kNotesCellIdentifer;

@interface NotesTableViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

//@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
