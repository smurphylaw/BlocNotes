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

@interface DataSource : NSObject <UITableViewDataSource>

@property (nonatomic, strong) NSArray *entries;
@property (nonatomic, strong) Note *entry;
@property(nonatomic, strong) NSManagedObjectContext *managedContext;

+(instancetype)sharedInstance;

@end
