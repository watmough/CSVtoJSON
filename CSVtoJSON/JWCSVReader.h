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
	// internal to parsing
	const char *bytes;
	unsigned long length;
	unsigned int chPos;

	// safe to access if required
	NSData *rawData;
	NSArray *rows;
}

// properties
@property(nonatomic,retain) NSData *rawData;
@property(nonatomic,retain) NSArray *rows;

// methods
- (id)initWithData:(NSData*)theData;
- (NSArray*)parseRawCSV;

@end
