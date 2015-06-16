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
#import "SearchResultsViewController.h"

@interface DataSource() {
    NSMutableArray *_entries;
}

@end

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
    
    self.fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Note"];
    [self.fetchRequest setEntity:entity];
    
    NSError *error;
    self.entries = [self.managedContext executeFetchRequest:self.fetchRequest error:&error];
    
    return self;
}

#pragma mark - Key/Value Observing

-(NSUInteger)countOfEntries {
    return self.entries.count;
}

-(id)objectInEntriesAtIndex:(NSUInteger)index {
    return [self.entries objectAtIndex:index];
}

-(NSArray *)entriesAtIndexes:(NSIndexSet *)indexes {
    return [self.entries objectsAtIndexes:indexes];
}

-(void)insertObject:(Note *)object inManagedContextAtIndex:(NSUInteger)index {
    [_entries insertObject:object atIndex:index];
}

-(void)removeObjectFromManagedContextAtIndex:(NSUInteger)index {
    [_entries removeObjectAtIndex:index];
}

-(void)replaceObjectInManagedContextAtIndex:(NSUInteger)index withObject:(id)object {
    [_entries replaceObjectAtIndex:index withObject:object];
}

-(void)deleteEntry:(Note *)entry forRowAtIndexPath:(NSIndexPath *)indexPath {
    NotesTableViewController *notesTVC = [[NotesTableViewController alloc] init];
    self.entry = [notesTVC.fetchedResultsController objectAtIndexPath:indexPath];
    [self.managedContext deleteObject:self.entry];
    
    NSError *error = nil;
    if (![self.managedContext save:&error]) {
        NSLog(@"Could not delete: %@ %@", error, [error localizedDescription]);
    }
    
    NSMutableArray *entryToDeleteWithKVO = [[NSMutableArray alloc] initWithArray:self.entries];
    [entryToDeleteWithKVO removeObject:self.entry];
    self.entries = entryToDeleteWithKVO;
    
}


@end
