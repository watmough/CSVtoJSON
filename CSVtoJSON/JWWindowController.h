//
//  JWWindowController.h
//  CSVtoJSON
//
//  Created by Jonathan Watmough on 10/26/11.
//  Copyright (c) 2011 Watmough Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface JWWindowController : NSWindowController
{
	NSTextView *rawTextView;
	NSTableView *tableView;
	NSTextView *jsonTextView;
}

@property(nonatomic,retain) IBOutlet NSTextView *rawTextView;
@property(nonatomic,retain) IBOutlet NSTableView *tableView;
@property(nonatomic,retain) IBOutlet NSTextView *jsonTextView;

// methods
- (void)updateRawTextView;

@end
