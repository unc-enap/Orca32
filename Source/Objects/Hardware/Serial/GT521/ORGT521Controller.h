//--------------------------------------------------------
// ORGT521Controller
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

@class ORCompositeTimeLineView;
@class ORSerialPortController;

@interface ORGT521Controller : OrcaObjectController
{
    IBOutlet NSTextField* lockDocField;
	IBOutlet NSTextField* probeAttachedTextField;
	IBOutlet NSTextField* correctionTypeTextField;
	IBOutlet NSTextField* usingCentigradeTextField;
	IBOutlet NSTextField* autoCountTextField;
	IBOutlet NSTextField* temperatureTextField;
	IBOutlet NSTextField* humidityTextField;
	IBOutlet NSTextField* locationField;
	IBOutlet NSTextField* countingModeTextField;
	IBOutlet NSTextField* count2TextField;
	IBOutlet NSTextField* count1TextField;
	IBOutlet NSTextField* size2TextField;
	IBOutlet NSTextField* size1TextField;
	IBOutlet NSTextField* measurementDateTextField;
	IBOutlet NSMatrix* valueAlarmLimitMatrix;
	IBOutlet NSMatrix* maxValueMatrix;

    IBOutlet NSButton*      lockButton;

	IBOutlet NSPopUpButton* cycleDurationPU;
    IBOutlet NSButton*      startCycleButton;
    IBOutlet NSButton*      stopCycleButton;
    IBOutlet NSTextField*   timeLeftInCycleField;
    IBOutlet NSTextField*   cycleNumberField;
	IBOutlet NSTextField*	cycleStartedField;
	
	IBOutlet ORCompositeTimeLineView*   plotter0;
    IBOutlet ORSerialPortController* serialPortController;
}

#pragma mark ***Initialization
- (id) init;
- (void) dealloc;
- (void) awakeFromNib;

#pragma mark ***Notifications
- (void) registerNotificationObservers;
- (void) updateWindow;

#pragma mark ***Interface Management
- (void) probeAttachedChanged:(NSNotification*)aNote;
- (void) correctionTypeChanged:(NSNotification*)aNote;
- (void) usingCentigradeChanged:(NSNotification*)aNote;
- (void) autoCountChanged:(NSNotification*)aNote;
- (void) temperatureChanged:(NSNotification*)aNote;
- (void) humidityChanged:(NSNotification*)aNote;
- (void) locationChanged:(NSNotification*)aNote;
- (void) valueAlarmLimitChanged:(NSNotification*)aNote;
- (void) maxValueChanged:(NSNotification*)aNote;
- (void) cycleNumberChanged:(NSNotification*)aNote;
- (void) cycleWillEndChanged:(NSNotification*)aNote;
- (void) cycleStartedChanged:(NSNotification*)aNote;
- (void) runningChanged:(NSNotification*)aNote;
- (void) cycleDurationChanged:(NSNotification*)aNote;
- (void) countingModeChanged:(NSNotification*)aNote;
- (void) count2Changed:(NSNotification*)aNote;
- (void) count1Changed:(NSNotification*)aNote;
- (void) size2Changed:(NSNotification*)aNote;
- (void) size1Changed:(NSNotification*)aNote;
- (void) measurementDateChanged:(NSNotification*)aNote;
- (void) updateButtons;
- (void) lockChanged:(NSNotification*)aNote;
- (void) updateTimePlot:(NSNotification*)aNotification;
- (void) scaleAction:(NSNotification*)aNotification;
- (void) miscAttributesChanged:(NSNotification*)aNotification;

#pragma mark ***Actions
- (IBAction) locationAction:(id)sender;
- (IBAction) lockAction:(id) sender;
- (IBAction) readRecordAction:(id)sender;
- (IBAction) cycleDurationAction:(id)sender;
- (IBAction) startCycleAction:(id)sender;
- (IBAction) stopCycleAction:(id)sender;
- (IBAction) valueAlarmLimitAction:(id)sender;
- (IBAction) maxValueAction:(id)sender;

#pragma mark ***Data Source
- (int) numberPointsInPlot:(id)aPlotter;
- (void) plotter:(id)aPlotter index:(int)i x:(double*)xValue y:(double*)yValue;
@end


