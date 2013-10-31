//--------------------------------------------------------
// ORGT521Controller
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

@class ORCompositeTimeLineView;
@class ORSerialPortController;

@interface ORGT521Controller : OrcaObjectController
{
    IBOutlet NSTextField* lockDocField;
	IBOutlet   NSTextField* temperatureTextField;
	IBOutlet   NSTextField* humidityTextField;
	IBOutlet NSTextField* locationField;
	IBOutlet NSTextField* countAlarmLimitTextField;
	IBOutlet NSTextField* maxCountsTextField;
	IBOutlet NSTextField* countingModeTextField;
	IBOutlet NSTextField* count2TextField;
	IBOutlet NSTextField* count1TextField;
	IBOutlet NSTextField* size2TextField;
	IBOutlet NSTextField* size1TextField;
	IBOutlet NSTextField* measurementDateTextField;

    IBOutlet NSButton*      lockButton;
    IBOutlet NSTextField*   timeField;

	IBOutlet NSPopUpButton* cycleDurationPU;
    IBOutlet NSButton*      startCycleButton;
    IBOutlet NSButton*      stopCycleButton;
    IBOutlet NSTextField*   timeLeftInCycleField;
    IBOutlet NSTextField*   cycleNumberField;
	IBOutlet NSTextField*	cycleStartedField;
	IBOutlet NSTextField*	runningTextField;
	
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
- (void) temperatureChanged:(NSNotification*)aNote;
- (void) humidityChanged:(NSNotification*)aNote;
- (void) locationChanged:(NSNotification*)aNote;
- (void) countAlarmLimitChanged:(NSNotification*)aNote;
- (void) maxCountsChanged:(NSNotification*)aNote;
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
- (IBAction) countAlarmLimitTextFieldAction:(id)sender;
- (IBAction) maxCountsTextFieldAction:(id)sender;
- (IBAction) lockAction:(id) sender;
- (IBAction) readRecordAction:(id)sender;
- (IBAction) clearBufferAction:(id)sender;
- (IBAction) cycleDurationAction:(id)sender;
- (IBAction) startCycleAction:(id)sender;
- (IBAction) stopCycleAction:(id)sender;


#pragma mark ***Data Source
- (int) numberPointsInPlot:(id)aPlotter;
- (void) plotter:(id)aPlotter index:(int)i x:(double*)xValue y:(double*)yValue;
@end


