//--------------------------------------------------------
// ObjWithHistoryModel
// Created by Mark  A. Howe on Fri Jul 22 2005
// Code partially generated by the OrcaCodeWizard. Written by Mark A. Howe.
// Copyright (c) 2005 CENPA, University of Washington. All rights reserved.
//-----------------------------------------------------------
//This program was prepared for the Regents of the University of 
//Washington at the Center for Experimental Nuclear Physics and 
//Astrophysics (CENPA) sponsored in part by the United States 
//Department of Energy (DOE) under Grant #DE-FG02-97ER41020. 
//The University has certain rights in the program pursuant to 
//the contract and the program should not be copied or distributed 
//outside your organization.  The DOE and the University of 
//Washington reserve all rights in the program. Neither the authors,
//University of Washington, or U.S. Government make any warranty, 
//express or implied, or assume any liability or responsibility 
//for the use of this software.
//-------------------------------------------------------------

#pragma mark ***Imported Files

#import "ObjWithHistoryModel.h"
#import "ORTimeRoi.h"

@implementation ObjWithHistoryModel

- (void) dealloc
{
 	[roiSet release];
	[super dealloc];
}

#pragma mark ***Accessors
- (NSMutableArray*) rois:(int)index
{
	if(!roiSet)roiSet = [[NSMutableArray alloc] init];
	NSTimeInterval t1 = 20;
	NSTimeInterval t2 = 60;
	int i;
	for(i=0;i<index+1;i++){
		if([roiSet count]<index+1){
			NSMutableArray* theRois = [[NSMutableArray alloc] init];
			[theRois addObject:[[[ORTimeRoi alloc] initWithMin:t1 max:t2] autorelease]];
			[roiSet addObject:theRois];
			[theRois release];
		}
	}
	
	return [roiSet objectAtIndex:index];
}

#pragma mark ***Archival
- (id) initWithCoder:(NSCoder*)decoder
{
	self = [super initWithCoder:decoder];
	[[self undoManager] disableUndoRegistration];
	roiSet	= [[decoder decodeObjectForKey:@"roiSet"] retain];
	[self loadHistory];
	[[self undoManager] enableUndoRegistration];
	
	return self;
}

- (void) encodeWithCoder:(NSCoder*)encoder
{
	[super encodeWithCoder:encoder];
	[encoder encodeObject:roiSet forKey:@"roiSet"];
}

- (NSString*) historyName
{
	return [self fullID];
}

- (NSString*) historyPath
{
	NSString* folder = [[ApplicationSupport sharedApplicationSupport] applicationSupportFolder:@"History"];
	return [folder stringByAppendingPathComponent:[self historyName]];
}

- (void) saveHistory
{
	id historyToSave = [self history];
	if(historyToSave){
		NSMutableData *theData = [NSMutableData data];
		NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:theData];
		[archiver setOutputFormat:NSPropertyListXMLFormat_v1_0];
		NSString* historyPath = [self historyPath];
		NSFileManager* fm = [NSFileManager defaultManager];
		if([fm fileExistsAtPath:historyPath])[fm removeItemAtPath:historyPath error:nil];
		[archiver encodeObject:historyToSave forKey:@"ObjHistory"];
		[archiver finishEncoding];
		[archiver release];
		[fm createFileAtPath:historyPath contents:theData attributes:nil];
	}
}

- (void) loadHistory
{
	NSData *theData = [NSData dataWithContentsOfFile:[self historyPath]];
	if([theData length]){
		NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:theData];
		id theHistory = [unarchiver decodeObjectForKey:@"ObjHistory"];
		[self setHistory:theHistory];
	}
}

- (void) deleteHistory
{
	NSString* historyPath = [self historyPath];
	NSFileManager* fm = [NSFileManager defaultManager];
	if([fm fileExistsAtPath:historyPath]){
		[fm removeItemAtPath:historyPath error:nil];
		[self setHistory:nil];
	}
}

// Subclasses should override the following methods and call saveHistory whenever they want a snapshot of 
// their history stored to disk. LoadHistory will be called automatically whenever the object is reloaded, 
// but subclasses can call it if they wish.
- (id) history
{
	//subclasses should override
	return nil;
}

- (void) setHistory:(id)someHistory
{
	//subclasses should override
	return;
}
@end

