//--------------------------------------------------------
// ORRGA300Model
// Created by Mark  A. Howe on Wed 4/15/2009
// Created by Mark  A. Howe on Tues Jan 4, 2012
// Code partially generated by the OrcaCodeWizard. Written by Mark A. Howe.
// Copyright (c) 2012 CENPA, University of Washington. All rights reserved.
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
#import "ORSerialPortWithQueueModel.h"

@class ORRGA300Cmd;

//Status Error Masks
#define kRGACommStatusMask			0x01
#define kRGAFilamentStatusMask		0x02
#define kRGAElectronMultiStatusMask	0x08
#define kRGAQMFStatusMask			0x10
#define kRGAElectrometerStatusMask	0x20
#define kRGA24VStatusMask			0x40

//RS2323 Error Masks
#define kRGABadCmd					0x01
#define kRGABadParam				0x02
#define kRGACmdTooLong				0x04
#define kRGAOverWrite				0x08
#define kRGATransOverWrite			0x10
#define kRGAJumper					0x20
#define kRGAParamConflict			0x40

//CEM Masks
#define kRGACEMNoElecMultiOption	0x10

//FIL Masks
#define kRGAFILSingleFilament		0x01
#define kRGAFILPressureTooHigh		0x20
#define kRGAFILCannotSetCurrent		0x40
#define kRGAFILNoFilament			0x80

//QMG Masks
#define kRGAQMFCurrentLimited		0x10
#define kRGAQMFCurrentTooHigh		0x40
#define kRGAQMFRF_CTTooHigh			0x80

//Power Supply Masks
#define kRGAPSExtPowerTooLow		0x40
#define kRGAPSExtPowerTooHigh		0x80

//Electrometer Masks
#define kRGADetOpAmpOffset	0x02
#define kRGADetCompNegInput 0x08
#define kRGADetCompPosInput 0x10
#define kRGADetDetNegInput  0x20
#define kRGADetDetPosInput  0x40
#define kRGADetAdcFailure	0x80

#define kRGAIdle			-999
#define kRGAAnalogScan		0
#define kRGATableScan		1
#define kRGAHistogramScan   2

#define kRGAAnalogMode		0
#define kRGATableMode		1
#define kRGAHistogramMode   2

@interface ORRGA300Model : ORSerialPortWithQueueModel
{
    @private
		NSMutableData*	inComingData;
		int		modelNumber;
		float	firmwareVersion;
		int		serialNumber;
		int		statusWord;
		int		psErrWord;
		int		detErrWord;
		int		qmfErrWord;
		int		cemErrWord;
		int		filErrWord;
		int		rs232ErrWord;
	
		int		ionizerDegassTime;
		int		ionizerElectronEnergy;
		float	ionizerEmissionCurrent;
		int		ionizerIonEnergy;
		int		ionizerFocusPlateVoltage;
		int		elecMultHVBias;
		int		noiseFloorSetting;
		int		analogScanPoints;
		int		histoScanPoints;
		int		finalMass;
		int		initialMass;
		int		stepsPerAmu;
		int		measuredIonCurrent;
		BOOL	electronMultiOption;
		float	elecMultGain;
        BOOL    useIonizerDefaults;
        BOOL    useDetectorDefaults;

		//readback values
		float	ionizerFilamentCurrentRB;
		int		ionizerElectronEnergyRB;
		int		ionizerIonEnergyRB;
		int		ionizerFocusPlateVoltageRB;
		int		noiseFloorSettingRB;
		int		elecMultHVBiasRB;
		float	elecMultGainRB;
		int		opMode;
		int		currentActivity;
	
		//scan parameters and data
		BOOL	expectingRawData;
		float	scanProgress;
		int		scanNumber;
		NSData* scanData;
		NSMutableDictionary* amuTableData;
		NSMutableArray* amus;
		int     currentAmuIndex;
        float   sensitivityFactor;
		NSMutableDictionary* filamentConstraints;
		NSMutableDictionary* cemConstraints;
        BOOL    scheduledForCouchPost;
        BOOL    constraintsDisabled;
}

#pragma mark •••Initialization
- (void) dealloc;

#pragma mark •••Accessors
- (NSString*) auxStatusString:(int)aChannel;
- (float) sensitivityFactor;
- (void) setSensitivityFactor:(float)aSensitivityFactor;
- (int)		currentAmuIndex;
- (NSData*) scanData;
- (int)		scanNumber;
- (void)	setScanNumber:(int)aScanNumber;
- (float)	scanProgress;
- (void)	setScanProgress:(float)aScanProgress;
- (int)		currentActivity;
- (int)		opMode;
- (void)	setOpMode:(int)aOpMode;
- (float)	elecMultGainRB;
- (int)		elecMultHVBiasRB;
- (int)		noiseFloorSettingRB;
- (int)		ionizerFocusPlateVoltageRB;
- (int)		ionizerIonEnergyRB;
- (int)		ionizerElectronEnergyRB;
- (float)	ionizerFilamentCurrentRB;
- (BOOL)	filamentIsOn;
- (float)	elecMultGain;
- (void)	setElecMultGain:(float)aElecMultGain;
- (BOOL)	electronMultiOption;
- (int)		measuredIonCurrent;

- (int)		stepsPerAmu;
- (void)	setStepsPerAmu:(int)aStepsPerAmu;
- (int)		histoScanPoints;
- (int)		analogScanPoints;
- (int)		noiseFloorSetting;
- (void)	setNoiseFloorSetting:(int)aNoiseFloorSetting;
- (int)		initialMass;
- (void)	setInitialMass:(int)aInitialMass;
- (int)		finalMass;
- (void)	setFinalMass:(int)aFinalMass;

- (int)		elecMultHVBias;
- (void)	setElecMultHVBias:(int)aElecMultHVBias;

- (int)		ionizerFocusPlateVoltage;
- (void)	setIonizerFocusPlateVoltage:(int)aIonizerFocusPlateVoltage;
- (int)		ionizerIonEnergy;
- (void)	setIonizerIonEnergy:(int)aIonizerIonEnergy;
- (float)	ionizerEmissionCurrent;
- (void)	setIonizerEmissionCurrent:(float)aIonizerEmissionCurrent;
- (int)		ionizerElectronEnergy;
- (void)	setIonizerElectronEnergy:(int)aIonizerElectronEnergy;
- (int)		ionizerDegassTime;
- (void)	setIonizerDegassTime:(int)aIonizerDegassTime;

- (BOOL)    useIonizerDefaults;
- (void)    setUseIonizerDefaults:(BOOL)aState;
- (BOOL)    useDetectorDefaults;
- (void)    setUseDetectorDefaults:(BOOL)aState;

- (int)		rs232ErrWord;
- (int)		filErrWord;
- (int)		cemErrWord;
- (int)		qmfErrWord;
- (int)		detErrWord;
- (int)		psErrWord;
- (int)		statusWord;
- (int)		serialNumber;
- (float)	firmwareVersion;
- (int)		modelNumber;

- (void) dataReceived:(NSNotification*)note;

#pragma mark •••Commands
- (void) sendIDRequest;
- (void) queryAll;
- (void) syncWithHW;
- (void) sendIDRequest;
- (void) sendInitComm;
- (void) sendReset;	
- (void) sendStandBy;	
- (void) sendErrQuery;
- (void) sendRS232ErrQuery;
- (void) sendDetErrQuery; 
- (void) sendFilamentErrQuery; 
- (void) sendEMErrQuery; 
- (void) sendPowerErrQuery; 
- (void) sendQMFErrQuery; 
- (void) sendElecMultGainQuery;
- (void) sendSensitivityQuery;

- (void) sendElecMultiGain;
- (void) sendIonizerElectronEnergy;
- (void) sendIonizerIonEnergy;
- (void) sendIonizerFocusPlateVoltage;

- (void) sendCalibrateAll;
- (void) sendCalibrateElectrometerIVResponse;

- (void) startDegassing;
- (void) stopDegassing;

- (void) sendInitialMass;
- (void) sendFinalMass;
- (void) sendStepsPerAmu; 

- (void) sendStepsPerAmuQuery;
- (void) turnDetectorOff;
- (void) sendDetectorParameters;
- (void) turnIonizerOff;
- (void) sendIonizerParameters; 

- (void) startMeasurement;
- (void) stopMeasurement;

- (void) addAmu;
- (void) addAmu:(id)anAmu atIndex:(int)anIndex;
- (void) removeAmuAtIndex:(int) anIndex;
- (unsigned long) amuCount;
- (id) amuAtIndex:(int)anIndex;
- (void) replaceAmuAtIndex:(int)anIndex withAmu:(id)anObject;

#pragma mark •••Archival
- (id)   initWithCoder:(NSCoder*)decoder;
- (void) encodeWithCoder:(NSCoder*)encoder;


#pragma mark •••Scan Methods
- (int) numberPointsInScan;
- (int) scanValueAtIndex:(int)i;
- (int) countsInAmuTableData:(int)i;
- (int) amuTable:(int)anAmu valueAtIndex:(int)i;

#pragma mark •••Constraints
- (void) addFilamentConstraint:(NSString*)aName reason:(NSString*)aReason;
- (void) removeFilamentConstraint:(NSString*)aName;
- (void) addCEMConstraint:(NSString*)aName reason:(NSString*)aReason;
- (void) removeCEMConstraint:(NSString*)aName;
- (NSDictionary*)filamentConstraints;
- (NSDictionary*)cemConstraints;
- (NSString*) filamentConstraintReport;
- (NSString*) cemConstraintReport;
- (void) disableConstraints;
- (void) enableConstraints;
- (BOOL) constraintsDisabled;

@end

@interface ORRGA300Cmd : NSObject
{
	BOOL waitForResponse;
	BOOL dataExpected;
	unsigned long expectedDataLength;
	NSString* cmd;
}

@property (nonatomic,assign) BOOL waitForResponse;
@property (nonatomic,assign) BOOL dataExpected;
@property (nonatomic,assign) unsigned long expectedDataLength;
@property (nonatomic,copy) NSString* cmd;
@end

extern NSString* ORRGA300ModelSensitivityFactorChanged;
extern NSString* ORRGA300ModelScanDataChanged;
extern NSString* ORRGA300ModelScanNumberChanged;
extern NSString* ORRGA300ModelScanProgressChanged;
extern NSString* ORRGA300ModelCurrentActivityChanged;
extern NSString* ORRGA300ModelOpModeChanged;
extern NSString* ORRGA300ModelElecMultGainRBChanged;
extern NSString* ORRGA300ModelElecMultHVBiasRBChanged;
extern NSString* ORRGA300ModelNoiseFloorSettingRBChanged;
extern NSString* ORRGA300ModelIonizerFocusPlateVoltageRBChanged;
extern NSString* ORRGA300ModelIonizerIonEnergyRBChanged;
extern NSString* ORRGA300ModelIonizerElectronEnergyRBChanged;
extern NSString* ORRGA300ModelIonizerFilamentCurrentRBChanged;
extern NSString* ORRGA300ModelElecMultGainChanged;
extern NSString* ORRGA300ModelElectronMultiOptionChanged;
extern NSString* ORRGA300ModelMeasuredIonCurrentChanged;
extern NSString* ORRGA300ModelStepsPerAmuChanged;
extern NSString* ORRGA300ModelInitialMassChanged;
extern NSString* ORRGA300ModelFinalMassChanged;
extern NSString* ORRGA300ModelHistoScanPointsChanged;
extern NSString* ORRGA300ModelAnalogScanPointsChanged;
extern NSString* ORRGA300ModelNoiseFloorSettingChanged;
extern NSString* ORRGA300ModelElecMultHVBiasChanged;
extern NSString* ORRGA300ModelIonizerFocusPlateVoltageChanged;
extern NSString* ORRGA300ModelIonizerIonEnergyChanged;
extern NSString* ORRGA300ModelIonizerEmissionCurrentChanged;
extern NSString* ORRGA300ModelIonizerElectronEnergyChanged;
extern NSString* ORRGA300ModelIonizerDegassTimeChanged;
extern NSString* ORRGA300ModelRs232ErrWordChanged;
extern NSString* ORRGA300ModelFilErrWordChanged;
extern NSString* ORRGA300ModelCemErrWordChanged;
extern NSString* ORRGA300ModelQmfErrWordChanged;
extern NSString* ORRGA300ModelDetErrWordChanged;
extern NSString* ORRGA300ModelPsErrWordChanged;
extern NSString* ORRGA300ModelStatusWordChanged;
extern NSString* ORRGA300ModelSerialNumberChanged;
extern NSString* ORRGA300ModelFirmwareVersionChanged;
extern NSString* ORRGA300ModelModelNumberChanged;
extern NSString* ORRGA300ModelAmuAdded;
extern NSString* ORRGA300ModelAmuRemoved;
extern NSString* ORRGA300ModelCurrentAmuIndexChanged;
extern NSString* ORRGA300Lock;
extern NSString* ORRGA300ModelUseIonizerDefaultsChanged;
extern NSString* ORRGA300ModelUseDetectorDefaultsChanged;
extern NSString* ORRGA300ModelConstraintsChanged;
extern NSString* ORRGA300ConstraintsDisabledChanged;

