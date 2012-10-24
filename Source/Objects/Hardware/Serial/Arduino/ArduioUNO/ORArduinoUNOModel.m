//--------------------------------------------------------
// ORArduinoUNOModel
// Created by Mark  A. Howe on Wed 10/17/2012
// Code partially generated by the OrcaCodeWizard. Written by Mark A. Howe.
// Copyright (c) 2012 University of North Carolina. All rights reserved.
//-----------------------------------------------------------
//This program was prepared for the Regents of the University of 
//North Carolina sponsored in part by the United States 
//Department of Energy (DOE) under Grant #DE-FG02-97ER41020. 
//The University has certain rights in the program pursuant to 
//the contract and the program should not be copied or distributed 
//outside your organization.  The DOE and the University of 
//North Carolina reserve all rights in the program. Neither the authors,
//University of North Carolina, or U.S. Government make any warranty, 
//express or implied, or assume any liability or responsibility  
//for the use of this software.
//-------------------------------------------------------------

#pragma mark •••Imported Files

#import "ORArduinoUNOModel.h"
#import "ORSerialPortAdditions.h"
#import "ORProcessModel.h"

#pragma mark •••External Strings
NSString* ORArduinoUNOLock					= @"ORArduinoUNOLock";
NSString* ORArduinoUNOModelPollTimeChanged	= @"ORArduinoUNOModelPollTimeChanged";
NSString* ORArduinoUNOModelAdcChanged		= @"ORArduinoUNOModelAdcChanged";
NSString* ORArduinoUNOPinTypeChanged		= @"ORArduinoUNOPinTypeChanged";
NSString* ORArduinoUNOPwmChanged			= @"ORArduinoUNOPwmChanged";
NSString* ORArduinoUNOPinStateOutChanged	= @"ORArduinoUNOPinStateOutChanged";
NSString* ORArduinoUNOPinStateInChanged		= @"ORArduinoUNOPinStateInChanged";
NSString* ORArduinoUNOPinNameChanged		= @"ORArduinoUNOPinNameChanged";
NSString* ORArduinoUNOHiLimitChanged		= @"ORArduinoUNOHiLimitChanged";
NSString* ORArduinoUNOLowLimitChanged		= @"ORArduinoUNOLowLimitChanged";
NSString* ORArduinoUNOSlopeChanged			= @"ORArduinoUNOSlopeChanged";
NSString* ORArduinoUNOInterceptChanged		= @"ORArduinoUNOInterceptChanged";
NSString* ORArduinoUNOMinValueChanged		= @"ORArduinoUNOMinValueChanged";
NSString* ORArduinoUNOMaxValueChanged		= @"ORArduinoUNOMaxValueChanged";

@interface ORArduinoUNOModel (private)
- (void)	clearDelay;
- (void)	processOneCommandFromQueue;
- (void)	enqueCmdString:(NSString*)aString;
- (void)	processReceivedString:(NSString*)aCommand;
- (void)	pollHardware;
@end

@implementation ORArduinoUNOModel
- (id) init
{
	self = [super init];
	int i;
	for(i=0;i<kNumArduinoUNOAdcChannels;i++){
		lowLimit[i] = 0;
		hiLimit[i]  = 5;
		minValue[i] = 0;
		maxValue[i]  = 5;
		slope[i] = 1;
		intercept[i] = 0;
	}
	return self;
}

- (void) dealloc
{
	int i;
	for(i=0;i<kNumArduinoUNOPins;i++)	[pinName[i] release];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
	[inComingData release];
	[super dealloc];
}

- (void) wakeUp
{
	if(pollTime){
		[self initHardware];
		[self pollHardware];
	}
	[super wakeUp];
}

- (void) sleep
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [super sleep];
}

- (void) setUpImage
{
	[self setImage:[NSImage imageNamed:@"ArduinoUNO.tif"]];
}

- (void) makeMainController
{
	[self linkToController:@"ORArduinoUNOController"];
}

- (NSString*) helpURL
{
	return @"RS232/Arduino.html";
}

#pragma mark •••Accessors
- (NSString*) pinName:(int)i
{
	if(i>=0 && i<kNumArduinoUNOPins){
		if([pinName[i] length])return pinName[i];
		else return [NSString stringWithFormat:@"Chan %d",i];
	}
	else return @"";
}

- (void) setPin:(int)i name:(NSString*)aName
{
	if(i>=0 && i<kNumArduinoUNOPins){
		[[[self undoManager] prepareWithInvocationTarget:self] setPin:i name:pinName[i]];
		
		[pinName[i] autorelease];
		pinName[i] = [aName copy]; 
		
		NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
		[userInfo setObject:[NSNumber numberWithInt:i] forKey: @"Pin"];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:ORArduinoUNOPinNameChanged object:self userInfo:userInfo];
		
	}
}

- (BOOL) validForPwm:(unsigned short)aPin
{
	switch(aPin){
			//only these pins can be PWM
		case 3:
		case 5:
		case 6:
		case 9:
		case 10:
		case 11: return YES;
		default: return NO;
	}
}

- (unsigned char) pwm:(unsigned short)aPin
{
	if(aPin<kNumArduinoUNOPins)return pwm[aPin];
	else return 0;
}

- (void) setPin:(unsigned short)aPin pwm:(unsigned char)aValue
{
	if(aPin<kNumArduinoUNOPins){
		if(pinType[aPin] == kArduinoPWM){
			if([self validForPwm:aPin]){
				[[[self undoManager] prepareWithInvocationTarget:self] setPin:aPin pwm:pwm[aPin]];
				pwm[aPin] = aValue;
				NSDictionary* userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:aPin] forKey:@"Pin"];
				[[NSNotificationCenter defaultCenter] postNotificationName:ORArduinoUNOPwmChanged object:self userInfo:userInfo];
			}
		}
	}
}

- (unsigned char) pinType:(unsigned short)aPin
{
	if(aPin>=2 && aPin<kNumArduinoUNOPins)return pinType[aPin];
	else return 0;
}

- (void) setPin:(unsigned short)aPin type:(unsigned char)aType
{
	if(aPin>=2 && aPin<kNumArduinoUNOPins){
		[[[self undoManager] prepareWithInvocationTarget:self] setPin:aPin type:pinType[aPin]];
		if(aType == kArduinoPWM){
			if([self validForPwm:aPin]){
				pinType[aPin] = kArduinoPWM;
			}
		}
		else pinType[aPin] = aType;
		
		NSDictionary* userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:aPin] forKey:@"Pin"];
		[[NSNotificationCenter defaultCenter] postNotificationName:ORArduinoUNOPinTypeChanged object:self userInfo:userInfo];
	}
}

- (BOOL) pinStateOut:(unsigned short)aPin;
{
	if(aPin>=2 && aPin<kNumArduinoUNOPins) return pinStateOut[aPin];
	else return NO;
}

- (void) setPin:(unsigned short)aPin stateOut:(BOOL)aValue
{
	@synchronized(self){
		if(aPin>=2 && aPin<kNumArduinoUNOPins){
			[[[self undoManager] prepareWithInvocationTarget:self] setPin:aPin stateOut:pinStateOut[aPin]];
			pinStateOut[aPin] = aValue;
			NSDictionary* userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:aPin] forKey:@"Pin"];
			[[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:ORArduinoUNOPinStateOutChanged object:self userInfo:userInfo];
		}
	}
}

- (BOOL) pinStateIn:(unsigned short)aPin;
{
	if(aPin>=2 && aPin<kNumArduinoUNOPins) return pinStateIn[aPin];
	else return NO;
}

- (void) setPin:(unsigned short)aPin stateIn:(BOOL)aValue
{
	@synchronized(self){
		if(aPin>=2 && aPin<kNumArduinoUNOPins){
			pinStateIn[aPin] = aValue;
			NSDictionary* userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:aPin] forKey:@"Pin"];
			[[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:ORArduinoUNOPinStateInChanged object:self userInfo:userInfo];
		}
	}
}

- (float)  adc:(unsigned short)aChan
{
	if(aChan<kNumArduinoUNOAdcChannels)return adc[aChan];
	else return 0;
}

- (void) setAdc:(unsigned short)aChan withValue:(float)aValue
{
	if(aChan<kNumArduinoUNOAdcChannels){
		adc[aChan] = aValue;
		NSDictionary* userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:aChan] forKey:@"Channel"];
		[[NSNotificationCenter defaultCenter] postNotificationName:ORArduinoUNOModelAdcChanged object:self userInfo:userInfo];
	}		
}

- (int) pollTime
{
    return pollTime;
}

- (void) setPollTime:(int)aPollTime
{
    [[[self undoManager] prepareWithInvocationTarget:self] setPollTime:pollTime];
    pollTime = aPollTime;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORArduinoUNOModelPollTimeChanged object:self];
	
	if(pollTime){
		[self performSelector:@selector(pollHardware) withObject:nil afterDelay:.2];
	}
	else {
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(pollHardware) object:nil];
	}
}

- (void) setUpPort
{
	[serialPort setSpeed:57600];
	[serialPort setParityNone];
	[serialPort setStopBits2:NO];
	[serialPort setDataBits:8];
}

- (void) firstActionAfterOpeningPort
{
	[cmdQueue removeAllObjects];
	[self initHardware];
	[self pollHardware];
}

- (float) slope:(int)i
{
	if(i>=0 && i<kNumArduinoUNOAdcChannels)return slope[i];
	else return 20./4095.;
}

- (void) setSlope:(int)i value:(float)aValue
{
	if(i>=0 && i<kNumArduinoUNOAdcChannels){
		[[[self undoManager] prepareWithInvocationTarget:self] setSlope:i value:slope[i]];
		
		slope[i] = aValue; 
		
		NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
		[userInfo setObject:[NSNumber numberWithInt:i] forKey: @"Channel"];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:ORArduinoUNOSlopeChanged object:self userInfo:userInfo];
		
	}
}

- (float) intercept:(int)i
{
	if(i>=0 && i<kNumArduinoUNOAdcChannels)return intercept[i];
	else return -10;
}

- (void) setIntercept:(int)i value:(float)aValue
{
	if(i>=0 && i<kNumArduinoUNOAdcChannels){
		[[[self undoManager] prepareWithInvocationTarget:self] setIntercept:i value:intercept[i]];
		
		intercept[i] = aValue; 
		
		NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
		[userInfo setObject:[NSNumber numberWithInt:i] forKey: @"Channel"];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:ORArduinoUNOInterceptChanged object:self userInfo:userInfo];
		
	}
}

- (float) lowLimit:(int)i
{
	if(i>=0 && i<kNumArduinoUNOAdcChannels)return lowLimit[i];
	else return 0;
}

- (void) setLowLimit:(int)i value:(float)aValue
{
	if(i>=0 && i<kNumArduinoUNOAdcChannels){
		[[[self undoManager] prepareWithInvocationTarget:self] setLowLimit:i value:lowLimit[i]];
		
		lowLimit[i] = aValue; 
		
		NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
		[userInfo setObject:[NSNumber numberWithInt:i] forKey: @"Channel"];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:ORArduinoUNOLowLimitChanged object:self userInfo:userInfo];
		
	}
}

- (float) hiLimit:(int)i
{
	if(i>=0 && i<kNumArduinoUNOAdcChannels)return hiLimit[i];
	else return 0;
}

- (void) setHiLimit:(int)i value:(float)aValue
{
	if(i>=0 && i<kNumArduinoUNOAdcChannels){
		[[[self undoManager] prepareWithInvocationTarget:self] setHiLimit:i value:lowLimit[i]];
		
		hiLimit[i] = aValue; 
		
		NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
		[userInfo setObject:[NSNumber numberWithInt:i] forKey: @"Channel"];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:ORArduinoUNOHiLimitChanged object:self userInfo:userInfo];
		
	}
}

- (float) minValue:(int)i
{
	if(i>=0 && i<kNumArduinoUNOAdcChannels)return minValue[i];
	else return 0;
}

- (void) setMinValue:(int)i value:(float)aValue
{
	if(i>=0 && i<kNumArduinoUNOAdcChannels){
		[[[self undoManager] prepareWithInvocationTarget:self] setMinValue:i value:minValue[i]];
		
		minValue[i] = aValue; 
		
		NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
		[userInfo setObject:[NSNumber numberWithInt:i] forKey: @"Channel"];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:ORArduinoUNOMinValueChanged object:self userInfo:userInfo];
		
	}
}
- (float) maxValue:(int)i
{
	if(i>=0 && i<kNumArduinoUNOAdcChannels)return maxValue[i];
	else return 0;
}

- (void) setMaxValue:(int)i value:(float)aValue
{
	if(i>=0 && i<kNumArduinoUNOAdcChannels){
		[[[self undoManager] prepareWithInvocationTarget:self] setMaxValue:i value:maxValue[i]];
		
		maxValue[i] = aValue; 
		
		NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
		[userInfo setObject:[NSNumber numberWithInt:i] forKey: @"Channel"];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:ORArduinoUNOMaxValueChanged object:self userInfo:userInfo];
		
	}
}


#pragma mark •••Archival
- (id) initWithCoder:(NSCoder*)decoder
{
	self = [super initWithCoder:decoder];
	[[self undoManager] disableUndoRegistration];
	[self setPollTime:		[decoder decodeIntForKey:	@"pollTime"]];

	int i;
	for(i=0;i<kNumArduinoUNOPins;i++) {
		
		NSString* aName = [decoder decodeObjectForKey:[NSString stringWithFormat:@"PinName%d",i]];
		if(aName)[self setPin:i name:aName];
		else	 [self setPin:i name:[NSString stringWithFormat:@"Pin %2d",i]];
		
		[self setPin:i stateOut:[decoder decodeIntForKey:[NSString stringWithFormat:@"PinStateOut%d",i]]];
		[self setPin:i type:[decoder decodeIntForKey:[NSString stringWithFormat:@"PinType%d",i]]];
		[self setPin:i pwm:[decoder decodeIntForKey:[NSString stringWithFormat:@"PinPwm%d",i]]];
	}
	for(i=0;i<kNumArduinoUNOPins;i++) {
		[self setMinValue:i value:[decoder decodeFloatForKey:[NSString stringWithFormat:@"minValue%d",i]]];
		[self setMaxValue:i value:[decoder decodeFloatForKey:[NSString stringWithFormat:@"maxValue%d",i]]];
		[self setLowLimit:i value:[decoder decodeFloatForKey:[NSString stringWithFormat:@"lowLimit%d",i]]];
		[self setHiLimit:i value:[decoder decodeFloatForKey:[NSString stringWithFormat:@"hiLimit%d",i]]];
		[self setSlope:i value:[decoder decodeFloatForKey:[NSString stringWithFormat:@"slope%d",i]]];
		[self setIntercept:i value:[decoder decodeFloatForKey:[NSString stringWithFormat:@"intercept%d",i]]];
		
	}
	
	[[self undoManager] enableUndoRegistration];
	
	return self;
}

- (void) encodeWithCoder:(NSCoder*)encoder
{
    [super encodeWithCoder:encoder];
	int i;
	for(i=0;i<kNumArduinoUNOAdcChannels;i++) {
		[encoder encodeObject:pinName[i] forKey:[NSString stringWithFormat:@"pinName%d",i]];
		[encoder encodeInt:pinStateOut[i] forKey:[NSString stringWithFormat:@"pinStateOut%d",i]];
		[encoder encodeInt:pinType[i] forKey:[NSString stringWithFormat:@"PinType%d",i]];
		[encoder encodeInt:pwm[i] forKey:[NSString stringWithFormat:@"PinPwm%d",i]];
	}
	for(i=0;i<kNumArduinoUNOPins;i++) {
		[encoder encodeFloat:lowLimit[i] forKey:[NSString stringWithFormat:@"lowLimit%d",i]];
		[encoder encodeFloat:hiLimit[i] forKey:[NSString stringWithFormat:@"hiLimit%d",i]];
		[encoder encodeFloat:slope[i] forKey:[NSString stringWithFormat:@"slope%d",i]];
		[encoder encodeFloat:intercept[i] forKey:[NSString stringWithFormat:@"intercept%d",i]];
		[encoder encodeFloat:minValue[i] forKey:[NSString stringWithFormat:@"minValue%d",i]];
		[encoder encodeFloat:maxValue[i] forKey:[NSString stringWithFormat:@"maxValue%d",i]];
	}
	[encoder encodeInt:pollTime			forKey: @"pollTime"];
}

#pragma mark •••HW Methods//-------------Methode to flag beginning of common script methods---------------------------------
- (void) commonScriptMethodSectionBegin { }

- (int) numberCommandsInQueue
{
	return [cmdQueue count];
}

- (void) writeOutput:(unsigned short) aPin state:(BOOL)aState
{
	if(aPin>=2 && aPin < kNumArduinoUNOPins){
		if(pinType[aPin] == kArduinoOutput){
			NSString* cmd = [NSString stringWithFormat:@"w d %d %d",aPin,aState];
			[self enqueCmdString:cmd];
			[[self undoManager] disableUndoRegistration];
			[self setPin:aPin stateOut:aState];
			[[self undoManager] enableUndoRegistration];
			 
		}
	}
}

- (void) writeAllOutputs:(unsigned short)aMask
{
 	@synchronized(self){
		unsigned int typeMask = 0;
		int i;
		for(i=2;i<kNumArduinoUNOPins;i++){
			if(pinType[i] == kArduinoOutput)typeMask |= (1<<i);
		}
		NSString* cmd = [NSString stringWithFormat:@"w m %d %d",typeMask,aMask];
		[self enqueCmdString:cmd];

	}
}

- (void) readAdcValues
{
	[self enqueCmdString:@"r a"];
}

- (void) readInputPins
{
	NSString* cmd = [NSString stringWithFormat:@"r d %d",[self inputMask]];
	[self enqueCmdString:cmd];
}

- (void) initHardware
{
	if([serialPort isOpen]){
		[self readInputPins];
		int i;
		unsigned int aMask = 0;
		for(i=2;i<kNumArduinoUNOPins;i++){
			if(pinType[i] == kArduinoOutput){
				if(pinStateOut[i] == YES){
					aMask |= (1<<i);
				}
			}
		}
		[self writeAllOutputs:aMask];
		
		for(i=2;i<kNumArduinoUNOPins;i++){
			if(pinType[i] == kArduinoPWM){
				NSString* cmd = [NSString stringWithFormat:@"w a %d %d",i,pwm[i]];
				[self enqueCmdString:cmd];
			}
		}
	}
}


- (void) commonScriptMethodSectionEnd { }
//-------------end of common script methods---------------------------------

- (unsigned int) inputMask
{
	unsigned int aMask = 0;
	int i;
	for(i=2;i<kNumArduinoUNOPins;i++){
		if(pinType[i] == kArduinoInput)aMask |= (1<<i);
	}
	return aMask;
}

- (void) updateAll
{
	[self readAdcValues];
	[self readInputPins];
}


#pragma mark •••Commands

- (void) dataReceived:(NSNotification*)note
{	
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
				[self processReceivedString:s];
			}
			p++;
		}
		if(numCharsProcessed){
			[inComingData replaceBytesInRange:NSMakeRange(0,numCharsProcessed) withBytes:nil length:0];
		}
	}
}



#pragma mark •••Bit Processing Protocol
- (void) processIsStarting { }
- (void) processIsStopping { }
- (void) startProcessCycle { }
- (void) endProcessCycle   
{ 
	if(oldProcessOutMask!=processOutMask){
		oldProcessOutMask = processOutMask;
		[self writeAllOutputs:processOutMask];
		[[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:ORForceProcessPollNotification object:self userInfo:nil];
	}
}

- (NSString*) identifier
{
	NSString* s;
 	@synchronized(self){
		s= [NSString stringWithFormat:@"ArdUNO,%lu",[self uniqueIdNumber]];
	}
	return s;
}

- (NSString*) processingTitle
{
	NSString* s;
 	@synchronized(self){
		s= [self identifier];
	}
	return s;
}

- (BOOL) processValue:(int)channel
{
	BOOL theValue = 0;
	@synchronized(self){
		if(channel>=2 && channel<kNumArduinoUNOPins){
			if(pinType[channel] == kArduinoInput) theValue = pinStateIn[channel];
		}
	}
	return theValue;
}

- (double) convertedValue:(int)aChan
{
	double theValue = 0;
	@synchronized(self){
		if(aChan<kNumArduinoUNOAdcChannels)theValue =  slope[aChan] * adc[aChan] + intercept[aChan];
    }
	return theValue;
}

- (void) setProcessOutput:(int)aChan value:(int)aValue 
{ 
 	@synchronized(self){
		if(aChan>=2 && aChan<kNumArduinoUNOPins){
			if(aValue>0) processOutMask |= (0x1<<aChan);
			else		 processOutMask &= ~(0x1<<aChan);
		}
	}
}

- (double) maxValueForChan:(int)aChan
{
	return maxValue[aChan];
}

- (double) minValueForChan:(int)aChan
{
	return minValue[aChan];
}

- (void) getAlarmRangeLow:(double*)theLowLimit high:(double*)theHighLimit channel:(int)channel
{
	@synchronized(self){
		if(channel<kNumArduinoUNOAdcChannels){
			*theLowLimit = lowLimit[channel];
			*theHighLimit =  hiLimit[channel];
		}
		else {
			*theLowLimit = 0;
			*theHighLimit = 5;
		}
	}		
}


@end

@implementation ORArduinoUNOModel (private)
- (void) clearDelay
{
	delay = NO;
	[self processOneCommandFromQueue];
}
- (void) processOneCommandFromQueue
{
    if(delay) return;
	
	NSString* cmdString = [self nextCmd];
	if(cmdString){
		if([cmdString isEqualToString:@"++Delay"]){
			delay = YES;
			[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(clearDelay) object:nil];
			[self performSelector:@selector(clearDelay) withObject:nil afterDelay:.2];
		}
		else {
			if([serialPort isOpen]){
				[self setLastRequest:cmdString];
				[serialPort writeDataInBackground:[cmdString dataUsingEncoding:NSASCIIStringEncoding]];
				[self startTimeout:3];
			}
			else {
				[self cancelTimeout];
				[cmdQueue removeAllObjects];
			}
        }
	}
}

- (void) enqueCmdString:(NSString*)aString
{
	if([aString rangeOfString:@"\r"].location == NSNotFound)aString = [aString stringByAppendingString:@"\r"];
	//do more error checking here: make sure command is valide
	
	[self enqueueCmd:aString];
	//[self enqueueCmd:@"++Delay"]; //uncomment if delay is needed.
	if(!lastRequest)[self processOneCommandFromQueue];
}

- (void) processReceivedString:(NSString*)aCommand
{
	[self cancelTimeout];
	[self setIsValid:YES];
	aCommand = [[[aCommand removeNLandCRs] trimSpacesFromEnds] removeExtraSpaces];
	NSArray* parts = [aCommand componentsSeparatedByString:@" "];
	BOOL unsolicited = NO;
	if([parts count] >= 1){
		if([[parts objectAtIndex:0] isEqualToString:@"a"]){
			if([parts count] >= kNumArduinoUNOAdcChannels+1){
				int i;
				for(i=0;i<kNumArduinoUNOAdcChannels;i++){
					float adcValue = [[parts objectAtIndex:1+i] floatValue] * 5.0/1023.;
					[self setAdc:i withValue:adcValue];
				}
			}
		}
		else if([[parts objectAtIndex:0] isEqualToString:@"d"]){
			if([parts count] >= kNumArduinoUNOAdcChannels+1){
				int i;
				for(i=0;i<kNumArduinoUNOPins;i++){
					int pinValue = [[parts objectAtIndex:1+i] intValue];
					[self setPin:i stateIn:pinValue];
				}
			}
		}
		else if([[parts objectAtIndex:0] isEqualToString:@"i"]){
			//unsolicited incomming string "i hiPinMask"
			unsolicited = YES;
			if([parts count] >= 2){
				unsigned int hiMask = [[parts objectAtIndex:1] unsignedIntValue];
				int i;
				for(i=0;i<kNumArduinoUNOPins;i++){
					int pinValue = ((hiMask & (1<<i)) > 0);
					[self setPin:i stateIn:pinValue];
				}
			}
		}
		else if([[parts objectAtIndex:0] isEqualToString:@"m"]){
			[[self undoManager] disableUndoRegistration];
			if([parts count] >= 2){
				unsigned int outputMask = [[parts objectAtIndex:1] unsignedIntValue];
				int i;
				for(i=2;i<kNumArduinoUNOPins;i++){
					BOOL state = ((outputMask & (0x1<<i))>0);
					[self setPin:i stateOut:state];
				}
			}
			[[self undoManager] enableUndoRegistration];
		}
		
		if(lastRequest && !unsolicited){
			[self setLastRequest:nil];			 //clear the last request
			[self processOneCommandFromQueue];	 //do the next command in the queue
		}
	}
}

- (void) pollHardware
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(pollHardware) object:nil];
	float nextTime = pollTime;
	if(nextTime == 9999)nextTime = .03;
	if([serialPort isOpen]){
		[self updateAll];
		if(pollTime)[self performSelector:@selector(pollHardware) withObject:nil afterDelay:nextTime];
	}
}
@end