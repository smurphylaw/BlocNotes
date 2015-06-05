//
//  DataSource.m
//  BlocNotes
//
//  Created by Murphy on 5/30/15.
//  Copyright (c) 2015 Murphy. All rights reserved.
//

#import "DataSource.h"
#import "NotesTableViewCell.h"
#import "NotesTableViewController.h"
#import "CoreDataStack.h"

@implementation DataSource

+(instancetype)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

-(instancetype)init {
    self = [super init];
        
    self.managedContext = [CoreDataStack defaultStack].managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:self.managedContext];
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Note"];
    [fetch setEntity:entity];
    
    NSError *error;
    self.entries = [self.managedContext executeFetchRequest:fetch error:&error];
    
    return self;
}

#pragma mark - Table View Datasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NotesTableViewController *notesVC = [[NotesTableViewController alloc] init];
    return notesVC.fetchedResultsController.sections.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.entries.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NotesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"notes" forIndexPath:indexPath];

    if ([self.entries count] > 0) {
        self.entry = self.entries[indexPath.row];
        cell.noteTitle.text = [self.entry valueForKey:@"title"];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NotesTableViewController *notesVC = [[NotesTableViewController alloc] init];
        [self.managedContext deleteObject:[notesVC.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![self.managedContext save:&error]) {
            NSLog(@"Could not delete: %@ %@", error, [error localizedDescription]);
        }
        
        NSMutableArray *entriesToDelete = [[NSMutableArray alloc] initWithArray:self.entries];
        [entriesToDelete removeObjectAtIndex:indexPath.row];
        self.entries = entriesToDelete;

        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    
}

@end
