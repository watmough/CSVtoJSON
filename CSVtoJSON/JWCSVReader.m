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
// getCh
// just returns a single byte as an unsigned int, ignoring UTF-8 etc.
// returns EOF at end of buffer.
//--------------------------------------------------------------------------------
- (unsigned int)getCh
{
	// get a character
	if (chPos<length) {
		return *(bytes+chPos++);
	}
	return -1;
}

//--------------------------------------------------------------------------------
// unGetCh
// backup a character, by moving the chPos back.
// used when we read a character, say a ',', then decide to put it back and let
// someone else read it.
//--------------------------------------------------------------------------------
- (void)unGetCh
{
	// move the pointer back in the buffer
	if (chPos>0) {
		chPos--;
	}
}

//--------------------------------------------------------------------------------
// isEscape:
// returns YES if we hit a '\' character, used for escaping '\r\n' etc.
//--------------------------------------------------------------------------------
- (BOOL)isEscape:(int)ch
{
	// escape character?
	return ch=='\\';
}

//--------------------------------------------------------------------------------
// isEOF:
// returns YES when we have read the last character, and there are no more.
//--------------------------------------------------------------------------------
- (BOOL)isEOF:(int)ch
{
	// end of file?
	return ch==-1;
}

//--------------------------------------------------------------------------------
// isEOL:
// returns YES when at end of a line. 
//--------------------------------------------------------------------------------
- (BOOL)isEOL:(int)ch
{
	// end of line
	return ch==13 || ch==10;
}

//--------------------------------------------------------------------------------
// isStringQuote:
// returns YES for " or ' characters.
//--------------------------------------------------------------------------------
- (BOOL)isStringQuote:(int)ch
{
	// start or end of a string
	return ch=='\"' || ch=='\'';
}

//--------------------------------------------------------------------------------
// isSeparator:
// returns YES for ','. All these characters should be selectable so we could load
// tab-separated files etc.
//--------------------------------------------------------------------------------
- (BOOL)isSeparator:(int)ch
{
	// field separator
	return ch==',';
}

//--------------------------------------------------------------------------------
// readField
// reads up until EOF, EOL or a separator.
// if no characters were found, returns nil, or if we found data, return an NSString.
// data is asumed to be UTF-8, and non-ASCII is passed through. See TestData.csv
//--------------------------------------------------------------------------------
- (NSString*)readField
{
	int ch = 0;
	// buffer to add characters to
	char buffer[MAX_FIELD+1];
	char *pos = buffer;
	BOOL haveChars = NO;
	// not in a string, set quote to look for matching end of string
	BOOL string = NO;
	int quote = 0;

	// read until end of line, or end of file
	while ((ch=[self getCh]) && ![self isEOL:ch] && ![self isEOF:ch]) {
		// return buffer as an NSString if we got a separator outside of a string
		if (!string && [self isSeparator:ch]) {
			*pos = '\0';
			[self unGetCh];
			return pos==buffer ? nil : [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
		}
		// check for an escape character
		else if (string && [self isEscape:ch] && pos-buffer<MAX_FIELD-1) {
			// read the next character and write both - right thing to do?
			int escaped = [self getCh];
			if (![self isEOL:escaped] && ![self isEOF:escaped]) {
				*pos++ = ch;
				*pos++ = escaped;
			}
		}
		// check if we are starting a string, and if so, remember the quote character used
		// only recognize a string at the start of a field
		else if (!string && [self isStringQuote:ch] && !haveChars && pos-buffer<MAX_FIELD)
		{
			// start a string - 
			quote = ch;
			string = YES;
			*pos++ = quote;
		}
		// check if we are in a string, and have matched the required end quote
		else if (string && [self isStringQuote:ch] && ch==quote && pos-buffer<MAX_FIELD) {
			// stop a string
			string = NO;
			*pos++ = quote;
		}
		// handle the default case of simply adding a character to our buffer, as long as we
		// have space - ensures we always parse full fields, even if we don't write it all.
		// we may be in a world of hurt if we are halfway through a unicode character... ruh roh
		else if (pos-buffer<MAX_FIELD) {
			*pos++ = ch;
			haveChars = YES;
		}
		else {
			// throw a buffer too small exception
			NSException *exception = [NSException 
									  exceptionWithName:@"JWCSVReader.m: readField: Parse error"
									  reason:[NSString stringWithFormat:@"Field longer than %d bytes",MAX_FIELD] userInfo:nil];
			@throw exception;
			return nil;
		}
	}
	// if we get here, we must have hit EOL or EOF or filled the buffer, just return what we have
	// added to the buffer, terminated with \0, and stuffed into an NSString.
	[self unGetCh];
	*pos = '\0';
	return pos==buffer ? nil : [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
}

//--------------------------------------------------------------------------------
// parseRawCSV
// build an array of lines, each of which consists of an array of fields. Fields
// are just NSStrings for now.
//--------------------------------------------------------------------------------
- (NSArray*)parseRawCSV
{
	// start of byte buffer
	chPos = 0;
	// always create a fresh array of rows
	self.rows = [[[NSMutableArray alloc] initWithCapacity:10000] autorelease];
	NSMutableArray *cols = nil;
	int ch = 0;
	int col = 0;
	int row = 0;
	// read until end of file (bytes)
	while ((ch=[self getCh]) && ![self isEOF:ch]) {
		// add  a row (array of column NSString values) if needed
		if (!cols) {
			cols = [[[NSMutableArray alloc] initWithCapacity:8] autorelease];
			[(NSMutableArray*)rows addObject:cols];
		}
		// check for end of line
		if ([self isEOL:ch]) {
			// eat any further \r\n characters, then reset to a new line
			// ch will be at the first ch of the new line
			while ((ch=[self getCh]) && [self isEOL:ch])
				{};
			// check for hitting end of file
			if ([self isEOF:ch])
				goto done;
			// bump row, set cols to nil to get a new one (above), and rebuffer ch
			row++;
			cols = nil;
			col = 0;
			[self unGetCh];
			continue;
		}
		// if we have a separator, move right a column
		if ([self isSeparator:ch]) {
			col++;
			// add an empty field @"" if we have less in cols than count of separators
			if ([cols count]<col) {
				[cols addObject:@""];
			}
		}
		else {
			// not a separator, so rebuffer ch and attempt to read a field
			[self unGetCh];
			NSString *field = [[self readField] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
			[cols addObject:field];
		}
	}
done:
	return self.rows;
}

@end


























