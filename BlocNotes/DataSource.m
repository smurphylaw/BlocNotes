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

#pragma mark - Notification Observers
- (void)registerForiCloudNotifications {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    NSPersistentStoreCoordinator *psc = [CoreDataStack defaultStack].persistentStoreCoordinator;
    
    [notificationCenter addObserver:self
                           selector:@selector(storesWillChange:)
                               name:NSPersistentStoreCoordinatorStoresWillChangeNotification
                             object:psc];
    
    [notificationCenter addObserver:self
                           selector:@selector(storesDidChange:)
                               name:NSPersistentStoreCoordinatorStoresDidChangeNotification
                             object:psc];
    
    [notificationCenter addObserver:self
                           selector:@selector(persistentStoreDidImportUbiquitousContentChanges:)
                               name:NSPersistentStoreDidImportUbiquitousContentChangesNotification
                             object:psc];
}

# pragma mark - iCloud Support

- (void) persistentStoreDidImportUbiquitousContentChanges:(NSNotification *)changeNotification {
    NSLog(@"[%@ %@] Store Did Import Ubiquitous Content Changes", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    NSManagedObjectContext *context = self.managedContext;
    
    [context performBlock:^{
        [context mergeChangesFromContextDidSaveNotification:changeNotification];
    }];
}

- (void)storesWillChange:(NSNotification *)notification {
    NSLog(@"[%@ %@] Store Will Change", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    [self.managedContext performBlock:^{
        if ([self.managedContext hasChanges]) {
            NSError *saveError;
            if (![self.managedContext save:&saveError]) {
                NSLog(@"Save error: %@", saveError);
            }
        } else {
            [self.managedContext reset];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ManagedObjectContextReset" object:nil];
        }
    }];
    
//    NSPersistentStoreUbiquitousTransitionType transitionType = [notification.userInfo[NSPersistentStoreUbiquitousTransitionTypeKey] integerValue];
//    NSLog(@"[%@ %@] Transition Type :%lu", NSStringFromClass([self class]), NSStringFromSelector(_cmd), transitionType);
    
}

- (void)storesDidChange:(NSNotification *)notification {
    NSLog(@"[%@ %@] Store Did Change", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    self.managedContext = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ManagedObjectContextRefetchRequied" object:nil];
    
}

#pragma mark - Helper methods

- (void)setupWithStoreURL:storeURL modelURL:modelURL storeOptions:storeOptions {
    self.storeOptions = storeOptions;
    self.storeURL     = storeURL;
    self.modelURL     = modelURL;
//    [self setupManagedObjectContext];
    [self registerForiCloudNotifications];
    self.managedContext.undoManager = [[NSUndoManager alloc] init];
}


@end
