//--------------------------------------------------------
// ORCP8CryopumpController
// Created by Mark Howe Tuesday, March 20,2012
// Code partially generated by the OrcaCodeWizard. Written by Mark A. Howe.
// Copyright (c) 2012, University of North Carolina. All rights reserved.
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

@class ORCompositePlotView;
@class BiStateView;
@class ORSerialPortController;

@interface ORCP8CryopumpController : OrcaObjectController
{
    IBOutlet NSTextField*	lockDocField;
	IBOutlet NSTabView*		tabView;	
	IBOutlet NSView*		totalView;
	IBOutlet NSTextField*	firstStageControlMethodRBField;
	IBOutlet NSPopUpButton* roughingInterlockPU;
    IBOutlet NSButton*      lockButton;
	IBOutlet NSPopUpButton*	standbyModePU;
	IBOutlet NSTextField*	repurgeTimeField;
	IBOutlet NSTextField*	pumpsPerCompressorField;
	IBOutlet NSTextField*	roughingInterlockStatusField;
	IBOutlet NSTextField*	roughingInterlockStatusField1;
	IBOutlet NSTextField*	roughingInterlockStatusField2;
	IBOutlet NSTextField*	restartTemperatureField;
	IBOutlet NSTextField*	rateOfRiseCyclesField;
	IBOutlet NSTextField*	rateOfRiseField;
	IBOutlet NSTextField*	roughToPressureField;
	IBOutlet NSTextField*	repurgeCyclesField;
	IBOutlet NSTextField*	extendedPurgeTimeField;
	IBOutlet NSTextField*	pumpRestartDelayField;
	IBOutlet NSTextField*	thermocouplePressureField;
	IBOutlet NSTextField*	roughValveInterlockField;
	IBOutlet NSTextField*	regenerationTimeField;
	IBOutlet NSTextField*	regenerationStepTimerField;
	IBOutlet NSTextField*	regenerationStartDelayField;
	IBOutlet NSTextField*	regenerationSequenceField;
	IBOutlet NSTextField*	regenerationErrorField;
	IBOutlet NSTextField*	regenerationCyclesField;
	IBOutlet NSTextField*	powerFailureRecoveryStatusField;
	IBOutlet NSPopUpButton* powerFailureRecoveryPU;
	IBOutlet NSTextField*	moduleVersionField;
	IBOutlet NSTextField*	lastRateOfRaiseField;
	IBOutlet NSPopUpButton* firstStageControlMethodPU;
	
	IBOutlet NSTextField*	firstStageControlTempField;
	IBOutlet NSTextField*	secondStageTempControlField;
	
	IBOutlet NSTextField*	failedRepurgeCyclesField;
	IBOutlet NSTextField*	failedRateRiseCyclesField;
	IBOutlet NSTextField*	elapsedTimeField;
	IBOutlet NSTextField*	dutyCycleField;
	IBOutlet NSButton*		shipTemperaturesButton;
    IBOutlet NSButton*		initHardwareButton;
    IBOutlet NSPopUpButton* pollTimePopup;
    IBOutlet NSButton*      pollNowButton;
	IBOutlet ORCompositePlotView*    plotter0;
    IBOutlet NSTextField*   cmdErrorField;
    IBOutlet NSTextField*   wasPowerFailureField;

	IBOutlet NSTextField*	firstStageTempField;
	IBOutlet NSTextField*	secondStageTempField;
	IBOutlet NSTextField*   timeField;

	IBOutlet NSButton*      pumpOnButton;
	IBOutlet NSButton*      pumpOffButton;
	IBOutlet NSTextField*	pumpStatusField;

	IBOutlet NSButton*      purgeOnButton;
	IBOutlet NSButton*      purgeOffButton;
	IBOutlet NSTextField*	purgeStatusField;

	IBOutlet NSButton*      roughingValveOpenButton;
	IBOutlet NSButton*      roughingValveClosedButton;
	IBOutlet NSTextField*	roughValveStatusField;

	IBOutlet NSButton*      thermocoupleOnButton;
	IBOutlet NSButton*      thermocoupleOffButton;
	IBOutlet NSTextField*	thermocoupleStatusField;
	
	
	IBOutlet NSButton*      regenAbortButton;
	IBOutlet NSButton*      regenStartFullButton;
	IBOutlet NSButton*      regenStartFastButton;
	IBOutlet NSButton*      regenActivateNormalPumpingButton;
	IBOutlet NSButton*      regenWarmAndStopButton;
	
	IBOutlet NSButton*      roughValveInterlockButton;
	IBOutlet BiStateView*   pumpOnBiStateView;
	IBOutlet BiStateView*   roughOpenBiStateView;
	IBOutlet BiStateView*   purgeOpenBiStateView;
	IBOutlet BiStateView*   thermocoupleOnBiStateView;
	IBOutlet BiStateView*   powerFailureOccurredBiStateView;
    IBOutlet ORSerialPortController* serialPortController;
	
	IBOutlet NSImageView*   powerConstraintImage;
	IBOutlet NSImageView*   purgeConstraintImage;
	IBOutlet NSImageView*   roughingConstraintImage;
	IBOutlet NSPanel*		constraintPanel;
	IBOutlet NSTextField*   constraintTitleField;
	IBOutlet NSTextView*    constraintView;

	NSSize					basicOpsSize;
	NSSize					expertOpsSize;
	NSSize					plotSize;
	NSView*					blankView;
}

#pragma mark ***Initialization
- (id) init;
- (void) dealloc;
- (void) awakeFromNib;

#pragma mark ***Notifications
- (void) registerNotificationObservers;
- (void) updateWindow;

#pragma mark ***Interface Management
- (void) constraintsChanged:(NSNotification*)aNote;
- (void) firstStageControlMethodRBChanged:(NSNotification*)aNote;
- (void) wasPowerFailureChanged:(NSNotification*)aNote;
- (void) cmdErrorChanged:(NSNotification*)aNote;
- (void) secondStageTempControlChanged:(NSNotification*)aNote;
- (void) roughingInterlockChanged:(NSNotification*)aNote;
- (void) standbyModeChanged:(NSNotification*)aNote;
- (void) repurgeTimeChanged:(NSNotification*)aNote;
- (void) pumpsPerCompressorChanged:(NSNotification*)aNote;
- (void) roughingInterlockStatusChanged:(NSNotification*)aNote;
- (void) restartTemperatureChanged:(NSNotification*)aNote;
- (void) rateOfRiseCyclesChanged:(NSNotification*)aNote;
- (void) rateOfRiseChanged:(NSNotification*)aNote;
- (void) roughToPressureChanged:(NSNotification*)aNote;
- (void) repurgeCyclesChanged:(NSNotification*)aNote;
- (void) extendedPurgeTimeChanged:(NSNotification*)aNote;
- (void) pumpRestartDelayChanged:(NSNotification*)aNote;
- (void) thermocouplePressureChanged:(NSNotification*)aNote;
- (void) thermocoupleStatusChanged:(NSNotification*)aNote;
- (void) statusChanged:(NSNotification*)aNote;
- (void) secondStageTempChanged:(NSNotification*)aNote;
- (void) roughValveInterlockChanged:(NSNotification*)aNote;
- (void) roughValveStatusChanged:(NSNotification*)aNote;
- (void) regenerationTimeChanged:(NSNotification*)aNote;
- (void) regenerationStepTimerChanged:(NSNotification*)aNote;
- (void) regenerationStartDelayChanged:(NSNotification*)aNote;
- (void) regenerationSequenceChanged:(NSNotification*)aNote;
- (void) regenerationErrorChanged:(NSNotification*)aNote;
- (void) regenerationCyclesChanged:(NSNotification*)aNote;
- (void) purgeStatusChanged:(NSNotification*)aNote;
- (void) pumpStatusChanged:(NSNotification*)aNote;
- (void) powerFailureRecoveryStatusChanged:(NSNotification*)aNote;
- (void) powerFailureRecoveryChanged:(NSNotification*)aNote;
- (void) moduleVersionChanged:(NSNotification*)aNote;
- (void) lastRateOfRaiseChanged:(NSNotification*)aNote;
- (void) firstStageControlMethodChanged:(NSNotification*)aNote;
- (void) firstStageControlTempChanged:(NSNotification*)aNote;
- (void) firstStageTempChanged:(NSNotification*)aNote;
- (void) failedRepurgeCyclesChanged:(NSNotification*)aNote;
- (void) failedRateRiseCyclesChanged:(NSNotification*)aNote;
- (void) elapsedTimeChanged:(NSNotification*)aNote;
- (void) dutyCycleChanged:(NSNotification*)aNote;
- (void) updateTimePlot:(NSNotification*)aNote;
- (void) scaleAction:(NSNotification*)aNote;
- (void) shipTemperaturesChanged:(NSNotification*)aNote;
- (void) lockChanged:(NSNotification*)aNote;
- (void) pollTimeChanged:(NSNotification*)aNote;
- (void) miscAttributesChanged:(NSNotification*)aNote;
- (void) scaleAction:(NSNotification*)aNote;
- (void) tabView:(NSTabView *)aTabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem;
- (void) windowDidResize:(NSNotification *)aNote;
- (void) updateButtons;
- (BOOL) portLocked;

#pragma mark ***Actions
- (void) beginConstraintPanel:(NSDictionary*)constraints actionTitle:(NSString*)aTitle;
- (IBAction) closeConstraintPanel:(id)sender;
- (IBAction) secondStageTempControlAction:(id)sender;
- (IBAction) standbyModeAction:(id)sender;
- (IBAction) repurgeTimeAction:(id)sender;
- (IBAction) pumpsPerCompressorAction:(id)sender;
- (IBAction) restartTemperatureAction:(id)sender;
- (IBAction) rateOfRiseCyclesAction:(id)sender;
- (IBAction) rateOfRiseAction:(id)sender;
- (IBAction) roughToPressureAction:(id)sender;
- (IBAction) repurgeCyclesAction:(id)sender;
- (IBAction) extendedPurgeTimeAction:(id)sender;
- (IBAction) pumpRestartDelayAction:(id)sender;
- (IBAction) statusAction:(id)sender;
- (IBAction) roughValveInterlockAction:(id)sender;
- (IBAction) roughValveStatusAction:(id)sender;
- (IBAction) regenerationStartDelayAction:(id)sender;
- (IBAction) powerFailureRecoveryAction:(id)sender;
- (IBAction) firstStageControlMethodAction:(id)sender;
- (IBAction) firstStageControlTempAction:(id)sender;
- (IBAction) initHardwareAction:(id)sender;
- (IBAction) shipTemperaturesAction:(id)sender;
- (IBAction) lockAction:(id) sender;
- (IBAction) pollTimeAction:(id)sender;
- (IBAction) pollNowAction:(id)sender;
- (IBAction) roughingInterlockAction:(id)sender;

- (IBAction) turnCryoPumpOnAction:(id)sender;
- (IBAction) turnCryoPumpOffAction:(id)sender;
- (void) turnOnCryoPumpDidFinish:(id)sheet returnCode:(int)returnCode contextInfo:(id)userInfo;
- (void) turnOffCryoPumpDidFinish:(id)sheet returnCode:(int)returnCode contextInfo:(id)userInfo;

- (IBAction) openPurgeValveAction:(id)sender;
- (IBAction) closePurgeValveAction:(id)sender;
- (void) openPurgeValveDidFinish:(id)sheet returnCode:(int)returnCode contextInfo:(id)userInfo;
- (void) closePurgeValveDidFinish:(id)sheet returnCode:(int)returnCode contextInfo:(id)userInfo;

- (IBAction) openRoughingValveAction:(id)sender;
- (IBAction) closeRoughingValveAction:(id)sender;
- (void) openRoughingValveDidFinish:(id)sheet returnCode:(int)returnCode contextInfo:(id)userInfo;
- (void) closeRoughingValveDidFinish:(id)sheet returnCode:(int)returnCode contextInfo:(id)userInfo;

- (IBAction) turnThermocoupleOnAction:(id)sender;
- (IBAction) turnThermocoupleOffAction:(id)sender;
- (void) turnOnThermocoupleDidFinish:(id)sheet returnCode:(int)returnCode contextInfo:(id)userInfo;
- (void) turnOffThermocoupleDidFinish:(id)sheet returnCode:(int)returnCode contextInfo:(id)userInfo;


- (int) numberPointsInPlot:(id)aPlotter;
- (void) plotter:(id)aPlotter index:(int)i x:(double*)xValue y:(double*)yValue;
@end


