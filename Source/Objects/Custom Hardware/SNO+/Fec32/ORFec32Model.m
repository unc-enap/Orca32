//
//  ORFec32Model.h
//  Orca
//
//  Created by Mark Howe on Wed Oct 15,2008.
//  Copyright (c) 2008 CENPA, University of Washington. All rights reserved.
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
#import "ORFec32Model.h"
#import "ORXL1Model.h"
#import "ORXL2Model.h"
#import "ORSNOCrateModel.h"
#import "ORFecDaughterCardModel.h"
#import "ORSNOConstants.h"
#import "OROrderedObjManager.h"
#import "ObjectFactory.h"
#import "ORSNOCrateModel.h"
#import "ORVmeReadWriteCommand.h"
#import "ORCommandList.h"

#define VERIFY_CMOS_SHIFT_REGISTER	// uncomment this to verify CMOS shift register loads - PH 09/17/99

// the bottom 16 and upper 16 FEC32 channels
#define BOTTOM_CHANNELS	0
#define UPPER_CHANNELS	1

// register offset for the FEC32 Discret and Sequencer Registers
static unsigned long fec32_register_offsets[] =
{	
	128,			// [0]  General Control and Status    	R/W
	132,			// [1]  ADC Value						R				
	136,			// [2]  Voltage Monitor C/S				R/W
	140,			// [3]  Pedestal Enable					W
	144,			// [4]  DAC Program						R/W
	148,			// [5]  Calibration DAC Program			W
	152,			// [6]  High Voltage Card C/S			R/W
	156, 			// [7]  CMOS spy-on-data-output			R
	160,			// [8]  CMOS Full						R
	164,			// [9]  CMOS Chip Select				R
	168,			// [10] CMOS Program [1-16]				W
	172,			// [11] CMOS Program [17-32]			W
	176,			// [12] CMOS LGISEL Set					R/W
	180,			// [13] Board ID						R/W
	// Changed these offsets -- they were incorrect.  RGV, PW, 5/18/96

	512,			// [32] Sequencer output C/S			R
	528,			// [33] Sequencer input C/S				R
	544,			// [34] CMOS Data Available				R/W
	560,			// [35] CMOS Chip Select				R/W
	576,			// [36] CMOS Chip Disable				W
	592, 			// [37] CMOS Data output				R
	628,			// [38] Fifo write pointer				R
	624,			// [39] Fifo read pointer				R
	632,			// [40] Fifo pointer difference			R

	1028,	//Fec32_CMOS_MISSED_COUNT_OFFSET
	1032,	//Fec32_CMOS_BUSY_REG_OFFSET
	1036,	//Fec32_CMOS_TOTALS_COUNTER_OFFSET
	1040,	//Fec32_CMOS_TEST_ID_OFFSET
	1044,	//Fec32_CMOS_SHIFT_REG_OFFSET
	1048,	//Fec32_CMOS_ARRAY_POINTER_OFFSET
	1052,	//Fec32_CMOS_COUNT_INFO_OFFSET

};

NSString* ORFecShowVoltsChanged				= @"ORFecShowVoltsChanged";
NSString* ORFecCommentsChanged				= @"ORFecCommentsChanged";
NSString* ORFecCmosChanged					= @"ORFecCmosChanged";
NSString* ORFecVResChanged					= @"ORFecVResChanged";
NSString* ORFecHVRefChanged					= @"ORFecHVRefChanged";
NSString* ORFecLock							= @"ORFecLock";
NSString* ORFecOnlineMaskChanged			= @"ORFecOnlineMaskChanged";
NSString* ORFecPedEnabledMaskChanged		= @"ORFecPedEnabledMaskChanged";
NSString* ORFecSeqDisabledMaskChanged		= @"ORFecSeqDisabledMaskChanged";
NSString* ORFecTrigger100nsDisabledMaskChanged		= @"ORFecTrigger100nsDisabledMaskChanged";
NSString* ORFecTrigger20nsDisabledMaskChanged		= @"ORFecTrigger20nsDisabledMaskChanged";
NSString* ORFecQllEnabledChanged					= @"ORFecQllEnabledChanged";
NSString* ORFec32ModelAdcVoltageChanged				= @"ORFec32ModelAdcVoltageChanged";
NSString* ORFec32ModelAdcVoltageStatusChanged		= @"ORFec32ModelAdcVoltageStatusChanged";
NSString* ORFec32ModelAdcVoltageStatusOfCardChanged	= @"ORFec32ModelAdcVoltageStatusOfCardChanged";

@interface ORFec32Model (private)
- (ORCommandList*) cmosShiftLoadAndClock:(unsigned short) registerAddress cmosRegItem:(unsigned short) cmosRegItem bitMaskStart:(short) bit_mask_start;
- (void) loadCmosShiftRegData:(unsigned short)whichChannels triggersDisabled:(BOOL)aTriggersDisabled;
- (void) loadCmosShiftRegisters:(BOOL) aTriggersDisabled;
@end

@implementation ORFec32Model

#pragma mark •••Initialization
- (id) init //designated initializer
{
    self = [super init];
    
    [[self undoManager] disableUndoRegistration];
	[self setComments:@""];
    [[self undoManager] enableUndoRegistration];
    
    return self;
}
- (void) dealloc
{
    [comments release];
    [super dealloc];
}

- (void) objectCountChanged
{
	int i;
	for(i=0;i<4;i++){
		dcPresent[i] =  NO;
		dc[i] = nil;
	}
	
	id aCard;
	NSEnumerator* e = [self objectEnumerator];
	while(aCard = [e nextObject]){
		if([aCard isKindOfClass:[ORFecDaughterCardModel class]]){
			dcPresent[[(ORFecDaughterCardModel*)aCard slot]] = YES;
			dc[[(ORFecDaughterCardModel*)aCard slot]] = aCard;
		}
	}
}

#pragma mark ***Accessors

- (float) adcVoltage:(int)index
{
	if(index>=0 && index<kNumFecMonitorAdcs) return adcVoltage[index];
	else return -1;
}

- (void) setAdcVoltage:(int)index withValue:(float)aValue
{
	if(index>=0 && index<kNumFecMonitorAdcs){
		adcVoltage[index] = aValue;
		NSDictionary* userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:index] forKey:@"index"];
		[[NSNotificationCenter defaultCenter] postNotificationName:ORFec32ModelAdcVoltageChanged object:self userInfo:userInfo];
	}
}

- (eFecMonitorState) adcVoltageStatusOfCard
{
	return adcVoltageStatusOfCard;
}

- (void) setAdcVoltageStatusOfCard:(eFecMonitorState)aState
{
	adcVoltageStatusOfCard = aState;
	[[NSNotificationCenter defaultCenter] postNotificationName:ORFec32ModelAdcVoltageStatusOfCardChanged object:self userInfo:nil];
}

- (eFecMonitorState) adcVoltageStatus:(int)index
{
	if(index>=0 && index<kNumFecMonitorAdcs) return adcVoltageStatus[index];
	else return kFecMonitorNeverMeasured;
}

- (void) setAdcVoltageStatus:(int)index withValue:(eFecMonitorState)aState
{
	if(index>=0 && index<kNumFecMonitorAdcs){
		adcVoltageStatus[index] = aState;
		NSDictionary* userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:index] forKey:@"index"];
		[[NSNotificationCenter defaultCenter] postNotificationName:ORFec32ModelAdcVoltageStatusChanged object:self userInfo:userInfo];
	}
}

- (BOOL) dcPresent:(unsigned short)index
{
	if(index<4)return dcPresent[index];
	else return NO;
}

- (BOOL) qllEnabled
{
	return qllEnabled;
}

- (void) setQllEnabled:(BOOL) state
{
    [[[self undoManager] prepareWithInvocationTarget:self] setQllEnabled:pedEnabledMask];
	qllEnabled = state;
	[[NSNotificationCenter defaultCenter] postNotificationName:ORFecQllEnabledChanged object:self];
}

- (BOOL) pmtOnline:(unsigned short)index
{
	if(index<32) return [self dcPresent:index/8] && (onlineMask & (1L<<index));
	else return NO;
}

- (unsigned long) pedEnabledMask
{
	return pedEnabledMask;
}

- (void) setPedEnabledMask:(unsigned long) aMask
{
    [[[self undoManager] prepareWithInvocationTarget:self] setPedEnabledMask:pedEnabledMask];
    pedEnabledMask = aMask;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORFecPedEnabledMaskChanged object:self];
	
}

- (unsigned long) seqDisabledMask
{
	return seqDisabledMask;
}

- (void) setSeqDisabledMask:(unsigned long) aMask
{
    [[[self undoManager] prepareWithInvocationTarget:self] setSeqDisabledMask:seqDisabledMask];
    seqDisabledMask = aMask;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORFecSeqDisabledMaskChanged object:self];
	
}

- (BOOL) trigger20nsDisabled:(short)chan
{
	return (trigger20nsDisabledMask & (1<<chan))!=0;
}
- (void) setTrigger20ns:(short) chan disabled:(short)state
{
	if(state) trigger20nsDisabledMask |= (1<<chan);
	else      trigger20nsDisabledMask &= ~(1<<chan);
}

- (BOOL) trigger100nsDisabled:(short)chan
{
	return (trigger100nsDisabledMask & (1<<chan))!=0;
}
- (void) setTrigger100ns:(short) chan disabled:(short)state
{
	if(state) trigger100nsDisabledMask |= (1<<chan);
	else      trigger100nsDisabledMask &= ~(1<<chan);
}
- (unsigned long) trigger20nsDisabledMask
{
	return trigger20nsDisabledMask;
}

- (void) setTrigger20nsDisabledMask:(unsigned long) aMask
{
    [[[self undoManager] prepareWithInvocationTarget:self] setTrigger20nsDisabledMask:trigger20nsDisabledMask];
    trigger20nsDisabledMask = aMask;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORFecTrigger20nsDisabledMaskChanged object:self];
}

- (unsigned long) trigger100nsDisabledMask
{
	return trigger100nsDisabledMask;
}

- (void) setTrigger100nsDisabledMask:(unsigned long) aMask
{
    [[[self undoManager] prepareWithInvocationTarget:self] setTrigger100nsDisabledMask:trigger100nsDisabledMask];
    trigger100nsDisabledMask = aMask;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORFecTrigger100nsDisabledMaskChanged object:self];
}

- (unsigned long) onlineMask
{
	return onlineMask;
}

- (void) setOnlineMask:(unsigned long) aMask
{
    [[[self undoManager] prepareWithInvocationTarget:self] setOnlineMask:onlineMask];
    onlineMask = aMask;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORFecOnlineMaskChanged object:self];
	
}

- (int) globalCardNumber
{
	return ([guardian crateNumber] * 16) + [self stationNumber];
}

- (NSComparisonResult) globalCardNumberCompare:(id)aCard
{
	return [self globalCardNumber] - [aCard globalCardNumber];
}


- (BOOL) showVolts
{
    return showVolts;
}

- (void) setShowVolts:(BOOL)aShowVolts
{
    [[[self undoManager] prepareWithInvocationTarget:self] setShowVolts:showVolts];
    
    showVolts = aShowVolts;
	
    [[NSNotificationCenter defaultCenter] postNotificationName:ORFecShowVoltsChanged object:self];
}

- (NSString*) comments
{
    return comments;
}

- (void) setComments:(NSString*)aComments
{
	if(!aComments) aComments = @"";
    [[[self undoManager] prepareWithInvocationTarget:self] setComments:comments];
    
    [comments autorelease];
    comments = [aComments copy];    
	
    [[NSNotificationCenter defaultCenter] postNotificationName:ORFecCommentsChanged object:self];
}

- (void) setUpImage
{
    [self setImage:[NSImage imageNamed:@"Fec32Card"]];
}

- (void) makeMainController
{
    [self linkToController:@"ORFec32Controller"];
}
- (unsigned char) cmos:(short)anIndex
{
	return cmos[anIndex];
}

- (void) setCmos:(short)anIndex withValue:(unsigned char)aValue
{
    [[[self undoManager] prepareWithInvocationTarget:self] setCmos:anIndex withValue:cmos[anIndex]];
	cmos[anIndex] = aValue;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORFecCmosChanged object:self];
}

- (float) vRes
{
	return vRes;
}

- (void) setVRes:(float)aValue
{
    [[[self undoManager] prepareWithInvocationTarget:self] setVRes:vRes];
	vRes = aValue;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORFecVResChanged object:self];
}

- (float) hVRef
{
	return hVRef;
}

- (void) setHVRef:(float)aValue
{
    [[[self undoManager] prepareWithInvocationTarget:self] setHVRef:hVRef];
	hVRef = aValue;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORFecHVRefChanged object:self];
}

#pragma mark Converted Data Methods
- (void) setCmosVoltage:(short)n withValue:(float) value
{
	if(value>kCmosMax)		value = kCmosMax;
	else if(value<kCmosMin)	value = kCmosMin;
	
	[self setCmos:n withValue:255.0*(value-kCmosMin)/(kCmosMax-kCmosMin)+0.5];
}

- (float) cmosVoltage:(short) n
{
	return ((kCmosMax-kCmosMin)/255.0)*cmos[n]+kCmosMin;
}

- (void) setVResVoltage:(float) value
{
	if(value>kVResMax)		value = kVResMax;
	else if(value<kVResMin)	value = kVResMin;
	[self setVRes:255.0*(value-kVResMin)/(kVResMax-kVResMin)+0.5];
}

- (float) vResVoltage
{
	return ((kVResMax-kVResMin)/255.0)*vRes+kVResMin;
}

- (void) setHVRefVoltage:(float) value
{
	if(value>kHVRefMax)		 value = kHVRefMax;
	else if(value<kHVRefMin) value = kHVRefMin;
	[self setHVRef:(255.0*(value-kHVRefMin)/(kHVRefMax-kHVRefMin)+0.5)];
}

- (float) hVRefVoltage
{
	return ((kHVRefMax-kHVRefMin)/255.0)*hVRef+kHVRefMin;
}
//readVoltages
//read the voltage and temp adcs for a crate and card
//assumes that bus access has already been granted.
-(void) readVoltages
{	
	@try {
		
		[[self xl2] select:self];
		
		bool statusChanged = false;
		short whichADC;
		for(whichADC=0;whichADC<kNumFecMonitorAdcs;whichADC++){
			short theValue = [self readVoltageValue:fecVoltageAdc[whichADC].mask];
			eFecMonitorState old_channel_status = [self adcVoltageStatus:whichADC];
			eFecMonitorState new_channel_status;
			if( theValue != -1) {
				float convertedValue = ((float)theValue-128.0)*fecVoltageAdc[whichADC].multiplier;
				[self setAdcVoltage:whichADC withValue:convertedValue];
				if(fecVoltageAdc[whichADC].check_expected_value){
					float expected = fecVoltageAdc[whichADC].expected_value;
					float delta = fabs(expected*[[self xl1] adcAllowedError:whichADC]);
					if(fabs(convertedValue-expected) < delta)	new_channel_status = kFecMonitorInRange;
					else										new_channel_status = kFecMonitorOutOfRange;
				}
				else new_channel_status = kFecMonitorInRange;
			}
			else new_channel_status = kFecMonitorReadError;
			
			[self setAdcVoltageStatus:whichADC withValue:new_channel_status];
			
			if(old_channel_status != new_channel_status){
				statusChanged = true;
			}
		}
		if(statusChanged){
			//sync up the card status
			[self setAdcVoltageStatusOfCard:kFecMonitorInRange];
			short whichADC;
			for(whichADC=0;whichADC<kNumFecMonitorAdcs;whichADC++){
				if([self adcVoltageStatus:whichADC] == kFecMonitorReadError){
					[self setAdcVoltageStatusOfCard:kFecMonitorReadError];
					break;
				}
				else if([self adcVoltageStatus:whichADC] == kFecMonitorOutOfRange){
					[self setAdcVoltageStatusOfCard:kFecMonitorOutOfRange];
					break;
				}
				
			}
			
			//sync up the crate status
			[[self crate] setVoltageStatus: kFecMonitorInRange];
			unsigned short card;
			for(card=0;card<16;card++){
				if([self adcVoltageStatusOfCard] == kFecMonitorReadError){
					[[self crate] setVoltageStatus:kFecMonitorReadError];
					break;
				}
				else if([self adcVoltageStatusOfCard] == kFecMonitorOutOfRange){
					[[self crate] setVoltageStatus:kFecMonitorOutOfRange];
					break;
				}
			}
/*			//sync up the system status (TBD... 12/15/2008 MAH)
			theConfigDB->VoltageStatusOfSystem(kFecMonitorInRange);
			unsigned short crate;
			for(crate=0;crate<kNumSCs;crate++){
				if(theConfigDB->VoltageStatusOfCrate(theCrate)== kFecMonitorReadError){
					theConfigDB->VoltageStatusOfSystem(kFecMonitorReadError);
					break;
				}
				else if(theConfigDB->VoltageStatusOfCrate(theCrate) == kFecMonitorOutOfRange){
					theConfigDB->VoltageStatusOfSystem(kFecMonitorOutOfRange);
					break;
				}
			}
*/
			
		}
		
		
	}
	@catch(NSException* localException) {
		[[self xl2] deselectCards];
	}
	[[self xl2] deselectCards];

	
}

const short kVoltageADCMaximumAttempts = 10;

-(short) readVoltageValue:(unsigned long) aMask
{
	short theValue = -1;
	
	@try {
		ORCommandList* aList = [ORCommandList commandList];
		
		// write the ADC mask keeping bits 14,15 high  i.e. CS,RD
		[aList addCommand: [self writeToFec32RegisterCmd:FEC32_VOLTAGE_MONITOR_REG value:aMask | 0x0000C000UL]];
		// write the ADC mask keeping bits 14,15 low -- this forces conversion
		[aList addCommand:[self delayCmd:0.001]];
		[aList addCommand: [self writeToFec32RegisterCmd:FEC32_VOLTAGE_MONITOR_REG value:aMask]];
		[aList addCommand:[self delayCmd:0.002]];
		int adcValueCmdIndex = [aList addCommand: [self readFromFec32RegisterCmd:FEC32_VOLTAGE_MONITOR_REG]];
		
		//MAH 8/30/99 leave the voltage register connected to a ground address.
		[aList addCommand: [self writeToFec32RegisterCmd:FEC32_VOLTAGE_MONITOR_REG value:groundMask | 0x0000C000UL]];
		[self executeCommandList:aList];
	
		//pull out the result
		unsigned long adcReadValue = [aList longValueForCmd:adcValueCmdIndex];
		if(adcReadValue & 0x100UL){
			theValue = adcReadValue & 0x000000ff; //keep only the lowest 8 bits.
		}
	}
	@catch(NSException* localException) {
	}

	
	return theValue;
}

#pragma mark •••Archival
- (id) initWithCoder:(NSCoder*)decoder
{
    self = [super initWithCoder:decoder];
	
    [[self undoManager] disableUndoRegistration];
	
    [self setShowVolts:				[decoder decodeBoolForKey:  @"showVolts"]];
    [self setComments:				[decoder decodeObjectForKey:@"comments"]];
    [self setVRes:					[decoder decodeFloatForKey: @"vRes"]];
    [self setHVRef:					[decoder decodeFloatForKey: @"hVRef"]];
	[self setOnlineMask:			[decoder decodeInt32ForKey: @"onlineMask"]];
	[self setPedEnabledMask:		[decoder decodeInt32ForKey: @"pedEnableMask"]];
	[self setSeqDisabledMask:		[decoder decodeInt32ForKey: @"seqDisabledMask"]];
	[self setAdcVoltageStatusOfCard:[decoder decodeIntForKey: @"adcVoltageStatusOfCard"]];
	int i;
	for(i=0;i<6;i++){
		[self setCmos:i withValue: [decoder decodeFloatForKey: [NSString stringWithFormat:@"cmos%d",i]]];
	}	
	for(i=0;i<kNumFecMonitorAdcs;i++){
		[self setAdcVoltage:i withValue: [decoder decodeFloatForKey: [NSString stringWithFormat:@"adcVoltage%d",i]]];
		[self setAdcVoltageStatus:i withValue: (eFecMonitorState)[decoder decodeIntForKey: [NSString stringWithFormat:@"adcStatus%d",i]]];
	}
    [[self undoManager] enableUndoRegistration];
	
    return self;
}

- (void) encodeWithCoder:(NSCoder*)encoder
{
	[super encodeWithCoder:encoder];
	
	[encoder encodeBool:showVolts			forKey:@"showVolts"];
	[encoder encodeObject:comments			forKey:@"comments"];
	[encoder encodeFloat:vRes				forKey:@"vRes"];
	[encoder encodeFloat:hVRef				forKey:@"hVRef"];
	[encoder encodeInt32:onlineMask			forKey:@"onlineMask"];
	[encoder encodeInt32:pedEnabledMask		forKey:@"pedEnabledMask"];
	[encoder encodeInt32:seqDisabledMask	forKey:@"seqDisabledMask"];
	[encoder encodeInt:adcVoltageStatusOfCard forKey:@"adcVoltageStatusOfCard"];
	
	int i;
	for(i=0;i<6;i++){
		[encoder encodeFloat:cmos[i] forKey:[NSString stringWithFormat:@"cmos%d",i]];
	}	
	for(i=0;i<kNumFecMonitorAdcs;i++){
		[encoder encodeFloat:adcVoltage[i] forKey:[NSString stringWithFormat:@"adcVoltage%d",i]];
		[encoder encodeInt:adcVoltageStatus[i] forKey:[NSString stringWithFormat:@"adcStatus%d",i]];
	}
}
#pragma mark •••Hardware Access

- (id) adapter
{
	id anAdapter = [[self guardian] adapter]; //should be the XL2 for this objects crate
	if(anAdapter)return anAdapter;
	else [NSException raise:@"No XL2" format:@"Check that the crate has an XL2"];
	return nil;
}
- (id) xl1
{
	return [[self xl2] xl1];
}
- (id) xl2
{
	id anAdapter = [[self guardian] adapter]; //should be the XL2 for this objects crate
	if(anAdapter)return anAdapter;
	else [NSException raise:@"No XL2" format:@"Check that the crate has an XL2"];
	return nil;
}

- (void) readBoardIds
{
	id xl2 = [self xl2];
	@try {
		[xl2 select:self];
		
		// Read the Daughter Cards for their ids
		NSEnumerator* e = [self objectEnumerator];
		id aCard;
		while(aCard = [e nextObject]){
			if([aCard isKindOfClass:[ORSNOCard class]]){
				[aCard readBoardIds];
			}
		}	
		// Read the PMTIC for its id
		//PerformBoardIDRead(HV_BOARD_ID_INDEX,&dataValue);
		
		//read the Mother Card for its id
		@try {
			[self setBoardID:[self performBoardIDRead:MC_BOARD_ID_INDEX]];
		}
		@catch(NSException* localException) {
			[self setBoardID:@"0000"];	
		}
		
		[xl2 deselectCards];
	    
	}
	@catch(NSException* localException) {
		[xl2 deselectCards];
		
	}
}

- (void) scan:(SEL)aResumeSelectorInGuardian 
{
	workingSlot = 0;
	working = YES;
	[self performSelector:@selector(scanWorkingSlot)withObject:nil afterDelay:0];
	resumeSelectorInGuardian = aResumeSelectorInGuardian;
}

- (void) scanWorkingSlot
{
	BOOL xl2OK = YES;
	@try {
		[[self xl2] selectCards:1L<<[self slot]];	
	}
	@catch(NSException* localException) {
		xl2OK = NO;
		NSLog(@"Unable to reach XL2 in crate: %d (Not inited?)\n",[self crateNumber]);
	}
	if(!xl2OK) working = NO;
	if(working) {
		@try {
			
			ORFecDaughterCardModel* proxyDC = [ObjectFactory makeObject:@"ORFecDaughterCardModel"];
			[proxyDC setGuardian:self];
			
			NSString* aBoardID = [proxyDC performBoardIDRead:workingSlot];
			if(![aBoardID isEqual: @"0000"]){
				NSLog(@"\tDC Slot: %d BoardID: %@\n",workingSlot,aBoardID);
				ORFecDaughterCardModel* theCard = [[OROrderedObjManager for:self] objectInSlot:workingSlot];
				if(!theCard){
					[self addObject:proxyDC];
					[self place:proxyDC intoSlot:workingSlot];
					theCard = proxyDC;
				}
				[theCard setBoardID:aBoardID];
			}
			else {
				NSLog(@"\tDC Slot: %d BoardID: BAD\n",workingSlot);
				ORFecDaughterCardModel* theCard = [[OROrderedObjManager for:self] objectInSlot:workingSlot];
				if(theCard)[self removeObject:theCard];
			}
		}
		@catch(NSException* localException) {
			NSLog(@"\tDC Slot: %d BoardID: ----\n",workingSlot);
			ORFecDaughterCardModel* theCard = [[OROrderedObjManager for:self] objectInSlot:workingSlot];
			if(theCard)[self removeObject:theCard];
		}
	}
	
	workingSlot++;
	if(working && (workingSlot<kNumSNODaughterCards)){
		[self performSelector:@selector(scanWorkingSlot) withObject:nil afterDelay:0];
	}
	else {
		[[self xl2] deselectCards];
		if(resumeSelectorInGuardian){
			[[self guardian] performSelector:resumeSelectorInGuardian withObject:nil afterDelay:0];
			resumeSelectorInGuardian = nil;

		}
	}
}

- (NSString*) performBoardIDRead:(short) boardIndex
{
	unsigned short 	dataValue = 0;
	unsigned long	writeValue = 0UL;
	unsigned long	theRegister = BOARD_ID_REG_NUMBER;
	// first select the board (XL2 must already be selected)
	unsigned long boardSelectVal = 0;
	boardSelectVal |= (1UL << boardIndex);
	
	ORCommandList* aList = [ORCommandList commandList];		//start a command list.
	
	[aList addCommand: [self writeToFec32RegisterCmd:FEC32_BOARD_ID_REG value:boardSelectVal]];
	
	//-------------------------------------------------------------------------------------------
	// load and clock in the first 9 bits instruction code and register address
	//[self boardIDOperation:(BOARD_ID_READ | theRegister) boardSelectValue:boardSelectVal beginIndex: 8];
	//moved here so we could combine all the commands into one list for speed.
	unsigned long theDataValue = (BOARD_ID_READ | theRegister);
	short index;
	for (index = 8; index >= 0; index--){
		if ( theDataValue & (1U << index) ) writeValue = (boardSelectVal | BOARD_ID_DI);
		else								writeValue = boardSelectVal;
		[aList addCommand: [self writeToFec32RegisterCmd:FEC32_BOARD_ID_REG value:writeValue]];					// load data value
		[aList addCommand: [self writeToFec32RegisterCmd:FEC32_BOARD_ID_REG value:(writeValue | BOARD_ID_SK)]];	// now clock in value
	}
	//-------------------------------------------------------------------------------------------
	
	// now read the data value; 17 reads, the last data bit is a dummy bit
	writeValue = boardSelectVal;
	
	int cmdRef[16];
	for (index = 15; index >= 0; index--){
		[aList addCommand: [self writeToFec32RegisterCmd:FEC32_BOARD_ID_REG value:writeValue]];
		[aList addCommand: [self writeToFec32RegisterCmd:FEC32_BOARD_ID_REG value:(writeValue | BOARD_ID_SK)]];	// now clock in value
		cmdRef[index] = [aList addCommand: [self readFromFec32RegisterCmd:FEC32_BOARD_ID_REG]];											// read the data bit
	}
	
	[aList addCommand: [self writeToFec32RegisterCmd:FEC32_BOARD_ID_REG value:writeValue]];					// read out the dummy bit
	[aList addCommand: [self writeToFec32RegisterCmd:FEC32_BOARD_ID_REG value:(writeValue | BOARD_ID_SK)]];	// now clock in value
	[aList addCommand: [self writeToFec32RegisterCmd:FEC32_BOARD_ID_REG value:0UL]];						// Now de-select all and clock
	[aList addCommand: [self writeToFec32RegisterCmd:FEC32_BOARD_ID_REG value:BOARD_ID_SK]];				// now clock in value

	[self executeCommandList:aList]; //send out the list (blocks until reply or timeout)
	
	//OK, assemble the result
	for (index = 15; index >= 0; index--){
		long readValue = [aList longValueForCmd:cmdRef[index]];
		if ( readValue & BOARD_ID_DO)dataValue |= (1U << index);
	}
	
	return hexToString(dataValue);
}

- (void) executeCommandList:(ORCommandList*)aList
{
	[[self xl2] executeCommandList:aList];		
}

- (unsigned long) fec32RegAddress:(unsigned long)aRegOffset
{
	return [[self guardian] registerBaseAddress] + fec32_register_offsets[aRegOffset];
}

- (id) writeToFec32RegisterCmd:(unsigned long) aRegister value:(unsigned long) aBitPattern
{
	unsigned long theAddress = [self fec32RegAddress:aRegister];
	return [[self xl2] writeHardwareRegisterCmd:theAddress value:aBitPattern];		
}

- (id) readFromFec32RegisterCmd:(unsigned long) aRegister
{
	unsigned long theAddress = [self fec32RegAddress:aRegister];
	return [[self xl2] readHardwareRegisterCmd:theAddress]; 		
}

- (id) delayCmd:(unsigned long) milliSeconds
{
	return [[self xl2] delayCmd:milliSeconds]; 		
}
								
- (void) writeToFec32Register:(unsigned long) aRegister value:(unsigned long) aBitPattern
{
	unsigned long theAddress = [self fec32RegAddress:aRegister];
	[[self xl2] writeHardwareRegister:theAddress value:aBitPattern];		
}

- (unsigned long) readFromFec32Register:(unsigned long) aRegister
{
	unsigned long theAddress = [self fec32RegAddress:aRegister];
	return [[self xl2] readHardwareRegister:theAddress]; 		
}

- (void) setFec32RegisterBits:(unsigned long) aRegister bitMask:(unsigned long) bits_to_set
{
	//set some bits in a register without destroying other bits
	unsigned long old_value = [self readFromFec32Register:aRegister];
	unsigned long new_value = (old_value & ~bits_to_set) | bits_to_set;
	[self writeToFec32Register:aRegister value:new_value]; 		
}

- (void) clearFec32RegisterBits:(unsigned long) aRegister bitMask:(unsigned long) bits_to_clear
{
	//Clear some bits in a register without destroying other bits
	unsigned long old_value = [self readFromFec32Register:aRegister];
	unsigned long new_value = (old_value & ~bits_to_clear);
	[self writeToFec32Register:aRegister value:new_value]; 		
}


- (void) boardIDOperation:(unsigned long)theDataValue boardSelectValue:(unsigned long) boardSelectVal beginIndex:(short) beginIndex
{
	unsigned long writeValue = 0UL;
	// load and clock in the instruction code

	
	ORCommandList* aList = [ORCommandList commandList];
	short index;
	for (index = beginIndex; index >= 0; index--){
		if ( theDataValue & (1U << index) ) writeValue = (boardSelectVal | BOARD_ID_DI);
		else								writeValue = boardSelectVal;
		[aList addCommand: [self writeToFec32RegisterCmd:FEC32_BOARD_ID_REG value:writeValue]];					// load data value
		[aList addCommand: [self writeToFec32RegisterCmd:FEC32_BOARD_ID_REG value:(writeValue | BOARD_ID_SK)]];	// now clock in value
		writeValue = 0UL;
	}
	[self executeCommandList:aList];
}

- (void) autoInit
{
	@try {
		
		[self readBoardIds];	//Find out if the HW is there...
		if(![boardID isEqualToString:@"0000"]  && ![boardID isEqualToString:@"FFFF"]){
			[self setOnlineMask:0xFFFFFFFF];
		}
		
		//Do standard Board Init Things
		ORTimer* timer = [[ORTimer alloc] init];
		[timer start];
		[self fullResetOfCard];
		NSLog(@"0: %f\n",[timer seconds]);
		[timer reset];
		[self loadAllDacs];
		NSLog(@"1: %f\n",[timer seconds]);
		[timer reset];
		//always disable TR20 and TR100 on autoinit - as per JFW instructions 07/23/98 PH
		//		LoadCmosShiftRegisters(true);
		
		// set up the hardware according to the ConfigDB
		[self setPedestals]; 	//MAH 3/22/98
		NSLog(@"2: %f\n",[timer seconds]);
		[timer reset];
		
		// now setup the PMT's wrt online/offline status - added 8/20/98 PMT
		[self performPMTSetup:YES];
		NSLog(@"3: %f\n",[timer seconds]);
		[timer reset];
		[timer release];
		
	}
	@catch(NSException* localException) {	
		// set the flags for the off-line status
		//theConfigDB -> SlotOnline(GetTheSnoCrateNumber(),itsFec32SlotNumber,FALSE);
		[self setOnlineMask:0x00000000];
		
	}
}


- (void) fullResetOfCard
{	
	@try {
		[[self xl2] select:self];
		[self setFec32RegisterBits:FEC32_GENERAL_CS_REG bitMask:FEC32_CSR_FULL_RESET]; // STEP 1: Master Reset the FEC32
		[self loadCrateAddress];													// STEP 2: Perform load of crate address
		
		// additional effect is to disable all the triggers
		short i;
		for(i=0;i<32;i++) {
			//theConfigDB->Pmt20nsTriggerDisabled(itsSNOCrate->Get_SC_Number(),itsFec32SlotNumber,i,true);
			//theConfigDB->Pmt100nsTriggerDisabled(itsSNOCrate->Get_SC_Number(),itsFec32SlotNumber,i,true);
		}
		
	}
	@catch(NSException* localException) {
		[[self xl2] deselectCards];
		NSLog(@"Failure during full reset of FEC32 Crate %d Slot %d.", [self crateNumber], [self stationNumber]);	
	}		
}

- (void) loadCrateAddress
{
	@try {	
		
		[[self xl2] select:self];
		unsigned long theOldCSRValue = [self readFromFec32Register:FEC32_GENERAL_CS_REG];
		// create new crate number in proper bit positions
		unsigned long crateNumber = (unsigned long) ( ( [self crateNumber] << FEC32_CSR_CRATE_BITSIFT ) & FEC32_CSR_CRATE_ADD );
		// clear old crate number, then mask in new.
		unsigned long theNewCSRValue = crateNumber | (theOldCSRValue & ~FEC32_CSR_CRATE_ADD);
		[self writeToFec32Register:FEC32_GENERAL_CS_REG value:theNewCSRValue];
		[[self xl2] deselectCards];
		
	}
	@catch(NSException* localException) {
		
		[[self xl2] deselectCards];
		NSLog(@"Failure during load of crate address on FEC32 Crate %d Slot %d.", [self crateNumber], [self stationNumber]);	
		
	}
}

- (void) loadAllDacs
{
	//-------------- variables -----------------
	unsigned long	i,j,k;								
	
	short theIndex;
	
	const short numChannels = 8;
	unsigned long writeValue = 0;
	
	unsigned long dacValues[8][17];
	
	//------------------------------------------
	
	
	NSLog(@"Setting all DACs for FEC32 (%d,%d)....\n", [self crateNumber],[self stationNumber]);
	//	StatusPrintf("Reading the DATABASE to get the values....");
	
	@try {
		[[self xl2] select:self];
		
		// Need to do Full Buffer mode before and after the DACs are loaded the first time
		// Full Buffer Mode of DAC loading, before the DACs are loaded -- this works 1/20/97
		
		ORCommandList* aList = [ORCommandList commandList];
		[aList addCommand: [self writeToFec32RegisterCmd:FEC32_DAC_PROGRAM_REG value:0x0]];  // set DACSEL
		
		for ( i = 1; i<= 16 ; i++) {
			
			if ( ( i<9 ) || ( i == 10) ){
				writeValue = 0UL;
				[aList addCommand: [self writeToFec32RegisterCmd:FEC32_DAC_PROGRAM_REG value:writeValue]];
			}
			else {
				writeValue = 0x0007FFFC;
				[aList addCommand: [self writeToFec32RegisterCmd:FEC32_DAC_PROGRAM_REG value:writeValue]];	// address value, enable this channel					
			}
			
			[aList addCommand: [self writeToFec32RegisterCmd:FEC32_DAC_PROGRAM_REG value:writeValue+1]];
		}
		
		[aList addCommand: [self writeToFec32RegisterCmd:FEC32_DAC_PROGRAM_REG value:0x2]];// remove DACSEL
		
		// now clock in the address and data values
		for ( i = numChannels; i >= 1 ; i--) {			// 8 channels, i.e. there are 8 lines of data values
			
			[aList addCommand: [self writeToFec32RegisterCmd:FEC32_DAC_PROGRAM_REG value:0x0]];  // set DACSEL
			
			// clock in the address values
			for ( j = 1; j<= 8; j++){					
				
				if ( j == i) {
					// enable all 17 DAC address lines for a particular channel
					writeValue = 0x0007FFFC;
					[aList addCommand: [self writeToFec32RegisterCmd:FEC32_DAC_PROGRAM_REG value:writeValue]];
				}
				else{
					writeValue = 0UL;
					[aList addCommand: [self writeToFec32RegisterCmd:FEC32_DAC_PROGRAM_REG value:writeValue]]; //disable channel
				}
				[aList addCommand: [self writeToFec32RegisterCmd:FEC32_DAC_PROGRAM_REG value:writeValue+1]];	// clock in
			}
			
			// first load the DAC values from the database into a 8x17 matirx
			short cIndex;
			for (cIndex = 0; cIndex <= 16; cIndex++){
				short rIndex;
				for (rIndex = 0; rIndex <= 7; rIndex++){
					switch( cIndex ){
							
						case 0:
							if ( rIndex%2 == 0 )	{
								theIndex = (rIndex/2);
								dacValues[rIndex][cIndex]		= [dc[theIndex] rp2:0];
								dacValues[rIndex + 1][cIndex]	= [dc[theIndex] rp2:1];
							}	
							break;
							
						case 1:
							if ( rIndex%2 == 0)	{
								theIndex = (rIndex/2);
								dacValues[rIndex][cIndex]		= [dc[theIndex] vli:0];					
								dacValues[rIndex + 1][cIndex]	= [dc[theIndex] vli:1];	
							}	
							break;
							
						case 2:
							if ( rIndex%2 == 0 )	{
								theIndex = (rIndex/2);
								dacValues[rIndex][cIndex]		= [dc[theIndex] vsi:0];					
								dacValues[rIndex + 1][cIndex]	= [dc[theIndex] vsi:1];		
							}	
							break;
							
						case 15:
							if ( rIndex%2 == 0 )	{
								theIndex = (rIndex/2);
								dacValues[rIndex][cIndex]		= [dc[theIndex] rp1:0];						
								dacValues[rIndex + 1][cIndex]   = [dc[theIndex] rp1:0];		
							}	
							break;
							
					}
					
					if ( (cIndex >= 3) && (cIndex <= 6) ) {
						
						dacValues[rIndex][cIndex] = [dc[cIndex - 3] vt:rIndex];
					}
					
					else if ( (cIndex >= 7) && (cIndex <= 14) ) {
						
						if ( (cIndex - 7)%2 == 0)	{
							theIndex = ( (cIndex - 7) / 2 );
							
							unsigned long theGain;
							if (rIndex/4)	theGain = 1;
							else			theGain = 0;
							dacValues[rIndex][cIndex]	= [dc[theIndex] vb:rIndex%4    egain:theGain];
							dacValues[rIndex][cIndex+1] = [dc[theIndex] vb:(rIndex%4)+4 egain:theGain];
						}
					}
					else if ( cIndex == 16) {
						switch( rIndex){
							case 6:  dacValues[rIndex][cIndex] = [self vRes];			break;
							case 7:  dacValues[rIndex][cIndex] = [self hVRef];			break;
							default: dacValues[rIndex][cIndex] = [self cmos:rIndex];	break;
						}		
					}
				}
			}
			
			// load data values, 17 DAC values at a time, from the electronics database
			// there are a total of 8x17 = 136 DAC values
			
			// load the data values
			for (j = 8; j >= 1; j--){					// 8 bits of data per channel
				
				writeValue = 0UL;
				for (k = 2; k<= 18; k++){				// 17 octal DACs
					if ( (1UL << j-1 ) & dacValues[numChannels - i][k-2] ) {
						writeValue |= 1UL << k;
					}
				}
				
				[aList addCommand: [self writeToFec32RegisterCmd:FEC32_DAC_PROGRAM_REG value:writeValue]];
				[aList addCommand: [self writeToFec32RegisterCmd:FEC32_DAC_PROGRAM_REG value:writeValue+1]];	// clock in
			}
			
			[aList addCommand: [self writeToFec32RegisterCmd:FEC32_DAC_PROGRAM_REG value:0x2]]; // remove DACSEL
		}
		
		// Full Buffer Mode of DAC loading, after the DACs are loaded -- this works 1/13/97
		
		// set DACSEL
		[aList addCommand: [self writeToFec32RegisterCmd:FEC32_DAC_PROGRAM_REG value:0x0]]; // set DACSEL
		
		for ( i = 1; i<= 16 ; i++){
			
			if ( ( i<9 ) || ( i == 10) ){
				writeValue = 0UL;
				[aList addCommand: [self writeToFec32RegisterCmd:FEC32_DAC_PROGRAM_REG value:writeValue]];
			}
			else{
				writeValue = 0x0007FFFC;
				[aList addCommand: [self writeToFec32RegisterCmd:FEC32_DAC_PROGRAM_REG value:writeValue]];
			}
			[aList addCommand: [self writeToFec32RegisterCmd:FEC32_DAC_PROGRAM_REG value:writeValue + 1]];	// clock in with bit 0 high
		}
		
		// remove DACSEL
		[aList addCommand: [self writeToFec32RegisterCmd:FEC32_DAC_PROGRAM_REG value:0x2]]; // remove DACSEL
		[self executeCommandList:aList];
		
		[[self xl2] deselectCards];		
		
		
	}
	@catch(NSException* localException) {
		[[self xl2] deselectCards];		
		NSLog(@"Could not load the DACs for FEC32(%d,%d)!\n", [self crateNumber], [self stationNumber]);			
	}	
}

- (void) setPedestals
{
	@try {
		[[self xl2] select:self];
		[self writeToFec32Register:FEC32_PEDESTAL_ENABLE_REG value:pedEnabledMask];
		[[self xl2] deselectCards];
	}
	@catch(NSException* localException) {
		[[self xl2] deselectCards];
		NSLog(@"Failure during Pedestal set of FEC32(%d,%d).", [self crateNumber], [self stationNumber]);			
		
	}	
	
}

-(void) performPMTSetup:(BOOL) aTriggersDisabled
{
	@try {
		
		[[self xl2] select:self];
		
		[self writeToFec32Register:FEC32_CMOS_CHIP_DISABLE_REG value:seqDisabledMask];
		
		//MAH 7/2/98
		unsigned long value = [self readFromFec32Register:FEC32_CMOS_LGISEL_SET_REG];
		if(qllEnabled)	value |= 0x00000001;
		else			value &= 0xfffffffe;	// JR 1999/06/04 Changed from 0xfffffff7
		[self writeToFec32Register:FEC32_CMOS_LGISEL_SET_REG value:value];
		
		//do the triggers
		[self loadCmosShiftRegisters:aTriggersDisabled];
		[[self xl2] deselectCards];
		
		
	}
	@catch(NSException* localException) {
		[[self xl2] deselectCards];
		NSLog(@"Error during taking channel(s) off-line on  FEC32 Crate %d Slot %d!", [self crateNumber], [self stationNumber]);	 		
	}
}

- (int) stationNumber
{
	//we have a weird mapping because fec cards can only be in slots 1-16 and they are mapped to 0 - 15
	return [[self crate] maxNumberOfObjects] - [self slot] - 2;
}

#pragma mark •••OROrderedObjHolding Protocol
- (int) maxNumberOfObjects	{ return 4; }
- (int) objWidth			{ return 39; }
- (int) groupSeparation		{ return 37; }
- (NSString*) nameForSlot:(int)aSlot	{ return [NSString stringWithFormat:@"Slot %d",aSlot]; }
- (BOOL) slot:(int)aSlot excludedFor:(id)anObj {return NO;}

- (NSRange) legalSlotsForObj:(id)anObj
{
	return NSMakeRange(0,[self maxNumberOfObjects]);
}

- (int)slotAtPoint:(NSPoint)aPoint 
{
	//what really screws us up is the space in the middle
	float y = aPoint.y;
	int objWidth = [self objWidth];
	float w = objWidth * [self maxNumberOfObjects] + [self groupSeparation];
	
	if(y>=0 && y<objWidth)						return 0;
	else if(y>objWidth && y<objWidth*2)			return 1;
	else if(y>=w-objWidth*2 && y<w-objWidth)	return 2;
	else if(y>=w-objWidth && y<w)				return 3;
	else										return -1;
}

- (NSPoint) pointForSlot:(int)aSlot 
{
	int objWidth = [self objWidth];
	float w = objWidth * [self maxNumberOfObjects] + [self groupSeparation];
	if(aSlot == 0)		return NSMakePoint(0,0);
	else if(aSlot == 1)	return NSMakePoint(0,objWidth+1);
	else if(aSlot == 2) return NSMakePoint(0,w-2*objWidth+1);
	else return NSMakePoint(0,w-objWidth+1);
}


- (void) place:(id)aCard intoSlot:(int)aSlot
{
	[aCard setSlot: aSlot];
	[aCard moveTo:[self pointForSlot:aSlot]];
}

- (int) slotForObj:(id)anObj
{
	return [anObj slot];
}

- (int) numberSlotsNeededFor:(id)anObj
{
	return [anObj numberSlotsUsed];
}
@end

@implementation ORFec32Model (private)

- (void) loadCmosShiftRegisters:(BOOL) aTriggersDisabled
{
	
	//-------------- variables -----------------
	
	unsigned short whichChannels;
	unsigned long writeValue = 0;	
	unsigned long registerAddress;
#ifdef VERIFY_CMOS_SHIFT_REGISTER
	int retry_cmos_load = 0;
#endif			
	
	
	//	StatusPrintf("Loading all CMOS Shift Registers for FEC32 #%d....",itsFec32SlotNumber);
	//	StatusPrintf("Reading the DATABASE to get the values....");
	
	@try {
		
		[[self xl2] select:self];
		
		short channel_index;
		for( channel_index = 0; channel_index < 2; channel_index++){
			
			switch (channel_index){
				case BOTTOM_CHANNELS:
					whichChannels = BOTTOM_CHANNELS;
					registerAddress = FEC32_CMOS_1_16_REG;
					break;
				case UPPER_CHANNELS:				
					whichChannels = UPPER_CHANNELS;
					registerAddress = FEC32_CMOS_17_32_REG;
					break;	
			}
			
			// load data into structure from database
			[self loadCmosShiftRegData:whichChannels triggersDisabled:aTriggersDisabled];
			
			// serially shift in 35 bits of data, the top 10 bits are shifted in as zero
			//STEP 1:
			// first shift in the top 10 bits: the bottom 0-15 channels first
			ORCommandList* aList = [ORCommandList commandList];
			short i;
			for (i = 0; i < 10; i++){
				[aList addCommand: [self writeToFec32RegisterCmd:registerAddress value:FEC32_CMOS_SHIFT_SERSTROB]];
				[aList addCommand: [self writeToFec32RegisterCmd:registerAddress value:FEC32_CMOS_SHIFT_SERSTROB | FEC32_CMOS_SHIFT_CLOCK]];
			}
 
			// STEP 2: tacTrim1
			[aList addCommands:[self cmosShiftLoadAndClock:registerAddress cmosRegItem:TAC_TRIM1 bitMaskStart:TACTRIM_BITS]];
			
			// STEP 3: tacTrim0
			[aList addCommands:[self cmosShiftLoadAndClock:registerAddress cmosRegItem:TAC_TRIM0 bitMaskStart:TACTRIM_BITS]];
			
			// STEP 4: ns20Mask
			[aList addCommands:[self cmosShiftLoadAndClock:registerAddress cmosRegItem:NS20_MASK bitMaskStart:NS20_MASK_BITS]];
			
			// STEP 5: ns20Width
			[aList addCommands:[self cmosShiftLoadAndClock:registerAddress cmosRegItem:NS20_WIDTH bitMaskStart:NS20_WIDTH_BITS]];
			
			// STEP 6: ns20Delay
			[aList addCommands:[self cmosShiftLoadAndClock:registerAddress cmosRegItem:NS20_DELAY bitMaskStart:NS20_DELAY_BITS]];
			
			// STEP 7: ns100Mask
			[aList addCommands:[self cmosShiftLoadAndClock:registerAddress cmosRegItem:NS100_MASK bitMaskStart:NS_MASK_BITS]];
			
			// STEP 8: ns100Delay
			[aList addCommands:[self cmosShiftLoadAndClock:registerAddress cmosRegItem:NS100_DELAY bitMaskStart:NS100_DELAY_BITS]];
			
			// FINAL STEP: SERSTOR
			writeValue = 0x3FFFF;
			[aList addCommand: [self writeToFec32RegisterCmd:registerAddress value:writeValue]];
			[self executeCommandList:aList]; //send out the list (blocks until reply or timeout)
#ifdef VERIFY_CMOS_SHIFT_REGISTER
			/*
			 ** VERIFY that we have set the shift register properly for the 16 channels just loaded - PH 09/17/99
			 */		
			// maximum number of times to attempt loading the CMOS shift register before throwing an exception
			const short	kMaxCmosLoadAttempts = 2;
			
			// maximum number of times to check the busy bit on the CMOS read before using the value
			const short kMaxCmosReadAttempts = 3;
			
			// verify each of the 16 channels that we just loaded
			int theChannel;
			for (theChannel=0; theChannel<16; ++theChannel) {
				
				unsigned long actualShiftReg, expectedShiftReg;
				
				// read back the CMOS shift register
				short retry_read;
				for (retry_read=0; retry_read<kMaxCmosReadAttempts; ++retry_read) {
					actualShiftReg = [self readFromFec32Register:Fec32_CMOS_SHIFT_REG_OFFSET + 32*(theChannel+16*channel_index)];
					if( !(actualShiftReg & 0x80000000) ) break;	// break if busy bit not set
					// otherwise: busy, so try to read again
				}
				// calculate the expected shift register value
				expectedShiftReg = ((cmosShiftRegisterValue[theChannel].cmos_shift_item[TAC_TRIM1]   & 0x0fUL) << 20) |
				((cmosShiftRegisterValue[theChannel].cmos_shift_item[TAC_TRIM0]   & 0x0fUL) << 16) |
				((cmosShiftRegisterValue[theChannel].cmos_shift_item[NS100_DELAY] & 0x3fUL) << 10) |
				((cmosShiftRegisterValue[theChannel].cmos_shift_item[NS20_MASK]   & 0x01UL) <<  9) |
				((cmosShiftRegisterValue[theChannel].cmos_shift_item[NS20_WIDTH]  & 0x1fUL) <<  4) |
				((cmosShiftRegisterValue[theChannel].cmos_shift_item[NS20_DELAY]  & 0x0fUL));
				
				// check the shift register value, ignoring upper 8 bits (write address and read error flag)
				if ((actualShiftReg & 0x00ffffffUL) == expectedShiftReg) {
					// success!
					if (retry_cmos_load) {
						// print a message if we needed to retry the load
						NSLog(@"Loaded CMOS Shift Registers for Crate %d, Card %d, Channel %d after %d attempts", 
							  [self crateNumber], [self stationNumber], theChannel + 16 * channel_index, retry_cmos_load+1);
						retry_cmos_load = 0;	// reset retry counter
					}		
				} else if (++retry_cmos_load < kMaxCmosLoadAttempts) {
					// verification error but we still want to keep trying
					--theChannel;	// try to load the same 16 channels again
				} else {
					// verification error after maximum number of retries
					NSLog(@"Error verifying CMOS Shift Register for Crate %d, Card %d, Channel %d:",
						  [self crateNumber], [self stationNumber], theChannel + 16 * channel_index);
					unsigned long badBits = (actualShiftReg ^ expectedShiftReg);
					if (actualShiftReg == 0UL) {
						NSLog(@"  - all shift register bits read back as zero");
					} else {
						if ((badBits >> 20) & 0x0fUL) {
							NSLog(@"  - loaded TAC1 trim   0x%.2lx, but read back 0x%.2lx",(expectedShiftReg >> 20) & 0x0fUL,
								  (actualShiftReg   >> 20) & 0x0fUL);
						}
						if ((badBits >> 16) & 0x0fUL) {
							NSLog(@"  - loaded TAC0 trim   0x%.2lx, but read back 0x%.2lx",(expectedShiftReg >> 16) & 0x0fUL,
								  (actualShiftReg   >> 16) & 0x0fUL);
						}
						if ((badBits >> 10) & 0x3fUL) {
							NSLog(@"  - loaded 100ns width 0x%.2lx, but read back 0x%.2lx",(expectedShiftReg >> 10) & 0x3fUL,
								  (actualShiftReg   >> 10) & 0x3fUL);
						}
						if ((badBits >> 9) & 0x01UL) {
							NSLog(@"  - loaded 20ns enable 0x%.2lx, but read back 0x%.2lx",(expectedShiftReg >> 9) & 0x01UL,
								  (actualShiftReg   >> 9) & 0x01UL);
						}
						if ((badBits >> 4) & 0x1fUL) {
							NSLog(@"  - loaded 20ns width  0x%.2lx, but read back 0x%.2lx",(expectedShiftReg >> 4) & 0x1fUL,
								  (actualShiftReg   >> 4) & 0x1fUL);
						}
						if ((badBits) & 0x0fUL) {
							NSLog(@"  - loaded 20ns delay  0x%.2lx, but read back 0x%.2lx",(expectedShiftReg) & 0x0fUL,
								  (actualShiftReg)   & 0x0fUL);
						}
					}
					retry_cmos_load = 0;	// reset retry counter
				}
			}
#endif // VERIFY_CMOS_SHIFT_REGISTER
		}
		
		[[self xl2] deselectCards];
		
		// CMOS Shift Register loading successful message to status window
		//		StatusPrintf("CMOS Shift Registers for FEC32 #%d have been loaded.",itsFec32SlotNumber);
		
	}
	@catch(NSException* localException) {
		[[self xl2] deselectCards];
		NSLog(@"Could not load the CMOS Shift Registers for FEC32 (%d,%d)!\n", [self crateNumber], [self stationNumber]);	 		
		
	}
	
	
}


- (ORCommandList*) cmosShiftLoadAndClock:(unsigned short) registerAddress cmosRegItem:(unsigned short) cmosRegItem bitMaskStart:(short) bit_mask_start
{
	
	short bit_mask;
	ORCommandList* aList = [ORCommandList commandList];
	
	// bit_mask_start : the number of bits to peel off from cmosRegItem
	for(bit_mask = bit_mask_start; bit_mask >= 0; bit_mask--){
		
		unsigned long writeValue = 0UL;
		short channel_index;
		for(channel_index = 0; channel_index < 16; channel_index++){
			if ( cmosShiftRegisterValue[channel_index].cmos_shift_item[cmosRegItem] & (1UL << bit_mask) ) {
				writeValue |= (1UL << channel_index + 2);
			}
		}
		
		// place data on line
		[aList addCommand: [self writeToFec32RegisterCmd:registerAddress value:writeValue | FEC32_CMOS_SHIFT_SERSTROB]];
		// now clock in data without SERSTROB for bit_mask = 0 and cmosRegItem = NS100_DELAY
		if( (cmosRegItem == NS100_DELAY) && (bit_mask == 0) ){
			[aList addCommand: [self writeToFec32RegisterCmd:registerAddress value:writeValue | FEC32_CMOS_SHIFT_CLOCK]];
		}
		// now clock in data
		[aList addCommand: [self writeToFec32RegisterCmd:registerAddress value:writeValue | FEC32_CMOS_SHIFT_SERSTROB | FEC32_CMOS_SHIFT_CLOCK]];
	}
	return aList;
}

-(void) loadCmosShiftRegData:(unsigned short)whichChannels triggersDisabled:(BOOL)aTriggersDisabled
{
	unsigned short dc_offset;
	
	switch (whichChannels){
		case BOTTOM_CHANNELS:
			dc_offset = 0;
			break;
		case UPPER_CHANNELS:
			dc_offset = 2;
			break;
	}
	
	// initialize cmosShiftRegisterValue structure	
	unsigned short i;
	for (i = 0; i < 16 ; i++){
		unsigned short j;
		for (j = 0; j < 7 ; j++){
			cmosShiftRegisterValue[i].cmos_shift_item[j] = 0;
		}
	}
	
	// load the data from the database into theCmosShiftRegUnion
	//temp.....CHVStatus theHVStatus;
	unsigned short dc_index;
	for ( dc_index= 0; dc_index < 2 ; dc_index++){
		
		unsigned short offset_index = dc_index*8;
		
		unsigned short regIndex;
		for (regIndex = 0; regIndex < 8 ; regIndex++){
			unsigned short channel = 8*(dc_offset+dc_index) + regIndex;
			cmosShiftRegisterValue[offset_index + regIndex].cmos_shift_item[TAC_TRIM1] = [dc[dc_index + dc_offset]  tac1trim:regIndex];
			cmosShiftRegisterValue[offset_index + regIndex].cmos_shift_item[TAC_TRIM0] = [dc[dc_index + dc_offset]  tac0trim:regIndex];
			cmosShiftRegisterValue[offset_index + regIndex].cmos_shift_item[NS20_WIDTH] = ([dc[dc_index + dc_offset]  ns20width:regIndex]) >> 1;	 // since bit 1 is the LSB
			cmosShiftRegisterValue[offset_index + regIndex].cmos_shift_item[NS20_DELAY] = ([dc[dc_index + dc_offset]  ns20delay:regIndex]) >> 1;    // since bit 1 is the LSB
			cmosShiftRegisterValue[offset_index + regIndex].cmos_shift_item[NS100_DELAY] = ([dc[dc_index + dc_offset] ns100width:regIndex]) >> 1;   // since bit 1 is the LSB
			
			if (aTriggersDisabled /*|| !theHVStatus.IsHVOnThisChannel(itsSNOCrate->Get_SC_Number(),itsFec32SlotNumber,channel)*/ ) {
				cmosShiftRegisterValue[offset_index + regIndex].cmos_shift_item[NS20_MASK] = 0;
				cmosShiftRegisterValue[offset_index + regIndex].cmos_shift_item[NS100_MASK] = 0;
				[self setTrigger20ns:channel disabled:YES];
				[self setTrigger100ns:channel disabled:YES];
			} else {
				cmosShiftRegisterValue[offset_index + regIndex].cmos_shift_item[NS20_MASK]  = ![self trigger20nsDisabled:channel];
				cmosShiftRegisterValue[offset_index + regIndex].cmos_shift_item[NS100_MASK] = ![self trigger100nsDisabled:channel];
			}
		}
		
	}		
}
@end

