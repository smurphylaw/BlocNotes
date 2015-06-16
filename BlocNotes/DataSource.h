//
//  DataSource.h
//  BlocNotes
//
//  Created by Murphy on 5/30/15.
//  Copyright (c) 2015 Murphy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Note.h"

@interface DataSource : NSObject

@property (nonatomic, strong) NSArray *entries;
@property (nonatomic, strong) NSArray *filteredEntries;
@property (nonatomic, strong) Note *entry;

@property (nonatomic, strong) NSManagedObjectContext *managedContext;
@property (nonatomic, strong) NSFetchRequest *fetchRequest;

+(instancetype)sharedInstance;
-(void)deleteEntry:(Note *)entry forRowAtIndexPath:(NSIndexPath *)indexPath;

@end
