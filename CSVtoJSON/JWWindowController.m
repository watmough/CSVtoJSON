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

@implementation JWWindowController

@synthesize rawTextView;
@synthesize tableView;
@synthesize rows;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
	
	// do we have a document?
	[self updateRawTextView];
}

#pragma mark -
#pragma mark UI Support

- (void)updateRawTextView
{
	// get document
	JWDocument *document = [self document];
	NSData *rawData = [document rawData];
	
	// format raw data as a string and refresh text view
	NSString *string = [NSString stringWithUTF8String:[rawData bytes]];
	[rawTextView setString:string];
	
	// ### process it
	[self processRawText];
}

#pragma mark -
#pragma mark Table View Support

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [rows count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	NSArray *colArray = [rows objectAtIndex:rowIndex];
	NSInteger colIndex = [(NSString*)[aTableColumn identifier] integerValue];
	return colIndex<[colArray count] ? [colArray objectAtIndex:colIndex] : nil;
}

#pragma mark -
#pragma mark Processing

- (void)processRawText
{
	// convert the raw into fields
	JWCSVReader *reader = [[JWCSVReader alloc] initWithData:[self.document rawData]];
	self.rows = [reader convert];
	NSLog(@"Converted data to %@",[rows description]);
}

@end




















