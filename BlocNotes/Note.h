//
//  Note.h
//  BlocNotes
//
//  Created by Murphy on 6/2/15.
//  Copyright (c) 2015 Murphy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Note : NSManagedObject

@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSString * body;
@property (nonatomic, retain) NSString * location;

@end
