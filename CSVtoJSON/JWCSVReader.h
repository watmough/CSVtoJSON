//
//  JWCSVReader.h
//  CSVtoJSON
//
//  Created by Jonathan Watmough on 10/26/11.
//  Copyright (c) 2011 Watmough Software. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MAX_FIELD 1024

@interface JWCSVReader : NSObject
{
	// internal
	const char *bytes;
	unsigned long length;
	
	NSData *rawData;
	
	NSArray *rows;
}

@property(nonatomic,retain) NSData *rawData;
@property(nonatomic,retain) NSArray *rows;

// methods
- (id)initWithData:(NSData*)theData;
- (NSArray*)convert;

@end
