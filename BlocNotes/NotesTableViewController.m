//
//  NotesTableViewController.m
//  BlocNotes
//
//  Created by Murphy on 5/30/15.
//  Copyright (c) 2015 Murphy. All rights reserved.
//

#import "NotesTableViewController.h"
#import "DataSource.h"
#import "DetailNoteViewController.h"

@interface NotesTableViewController()

@end

@implementation NotesTableViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = [DataSource sharedInstance];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(newNote)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    self.fetchedResultsController.delegate = self;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.tableView reloadData];
}

#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSMutableArray *entriesArray =[[DataSource sharedInstance].entries mutableCopy];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Note *note = (Note *)entriesArray[indexPath.row];
        [[segue destinationViewController] setEntry: note];
    }
}

#pragma mark - Table View

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


// This method not calling? Works in DataSource.m
//-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        NSManagedObjectContext *context = [DataSource sharedInstance].managedContext;
//        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
//        
//        NSError *error = nil;
//        if (![context save:&error]) {
//            NSLog(@"Could not delete: %@ %@", error, [error localizedDescription]);
//        }
//        
//        NSMutableArray *entriesToDelete = [[NSMutableArray alloc] initWithArray:[DataSource sharedInstance].entries];
//        [entriesToDelete removeObjectAtIndex:indexPath.row];
//        [DataSource sharedInstance].entries = entriesToDelete;
//        
//        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    }
//}


-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}


#pragma mark - NSFetchedResultsController

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:[DataSource sharedInstance].managedContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[DataSource sharedInstance].managedContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    return _fetchedResultsController;
}

#pragma mark - Helper methods

-(void)newNote {
    DetailNoteViewController *detailNoteVC = [self.storyboard instantiateViewControllerWithIdentifier:@"showDetail"];
    [self.navigationController pushViewController:detailNoteVC animated:YES];
}


@end
