//
//  SearchResultsViewController.h
//  BlocNotes
//
//  Created by Murphy on 6/6/15.
//  Copyright (c) 2015 Murphy. All rights reserved.
//

#import "NotesTableViewController.h"
#import "Note.h"

@interface SearchResultsViewController : NotesTableViewController

@property (nonatomic, strong) NSArray *filteredEntries;
@property (nonatomic, strong) Note *entry;

@end
