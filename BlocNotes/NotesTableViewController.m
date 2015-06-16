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
#import "SearchResultsViewController.h"
#import "NotesTableViewCell.h"

NSString *const kNotesCellIdentifer = @"notes";

@interface NotesTableViewController() <UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating>

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) SearchResultsViewController *resultsTableController;

@end

@implementation NotesTableViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [[DataSource sharedInstance] addObserver:self forKeyPath:@"entries" options:0 context:nil];
    //self.tableView.dataSource = [DataSource sharedInstance];
    _resultsTableController = [[SearchResultsViewController alloc] init];
    _searchController = [[UISearchController alloc] initWithSearchResultsController:self.resultsTableController];
    
    // Navigation Item
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(newNote)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    self.fetchedResultsController.delegate = self;
    self.resultsTableController.tableView.delegate = self;
    
    // Search Controller
    self.searchController.searchResultsUpdater = self;
    self.searchController.searchBar.delegate = self;
    [self.searchController.searchBar sizeToFit];
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.definesPresentationContext = YES;
    
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    self.searchController.searchBar.placeholder = @"Search Notes";
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TableCell" bundle:nil] forCellReuseIdentifier:kNotesCellIdentifer];
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.tableView reloadData];
}

// ** ISSUE - Need fix **
//-(void)dealloc {
//    [[DataSource sharedInstance] removeObserver:self forKeyPath:@"entry"];
//}

#pragma mark - Table View

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return (tableView == self.tableView) ? self.fetchedResultsController.sections.count : 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [DataSource sharedInstance].entries.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NotesTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kNotesCellIdentifer forIndexPath:indexPath];
    
    if ([[DataSource sharedInstance].entries count] > 0) {
        [DataSource sharedInstance].entry = [DataSource sharedInstance].entries[indexPath.row];
        cell.noteTitle.text = [[DataSource sharedInstance].entry valueForKey:@"title"];
    }

    return cell;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [[DataSource sharedInstance] deleteEntry:[DataSource sharedInstance].entry forRowAtIndexPath:indexPath];

    }
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    CGRect searchBarFrame = self.searchController.searchBar.frame;
    [self.tableView scrollRectToVisible:searchBarFrame animated:NO];
    return NSNotFound;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (self.tableView == tableView) {
        Note *selectedEntry = [DataSource sharedInstance].entries[indexPath.row];
        
        DetailNoteViewController *detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"showDetail"];
        detailViewController.entry = selectedEntry;
        [self.navigationController pushViewController:detailViewController animated:YES];
        
    } else {
        Note *selectedEntry = [DataSource sharedInstance].filteredEntries[indexPath.row];
        
        DetailNoteViewController *detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"showDetail"];
        detailViewController.entry = selectedEntry;
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
    
    // Not necessary but ios 8.0.4 bug requires it
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - Key/Value Notifications

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == [DataSource sharedInstance] && [keyPath isEqualToString:@"entries"]) {
        int kindOfChange = [change[NSKeyValueChangeKindKey] intValue];
        
        if (kindOfChange == NSKeyValueChangeSetting) {
            [self.tableView reloadData];
        } else if (kindOfChange == NSKeyValueChangeInsertion || kindOfChange == NSKeyValueChangeRemoval || kindOfChange == NSKeyValueChangeReplacement){
            NSIndexSet *indexSetOfChanges = change[NSKeyValueChangeIndexesKey];
            
            NSMutableArray *indexPathsThatChanged = [NSMutableArray array];
            [indexSetOfChanges enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:idx inSection:0];
                [indexPathsThatChanged addObject:newIndexPath];
            }];
            
            [self.tableView beginUpdates];
            
            if (kindOfChange == NSKeyValueChangeInsertion) {
                [self.tableView insertRowsAtIndexPaths:indexPathsThatChanged withRowAnimation:UITableViewRowAnimationAutomatic];
            } else if (kindOfChange == NSKeyValueChangeRemoval) {
                [self.tableView deleteRowsAtIndexPaths:indexPathsThatChanged withRowAnimation:UITableViewRowAnimationAutomatic];
            } else if (kindOfChange == NSKeyValueChangeReplacement) {
                [self.tableView reloadRowsAtIndexPaths:indexPathsThatChanged withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            
            [self.tableView endUpdates];
        }
    }
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
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[DataSource sharedInstance].managedContext sectionNameKeyPath:nil cacheName:@"Master"];
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

#pragma mark - UISearchBarDelegate

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

//-(void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
//    [self updateSearchResultsForSearchController:self.searchController];    
//}

#pragma mark - UISearchResultsUpdating

-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    if ([DataSource sharedInstance].managedContext) {
    
        NSString *searchText = searchController.searchBar.text;
        NSString *strippedString = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        NSArray *searchItems = nil;
        if (strippedString.length > 0) {
            searchItems = [strippedString componentsSeparatedByString:@" "];
        }
        
        NSString *predicateFormat = @"(%K CONTAINS[cd] %@) OR (%K CONTAINS[cd] %@)";
        NSString *searchAttributeTitle = @"title";
        NSString *searchAttributeBody = @"body";

        NSPredicate *predicateTitle = [NSPredicate predicateWithFormat:predicateFormat, searchAttributeTitle, strippedString, searchAttributeBody, strippedString];
            
        NSFetchRequest *fetchRequest = [DataSource sharedInstance].fetchRequest;
        [fetchRequest setPredicate: predicateTitle];
        
        NSError *error;
        [DataSource sharedInstance].filteredEntries = [[DataSource sharedInstance].managedContext executeFetchRequest:fetchRequest error:&error];
        
        self.resultsTableController.filteredEntries = [DataSource sharedInstance].filteredEntries;
        [self.resultsTableController.tableView reloadData];
    }
}

#pragma mark - Helper methods

-(void)newNote {
    DetailNoteViewController *detailNoteVC = [self.storyboard instantiateViewControllerWithIdentifier:@"showDetail"];
    [self.navigationController pushViewController:detailNoteVC animated:YES];
}


@end
