//--------------------------------------------------------
// ORGT521Model
// Created by Mark  A. Howe on Oct 31, 2013
// Code partially generated by the OrcaCodeWizard. Written by Mark A. Howe.
// Copyright (c) 2013 CENPA, University of North Carolina. All rights reserved.
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

#pragma mark ***Imported Files
#import "ORAdcProcessing.h"
#import "ORSerialPortWithQueueModel.h"

@class ORTimeRate;
@class ORAlarm;

#define kGT521Cumulative    0
#define kGT521Differential  1
#define kGT521Uncorrected   2

#define kGT521CubicFoot     0
#define kGT521CubicLiter    1

#define kGT521DelayTime  0.3

@interface ORGT521Model : ORSerialPortWithQueueModel <ORAdcProcessing>
{
    @private
		BOOL             delay;
		unsigned long	 timeMeasured;
        NSMutableString* buffer;
		NSString*	measurementDate;
		float		size1;
		float		size2;
		int			count1;
		int			count2;
		int			countingMode;
		int			cycleDuration;
		BOOL		running;
		NSDate*		cycleStarted;
		NSDate*		cycleWillEnd;
		int			cycleNumber;
		ORTimeRate*	timeRates[4];
		BOOL		wasRunning;
        BOOL		dataValid;
		BOOL		sentStartOnce;
		BOOL		sentStopOnce;
		int         missedCycleCount;
		ORAlarm*	missingCyclesAlarm;
        int         location;
        float       humidity;
        float       temperature;
        BOOL        restart;
        BOOL        usingCentigrade;
        BOOL        autoCount;
        int         correctionType;
        BOOL        probeAttached;
    
        float		maxValue[4];
        float		valueAlarmLimit[4];
}

#pragma mark ***Initialization
- (id)   init;
- (void) dealloc;
- (void) dataReceived:(NSNotification*)note;
- (BOOL) dataForChannelValid:(int)aChannel;

#pragma mark ***Accessors
- (BOOL) probeAttached;
- (void) setProbeAttached:(BOOL)aProbeAttached;
- (int)  correctionType;
- (void) setCorrectionType:(int)aCorrectionType;
- (BOOL) usingCentigrade;
- (void) setUsingCentigrade:(BOOL)aUsingCentigrade;
- (BOOL) autoCount;
- (void) setAutoCount:(BOOL)aAutoCount;
- (float) temperature;
- (void) setTemperature:(float)aTemperature;
- (float) humidity;
- (void) setHumidity:(float)aHumidity;
- (int) location;
- (void) setLocation:(int)aLocation;
- (ORTimeRate*)timeRate:(int)index;
- (int) cycleNumber;
- (void) setCycleNumber:(int)aCycleNumber;
- (NSDate*) cycleWillEnd;
- (void) setCycleWillEnd:(NSDate*)aCycleWillEnd;
- (NSDate*) cycleStarted;
- (void) setCycleStarted:(NSDate*)aCycleStarted;
- (BOOL) running;
- (void) setRunning:(BOOL)aRunning;
- (int) cycleDuration;
- (void) setCycleDuration:(int)aCycleDuration;
- (int) countingMode;
- (void) setCountingMode:(int)aCountingMode;
- (int) count2;
- (void) setCount2:(int)aCount2;
- (int) count1;
- (void) setCount1:(int)aCount1;
- (float) size2;
- (void) setSize2:(float)aSize2;
- (float) size1;
- (void) setSize1:(float)aSize1;
- (NSString*) measurementDate;
- (void) setMeasurementDate:(NSString*)aMeasurementDate;
- (unsigned long) timeMeasured;
- (NSString*) countingModeString;
- (BOOL) dataForChannelValid:(int)aChannel;
- (void) setMissedCycleCount:(int)aValue;
- (int) missedCycleCount;
- (float) valueAlarmLimit:(int)index;
- (void) setIndex:(int)index valueAlarmLimit:(float)aCountAlarmLimit;
- (float) maxValue:(int)index;
- (void) setIndex:(int)index maxValue:(float)aMaxCounts;

#pragma mark ***Polling
- (void) startCycle;
- (void) startCycle:(BOOL)force;
- (void) stopCycle;

#pragma mark ***Commands
- (void) addCmdToQueue:(NSString*)aCmd;
- (id)   initWithCoder:(NSCoder*)decoder;
- (void) encodeWithCoder:(NSCoder*)encoder;
- (void) startCounting;	
- (void) stopCounting;	
- (void) clearBuffer;				
- (void) getFirmwareVersion;
- (void) getLastRecord;					
- (void) selectUnit;
- (void) setSampleTime;
#pragma mark •••Adc Processing Protocol
- (void)processIsStarting;
- (void)processIsStopping;
- (void) startProcessCycle;
- (void) endProcessCycle;
- (double) minValueForChan:(int)aChan;
- (BOOL) processValue:(int)channel;
- (void) setProcessOutput:(int)channel value:(int)value;
- (NSString*) processingTitle;
- (void) getAlarmRangeLow:(double*)theLowLimit high:(double*)theHighLimit  channel:(int)channel;
- (double) convertedValue:(int)channel;
- (double) maxValueForChan:(int)channel;

@end

extern NSString* ORGT521ModelProbeAttachedChanged;
extern NSString* ORGT521ModelCorrectionTypeChanged;
extern NSString* ORGT521ModelUsingCentigradeChanged;
extern NSString* ORGT521ModelAutoCountChanged;
extern NSString* ORGT521ModelTemperatureChanged;
extern NSString* ORGT521ModelHumidityChanged;
extern NSString* ORGT521ModelLocationChanged;
extern NSString* ORGT521ModelValueAlarmLimitChanged;
extern NSString* ORGT521ModelMaxValueChanged;
extern NSString* ORGT521ModelCycleNumberChanged;
extern NSString* ORGT521ModelCycleWillEndChanged;
extern NSString* ORGT521ModelCycleStartedChanged;
extern NSString* ORGT521ModelRunningChanged;
extern NSString* ORGT521ModelCycleDurationChanged;
extern NSString* ORGT521ModelCountingModeChanged;
extern NSString* ORGT521ModelCount2Changed;
extern NSString* ORGT521ModelCount1Changed;
extern NSString* ORGT521ModelSize2Changed;
extern NSString* ORGT521ModelSize1Changed;
extern NSString* ORGT521ModelMeasurementDateChanged;
extern NSString* ORGT521ModelPollTimeChanged;
extern NSString* ORGT521ModelMissedCountChanged;
extern NSString* ORGT521Lock;
