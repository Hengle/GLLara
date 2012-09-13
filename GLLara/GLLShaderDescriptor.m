//
//  GLLShaderDescriptor.m
//  GLLara
//
//  Created by Torsten Kammer on 05.09.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import "GLLShaderDescriptor.h"

#import "GLLModelParams.h"

@implementation GLLShaderDescriptor

- (id)initWithPlist:(NSDictionary *)plist name:(NSString *)name baseURL:(NSURL *)baseURL modelParameters:(GLLModelParams *)parameters;
{
	if (!(self = [super init])) return nil;
	
	_baseURL = [baseURL copy];
	_name = [name copy];
	
	_vertexName = plist[@"vertex"];
	_geometryName = plist[@"geometry"];
	_fragmentName = plist[@"fragment"];
	
	_parameterUniformNames = plist[@"parameters"];
	_textureUniformNames = plist[@"textures"];
	_additionalUniformNames = plist[@"additionalParameters"];
	
	_alphaMeshGroups = [NSSet setWithArray:plist[@"alphaMeshGroups"]];
	_solidMeshGroups = [NSSet setWithArray:plist[@"solidMeshGroups"]];

	_programIdentifier = [NSString stringWithFormat:@"%@ (%@)", _name, _baseURL.absoluteString];
	
	_parameters = parameters;
	
	return self;
}

- (NSArray *)allUniformNames
{
	if (!self.parameterUniformNames)
		return self.additionalUniformNames;
	else
		return [self.parameterUniformNames arrayByAddingObjectsFromArray:self.additionalUniformNames];
}

- (GLLRenderParameterDescription *)descriptionForParameter:(NSString *)parameterName;
{
	return [self.parameters descriptionForParameter:parameterName];
}

@end
