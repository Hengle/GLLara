//
//  GLLItemListController.m
//  GLLara
//
//  Created by Torsten Kammer on 17.09.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import "GLLItemListController.h"

#import "NSArray+Map.h"
#import "GLLItem.h"
#import "GLLItemController.h"

@interface GLLItemListController ()
{
	id managedObjectContextObserver;
	NSMutableArray *itemControllers;
}

@end

@implementation GLLItemListController

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
{
	if (!(self = [super init])) return nil;
	
	_managedObjectContext = managedObjectContext;
	
	itemControllers = [[NSMutableArray alloc] init];
	
	// Load existing items
	NSFetchRequest *allItemsRequest = [[NSFetchRequest alloc] initWithEntityName:@"GLLItem"];
	NSArray *allItems = [self.managedObjectContext executeFetchRequest:allItemsRequest error:NULL];
	NSMutableArray *controllers = [self mutableArrayValueForKey:@"sourceListChildren"];
	for (GLLItem *item in allItems)
		[controllers addObject:[[GLLItemController alloc] initWithItem:item]];
	
	// Set up loading of future items and destroying items.
	// Store self as weak in the block, so it does not retain this.
	__block __weak id weakSelf = self;
	managedObjectContextObserver = [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextObjectsDidChangeNotification object:_managedObjectContext queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
		GLLItemListController *self = weakSelf;
		
		NSMutableArray *controllers = [self mutableArrayValueForKey:@"sourceListChildren"];
		
		NSArray *toRemove = [itemControllers map:^(GLLItemController *drawer){
			return [notification.userInfo[NSDeletedObjectsKey] containsObject:drawer.item] ? drawer : nil;
		}];
		[controllers removeObjectsInArray:toRemove];
		
		// New objects includes absolutely anything. Restrict this to items.
		[controllers addObjectsFromArray:[notification.userInfo[NSInsertedObjectsKey] map:^(GLLItem *newItem){
			return [newItem.entity isKindOfEntity:[NSEntityDescription entityForName:@"GLLItem" inManagedObjectContext:managedObjectContext]] ? [[GLLItemController alloc] initWithItem:newItem] : nil;
		}]];
	}];

	
	return self;
}

- (void)insertObject:(GLLItemController *)object inSourceListChildrenAtIndex:(NSUInteger)index
{
	[itemControllers insertObject:object atIndex:index];
}

- (void)removeObjectFromSourceListChildrenAtIndex:(NSUInteger)index
{
	[itemControllers removeObjectAtIndex:index];
}

- (void)replaceObjectInSourceListChildrenAtIndex:(NSUInteger)index withObject:(GLLItemController *)newObject;
{
	[itemControllers replaceObjectAtIndex:index withObject:newObject];
}

- (BOOL)isSourceListHeader
{
	return YES;
}
- (NSString *)sourceListDisplayName
{
	return NSLocalizedString(@"Items", @"items source list header");
}
- (BOOL)isLeafInSourceList
{
	return NO;
}
- (NSUInteger)countOfSourceListChildren
{
	return [itemControllers count];
}
- (id)objectInSourceListChildrenAtIndex:(NSUInteger)index;
{
	return [itemControllers objectAtIndex:index];
}

@end
