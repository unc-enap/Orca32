//
//  MJDPreAmpModel.m
//  Orca
//
//  Created by Mark Howe on Wed Jan 18 2012.
//  Copyright � 2012 University of North Carolina. All rights reserved.
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

#pragma mark ���Imported Files
#import "ORMJDPreAmpModel.h"
#import "ORDataTypeAssigner.h"
#import "ORDataPacket.h"
#import "ORTimeRate.h"
#import "ORAlarm.h"

#pragma mark ���Notification Strings
NSString* ORMJDPreAmpModelAdcEnabledMaskChanged = @"ORMJDPreAmpModelAdcEnabledMaskChanged";
NSString* ORMJDPreAmpModelPollTimeChanged	= @"ORMJDPreAmpModelPollTimeChanged";
NSString* ORMJDPreAmpModelShipValuesChanged = @"ORMJDPreAmpModelShipValuesChanged";
NSString* ORMJDPreAmpLoopForeverChanged		= @"ORMJDPreAmpLoopForeverChanged";
NSString* ORMJDPreAmpPulseCountChanged		= @"ORMJDPreAmpPulseCountChanged";
NSString* ORMJDPreAmpEnabledChanged			= @"ORMJDPreAmpEnabledChanged";
NSString* ORMJDPreAmpAttenuatedChanged		= @"ORMJDPreAmpAttenuatedChanged";
NSString* ORMJDPreAmpFinalAttenuatedChanged	= @"ORMJDPreAmpFinalAttenuatedChanged";
NSString* ORMJDPreAmpPulserMaskChanged		= @"ORMJDPreAmpPulserMaskChanged";
NSString* ORMJDPreAmpPulseHighTimeChanged	= @"ORMJDPreAmpPulseHighTimeChanged";
NSString* ORMJDPreAmpPulseLowTimeChanged	= @"ORMJDPreAmpPulseLowTimeChanged";
NSString* ORMJDPreAmpDacArrayChanged		= @"ORMJDPreAmpDacArrayChanged";
NSString* ORMJDPreAmpDacChanged				= @"ORMJDPreAmpDacChanged";
NSString* ORMJDPreAmpAmplitudeArrayChanged	= @"ORMJDPreAmpAmplitudeArrayChanged";
NSString* ORMJDPreAmpAmplitudeChanged		= @"ORMJDPreAmpAmplitudeChanged";
NSString* MJDPreAmpSettingsLock				= @"MJDPreAmpSettingsLock";
NSString* ORMJDPreAmpAdcChanged				= @"ORMJDPreAmpAdcChanged";
NSString* ORMJDFeedBackResistorArrayChanged = @"ORMJDFeedBackResistorArrayChanged";
NSString* ORMJDBaselineVoltageArrayChanged  = @"ORMJDBaselineVoltageArrayChanged";
NSString* ORMJDFeedBackResistorChanged      = @"ORMJDFeedBackResistorChanged";
NSString* ORMJDBaselineVoltageChanged		= @"ORMJDBaselineVoltageChanged";


#pragma mark ���Local Strings
static NSString* MJDPreAmpInputConnector     = @"MJDPreAmpInputConnector";

#define kDAC1 0x80000000
#define kDAC2 0x81000000
#define kDAC3 0x82000000
#define kDAC4 0x83000000

#define kDACA_H_Base		0x00200000
#define kPulserLowTimeMask	0xC0000000
#define kPulserHighTimeMask	0xC1000000
#define kAttnPatternMask	0xC2000000
#define kPulserStartMask	0xC3000000
#define kPulserLoopForever  (0x1<<23)
#define kPulserUseLoopCount (0x1<<22)

#define kADC1		0xE0000000
#define kADC2		0xE1000000

#define kReadAdcChannel0 0x00801000 // 8 single-ended inputs mode
#define kReadAdcChannel1 0x00841000
#define kReadAdcChannel2 0x00881000
#define kReadAdcChannel3 0x008C1000
#define kReadAdcChannel4 0x00901000
#define kReadAdcChannel5 0x00941000
#define kReadAdcChannel6 0x00981000
#define kReadAdcChannel7 0x009C1000

#define kReadTempChannel7 0x009F1000 // 7 pseudo-differential inputs mode, temperature read out from channel 7 - niko

//new stuff

#define kControlReg  0x4
#define kRangeReg1   0x5
#define kRangeReg2   0x6

#define kBipolar10V     0x0
#define kBipolar5V      0x1
#define kBipolar2_5V    0x2
#define kUniploar10V    0x3

#define kSingleEnded 0x0
#define kPseudoDiff  0x3

struct {
    unsigned long adcSelection;
    unsigned long mode;
    BOOL calculateLeakageCurrent;
    int leakageCurrentIndex;
    float slope;
    float intercept;
} mjdPreAmpTable[16] = {
    {kADC1,YES, 0,kSingleEnded,2*20/8192.,0},   //0,0
    {kADC1,YES, 1,kSingleEnded,2*20/8192.,0},   //0,1
    {kADC1,YES, 2,kSingleEnded,2*20/8192.,0},   //0,2
    {kADC1,YES, 3,kSingleEnded,2*20/8192.,0},   //0,3
    {kADC1,YES, 4,kSingleEnded,2*20/8192.,0},   //0,4
    {kADC1,NO, -1,kSingleEnded,2*20/8192.,0},   //0,5
    {kADC1,NO, -1,kSingleEnded,2*20/8192.,0},   //0,6
    {kADC1,NO, -1,kPseudoDiff,-0.4494,2387.82}, //0,7
    {kADC2,YES, 5,kSingleEnded,2*20/8192.,0},   //1,0
    {kADC2,YES, 6,kSingleEnded,2*20/8192.,0},   //1,1
    {kADC2,YES, 7,kSingleEnded,2*20/8192.,0},   //1,2
    {kADC2,YES, 8,kSingleEnded,2*20/8192.,0},   //1,3
    {kADC2,YES, 9,kSingleEnded,2*20/8192.,0},   //1,4
    {kADC2,NO, -1,kSingleEnded,4*20/8192.,0},   //1,5
    {kADC2,NO, -1,kSingleEnded,4*20/8192.,0},   //1,6
    {kADC2,NO, -1,kPseudoDiff,-0.4494,2387.82}, //1,7
};

@interface ORMJDPreAmpModel (private)
- (void) updateTrends;
- (void) calculateLeakageCurrentForAdc:(int) aChan;
- (void) postCouchDBRecord;
@end

@implementation ORMJDPreAmpModel
#pragma mark ���initialization
- (id) init //designated initializer
{
    self = [super init];
    [[self undoManager] disableUndoRegistration];
	[self setUpArrays];
    [[self undoManager] enableUndoRegistration];
    return self;
}

- (void) dealloc
{
    [dacs release];
	int i;
	for(i=0;i<kMJDPreAmpAdcChannels;i++){
		[adcHistory[i] release];
	}
    
    for(i=0;i<kMJDPreAmpLeakageCurrentChannels;i++){
		[leakageCurrentHistory[i] release];
	}
    for(i=0;i<2;i++){
        [temperatureAlarm[i] clearAlarm];
        [temperatureAlarm[i] release];
    }
    for(i=0;i<kMJDPreAmpAdcChannels;i++){
        [adcAlarm[i] clearAlarm];
        [adcAlarm[i] release];
    }
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
	if(pollTime){
		[self pollValues];
	}
}

- (void) setUpArrays
{
	if(!dacs){
		[self setDacs:[NSMutableArray arrayWithCapacity:kMJDPreAmpDacChannels]];
		int i;
		for(i=0;i<kMJDPreAmpDacChannels;i++){
			[dacs addObject:[NSNumber numberWithInt:0]];
		}	
	}
	if(!amplitudes){
		[self setAmplitudes:[NSMutableArray arrayWithCapacity:kMJDPreAmpDacChannels]];
		int i;
		for(i=0;i<kMJDPreAmpDacChannels;i++){
			[amplitudes addObject:[NSNumber numberWithInt:0]];
		}	
	}

    if(!feedBackResistors){
		[self setFeedBackResistors:[NSMutableArray arrayWithCapacity:kMJDPreAmpAdcChannels]];
		int i;
		for(i=0;i<kMJDPreAmpAdcChannels;i++){
			[feedBackResistors addObject:[NSNumber numberWithInt:0]];
		}
	}
    if(!baselineVoltages){
		[self setBaselineVoltages:[NSMutableArray arrayWithCapacity:kMJDPreAmpAdcChannels]];
		int i;
		for(i=0;i<kMJDPreAmpAdcChannels;i++){
			[baselineVoltages addObject:[NSNumber numberWithInt:0]];
		}
	}
}

- (void) makeConnectors
{
    ORConnector* aConnector = [[ORConnector alloc] initAt:NSMakePoint(2,[self frame].size.height/2 - kConnectorSize/2) withGuardian:self withObjectLink:self];
	[aConnector setConnectorType: 'SPII' ];
	[aConnector addRestrictedConnectionType: 'SPIO' ]; 
	[aConnector setOffColor:[NSColor colorWithCalibratedRed:0 green:.68 blue:.65 alpha:1.]];
    [[self connectors] setObject:aConnector forKey:MJDPreAmpInputConnector];
    [aConnector release];
}

- (void) setUpImage
{
    [self setImage:[NSImage imageNamed:@"MJDPreAmp"]];
}

- (void) makeMainController
{
    [self linkToController:@"ORMJDPreAmpController"];
}

#pragma mark ���Accessors
- (ORTimeRate*)adcHistory:(int)index
{
    if(index>=0 && index<kMJDPreAmpAdcChannels)return adcHistory[index];
    else return nil;
}

- (ORTimeRate*)leakageCurrentHistory:(int)index
{
    if(index>=0 && index<kMJDPreAmpLeakageCurrentChannels)return leakageCurrentHistory[index];
    else return nil;
}


- (unsigned long) adcEnabledMask
{
    return adcEnabledMask;
}

- (void) setAdcEnabledMask:(unsigned long)aAdcEnabledMask
{
    [[[self undoManager] prepareWithInvocationTarget:self] setAdcEnabledMask:adcEnabledMask];
    
    adcEnabledMask = aAdcEnabledMask;

    [[NSNotificationCenter defaultCenter] postNotificationName:ORMJDPreAmpModelAdcEnabledMaskChanged object:self];
}

- (BOOL) shipValues
{
    return shipValues;
}

- (void) setShipValues:(BOOL)aShipValues
{
    [[[self undoManager] prepareWithInvocationTarget:self] setShipValues:shipValues];
    
    shipValues = aShipValues;

    [[NSNotificationCenter defaultCenter] postNotificationName:ORMJDPreAmpModelShipValuesChanged object:self];
}

- (int) pollTime
{
    return pollTime;
}

- (void) setPollTime:(int)aPollTime
{
    [[[self undoManager] prepareWithInvocationTarget:self] setPollTime:aPollTime];
    pollTime = aPollTime;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORMJDPreAmpModelPollTimeChanged object:self];
	
	if(pollTime){
		[self performSelector:@selector(pollValues) withObject:nil afterDelay:2];
	}
	else {
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(pollValues) object:nil];
	}
}

- (NSMutableArray*) feedBackResistors
{
    return feedBackResistors;
}
- (void) setFeedBackResistors:(NSMutableArray*)anArray
{
    [anArray retain];
    [feedBackResistors release];
    feedBackResistors = anArray;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ORMJDFeedBackResistorArrayChanged object:self];

}
- (float) feedBackResistor:(unsigned short) aChan
{
    if(aChan<kMJDPreAmpAdcChannels){
        return [[feedBackResistors objectAtIndex:aChan] floatValue];
	}
	else return 0.0;

}
- (void) setFeedBackResistor:(int) aChan value:(float) aValue
{
    if(aChan<kMJDPreAmpAdcChannels){
		[[[self undoManager] prepareWithInvocationTarget:self] setFeedBackResistor:aChan value:[self feedBackResistor:aChan]];
		[feedBackResistors replaceObjectAtIndex:aChan withObject:[NSNumber numberWithFloat:aValue]];
        
		NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
		[userInfo setObject:[NSNumber numberWithFloat:aChan] forKey: @"Channel"];
        
        //update leakage current for relevant channels
        if(mjdPreAmpTable[aChan].calculateLeakageCurrent){
            [self calculateLeakageCurrentForAdc:aChan];
        }
        
 		[[NSNotificationCenter defaultCenter] postNotificationName:ORMJDFeedBackResistorChanged
															object:self
														  userInfo: userInfo];
       
	}

}
- (NSMutableArray*) baselineVoltages
{
    return baselineVoltages;

}
- (void) setBaselineVoltages:(NSMutableArray*)anArray
{
    [anArray retain];
    [baselineVoltages release];
    baselineVoltages = anArray;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ORMJDBaselineVoltageArrayChanged object:self];
  
}

- (float) baselineVoltage:(unsigned short) aChan
{
    if(aChan<[baselineVoltages count]){
        return [[baselineVoltages objectAtIndex:aChan] floatValue];
	}
	else return 0.0;
 
}

- (void) setBaselineVoltage:(int) aChan value:(float) aValue
{
    if(aChan<[baselineVoltages count]){
		[[[self undoManager] prepareWithInvocationTarget:self] setBaselineVoltage:aChan value:[self baselineVoltage:aChan]];
		[baselineVoltages replaceObjectAtIndex:aChan withObject:[NSNumber numberWithFloat:aValue]];
        
		NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
		[userInfo setObject:[NSNumber numberWithFloat:aChan] forKey: @"Channel"];
        
        if(mjdPreAmpTable[aChan].calculateLeakageCurrent){
            [self calculateLeakageCurrentForAdc:aChan];
        }
        
 		[[NSNotificationCenter defaultCenter] postNotificationName:ORMJDBaselineVoltageChanged
															object:self
														  userInfo: userInfo];
        
	}
}



- (float) adc:(unsigned short) aChan
{
	if(aChan<kMJDPreAmpAdcChannels){
		if(adcEnabledMask & (0x1<<aChan))return adcs[aChan];
		else return 0.0;
	}
	else return 0.0;
}

- (float) leakageCurrent:(unsigned short) aChan
{
	if(aChan>=0 && aChan<kMJDPreAmpLeakageCurrentChannels){
		if(adcEnabledMask & (0x1<<aChan))return leakageCurrents[aChan];
		else return 0.0;
	}
	else return 0.0;
}


- (void) setAdc:(int) aChan value:(float) aValue
{
	if(aChan>=0 && aChan<kMJDPreAmpAdcChannels){
        
		adcs[aChan] = aValue;
	
		NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
		[userInfo setObject:[NSNumber numberWithFloat:aChan] forKey: @"Channel"];

         
		[[NSNotificationCenter defaultCenter] postNotificationName:ORMJDPreAmpAdcChanged
															object:self
														  userInfo: userInfo];
	}
}

- (void) setLeakageCurrent:(int) aChan value:(float) aValue
{
    leakageCurrents[aChan] = aValue;
}

- (BOOL) loopForever
{
    return loopForever;
}

- (void) setLoopForever:(BOOL)aLoopForever
{
    [[[self undoManager] prepareWithInvocationTarget:self] setLoopForever:loopForever];
    
    loopForever = aLoopForever;

    [[NSNotificationCenter defaultCenter] postNotificationName:ORMJDPreAmpLoopForeverChanged object:self];
}

- (unsigned short) pulseCount
{
    return pulseCount;
}

- (void) setPulseCount:(unsigned short)aPulseCount
{
    [[[self undoManager] prepareWithInvocationTarget:self] setPulseCount:pulseCount];
    
    pulseCount = aPulseCount;

    [[NSNotificationCenter defaultCenter] postNotificationName:ORMJDPreAmpPulseCountChanged object:self];
}

- (BOOL) enabled:(int)index
{
	if(index>=0 && index<2) return enabled[index];
    else return NO;
}

- (void) setEnabled:(int)index value:(BOOL)aEnabled
{
	if(index<0 || index>1) return;
    [[[self undoManager] prepareWithInvocationTarget:self] setEnabled:index value:enabled[index]];
    enabled[index] = aEnabled;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORMJDPreAmpEnabledChanged object:self];
}

- (BOOL) attenuated:(int)index
{
	if(index>=0 && index<2) return attenuated[index];
    else return NO;
}

- (void) setAttenuated:(int)index value:(BOOL)aAttenuated
{
	if(index<0 || index>1) return;
    [[[self undoManager] prepareWithInvocationTarget:self] setAttenuated:index value:attenuated[index]];
    attenuated[index] = aAttenuated;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORMJDPreAmpAttenuatedChanged object:self];
}

- (BOOL) finalAttenuated:(int)index
{
	if(index>=0 && index<2) return finalAttenuated[index];
    else return NO;
}

- (void) setFinalAttenuated:(int)index value:(BOOL)aAttenuated
{
	if(index<0 || index>1) return;
    [[[self undoManager] prepareWithInvocationTarget:self] setFinalAttenuated:index value:finalAttenuated[index]];
    finalAttenuated[index] = aAttenuated;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORMJDPreAmpFinalAttenuatedChanged object:self];
}


- (unsigned short) pulserMask
{
    return pulserMask;
}

- (void) setPulserMask:(unsigned short)aPulserMask
{
    [[[self undoManager] prepareWithInvocationTarget:self] setPulserMask:pulserMask];
    pulserMask = aPulserMask;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORMJDPreAmpPulserMaskChanged object:self];
}

- (int) pulseHighTime
{
	return pulseHighTime;
}

- (void) setPulseHighTime:(int)aPulseHighTime
{
	if(aPulseHighTime<1)			aPulseHighTime=1;
	else if(aPulseHighTime>0xFFFF)	aPulseHighTime = 0xFFFF;
	[[[self undoManager] prepareWithInvocationTarget:self] setPulseHighTime:pulseHighTime];
    pulseHighTime = aPulseHighTime;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORMJDPreAmpPulseHighTimeChanged object:self];
}

- (int) pulseLowTime
{
	return pulseLowTime;
}

- (void) setPulseLowTime:(int)aPulseLowTime
{
	if(aPulseLowTime<1)			aPulseLowTime=1;
	else if(aPulseLowTime>0xFFFF)	aPulseLowTime = 0xFFFF;
	
	[[[self undoManager] prepareWithInvocationTarget:self] setPulseLowTime:pulseLowTime];
    pulseLowTime = aPulseLowTime;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORMJDPreAmpPulseLowTimeChanged object:self];
}

- (NSMutableArray*) dacs
{
    return dacs;
}

- (void) setDacs:(NSMutableArray*)anArray
{
    [anArray retain];
    [dacs release];
    dacs = anArray;

    [[NSNotificationCenter defaultCenter] postNotificationName:ORMJDPreAmpDacArrayChanged object:self];
}

- (unsigned long) dac:(unsigned short) aChan
{
    return [[dacs objectAtIndex:aChan] unsignedShortValue];
}

- (void) setDac:(unsigned short) aChan withValue:(unsigned long) aValue
{
	if(aValue>0xffff) aValue = 0xffff;
    [[[self undoManager] prepareWithInvocationTarget:self] setDac:aChan withValue:[self dac:aChan]];
	[dacs replaceObjectAtIndex:aChan withObject:[NSNumber numberWithInt:aValue]];
	
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:[NSNumber numberWithInt:aChan] forKey: @"Channel"];
	
    [[NSNotificationCenter defaultCenter] postNotificationName:ORMJDPreAmpDacChanged
														object:self
													  userInfo: userInfo];
}

- (unsigned long) timeMeasured
{
	return timeMeasured;
}
- (NSMutableArray*) amplitudes
{
    return amplitudes;
}

- (void) setAmplitudes:(NSMutableArray*)anArray
{
    [anArray retain];
    [amplitudes release];
    amplitudes = anArray;
	
    [[NSNotificationCenter defaultCenter] postNotificationName:ORMJDPreAmpAmplitudeArrayChanged object:self];
}

- (unsigned long) amplitude:(int) aChan
{
    return [[amplitudes objectAtIndex:aChan] unsignedShortValue];
}

- (void) setAmplitude:(int) aChan withValue:(unsigned long) aValue
{
	if(aValue>0xffff) aValue = 0xffff;
    [[[self undoManager] prepareWithInvocationTarget:self] setAmplitude:aChan withValue:[self amplitude:aChan]];
	[amplitudes replaceObjectAtIndex:aChan withObject:[NSNumber numberWithInt:aValue]];
	
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:[NSNumber numberWithUnsignedShort:aChan] forKey: @"Channel"];
	
    [[NSNotificationCenter defaultCenter] postNotificationName:ORMJDPreAmpAmplitudeChanged
														object:self
													  userInfo: userInfo];
}

- (NSString*) helpURL
{
	return nil;
}

#pragma mark ���HW Access
- (void) writeFetVdsToHW
{
	int i;
	for(i=0;i<kMJDPreAmpDacChannels;i++){
		[self writeFetVds:i];
	}
}

- (void) writeFetVds:(int)index
{
	if(index>=0 && index<16){
		unsigned long theValue;
		//set up the Octal chip mask first
		if(index<8)	theValue = kDAC3;
		else		theValue = kDAC4;
		
		//set up which of eight DAC on that octal chip
		theValue |= (kDACA_H_Base | (index%8 << 16));
		
		//set up the value
		theValue |= [self dac:index];
		[self writeAuxIOSPI:theValue];
	}
}

- (void) writeAmplitudes
{
	int i;
	for(i=0;i<kMJDPreAmpDacChannels;i++){
		[self writeAmplitude:i];
	}
}

- (void) writeAmplitude:(int)index
{
	if(index>=0 && index<16){
		unsigned long theValue;
		//set up the Octal chip mask first
		if(index<8)	theValue = kDAC1;
		else		theValue = kDAC2;
		
		//set up which of eight DAC on that octal chip
		theValue |= (kDACA_H_Base | (index%8 << 16));
		
		//set up the value
		theValue |= [self amplitude:index];
		[self writeAuxIOSPI:theValue];
	}
}

- (void) zeroAmplitudes
{
    unsigned long zeroAllOctalChips = 0x2F0000;
	[self writeAuxIOSPI:(kDAC1 | zeroAllOctalChips)];
	[self writeAuxIOSPI:(kDAC2 | zeroAllOctalChips)];
}

- (void) writeAdcRanges
{
    rangesHaveBeenSet = YES;
    //the control word is mapped to bits 23 - bit 8 of the 32 bit word sent to the
    //controller
    
    //both chips are set up the same. so we only have to 
    unsigned long controlWord;    
    controlWord =   (kRangeReg1      << 13)  |
                    (kBipolar10V     << 11)  |       //chan 0
                    (kBipolar10V     << 9)   |       //chan 1
                    (kBipolar10V     << 7)   |       //chan 2
                    (kBipolar10V     << 5);           //chan 3
    [self writeAuxIOSPI:kADC1 | (controlWord<<8)];   //shift to bit 8 + add the adc sel
    [self writeAuxIOSPI:kADC2 | (controlWord<<8)];   //shift to bit 8 + add the adc sel
    
    controlWord =   (kRangeReg2      << 13)  |
                    (kBipolar10V     << 11)  |        //chan 4
                    (kBipolar10V     << 9)   |        //chan 5
                    (kBipolar10V     << 7)   |        //chan 6
                    (kBipolar2_5V    << 5);           //chan 7
    [self writeAuxIOSPI:kADC1 | (controlWord<<8)];    //shift to bit 8 + add the adc sel
    [self writeAuxIOSPI:kADC2 | (controlWord<<8)];    //shift to bit 8 + add the adc sel
}

- (void) readAllAdcs
{
    [self readAllAdcs:NO];
}

- (void) readAllAdcs:(BOOL)verbose
{
    if(!rangesHaveBeenSet)[self writeAdcRanges];

    int chan;
	for(chan=0;chan<kMJDPreAmpAdcChannels;chan++){
		if(adcEnabledMask & (0x1<<chan)){
            unsigned long controlWord = (kControlReg << 13)    |            //sel the chan set
                                        ((chan%2)<<10)         |           //set chan
                                        (mjdPreAmpTable[chan].mode << 8);   //set mode, other bits are zero
            
            unsigned long rawAdcValue = [self writeAuxIOSPI:(mjdPreAmpTable[chan].adcSelection << 13) | (controlWord<<8)];
            
			int decodedChannel = (rawAdcValue & 0xE000) >> 13; //use the whichever chan was converted, may be diff than the one selected above.
                        
            long adcValue;
            if(rawAdcValue & 0x1000)adcValue = -(~rawAdcValue & 0x1FFF) + 1;
            else adcValue                    = rawAdcValue & 0x1FFF;
            
            float convertedValue = adcValue*mjdPreAmpTable[decodedChannel].slope + adcValue*mjdPreAmpTable[decodedChannel].intercept;
            
			if(verbose)NSLog(@"%d: %.2f (0x%08x)\n",decodedChannel,convertedValue,rawAdcValue&0x1FFF);
            
			[self setAdc:decodedChannel value:convertedValue];
            [self checkAdcIsWithinLimits:decodedChannel];
            
            if(mjdPreAmpTable[chan].calculateLeakageCurrent){
                [self calculateLeakageCurrentForAdc:chan];
             }
        
		}
		else [self setAdc:chan value:0.0];
	}
    
    [self checkTempIsWithinLimits];

	//get the time(UT!) for the data record.
	time_t	ut_Time;
	time(&ut_Time);
	timeMeasured = ut_Time;
}

- (void) pollValues
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(pollValues) object:nil];
        
	[self readAllAdcs];
    [self updateTrends];
    //[self postCouchDBRecord];

	if(shipValues)[self shipRecords];
	if(pollTime)[self performSelector:@selector(pollValues) withObject:nil afterDelay:pollTime];
}


- (void) stopPulser
{
    // stop pulsing: write nothing to kPulserStartMask
	[self writeAuxIOSPI:kPulserStartMask];
	//[self writeAuxIOSPI:(kPulserStartMask | kPulserUseLoopCount)];

    //Now park it! First zero all pulse amplitudes
    [self zeroAmplitudes];
	//write zeros to the pattern, enable the attenuators, and disable the pulser outputs
	[self writeAuxIOSPI:(kAttnPatternMask | 0x22)];
	NSLog(@"PreAmp(%d) Disabled Pulser\n",[self uniqueIdNumber]);
}	

- (void) startPulser
{
    if(pulseCount == 0 && !loopForever) {
	  NSLog(@"PreAmp(%d)::startPulser() -- pulseCount = 0 but not looping forever, returning...\n",[self uniqueIdNumber]);
      return;
    }

	//set the pulser amplitudes
    [self writeAmplitudes];

	unsigned long aValue = 0;
	//set the high and low times (frequency)
	aValue = kPulserLowTimeMask | ((pulseLowTime&0xFFFF)<<8);
	[self writeAuxIOSPI:aValue];
	aValue = kPulserHighTimeMask | ((pulseHighTime&0xFFFF)<<8);
	[self writeAuxIOSPI:aValue];
	
	//set the bit pattern and global attenuators / enables
	aValue =  kAttnPatternMask | 
		((pulserMask		 & 0xFF00)) | 
		((pulserMask		 & 0x00FF) << 16) | 
		((attenuated[0]      & 0x1) << 7)  |
		((finalAttenuated[0] & 0x1) << 6)  | 
		((enabled[0]         & 0x1) << 5) |
		((attenuated[1]	     & 0x1) << 3)  | 
		((finalAttenuated[1] & 0x1) << 2)  | 
		((enabled[1]         & 0x1) << 1) ;
	[self writeAuxIOSPI:aValue];
	
    // start pulsing
	aValue = kPulserStartMask | ((pulseCount-1) & 0xffff);
	if(loopForever) aValue |= kPulserLoopForever;
	else			aValue |= kPulserUseLoopCount;
	[self writeAuxIOSPI:aValue];
	NSLog(@"PreAmp(%d) Started Pulser\n",[self uniqueIdNumber]);
}

- (unsigned long)  writeAuxIOSPI:(unsigned long)aValue
{
	id connectedObj = [self objectConnectedTo:MJDPreAmpInputConnector];
	if([connectedObj respondsToSelector:@selector(writeAuxIOSPI:)]){
		return [connectedObj writeAuxIOSPI:aValue];
	}
    return 0;
}

#pragma mark ���Archival
- (id)initWithCoder:(NSCoder*)decoder
{
    self = [super initWithCoder:decoder];
	
    [[self undoManager] disableUndoRegistration];
    [self setAdcEnabledMask:[decoder decodeInt32ForKey:@"adcEnabledMask"]];
    [self setShipValues:	[decoder decodeBoolForKey: @"shipValues"]];
	[self setPollTime:		[decoder decodeIntForKey:  @"pollTime"]];
	
	int i;
	for(i=0;i<2;i++){
		[self setEnabled:i		   value:[decoder decodeBoolForKey:[NSString stringWithFormat: @"enabled%d",i]]];
		[self setAttenuated:i      value:[decoder decodeBoolForKey:[NSString stringWithFormat: @"attenuated%d",i]]];
		[self setFinalAttenuated:i value:[decoder decodeBoolForKey:[NSString stringWithFormat: @"finalAttenuated%d",i]]];
	}
	
    [self setLoopForever:	[decoder decodeBoolForKey:   @"loopForever"]];
    [self setPulseCount:	[decoder decodeIntForKey:    @"pulseCount"]];
	[self setPulseHighTime:	[decoder decodeIntForKey:    @"pulseHighTime"]];
	[self setPulseLowTime:	[decoder decodeIntForKey:    @"pulseLowTime"]];
	[self setPulserMask:	[decoder decodeIntForKey:    @"pulserMask"]];
    [self setDacs:			[decoder decodeObjectForKey: @"dacs"]];
    [self setAmplitudes:	[decoder decodeObjectForKey: @"amplitudes"]];
    [self setFeedBackResistors:	[decoder decodeObjectForKey: @"feedBackResistors"]];
    [self setBaselineVoltages:	[decoder decodeObjectForKey: @"baselineVoltages"]];
	
    if(!dacs || !amplitudes || !feedBackResistors || !baselineVoltages)	[self setUpArrays];

    [[self undoManager] enableUndoRegistration];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder*)encoder
{
    [super encodeWithCoder:encoder];
	[encoder encodeInt32:adcEnabledMask forKey:@"adcEnabledMask"];
	[encoder encodeBool:shipValues		forKey:@"shipValues"];
	[encoder encodeInt:pollTime			forKey:@"pollTime"];
	int i;
	for(i=0;i<2;i++){
		[encoder encodeBool:enabled[i]			forKey:[NSString stringWithFormat:@"enabled%d",i]];
		[encoder encodeBool:attenuated[i]		forKey:[NSString stringWithFormat:@"attenuated%d",i]];
		[encoder encodeBool:finalAttenuated[i]	forKey:[NSString stringWithFormat:@"finalAttenuated%d",i]];
	}
	
	[encoder encodeBool:loopForever		forKey:@"loopForever"];
	[encoder encodeInt:pulseCount		forKey:@"pulseCount"];
	[encoder encodeInt:pulseHighTime	forKey:@"pulseHighTime"];
	[encoder encodeInt:pulseLowTime		forKey:@"pulseLowTime"];
	[encoder encodeInt:pulserMask		forKey:@"pulserMask"];
	[encoder encodeObject:dacs			forKey:@"dacs"];
	[encoder encodeObject:amplitudes	forKey:@"amplitudes"];
	[encoder encodeObject:feedBackResistors			forKey:@"feedBackResistors"];
	[encoder encodeObject:baselineVoltages			forKey:@"baselineVoltages"];
}

- (NSMutableDictionary*) addParametersToDictionary:(NSMutableDictionary*)dictionary
{
    NSMutableDictionary* objDictionary = [NSMutableDictionary dictionary];
    [objDictionary setObject:NSStringFromClass([self class]) forKey:@"Class Name"];
    [objDictionary setObject:[NSNumber numberWithInt:[self uniqueIdNumber]] forKey:@"preampID"];
    
    [dictionary setObject:objDictionary forKey:[self identifier]];
    return objDictionary;
}

#pragma mark ���Data Records
- (unsigned long) dataId					{ return dataId;   }
- (void) setDataId: (unsigned long) DataId	{ dataId = DataId; }
- (void) setDataIds:(id)assigner			{ dataId = [assigner assignDataIds:kLongForm]; }
- (void) syncDataIdsWith:(id)anotherTPG262	{ [self setDataId:[anotherTPG262 dataId]]; }

- (void) appendDataDescription:(ORDataPacket*)aDataPacket userInfo:(id)userInfo
{
    //----------------------------------------------------------------------------------------
    // first add our description to the data description
    [aDataPacket addDataDescriptionItem:[self dataRecordDescription] forKey:@"MJDPreAmpModel"];
}

- (NSDictionary*) dataRecordDescription
{
    NSMutableDictionary* dataDictionary = [NSMutableDictionary dictionary];
    NSDictionary* aDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
								 @"ORMJDPreAmpDecoderForAdc",						@"decoder",
								 [NSNumber numberWithLong:dataId],					@"dataId",
								 [NSNumber numberWithBool:NO],						@"variable",
								 [NSNumber numberWithLong:kMJDPreAmpDataRecordLen],	@"length",
								 nil];
	
    [dataDictionary setObject:aDictionary forKey:@"Adcs"];
    
    return dataDictionary;
}

- (void) shipRecords
{
	
    if([[ORGlobal sharedGlobal] runInProgress]){
		
		unsigned long data[kMJDPreAmpDataRecordLen];
		
		data[0] = dataId | kMJDPreAmpDataRecordLen;
		data[1] = [self uniqueIdNumber]&0xfff;
		data[2] = timeMeasured;
		data[3] = adcEnabledMask;
		
		union {
			float asFloat;
			unsigned long asLong;
		} theData;
		
		int index = 5;
		int i;
		for(i=0;i<kMJDPreAmpDacChannels;i++){
			theData.asFloat = [self adc:i];
			data[index]     = theData.asLong;
			index++;
		}
		
		[[NSNotificationCenter defaultCenter] postNotificationName: ORQueueRecordForShippingNotification 
                                object: [NSData dataWithBytes:data length:sizeof(long)*kMJDPreAmpDataRecordLen]];
	}
}


#pragma mark ���Alarms
- (void) checkTempIsWithinLimits
{
    float maxAllowedTemperature = 50; //<<-Niko, set this or make a dialog field for it
    int aChip;
    float aTemperature;
    for(aChip=0;aChip<2;aChip++){
        if(aChip == 0)  aTemperature = [self adc:7];
        else            aTemperature = [self adc:15];
        if(aTemperature >= maxAllowedTemperature){
 			if(!temperatureAlarm[aChip]){
				temperatureAlarm[aChip] = [[ORAlarm alloc] initWithName:[NSString stringWithFormat:@"Preamp %lu Temperature",[self uniqueIdNumber]] severity:kRangeAlarm];
                [temperatureAlarm[aChip] setHelpString:[NSString stringWithFormat:@"Preamp %lu has exceeded %.1f C. This alarm will be in effect until the temperature returns to normal limits. It can be silenced by acknowledging it.",[self uniqueIdNumber],maxAllowedTemperature]];
				[temperatureAlarm[aChip] setSticky:YES];
			}
			[temperatureAlarm[aChip] postAlarm];
        }
        else {
            [temperatureAlarm[aChip] clearAlarm];
			[temperatureAlarm[aChip] release];
			temperatureAlarm[aChip] = nil;
        }
    }
}

- (void) checkLeakageCurrentIsWithinLimits:(int)aChan
{
    float maxAllowedLeakageCurrent = 50;//pA    
    NSString* alarmName  = [NSString stringWithFormat:@"Preamp %lu Channel %d Leakage Current",[self uniqueIdNumber], aChan];
    float aLeakageCurrent = [self leakageCurrent:aChan];
    if(aLeakageCurrent >= maxAllowedLeakageCurrent){
        if(!leakageCurrentAlarm[aChan]){
            leakageCurrentAlarm[aChan] = [[ORAlarm alloc] initWithName:alarmName severity:kRangeAlarm];
            [leakageCurrentAlarm[aChan] setHelpString:[NSString stringWithFormat:@"Preamp %lu Channel %d leakage current value exceeded limits. This alarm will be in effect until the leakage current returns to normal limits. It can be silenced by acknowledging it.",[self uniqueIdNumber], aChan]];
            [leakageCurrentAlarm[aChan] setSticky:YES];
        }
        [leakageCurrentAlarm[aChan] postAlarm];
    }
    else {
        [leakageCurrentAlarm[aChan] clearAlarm];
        [leakageCurrentAlarm[aChan] release];
        leakageCurrentAlarm[aChan] = nil;
    }
}

- (void) checkAdcIsWithinLimits:(int)anIndex
{
    if(anIndex != 5 && anIndex!=6 && anIndex!= 13 && anIndex!= 14)return;
    float aValue = [self adc:anIndex];
    BOOL postAlarm = NO;
    NSString* alarmName;
    switch(anIndex){
        case 5:
            if(fabs(aValue - 12) >= 0.5){  
                alarmName  = [NSString stringWithFormat:@"Preamp %lu +12V Supply",[self uniqueIdNumber]];
                postAlarm  = YES;
            }
        break;
            
        case 6:
            if(fabs(aValue + 12) >= 0.5){ 
                alarmName = [NSString stringWithFormat:@"Preamp %lu -12V Supply",[self uniqueIdNumber]];
                postAlarm  = YES;
            }
        break;
            
        case 13:
            if(fabs(aValue - 24) >= 0.5){
                alarmName = [NSString stringWithFormat:@"Preamp %lu +24V Supply",[self uniqueIdNumber]];
                postAlarm  = YES;
            }
        break;
            
        case 14:
            if(fabs(aValue + 24) >= 0.5){
                alarmName = [NSString stringWithFormat:@"Preamp %lu -24V Supply",[self uniqueIdNumber]];
                postAlarm  = YES;
            }
        break;
    }
    
    if(postAlarm){
        if(!adcAlarm[anIndex]){
            adcAlarm[anIndex] = [[ORAlarm alloc] initWithName:alarmName severity:kRangeAlarm];
            [adcAlarm[anIndex] setHelpString:[NSString stringWithFormat:@"Preamp %lu adc value exceeded limits (was at %.2f). This alarm will be in effect until the adc value returns to normal limits. It can be silenced by acknowledging it.",[self uniqueIdNumber],aValue]];
            [adcAlarm[anIndex] setSticky:YES];
        }
        [adcAlarm[anIndex] postAlarm];
    }
    else {
        [adcAlarm[anIndex] clearAlarm];
        [adcAlarm[anIndex] release];
        adcAlarm[anIndex] = nil;
        
    }
}
@end

@implementation ORMJDPreAmpModel (private)
- (void) updateTrends
{
    int chan;
	for(chan=0;chan<kMJDPreAmpAdcChannels;chan++){
        
        if(!adcHistory[chan]) adcHistory[chan] = [[ORTimeRate alloc] init];
        [adcHistory[chan] addDataToTimeAverage:[self adc:chan]];
        
        if(mjdPreAmpTable[chan].calculateLeakageCurrent){
            int     leakageIndex = mjdPreAmpTable[chan].leakageCurrentIndex;
            float   aValue       = [self leakageCurrent:leakageIndex];
            if(!leakageCurrentHistory[leakageIndex]) leakageCurrentHistory[leakageIndex] = [[ORTimeRate alloc] init];
            [leakageCurrentHistory[leakageIndex] addDataToTimeAverage:aValue];
        }
    }
}
- (void) calculateLeakageCurrentForAdc:(int) adcChan
{
    //value returned in picoamps
    float nanoToPico = 1000.;
    
    int currentChan = mjdPreAmpTable[adcChan].leakageCurrentIndex;
    if(currentChan>0){
        //leakage current is (first stage output voltage - baseline voltage)/feedback resistance
        float leakageCurrent = -nanoToPico*([self adc:adcChan] - [self baselineVoltage:adcChan])/ [self feedBackResistor:adcChan];//in picoamps
        [self setLeakageCurrent:currentChan value:leakageCurrent];
        [self checkLeakageCurrentIsWithinLimits:currentChan];
    }
}

- (void) postCouchDBRecord
{
    NSDictionary* values = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSString stringWithFormat:@"%f",adcs[0]],  @"Baseline0",
                            [NSString stringWithFormat:@"%f",adcs[1]],  @"Baseline1",
                            [NSString stringWithFormat:@"%f",adcs[2]],  @"Baseline2",
                            [NSString stringWithFormat:@"%f",adcs[3]],  @"Baseline3",
                            [NSString stringWithFormat:@"%f",adcs[4]],  @"Baseline4",
                            [NSString stringWithFormat:@"%f",adcs[5]],  @"+12V",
                            [NSString stringWithFormat:@"%f",adcs[6]],  @"-12V",
                            [NSString stringWithFormat:@"%f",adcs[7]],  @"Temp1",
                            [NSString stringWithFormat:@"%f",adcs[8]],  @"Baseline5",
                            [NSString stringWithFormat:@"%f",adcs[9]],  @"Baseline6",
                            [NSString stringWithFormat:@"%f",adcs[10]], @"Baseline7",
                            [NSString stringWithFormat:@"%f",adcs[11]], @"Baseline8",
                            [NSString stringWithFormat:@"%f",adcs[12]], @"Baseline9",
                            [NSString stringWithFormat:@"%f",adcs[13]], @"+24V",
                            [NSString stringWithFormat:@"%f",adcs[14]], @"-24V",
                            [NSString stringWithFormat:@"%f",adcs[15]], @"Temp2",
                            [NSString stringWithFormat:@"%f",leakageCurrents[0]],  @"Leakage0",
                            [NSString stringWithFormat:@"%f",leakageCurrents[1]],  @"Leakage1",
                            [NSString stringWithFormat:@"%f",leakageCurrents[2]],  @"Leakage2",
                            [NSString stringWithFormat:@"%f",leakageCurrents[3]],  @"Leakage3",
                            [NSString stringWithFormat:@"%f",leakageCurrents[4]],  @"Leakage4",
                            [NSString stringWithFormat:@"%f",leakageCurrents[5]],  @"Leakage5",
                            [NSString stringWithFormat:@"%f",leakageCurrents[6]],  @"Leakage6",
                            [NSString stringWithFormat:@"%f",leakageCurrents[7]],  @"Leakage7",
                            [NSString stringWithFormat:@"%f",leakageCurrents[8]],  @"Leakage8",
                            [NSString stringWithFormat:@"%f",leakageCurrents[9]],  @"Leakage9",
                            [NSString stringWithFormat:@"%f",leakageCurrents[10]], @"Leakage10",
                            nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ORCouchDBAddHistoryRecord" object:self userInfo:values];
}

@end
