//
//  GLLItemMesh.m
//  GLLara
//
//  Created by Torsten Kammer on 05.09.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import "GLLItemMesh.h"

#import <AppKit/NSKeyValueBinding.h>

#import "GLLItem.h"
#import "GLLModel.h"
#import "GLLModelMesh.h"
#import "GLLModelParams.h"
#import "GLLRenderParameter.h"
#import "GLLRenderParameterDescription.h"
#import "GLLShaderDescription.h"

@implementation GLLItemMesh

+ (NSSet *)keyPathsForValuesAffectingRenderSettings
{
	return [NSSet setWithObjects:@"isVisible", @"cullFaceMode", nil];
}

@dynamic cullFaceMode;
@dynamic isVisible;
@dynamic item;
@dynamic renderParameters;

@dynamic mesh;
@dynamic meshIndex;
@dynamic displayName;

@synthesize renderSettings;

- (void)setItem:(GLLItem *)item
{
	[self willChangeValueForKey:@"item"];
	[self setPrimitiveValue:item forKey:@"item"];
	[self didChangeValueForKey:@"item"];
	
	// Replace all render parameters
	NSDictionary *values = self.mesh.renderParameterValues;
	NSMutableSet *renderParameters = [self mutableSetValueForKey:@"renderParameters"];
	[renderParameters removeAllObjects];
	for (NSString *uniformName in self.mesh.shader.allUniformNames)
	{
		GLLRenderParameterDescription *description = [self.mesh.shader descriptionForParameter:uniformName];

		GLLRenderParameter *parameter;
		
		if ([description.type isEqual:GLLRenderParameterTypeFloat])
			parameter = [NSEntityDescription insertNewObjectForEntityForName:@"GLLFloatRenderParameter" inManagedObjectContext:self.managedObjectContext];
		else if ([description.type isEqual:GLLRenderParameterTypeColor])
			parameter = [NSEntityDescription insertNewObjectForEntityForName:@"GLLColorRenderParameter" inManagedObjectContext:self.managedObjectContext];
		else
			continue; // Skip this param
		
		parameter.name = uniformName;
		[parameter setValue:values[uniformName] forKey:@"value"];
		
		[renderParameters addObject:parameter];
	}
}

#pragma mark - Derived

- (NSUInteger)meshIndex
{
	return [self.item.meshes indexOfObject:self];
}

- (GLLModelMesh *)mesh
{
	return self.item.model.meshes[self.meshIndex];
}

- (NSString *)displayName
{
	return self.mesh.name;
}

- (GLLRenderParameter *)renderParameterWithName:(NSString *)parameterName;
{
	for (GLLRenderParameter *parameter in self.renderParameters)
	{
		if ([parameter.name isEqual:parameterName])
			return parameter;
	}
	return nil;
}

- (id)valueForUndefinedKey:(NSString *)key
{
	GLLRenderParameter *param = [self renderParameterWithName:key];
	if (param) return param;
	else return NSNotApplicableMarker;
}

#pragma mark - Source list item

- (BOOL)isSourceListHeader
{
	return NO;
}
- (NSString *)sourceListDisplayName
{
	return self.mesh.name;
}
- (BOOL)isLeafInSourceList
{
	return YES;
}
- (NSUInteger)countOfSourceListChildren
{
	return 0;
}
- (id)objectInSourceListChildrenAtIndex:(NSUInteger)index;
{
	return nil;
}

@end
