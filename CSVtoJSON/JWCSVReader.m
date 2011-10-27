//
//  JWCSVReader.m
//  CSVtoJSON
//
//  Created by Jonathan Watmough on 10/26/11.
//  Copyright (c) 2011 Watmough Software. All rights reserved.
//

#import "JWCSVReader.h"

@implementation JWCSVReader

@synthesize rawData;
@synthesize rows;

//--------------------------------------------------------------------------------
// initWithData:
//--------------------------------------------------------------------------------
- (id)initWithData:(NSData*)theData
{
	if ((self=[super init])) {
		
		// save passed data
		self.rawData = theData;
		bytes = [theData bytes];
		length = [theData length];
		

	}
	return self;
}

//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------

int chPos = 0;

- (int)getCh
{
	// get a character
	if (chPos<length) {
		return *(bytes+chPos++);
	}
	return -1;
}

- (void)unGetCh
{
	// move the pointer back in the buffer
	if (chPos>0) {
		chPos--;
	}
}

- (BOOL)isEscape:(int)ch
{
	// escape character?
	return ch='\\';
}

- (BOOL)isEOF:(int)ch
{
	// end of file?
	return ch==-1;
}

- (BOOL)isEOL:(int)ch
{
	// end of line
	return ch==13 || ch==10;
}

- (BOOL)isStringQuote:(int)ch
{
	// start or end of a string
	return ch=='\"' || ch=='\'';
}

- (BOOL)isSeparator:(int)ch
{
	// field separator
	return ch==',';
}

- (NSString*)readField
{
	// read a field into a buffer
	char buffer[MAX_FIELD];
	char *pos = buffer;
	int ch = 0;
	BOOL string = NO;
	int quote = 0;
	
	while ((ch=[self getCh]) && ![self isEOL:ch] && ![self isEOF:ch]) {
		if (!string && [self isSeparator:ch]) {
			// return string if we hit a separator outside of a string
			*pos = '\0';
			[self unGetCh];
			return pos==buffer ? nil : [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
		}
		else if (string && ch==quote) {
			// stop a string
			string = NO;
			*pos++ = quote;
		}
		else if (string && [self isEscape:ch]) {
			// read the next character and write both - right thing to do?
			int escaped = [self getCh];
			if (![self isEOL:escaped] && ![self isEOF:escaped]) {
				*pos++ = ch;
				*pos++ = escaped;
			}
		}
		else if (!string && [self isStringQuote:ch])
		{
			// start a string - 
			quote = ch;
			string = YES;
			*pos++ = quote;
		}
		// handle the default case of simply adding a character to our buffer
		else
			*pos++ = ch;
	}
	// if we get here, we must have hit EOL or EOF, just return what we have
	[self unGetCh];
	*pos = '\0';
	return pos==buffer ? nil : [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
}

- (NSArray*)convert
{
	self.rows = [[[NSMutableArray alloc] initWithCapacity:10000] autorelease];
	NSMutableArray *cols = nil;
	int ch = 0;
	int col = 0;
	int row = 0;
	while ((ch=[self getCh]) && ![self isEOF:ch]) {
		// add  a row if needed
		if (!cols) {
			cols = [[[NSMutableArray alloc] initWithCapacity:8] autorelease];
			[(NSMutableArray*)rows addObject:cols];
		}
		// check for end of line
		if ([self isEOL:ch]) {
			// eat any further \r\n characters, then reset to a new line
			// ch will be at the first ch of the new line
			while ((ch=[self getCh]) && [self isEOL:ch]) {};
			if ([self isEOF:ch]) {
				goto done;
			}
			row++;
			cols = nil;
			col = 0;
			[self unGetCh];
			continue;
		}
		// check for separator
		if ([self isSeparator:ch]) {
			col++;
			// add an empty field if we hit a null
			if ([cols count]<col) {
				[cols addObject:@""];
			}
		}
		else {
			// read a field
			[self unGetCh];
			NSString *field = [[self readField] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
			[cols addObject:field];
//			NSLog(@"[%d,%d] %@",row,col,field);
		}
	}
done:
	return self.rows;
}


@end


























