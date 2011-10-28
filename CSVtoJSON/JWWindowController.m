//
//  JWWindowController.m
//  CSVtoJSON
//
//  Created by Jonathan Watmough on 10/26/11.
//  Copyright (c) 2011 Watmough Software. All rights reserved.
//

#import "JWWindowController.h"
#import "JWDocument.h"
#import "JWCSVReader.h"
#import "JSONKit.h"

@implementation JWWindowController

@synthesize rawTextView;
@synthesize tableView;
@synthesize jsonTextView;

//--------------------------------------------------------------------------------
// initWithWindow:
//--------------------------------------------------------------------------------
- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

//--------------------------------------------------------------------------------
// windowDidLoad
//--------------------------------------------------------------------------------
- (void)windowDidLoad
{
    [super windowDidLoad];

	// update document if we have one
	if (self.document && [self.document rawData]) {
		[self updateRawTextView];
	}
}

#pragma mark -
#pragma mark UI Support

//--------------------------------------------------------------------------------
// updateRawTextView
//--------------------------------------------------------------------------------
- (void)updateRawTextView
{
	// get document
	JWDocument *document = [self document];
	NSData *rawData = [document rawData];
	
	// format raw data as a string and refresh text view
	NSString *string = [NSString stringWithUTF8String:[rawData bytes]];
	[rawTextView setString:string];
	
	// convert the raw into fields
	JWCSVReader *reader = [[JWCSVReader alloc] initWithData:[self.document rawData]];
	[[self document] setCocoaData:[reader parseRawCSV]];
	[reader release];
	
	// display the json data
	[self.document setJsonData:[[self.document cocoaData] JSONData]];
	[jsonTextView setString:[[self.document cocoaData] JSONString]];
}

#pragma mark -
#pragma mark Table View Support

//--------------------------------------------------------------------------------
// numberOfRowsInTableView
// just the number of parsed rows of the CSV data.
//--------------------------------------------------------------------------------
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	NSArray *rows = [[self document] cocoaData];
	return [rows count];
}

//--------------------------------------------------------------------------------
// tableView:objectValueForTableColumn:row:
// we just use the column id 0-7 to identify what column of data we want.
//--------------------------------------------------------------------------------
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	NSInteger colIndex = [(NSString*)[aTableColumn identifier] integerValue];
	// get the columnar data
	NSArray *rows = [[self document] cocoaData];
	NSArray *colArray = [rows objectAtIndex:rowIndex];
	return colIndex<[colArray count] ? [colArray objectAtIndex:colIndex] : nil;
}

@end




















