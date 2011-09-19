//--------------------------------------------------------
// ORMet237Model
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

#import "ORMet237Model.h"
#import "ORSerialPort.h"
#import "ORSerialPortList.h"
#import "ORSerialPort.h"
#import "ORSerialPortAdditions.h"
#import "ORDataTypeAssigner.h"
#import "ORDataPacket.h"

#pragma mark ***External Strings
NSString* ORMet237ModelCycleNumberChanged	= @"ORMet237ModelCycleNumberChanged";
NSString* ORMet237ModelCycleWillEndChanged	= @"ORMet237ModelCycleWillEndChanged";
NSString* ORMet237ModelCycleStartedChanged	= @"ORMet237ModelCycleStartedChanged";
NSString* ORMet237ModelRunningChanged		= @"ORMet237ModelRunningChanged";
NSString* ORMet237ModelCycleDurationChanged = @"ORMet237ModelCycleDurationChanged";
NSString* ORMet237ModelCountingModeChanged	= @"ORMet237ModelCountingModeChanged";
NSString* ORMet237ModelCount2Changed		= @"ORMet237ModelCount2Changed";
NSString* ORMet237ModelCount1Changed		= @"ORMet237ModelCount1Changed";
NSString* ORMet237ModelSize2Changed			= @"ORMet237ModelSize2Changed";
NSString* ORMet237ModelSize1Changed			= @"ORMet237ModelSize1Changed";
NSString* ORMet237ModelMeasurementDateChanged = @"ORMet237ModelMeasurementDateChanged";
NSString* ORMet237ModelSerialPortChanged	= @"ORMet237ModelSerialPortChanged";
NSString* ORMet237ModelPortNameChanged		= @"ORMet237ModelPortNameChanged";
NSString* ORMet237ModelPortStateChanged		= @"ORMet237ModelPortStateChanged";

NSString* ORMet237Lock = @"ORMet237Lock";

@interface ORMet237Model (private)
- (void) timeout;
- (void) processOneCommandFromQueue;
- (void) process_response:(NSString*)theResponse;
- (void) goToNextCommand;
- (void) startTimeOut;
- (void) checkCycle;
@end

@implementation ORMet237Model

#define kMet237CmdTimeout  10

- (id) init
{
	self = [super init];
    [self registerNotificationObservers];
	return self;
}

- (void) dealloc
{
    [cycleWillEnd release];
    [cycleStarted release];
    [measurementDate release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [buffer release];
	[cmdQueue release];
    [portName release];
    if([serialPort isOpen]){
        [serialPort close];
    }
    [serialPort release];
	
	[super dealloc];
}

- (void) sleep
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[super sleep];
}

- (void) wakeUp
{
	[super wakeUp];
}

- (void) setUpImage
{
	[self setImage:[NSImage imageNamed:@"Met237.tif"]];
}

- (void) makeMainController
{
	[self linkToController:@"ORMet237Controller"];
}

- (void) registerNotificationObservers
{
	NSNotificationCenter* notifyCenter = [NSNotificationCenter defaultCenter];

    [notifyCenter addObserver : self
                     selector : @selector(dataReceived:)
                         name : ORSerialPortDataReceived
                       object : nil];
}

- (void) dataReceived:(NSNotification*)note
{
    if([[note userInfo] objectForKey:@"serialPort"] == serialPort){
		
        NSString* theString = [[[[NSString alloc] initWithData:[[note userInfo] objectForKey:@"data"] 
												      encoding:NSASCIIStringEncoding] autorelease] uppercaseString];
		
		//the serial port may break the data up into small chunks, so we have to accumulate the chunks until
		//we get a full piece.
		theString = [[theString componentsSeparatedByString:@"\n"] componentsJoinedByString:@""];
		theString = [[theString componentsSeparatedByString:@">"] componentsJoinedByString:@""];
		
        if(!buffer)buffer = [[NSMutableString string] retain];
        [buffer appendString:theString];	
		
        do {
            NSRange lineRange = [buffer rangeOfString:@"\r"];
            if(lineRange.location!= NSNotFound){
                NSString* theResponse = [[[buffer substringToIndex:lineRange.location+1] copy] autorelease];
                [buffer deleteCharactersInRange:NSMakeRange(0,lineRange.location+1)];      //take the cmd out of the buffer
				theResponse = [theResponse stringByReplacingOccurrencesOfString:@"\r" withString:@""];
				theResponse = [theResponse stringByReplacingOccurrencesOfString:@"\n" withString:@""];

				if([theResponse length] != 0){
					[self process_response:theResponse];
				}
            }
        } while([buffer rangeOfString:@"\r"].location!= NSNotFound);
	}
}

#pragma mark ***Accessors

- (int) cycleNumber
{
    return cycleNumber;
}

- (void) setCycleNumber:(int)aCycleNumber
{
    cycleNumber = aCycleNumber;

    [[NSNotificationCenter defaultCenter] postNotificationName:ORMet237ModelCycleNumberChanged object:self];
}

- (NSCalendarDate*) cycleWillEnd
{
    return cycleWillEnd;
}

- (void) setCycleWillEnd:(NSCalendarDate*)aCycleWillEnd
{
    [aCycleWillEnd retain];
    [cycleWillEnd release];
    cycleWillEnd = aCycleWillEnd;

    [[NSNotificationCenter defaultCenter] postNotificationName:ORMet237ModelCycleWillEndChanged object:self];
}

- (NSCalendarDate*) cycleStarted
{
    return cycleStarted;
}

- (void) setCycleStarted:(NSCalendarDate*)aCycleStarted
{
    [aCycleStarted retain];
    [cycleStarted release];
    cycleStarted = aCycleStarted;

    [[NSNotificationCenter defaultCenter] postNotificationName:ORMet237ModelCycleStartedChanged object:self];
}

- (BOOL) running
{
    return running;
}

- (void) setRunning:(BOOL)aRunning
{
    running = aRunning;

    [[NSNotificationCenter defaultCenter] postNotificationName:ORMet237ModelRunningChanged object:self];
}

- (int) cycleDuration
{
    return cycleDuration;
}

- (void) setCycleDuration:(int)aCycleDuration
{
	if(aCycleDuration == 0) aCycleDuration = 1;
    [[[self undoManager] prepareWithInvocationTarget:self] setCycleDuration:cycleDuration];
    
    cycleDuration = aCycleDuration;

    [[NSNotificationCenter defaultCenter] postNotificationName:ORMet237ModelCycleDurationChanged object:self];
}

- (int) countingMode
{
    return countingMode;
}

- (void) setCountingMode:(int)aCountingMode
{
    countingMode = aCountingMode;

    [[NSNotificationCenter defaultCenter] postNotificationName:ORMet237ModelCountingModeChanged object:self];
}

- (NSString*) countingModeString
{
	switch ([self countingMode]) {
		case kMet237Counting: return @"Counting";
		case kMet237Holding:  return @"Holding";
		case kMet237Stopped:  return @"Stopped";
		default: return @"--";
	}
}

- (int) count2
{
    return count2;
}

- (void) setCount2:(int)aCount2
{
    count2 = aCount2;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORMet237ModelCount2Changed object:self];
}

- (int) count1
{
    return count1;
}

- (void) setCount1:(int)aCount1
{
    count1 = aCount1;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORMet237ModelCount1Changed object:self];
}

- (float) size2
{
    return size2;
}

- (void) setSize2:(float)aSize2
{
    size2 = aSize2;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORMet237ModelSize2Changed object:self];
}

- (float) size1
{
    return size1;
}

- (void) setSize1:(float)aSize1
{
    size1 = aSize1;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORMet237ModelSize1Changed object:self];
}

- (NSString*) measurementDate
{
	if(!measurementDate)return @"";
    else return measurementDate;
}

- (void) setMeasurementDate:(NSString*)aMeasurementDate
{
    [measurementDate autorelease];
    measurementDate = [aMeasurementDate copy];    

    [[NSNotificationCenter defaultCenter] postNotificationName:ORMet237ModelMeasurementDateChanged object:self];
}

- (unsigned long) timeMeasured
{
	return timeMeasured;
}

- (NSString*) lastRequest
{
	return lastRequest;
}

- (void) setLastRequest:(NSString*)aRequest
{
	[lastRequest autorelease];
	lastRequest = [aRequest copy];    
}

- (BOOL) portWasOpen
{
    return portWasOpen;
}

- (void) setPortWasOpen:(BOOL)aPortWasOpen
{
    portWasOpen = aPortWasOpen;
}

- (NSString*) portName
{
	if(!portName)return @"";
    else return portName;
}

- (void) setPortName:(NSString*)aPortName
{
    [[[self undoManager] prepareWithInvocationTarget:self] setPortName:portName];
    
    if(![aPortName isEqualToString:portName]){
        [portName autorelease];
        portName = [aPortName copy];    

        BOOL valid = NO;
        NSEnumerator *enumerator = [ORSerialPortList portEnumerator];
        ORSerialPort *aPort;
        while (aPort = [enumerator nextObject]) {
            if([portName isEqualToString:[aPort name]]){
                [self setSerialPort:aPort];
                if(portWasOpen){
                    [self openPort:YES];
				}
                valid = YES;
                break;
            }
        } 
        if(!valid){
            [self setSerialPort:nil];
        }       
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:ORMet237ModelPortNameChanged object:self];
}

- (ORSerialPort*) serialPort
{
    return serialPort;
}

- (void) setSerialPort:(ORSerialPort*)aSerialPort
{
    [aSerialPort retain];
    [serialPort release];
    serialPort = aSerialPort;

    [[NSNotificationCenter defaultCenter] postNotificationName:ORMet237ModelSerialPortChanged object:self];
}

- (void) openPort:(BOOL)state
{
    if(state) {
		[serialPort setSpeed:9600];
		[serialPort setParityNone];
		[serialPort setStopBits2:NO];
		[serialPort setDataBits:8];
        [serialPort open];
    }
    else [serialPort close];
    portWasOpen = [serialPort isOpen];
    [[NSNotificationCenter defaultCenter] postNotificationName:ORMet237ModelPortStateChanged object:self];
}

#pragma mark ***Archival
- (id) initWithCoder:(NSCoder*)decoder
{
	self = [super initWithCoder:decoder];
	[[self undoManager] disableUndoRegistration];
	[self setCycleDuration:		[decoder decodeIntForKey:@"cycleDuration"]];
	[self setPortWasOpen:		[decoder decodeBoolForKey:	@"ORMet237ModelPortWasOpen"]];
    [self setPortName:			[decoder decodeObjectForKey:@"portName"]];
	[[self undoManager] enableUndoRegistration];
	
    [self registerNotificationObservers];

	return self;
}
- (void) encodeWithCoder:(NSCoder*)encoder
{
    [super encodeWithCoder:encoder];
    [encoder encodeInt:cycleDuration forKey:@"cycleDuration"];
    [encoder encodeBool:	portWasOpen		forKey:	@"ORMet237ModelPortWasOpen"];
    [encoder encodeObject:	portName		forKey: @"portName"];
}

#pragma mark *** Commands
- (void) addCmdToQueue:(NSString*)aCmd
{
    if([serialPort isOpen]){ 
		if(!cmdQueue)cmdQueue = [[NSMutableArray array] retain];
		[cmdQueue addObject:aCmd];
		if(!lastRequest){
			[self processOneCommandFromQueue];
		}
	}
}

- (void) initHardware
{
}

- (void) sendAuto					{ [self addCmdToQueue:@"U"]; [self addCmdToQueue:@"a"]; }
- (void) sendManual					{ [self addCmdToQueue:@"U"]; [self addCmdToQueue:@"b"]; }
- (void) startCountingByComputer	{ [self addCmdToQueue:@"U"]; [self addCmdToQueue:@"c"]; }
- (void) startCountingByCounter		{ [self addCmdToQueue:@"U"]; [self addCmdToQueue:@"d"]; }
- (void) stopCounting				{ [self addCmdToQueue:@"U"]; [self addCmdToQueue:@"e"]; }
- (void) clearBuffer				{ [self addCmdToQueue:@"U"]; [self addCmdToQueue:@"C"]; }
- (void) getNumberRecords			{ [self addCmdToQueue:@"U"]; [self addCmdToQueue:@"D"]; }
- (void) getRevision				{ [self addCmdToQueue:@"U"]; [self addCmdToQueue:@"E"]; }
- (void) getMode					{ [self addCmdToQueue:@"U"]; [self addCmdToQueue:@"M"]; }
- (void) getModel					{ [self addCmdToQueue:@"U"]; [self addCmdToQueue:@"T"]; }
- (void) getRecord					{ [self addCmdToQueue:@"U"]; [self addCmdToQueue:@"A"]; }
- (void) resendRecord				{ [self addCmdToQueue:@"U"]; [self addCmdToQueue:@"R"]; }
- (void) goToStandbyMode			{ [self addCmdToQueue:@"U"]; [self addCmdToQueue:@"h"]; }
- (void) getToActiveMode			{ [self addCmdToQueue:@"U"]; [self addCmdToQueue:@"g"]; }
- (void) goToLocalMode				{ [self addCmdToQueue:@"U"]; [self addCmdToQueue:@"l"]; }
- (void) universalSelect			{ [self addCmdToQueue:@"U"]; }

#pragma mark ***Polling and Cycles
- (void) startCycle
{
	if(![self running]){
		[self setRunning:YES];
		[self setCycleNumber:1];
		NSCalendarDate* now = [NSCalendarDate date];
		[self setCycleStarted:now];
		[self setCycleWillEnd:[now dateByAddingTimeInterval:[self cycleDuration]*60]]; 
		[self clearBuffer];
		[self startCountingByComputer];
		[self checkCycle];
	}
}

- (void) stopCycle
{
	if([self running]){
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkCycle) object:nil];
		[self setRunning:NO];
		[self setCycleNumber:0];
		[self stopCounting];
	}
}
@end

@implementation ORMet237Model (private)
- (void) checkCycle
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkCycle) object:nil];
	if(running){
		NSDate* now = [NSDate date];
		if([cycleWillEnd timeIntervalSinceDate:now] >= 0){
			[[NSNotificationCenter defaultCenter] postNotificationName:ORMet237ModelCycleWillEndChanged object:self];
			[self getMode];
			[self performSelector:@selector(checkCycle) withObject:nil afterDelay:1];
		}
		else {
			int theCount = [self cycleNumber];
			[self setCycleNumber:theCount+1];
			[self stopCounting];
			[self getRecord];
			[self startCountingByComputer];
			[self setCycleWillEnd:[now dateByAddingTimeInterval:[self cycleDuration]*60]]; 
		}
	}
}

- (void) timeout
{
	NSLogError(@"Met237",@"command timeout",nil);
	[cmdQueue removeAllObjects];
	[self setLastRequest:nil];
}

- (void) goToNextCommand
{
	[self setLastRequest:nil];			 //clear the last request
	[self processOneCommandFromQueue];	 //do the next command in the queue
}

- (void) processOneCommandFromQueue
{
	if([cmdQueue count] == 0) return;
	NSString* aCmd = [[[cmdQueue objectAtIndex:0] retain] autorelease];
	[cmdQueue removeObjectAtIndex:0];
	[self setLastRequest:aCmd];
	
	if(aCmd){
		[self startTimeOut];
		[serialPort writeString:[NSString stringWithFormat:@"%@\r",aCmd]];
	}
	if(!lastRequest){
		[self performSelector:@selector(processOneCommandFromQueue) withObject:nil afterDelay:1];
	}
}

- (void) process_response:(NSString*)theResponse
{
	if([theResponse hasPrefix:@"a"]){	//Auto Mode
	}
	
	else if([theResponse hasPrefix:@"b"]){	//Manual Mode
	}
	
	else if([theResponse hasPrefix:@"c"]){	//Computer Controlled Start count
	}
	
	else if([theResponse hasPrefix:@"d"]){	//Counter Controlled Start count
	}
	
	else if([theResponse hasPrefix:@"C"]){	//Clear Buffer
	}
	
	else if([theResponse hasPrefix:@"D"]){	//Number of Records
	}
	
	else if([theResponse hasPrefix:@"E"]){	//EProm Version
	}
	
	else if([theResponse hasPrefix:@"M"]){	//Mode Request
		NSString* s = [theResponse substringWithRange:NSMakeRange(1,1)];
		if([s isEqualToString:@"C"])	  [self setCountingMode:kMet237Counting];
		else if([s isEqualToString:@"H"]) [self setCountingMode:kMet237Holding];
		else if([s isEqualToString:@"S"]) [self setCountingMode:kMet237Stopped];
	}
	
	else if([theResponse hasPrefix:@"R"]){	//Indentify Model
	}
	
	else if([theResponse hasPrefix:@"A"]){	//Send record
		NSArray* parts = [theResponse componentsSeparatedByString:@" "];
		if([parts count] >= 8){
			NSString* datePart		= [parts objectAtIndex:1];
			NSString* timePart		= [parts objectAtIndex:2];
			NSString* size1Part		= [parts objectAtIndex:4];
			NSString* count1Part	= [parts objectAtIndex:5];
			NSString* size2Part		= [parts objectAtIndex:6];
			NSString* count2Part	= [parts objectAtIndex:7];
			
			[self setMeasurementDate: [NSString stringWithFormat:@"%02d/%02d/%02d %02d:%02d:%02d",
									   [datePart substringWithRange:NSMakeRange(0,2)],
									   [datePart substringWithRange:NSMakeRange(2,2)],
									   [datePart substringWithRange:NSMakeRange(4,2)],
									   [timePart substringWithRange:NSMakeRange(0,2)],
									   [timePart substringWithRange:NSMakeRange(2,2)],
									   [timePart substringWithRange:NSMakeRange(4,2)]
									   ]];
			 
			 [self setSize1: [size1Part floatValue]];
			 [self setCount1: [count1Part intValue]];
			 [self setSize2: [size2Part floatValue]];
			 [self setCount2: [count2Part intValue]];
		
		}
	}
			 
	else if([theResponse hasPrefix:@"R"]){	//resend record
	}
			 
	else if([theResponse hasPrefix:@"h"]){	//standby Mode
	}
			 
	else if([theResponse hasPrefix:@"g"]){	//active Mode
	}
			 
	else if([theResponse hasPrefix:@"l"]){	//active Mode
	}
			 
	else if([theResponse hasPrefix:@"U"]){		//Universal Select
												//do nothing
	}
	
	//NSLog(@"%@\n",theResponse);
}

- (void) startTimeOut
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeout) object:nil];
	[self performSelector:@selector(timeout) withObject:nil afterDelay:kMet237CmdTimeout];
}
@end
