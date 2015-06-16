//
//  SearchResultsViewController.m
//  BlocNotes
//
//  Created by Murphy on 6/6/15.
//  Copyright (c) 2015 Murphy. All rights reserved.
//

#import "SearchResultsViewController.h"
#import "NotesTableViewCell.h"
#import "DataSource.h"

@interface SearchResultsViewController ()

@end

@implementation SearchResultsViewController

-(void)viewDidLoad {
    
    self.filteredEntries = [DataSource sharedInstance].filteredEntries;
}

-(void)didReceiveMemoryWarning {
    [DataSource sharedInstance].fetchRequest = nil;
    [super didReceiveMemoryWarning];
}

#pragma mark - Table View

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredEntries.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NotesTableViewCell *cell = (NotesTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kNotesCellIdentifer];
    
    if (cell == nil) {
        cell = [[NotesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kNotesCellIdentifer];
    }

    if ([self.filteredEntries count] > 0) {
        self.entry = self.filteredEntries[indexPath.row];
        cell.textLabel.text = [self.entry valueForKey:@"title"];
        //cell.noteTitle.text = [self.entry valueForKey:@"title"];
    }
    
    return cell;
}


@end
