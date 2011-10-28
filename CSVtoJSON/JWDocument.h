//
//  JWDocument.h
//  CSVtoJSON
//
//  Created by Jonathan Watmough on 10/26/11.
//  Copyright (c) 2011 Watmough Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface JWDocument : NSDocument
{
	NSData *rawData;
	NSData *jsonData;
	NSArray *cocoaData;
}

// properties
@property (nonatomic,retain) NSData *rawData;
@property (nonatomic,retain) NSData *jsonData;
@property (nonatomic,retain) NSArray *cocoaData;

// methods

@end
