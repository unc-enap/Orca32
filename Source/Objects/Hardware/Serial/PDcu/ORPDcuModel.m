//--------------------------------------------------------
// ORPDcuModel
// Created by Mark  A. Howe on Wed 4/15/2009
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

#pragma mark •••Imported Files

#import "ORPDcuModel.h"
#import "ORSerialPort.h"
#import "ORSerialPortAdditions.h"
#import "ORDataTypeAssigner.h"
#import "ORDataPacket.h"
#import "ORTimeRate.h"
#import "ORSafeQueue.h"

#pragma mark •••External Strings
NSString* ORPDcuModelTmpRotSetChanged		= @"ORPDcuModelTmpRotSetChanged";
NSString* ORPDcuModelPressureScaleChanged	= @"ORPDcuModelPressureScaleChanged";
NSString* ORPDcuModelStationPowerChanged	= @"ORPDcuModelStationPowerChanged";
NSString* ORPDcuModelMotorPowerChanged		= @"ORPDcuModelMotorPowerChanged";
NSString* ORPDcuModelPressureChanged		= @"ORPDcuModelPressureChanged";
NSString* ORPDcuModelMotorCurrentChanged	= @"ORPDcuModelMotorCurrentChanged";
NSString* ORPDcuModelActualRotorSpeedChanged = @"ORPDcuModelActualRotorSpeedChanged";
NSString* ORPDcuModelSetRotorSpeedChanged	= @"ORPDcuModelSetRotorSpeedChanged";
NSString* ORPDcuTurboStateChanged			= @"ORPDcuTurboStateChanged";
NSString* ORPDcuModelDeviceAddressChanged	= @"ORPDcuModelDeviceAddressChanged";
NSString* ORPDcuModelPollTimeChanged		= @"ORPDcuModelPollTimeChanged";
NSString* ORPDcuModelSerialPortChanged		= @"ORPDcuModelSerialPortChanged";
NSString* ORPDcuModelPortNameChanged		= @"ORPDcuModelPortNameChanged";
NSString* ORPDcuModelPortStateChanged		= @"ORPDcuModelPortStateChanged";
NSString* ORPDcuTurboAcceleratingChanged	= @"ORPDcuTurboAcceleratingChanged";
NSString* ORPDcuTurboSpeedAttainedChanged	= @"ORPDcuTurboSpeedAttainedChanged";
NSString* ORPDcuTurboOverTempChanged		= @"ORPDcuTurboOverTempChanged";
NSString* ORPDcuDriveOverTempChanged		= @"ORPDcuDriveOverTempChanged";
NSString* ORPDcuOilDeficiencyChanged		= @"ORPDcuOilDeficiencyChanged";
NSString* ORPDcuLock						= @"ORPDcuLock";

#pragma mark •••Status Parameters
#define kTMPRotSet		707
#define kDeviceAddress	797
#define kOilDeficiency	301
#define kTempDriveUnit	304
#define kTempTurbo		305
#define kSpeedAttained	306
#define kAccelerating	307
#define kSetSpeed		308
#define kActualSpeed	309
#define kMotorCurrent	310
#define kPressure		340
#define kUnitName		350
#define kStandby		2
#define kStationPower	10
#define kMotorPower		23
#define kRemoteOps		28

@interface ORPDcuModel (private)
- (NSString*) formatExp:(float)aFloat;
- (void)	timeout;
- (void)	processOneCommandFromQueue;
- (int)		checkSum:(NSString*)aString;
- (void)	enqueCmdString:(NSString*)aString;
- (void)	processReceivedString:(NSString*)aCommand;
- (BOOL)	extractBool:(NSString*)aCommand;
- (int)		extractInt:(NSString*)aCommand;
- (float)	extractFloat:(NSString*)aCommand;
- (NSString*) extractString:(NSString*)aCommand;
- (void) clearAlarms;
- (void) pollPressures;
@end

@implementation ORPDcuModel

- (void) dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
	[cmdQueue release];
	[lastRequest release];
	[inComingData release];
    [noOilAlarm clearAlarm];
    [noOilAlarm release];
	
	[super dealloc];
}

- (void)sleep
{
    [super sleep];
    	
    [noOilAlarm clearAlarm];
    [noOilAlarm release];
    noOilAlarm = nil;
}

- (void) setUpImage
{
	[self setImage:[NSImage imageNamed:@"PDcu.tif"]];
}

- (void) makeMainController
{
	[self linkToController:@"ORPDcuController"];
}

#pragma mark •••Accessors
- (int) tmpRotSet
{
    return tmpRotSet;
}

- (void) setTmpRotSet:(int)aTmpRotSet
{
	if(aTmpRotSet<20)aTmpRotSet = 20;
	else if(aTmpRotSet>100)aTmpRotSet=100;
    [[[self undoManager] prepareWithInvocationTarget:self] setTmpRotSet:tmpRotSet];
    tmpRotSet = aTmpRotSet;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORPDcuModelTmpRotSetChanged object:self];
}

- (int) pollTime
{
    return pollTime;
}

- (void) setPollTime:(int)aPollTime
{
    [[[self undoManager] prepareWithInvocationTarget:self] setPollTime:pollTime];
    pollTime = aPollTime;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORPDcuModelPollTimeChanged object:self];
	
	if(pollTime){
		[self performSelector:@selector(pollPressures) withObject:nil afterDelay:pollTime];
	}
	else {
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(pollPressures) object:nil];
	}
}

- (float) pressureScaleValue
{
	return pressureScaleValue;
}

- (int) pressureScale
{
    return pressureScale;
}

- (void) setPressureScale:(int)aPressureScale
{
	if(aPressureScale<0)aPressureScale=0;
	else if(aPressureScale>11)aPressureScale=11;
	
    [[[self undoManager] prepareWithInvocationTarget:self] setPressureScale:pressureScale];
    
    pressureScale = aPressureScale;
	
	pressureScaleValue = powf(10.,(float)pressureScale);
	
    [[NSNotificationCenter defaultCenter] postNotificationName:ORPDcuModelPressureScaleChanged object:self];
}

- (ORTimeRate*)timeRate
{
	return timeRate;
}

- (BOOL) stationPower
{
    return stationPower;
}

- (void) setStationPower:(BOOL)aStationPower
{
    stationPower = aStationPower;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORPDcuModelStationPowerChanged object:self];
}

- (BOOL) motorPower
{
    return motorPower;
}

- (void) setMotorPower:(BOOL)aMotorPower
{
    motorPower = aMotorPower;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORPDcuModelMotorPowerChanged object:self];
}

- (float) pressure
{
    return pressure;
}

- (void) setPressure:(float)aPressure
{
    pressure = aPressure;
	if(timeRate == nil) timeRate = [[ORTimeRate alloc] init];
	[timeRate addDataToTimeAverage:aPressure];
    [[NSNotificationCenter defaultCenter] postNotificationName:ORPDcuModelPressureChanged object:self];
}

- (float) motorCurrent
{
    return motorCurrent;
}

- (void) setMotorCurrent:(float)aMotorCurrent
{
    motorCurrent = aMotorCurrent;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORPDcuModelMotorCurrentChanged object:self];
}


- (int) actualRotorSpeed
{
    return actualRotorSpeed;
}

- (void) setActualRotorSpeed:(int)aActualRotorSpeed
{
    actualRotorSpeed = aActualRotorSpeed;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORPDcuModelActualRotorSpeedChanged object:self];
}

- (int) setRotorSpeed
{
    return setRotorSpeed;
}

- (void) setSetRotorSpeed:(int)aSetRotorSpeed
{
    setRotorSpeed = aSetRotorSpeed;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORPDcuModelSetRotorSpeedChanged object:self];
}

- (BOOL) turboAccelerating
{
    return turboAccelerating;
}

- (void) setTurboAccelerating:(BOOL)aTurboAccelerating
{
    turboAccelerating = aTurboAccelerating;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORPDcuTurboAcceleratingChanged object:self];
}

- (BOOL) speedAttained
{
    return speedAttained;
}

- (void) setSpeedAttained:(BOOL)aSpeedAttained
{
    speedAttained = aSpeedAttained;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORPDcuTurboSpeedAttainedChanged object:self];
}

- (BOOL) turboPumpOverTemp
{
    return turboPumpOverTemp;
}

- (void) setTurboPumpOverTemp:(BOOL)aTurboPumpOverTemp
{
    turboPumpOverTemp = aTurboPumpOverTemp;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORPDcuTurboOverTempChanged object:self];
}

- (BOOL) driveUnitOverTemp
{
    return driveUnitOverTemp;
}

- (void) setDriveUnitOverTemp:(BOOL)aDriveUnitOverTemp
{
    driveUnitOverTemp = aDriveUnitOverTemp;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORPDcuDriveOverTempChanged object:self];
}

- (BOOL) oilDeficiency
{
    return oilDeficiency;
}

- (void) setOilDeficiency:(BOOL)aOilDeficiency
{    
    oilDeficiency = aOilDeficiency;
	if(oilDeficiency){
		if(!noOilAlarm){
			NSString* s = [NSString stringWithFormat:@"No Oil -- DCU %lu",[self uniqueIdNumber]];
			noOilAlarm = [[ORAlarm alloc] initWithName:s severity:kImportantAlarm];
			[noOilAlarm setSticky:YES];
			[noOilAlarm setHelpStringFromFile:@"NoOilHelp"];
			[noOilAlarm setAcknowledged:NO];
		}                      
		[noOilAlarm postAlarm];
	}
	else {
		if(noOilAlarm){
			[noOilAlarm clearAlarm];
			[noOilAlarm release];
			noOilAlarm = nil;
		}
	}
    [[NSNotificationCenter defaultCenter] postNotificationName:ORPDcuOilDeficiencyChanged object:self];
}

- (int) deviceAddress
{
    return deviceAddress;
}

- (void) setDeviceAddress:(int)aDeviceAddress
{
	//if(aDeviceAddress<1)aDeviceAddress = 1;
	//else if(aDeviceAddress>255)aDeviceAddress= 255;
	
    [[[self undoManager] prepareWithInvocationTarget:self] setDeviceAddress:deviceAddress];
	if([serialPort isOpen]){
		//[self sendDataSet:kDeviceAddress integer:aDeviceAddress];
	}
    deviceAddress = aDeviceAddress;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORPDcuModelDeviceAddressChanged object:self];
}

- (NSString*) lastRequest
{
	return lastRequest;
}

- (void) setLastRequest:(NSString*)aCmdString
{
	[lastRequest autorelease];
	lastRequest = [aCmdString copy];    
}

- (void) openPort:(BOOL)state
{
    if(state) {
        [serialPort open];
		[serialPort setSpeed:9600];
		[serialPort setParityNone];
		[serialPort setStopBits2:NO];
		[serialPort setDataBits:8];
		[serialPort commitChanges];

		[serialPort setDelegate:self];
    }
    else {
		[serialPort close];
		[self clearAlarms];
	}
    portWasOpen = [serialPort isOpen];
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSerialPortModelPortStateChanged object:self];
    
}

#pragma mark •••Archival
- (id) initWithCoder:(NSCoder*)decoder
{
	self = [super initWithCoder:decoder];
	[[self undoManager] disableUndoRegistration];
	[self setTmpRotSet:		[decoder decodeIntForKey:	@"tmpRotSet"]];
	[self setPollTime:		[decoder decodeIntForKey:	@"pollTime"]];
	[self setPressureScale:	[decoder decodeIntForKey:	@"pressureScale"]];
	[self setDeviceAddress:	[decoder decodeIntForKey:	@"deviceAddress"]];
	[[self undoManager] enableUndoRegistration];
	cmdQueue = [[ORSafeQueue alloc] init];
	
	return self;
}

- (void) encodeWithCoder:(NSCoder*)encoder
{
    [super encodeWithCoder:encoder];
    [encoder encodeInt:tmpRotSet		forKey:@"tmpRotSet"];
    [encoder encodeInt:pressureScale	forKey: @"pressureScale"];
    [encoder encodeInt:deviceAddress	forKey: @"deviceAddress"];
    [encoder encodeInt:pollTime			forKey: @"pollTime"];
}

#pragma mark •••HW Methods
- (void) initUnit
{
	[self sendTmpRotSet:[self tmpRotSet]];
}

- (void) getDeviceAddress	{ [self sendDataRequest:kDeviceAddress]; }
- (void) getTMPRotSet		{ [self sendDataRequest:kTMPRotSet]; }
- (void) getOilDeficiency	{ [self sendDataRequest:kOilDeficiency]; }
- (void) getTurboTemp		{ [self sendDataRequest:kTempTurbo]; }
- (void) getDriveTemp		{ [self sendDataRequest:kTempDriveUnit]; }
- (void) getSpeedAttained	{ [self sendDataRequest:kSpeedAttained]; }
- (void) getAccelerating	{ [self sendDataRequest:kAccelerating]; }
- (void) getSetSpeed		{ [self sendDataRequest:kSetSpeed]; }
- (void) getActualSpeed		{ [self sendDataRequest:kActualSpeed]; }
- (void) getMotorCurrent	{ [self sendDataRequest:kMotorCurrent]; }
- (void) getPressure		{ [self sendDataRequest:kPressure]; }
- (void) getMotorPower		{ [self sendDataRequest:kMotorPower]; }
- (void) getStationPower	{ [self sendDataRequest:kStationPower]; }
- (void) getStandby			{ [self sendDataRequest:kStandby]; }
- (void) getUnitName		{ [self sendDataRequest:kUnitName]; }

- (void) updateAll
{
	[self getOilDeficiency];
	[self getTurboTemp];
	[self getDriveTemp];
	[self getAccelerating];
	[self getSpeedAttained];
	[self getSetSpeed];
	[self getActualSpeed];
	[self getMotorCurrent];
	[self getPressure];
	[self getStationPower];
	[self getMotorPower];
}

- (void) sendTmpRotSet:(int)aValue
{
	[self sendDataSet:kTMPRotSet real:aValue];
}

- (void) sendMotorPower:(BOOL)aState
{
	[self sendDataSet:kMotorPower bool:aState];
}

- (void) sendStationPower:(BOOL)aState
{
	[self sendDataSet:kStationPower bool:aState];
}

- (void) sendStandby:(BOOL)aState
{
	[self sendDataSet:kStandby bool:aState];
}

- (void) turnStationOn
{
	[self sendStandby:YES];
	[self sendStationPower:YES];
	[self sendMotorPower:YES];
}

- (void) turnStationOff
{
	[self sendMotorPower:NO];
	[self sendStationPower:NO];
	[self sendStandby:NO];
}

#pragma mark •••Commands
- (void) sendDataRequest:(int)aParamNum 
{
	//---------------------------
	//format of a data request
	//xxx00yyy02=?zzz\r
	//xxx = device address
	//yyy = parameter number
	//zzz = checksum
	//---------------------------
	NSString* cmdString = [NSString stringWithFormat:@"%03d00%03d02=?",deviceAddress,aParamNum];
	cmdString = [cmdString stringByAppendingFormat:@"%03d\r",[self checkSum:cmdString]];
	[self enqueCmdString:cmdString];
	
	//-VVVVVVVVVVVVVVVVVVVVV
	//for testing only.  Echoes back a response......
	//NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
	//NSString* s = [NSString stringWithFormat:@"%03d00%03d061.2E-2",deviceAddress,aParamNum];
	//s = [s stringByAppendingFormat:@"%03d\r",[self checkSum:cmdString]];

	//[userInfo setObject:[s dataUsingEncoding:NSASCIIStringEncoding] forKey:@"data"];
	//NSNotification* note =  [NSNotification notificationWithName:@"junk" object:nil userInfo:userInfo]; 
	//[self dataReceived:note];
	//-^^^^^^^^^^^^^^^^^^^^^^^
}

//---------------------------
//format of a data set
//xxx10yyyLLDD..DDzzz\r
//xxx = device address
//yyy = parameter number
//LL  = data length
//DD..DD = the data (variable length
//zzz = checksum
//---------------------------

- (void) sendDataSet:(int)aParamNum bool:(BOOL)aState 
{
	NSString* trueString = @"111111";
	NSString* falseString = @"000000";
	NSString* cmdString = [NSString stringWithFormat:@"%03d10%03d06%@",deviceAddress,aParamNum,aState?trueString:falseString];
	cmdString = [cmdString stringByAppendingFormat:@"%03d\r",[self checkSum:cmdString]];
	[self enqueCmdString:cmdString];
}

- (void) sendDataSet:(int)aParamNum integer:(unsigned int)anInt 
{
	NSString* cmdString = [NSString stringWithFormat:@"%03d10%03d06%06u",deviceAddress,aParamNum,anInt];
	cmdString = [cmdString stringByAppendingFormat:@"%03d\r",[self checkSum:cmdString]];
	[self enqueCmdString:cmdString];
}

- (void) sendDataSet:(int)aParamNum real:(float)aFloat 
{
	NSString* cmdString = [NSString stringWithFormat:@"%03d10%03d06%06d",deviceAddress,aParamNum,(int)(aFloat*100)];
	cmdString = [cmdString stringByAppendingFormat:@"%03d\r",[self checkSum:cmdString]];
	[self enqueCmdString:cmdString];
}

- (void) sendDataSet:(int)aParamNum expo:(float)aFloat 
{
	NSString* cmdString = [NSString stringWithFormat:@"%03d10%03d06%@",deviceAddress,aParamNum,[self formatExp:aFloat]];
	cmdString = [cmdString stringByAppendingFormat:@"%03d\r",[self checkSum:cmdString]];
	[self enqueCmdString:cmdString];
}

- (void) sendDataSet:(int)aParamNum shortInteger:(unsigned short)aShort 
{
	NSString* cmdString = [NSString stringWithFormat:@"%03d10%03d03%03u",deviceAddress,aParamNum,aShort];
	cmdString = [cmdString stringByAppendingFormat:@"%03d\r",[self checkSum:cmdString]];
	[self enqueCmdString:cmdString];
}

#pragma mark •••Data Records
- (unsigned long) dataId { return dataId; }
- (void) setDataId: (unsigned long) DataId
{
    dataId = DataId;
}
- (void) setDataIds:(id)assigner
{
    dataId       = [assigner assignDataIds:kLongForm];
}

- (void) syncDataIdsWith:(id)anotherPDcu
{
    [self setDataId:[anotherPDcu dataId]];
}

- (void) appendDataDescription:(ORDataPacket*)aDataPacket userInfo:(NSDictionary*)userInfo
{
    //----------------------------------------------------------------------------------------
    // first add our description to the data description
    [aDataPacket addDataDescriptionItem:[self dataRecordDescription] forKey:@"PDcuModel"];
}

- (NSDictionary*) dataRecordDescription
{
    NSMutableDictionary* dataDictionary = [NSMutableDictionary dictionary];
    NSDictionary* aDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
        @"ORPDcuDecoderForAdc",				@"decoder",
        [NSNumber numberWithLong:dataId],   @"dataId",
        [NSNumber numberWithBool:NO],       @"variable",
        [NSNumber numberWithLong:8],        @"length",
        nil];
    [dataDictionary setObject:aDictionary forKey:@"Adcs"];
    
    return dataDictionary;
}

- (void) dataReceived:(NSNotification*)note
{
	if(!lastRequest)return;
	
    if([[note userInfo] objectForKey:@"serialPort"] == serialPort){
		if(!inComingData)inComingData = [[NSMutableData data] retain];
		[inComingData appendData:[[note userInfo] objectForKey:@"data"]];
		
		char* p = (char*)[inComingData bytes];
		int i;
		int numCharsProcessed=0;
		NSMutableData* cmd =  [NSMutableData dataWithCapacity:64];
		for(i=0;i<[inComingData length];i++){
			[cmd appendBytes:p length:1];
			if(*p == '\r'){
				NSString* s = [[[NSString alloc] initWithData:cmd encoding:NSASCIIStringEncoding] autorelease];
				numCharsProcessed += [cmd length];
				[cmd setLength:0];
				if([s rangeOfString:@"=?"].location == NSNotFound){
					NSLog(@"received: %@\n",s);
					[self processReceivedString:s];
				}
			}
			p++;
		}
		if(numCharsProcessed){
			[inComingData replaceBytesInRange:NSMakeRange(0,numCharsProcessed) withBytes:nil length:0];
		}
	}
}

- (void) decode:(int)paramNumber command:(NSString*)aCommand
{
	switch (paramNumber) {
		case kDeviceAddress: [self setDeviceAddress:	[self extractInt:aCommand]]; break;
		case kStationPower:	 [self setStationPower:		[self extractBool:aCommand]]; break;
		case kMotorPower:	 [self setMotorPower:		[self extractBool:aCommand]]; break;
		case kOilDeficiency: [self setOilDeficiency:	[self extractBool:aCommand]]; break;
		case kTempDriveUnit: [self setDriveUnitOverTemp:[self extractBool:aCommand]]; break;
		case kTempTurbo:	 [self setTurboPumpOverTemp:[self extractBool:aCommand]]; break;
		case kSpeedAttained: [self setSpeedAttained:	[self extractBool:aCommand]]; break;
		case kAccelerating:  [self setTurboAccelerating:[self extractBool:aCommand]]; break;

		case kSetSpeed:		[self setSetRotorSpeed:		[self extractInt:aCommand]];   break;
		case kActualSpeed:  [self setActualRotorSpeed:	[self extractInt:aCommand]];   break;
		case kMotorCurrent: [self setMotorCurrent:		[self extractFloat:aCommand]]; break;
		case kPressure:		[self setPressure:			[self extractFloat:aCommand]]; break;			
		case kUnitName:		NSLog(@"DCU Unit: %@\n",	[self extractString:aCommand]);break;	
		default:
		break;
	}
}
@end

@implementation ORPDcuModel (private)
- (void) clearAlarms
{
	if(noOilAlarm){
		[noOilAlarm clearAlarm];
		[noOilAlarm release];
		noOilAlarm = nil;
	}	
}

- (BOOL)  extractBool: (NSString*)aCommand	{ return [[aCommand substringWithRange:NSMakeRange(10,6)] intValue]!=0; }
- (int)   extractInt:  (NSString*)aCommand	{ return [[aCommand substringWithRange:NSMakeRange(10,6)] intValue]; }
- (float) extractFloat:(NSString*)aCommand	{ return [[aCommand substringWithRange:NSMakeRange(10,6)] floatValue]; }
- (NSString*) extractString:(NSString*)aCommand	
{
	int numChars = [[aCommand substringWithRange:NSMakeRange(8,2)] intValue];
	return [aCommand substringWithRange:NSMakeRange(10,numChars)];
}

- (void) timeout
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeout) object:nil];
	NSLogError(@"command timeout",@"PAC",nil);
	[self setLastRequest:nil];
	[cmdQueue removeAllObjects];
	[self processOneCommandFromQueue];	 //do the next command in the queue
}

- (void) processOneCommandFromQueue
{
	if([cmdQueue count] == 0) return;
	NSString* cmdString = [cmdQueue dequeue];
	[self setLastRequest:cmdString];
	NSLog(@"send: %@\n",cmdString);
	[serialPort writeDataInBackground:[cmdString dataUsingEncoding:NSASCIIStringEncoding]];
	[self performSelector:@selector(timeout) withObject:nil afterDelay:.3];
}

- (int) checkSum:(NSString*)aString
{
	int i;
	int sum = 0;
	for(i=0;i<[aString length];i++){
		sum += (int)[aString characterAtIndex:i];
	}
	return sum%256;
}

- (void) enqueCmdString:(NSString*)aString
{
	if([serialPort isOpen]){
		[cmdQueue enqueue:aString];
		if(!lastRequest)[self processOneCommandFromQueue];
	}
}

- (NSString*) formatExp:(float)aFloat
{
	NSString* s = [NSString stringWithFormat:@"%.1E",aFloat];
	NSArray* parts = [s componentsSeparatedByString:@"E"];
	float m = [[parts objectAtIndex:0] floatValue];
	int e = [[parts objectAtIndex:1] intValue];
	s= [NSString stringWithFormat:@"%.1fE%d",m,e];
	s = [[s componentsSeparatedByString:@".0"] componentsJoinedByString:@""];
	int len = [s length];
	if(len<6){
		int i;
		for(i=0;i<6-len;i++){
			s = [NSString stringWithFormat:@"0%@",s];
		}
	}
	return s;
}

- (void) processReceivedString:(NSString*)aCommand
{
	BOOL doNextCommand = NO;
	//double check that the device address matches.
	int anAddress = [[aCommand substringToIndex:3] intValue];
	if(anAddress == deviceAddress){
		int receivedParam = [[aCommand substringWithRange:NSMakeRange(5,3)] intValue];
		[self decode:receivedParam command:aCommand];
		
		if(lastRequest){
			//if the param number matches the last cmd sent, then assume a match and remove the timeout
			int lastParam	  = [[lastRequest    substringWithRange:NSMakeRange(5,3)] intValue];
			if(receivedParam == lastParam){
				[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeout) object:nil];
				[self setLastRequest:nil];			 //clear the last request
				doNextCommand = YES;
			}
		}
	}
	
	if(doNextCommand){
		[ORTimer delay:.1];
		[self processOneCommandFromQueue];	 //do the next command in the queue
	}
}
- (void) pollPressures
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(pollPressures) object:nil];
	[self updateAll];
	[self performSelector:@selector(pollPressures) withObject:nil afterDelay:pollTime];
}
@end
