//--------------------------------------------------------
// ORNMon5085Model
// Created by Mark  A. Howe on Fri Oct 4, 2014
// Code partially generated by the OrcaCodeWizard. Written by Mark A. Howe.
// Copyright (c) 2013 University of North Carolina. All rights reserved.
//-----------------------------------------------------------
//This program was prepared for the Regents of the University of
//North Carolina  sponsored in part by the United States
//Department of Energy (DOE) under Grant #DE-FG02-97ER41020.
//The University has certain rights in the program pursuant to
//the contract and the program should not be copied or distributed
//outside your organization.  The DOE and the University of
//North Carolina reserve all rights in the program. Neither the authors,
//University of North Carolina, or U.S. Government make any warranty,
//express or implied, or assume any liability or responsibility
//for the us of this software.
//-------------------------------------------------------------

#pragma mark •••Imported Files
#import "ORSerialPortWithQueueModel.h"

#define kNMon5085RateMode   0
#define kNMon5085Integrate  1

@class ORTimeRate;

@interface ORNMon5085Model : ORSerialPortWithQueueModel
{
    @private
		NSMutableData*	inComingData;
        int             mode;
        int             modeTime;
        float           radValue;
        NSString*       units;
        unsigned long   timeMeasured;
        NSDate*         dateMeasured;
        ORTimeRate*		timeRate;
        BOOL			isLog;
        BOOL            isRunning;
        BOOL            runHeartBeat;
        int             timeUtilStop;
        BOOL            manualOp;
        float           calibrationValue;
        int             discriminator;
        NSString*       actualMode;
        int             deadtime;
        int             highVoltage;
        NSDate*         dateOfMaxRadValue;
        float           maxRadValue;
}

#pragma mark •••Initialization
- (void) dealloc;

#pragma mark •••Accessors
- (float)   maxRadValue;
- (void)    setMaxRadValue:(float)aMaxRadValue;
- (NSDate*) dateOfMaxRadValue;
- (void)    setDateOfMaxRadValue:(NSDate*)aDateOfMaxRadValue;
- (int)     highVoltage;
- (void)    setHighVoltage:(int)aHighVoltage;
- (int)     deadtime;
- (void)    setDeadtime:(int)aDeadtime;
- (NSString*) actualMode;
- (void)    setActualMode:(NSString*)aActualMode;
- (int)     discriminator;
- (void)    setDiscriminator:(int)aDiscriminator;
- (float)   calibrationValue;
- (void)    setCalibrationValue:(float)aCalibrationValue;
- (int)     timeUtilStop;
- (void)    setTimeUtilStop:(int)aTimeUtilStop;
- (NSDate*) dateMeasured;
- (BOOL)    isRunning;
- (void)    setIsRunning:(BOOL)aValue;
- (unsigned long) timeMeasured;
- (NSString*) units;
- (void)    setUnits:(NSString*)aUnits;
- (float)   radValue;
- (void)    setRadValue:(float)aRadValue;
- (int)     modeTime;
- (void)    setModeTime:(int)aSeconds;
- (int)     mode;
- (void)    setMode:(int)aMode;
- (void)    dataReceived:(NSNotification*)note;
- (BOOL)    isLog;
- (void)    setIsLog:(BOOL)aIsLog;
- (ORTimeRate*)timeRate;
- (void)    runTimeOut;

#pragma mark •••Commands
- (void) initHW;
- (void) toggleRun;
- (void) sendSorQCommand;

#pragma mark •••Archival
- (id)   initWithCoder:(NSCoder*)decoder;
- (void) encodeWithCoder:(NSCoder*)encoder;
@end

extern NSString* ORNMon5085ModelMaxRadValueChanged;
extern NSString* ORNMon5085ModelDateOfMaxRadValueChanged;
extern NSString* ORNMon5085ModelHighVoltageChanged;
extern NSString* ORNMon5085ModelDeadtimeChanged;
extern NSString* ORNMon5085ModelActualModeChanged;
extern NSString* ORNMon5085ModelDiscriminatorChanged;
extern NSString* ORNMon5085ModelCalibrationValueChanged;
extern NSString* ORNMon5085ModelTimeUtilStopChanged;
extern NSString* ORNMon5085ModelIsRunningChanged;
extern NSString* ORNMon5085ModelUnitsChanged;
extern NSString* ORNMon5085ModelRadValueChanged;
extern NSString* ORNMon5085ModelModeTimeChanged;
extern NSString* ORNMon5085ModelModeChanged;
extern NSString* ORNMon5085ModelRunningChanged;
extern NSString* ORNMon5085Lock;
extern NSString* ORNMon5085IsLogChanged;
