//
//  JWDocument.m
//  CSVtoJSON
//
//  Created by Jonathan Watmough on 10/26/11.
//  Copyright (c) 2011 Watmough Software. All rights reserved.
//

#import "JWDocument.h"
#import "JWWindowController.h"
#import "JWCSVReader.h"
#import "JSONKit.h"

@implementation JWDocument

@synthesize rawData;
@synthesize jsonData;
@synthesize cocoaData;

//--------------------------------------------------------------------------------
// init
//--------------------------------------------------------------------------------
- (id)init
{
    self = [super init];
    if (self) {
		// Add your subclass-specific initialization here.
		// If an error occurs here, return nil.
    }
    return self;
}


//--------------------------------------------------------------------------------
// makeWindowControllers
// we are a document-based app, so we'll use a custom window controller, instead of
// just an app delegate like in iOS, or in a single window app.
//--------------------------------------------------------------------------------
- (void)makeWindowControllers
{
//	JWWindowController *controller = [[JWWindowController alloc] initWithWindowNibName:[self windowNibName]];
	JWWindowController *controller = [[JWWindowController alloc] initWithWindowNibName:@"JWDocument"];
	[self addWindowController:controller];
}

//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
/*
- (NSString *)windowNibName
{
	// Override returning the nib file name of the document
	// If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
	return @"JWDocument";
}*/

//--------------------------------------------------------------------------------
// windowControllerDidLoadNib:
// ??? maybe some of the controller code should be in here?
//--------------------------------------------------------------------------------
- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
	[super windowControllerDidLoadNib:aController];
	// Add any code here that needs to be executed once the windowController has loaded the document's window.
}

#pragma mark -
#pragma mark Suppported Document Types

// class method + writableTypes returns everything setup in info

- (NSArray *)writableTypesForSaveOperation:(NSSaveOperationType)saveOperation
{
	// just make it so we always save JSON
	return [NSArray arrayWithObject:@"JSON Text"];
}


#pragma mark -
#pragma mark Saving and Loading

//--------------------------------------------------------------------------------
// dataOfType:error:
// support saving as JSON.
//--------------------------------------------------------------------------------
- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
	NSLog(@"dataOfType: %@",typeName);
	/*
	 Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
	You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
	*/
	
	// if we have json data, then just return it
	if ([typeName isEqualToString:@"JSON Text"]) {
		if (!jsonData) {
			// ok, need to create json data from an array of arrays...
			self.jsonData = [cocoaData JSONData];
		}
		return jsonData;
	}
	
	NSException *exception = [NSException exceptionWithName:@"UnimplementedMethod" reason:[NSString stringWithFormat:@"%@ is unimplemented", NSStringFromSelector(_cmd)] userInfo:nil];
	@throw exception;
	return nil;
}

//--------------------------------------------------------------------------------
// readFromData:ofType:error:
// gets passed an NSData of some txt/csv file.
//--------------------------------------------------------------------------------
- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
	/*
	Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning NO.
	You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead.
	*/

	// save the passed data
	self.rawData = data;
	
	return YES;
}

@end

























