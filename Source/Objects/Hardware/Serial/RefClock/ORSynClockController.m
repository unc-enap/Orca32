//--------------------------------------------------------
// ORSynClockController
// Created by Mark  A. Howe on Fri Jul 22 2005 / Julius Hartmann, KIT, November 2017
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
//for the use of this softwarePulser.
//-------------------------------------------------------------

#pragma mark ***Imported Files

#import "ORSynClockController.h"
#import "ORSynClockModel.h"


@implementation ORSynClockController


- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [topLevelObjects release];
    
    [super dealloc];
}

#pragma mark ***Initialization

//- (id) init
//{
//    self = [super initWithWindowNibName:@"SynClock"];
//    return self;
//}

//- (void) awakeFromNib
//{
//   // [self populatePortListPopup];
//    [super awakeFromNib];
//}

- (void) awakeFromNib
{
    if(!deviceContent){
        if ([[NSBundle mainBundle] loadNibNamed:@"SynClock" owner:self  topLevelObjects:&topLevelObjects]){
            [topLevelObjects retain];
            
            [deviceView setContentView:deviceContent];
            //NSLog(@"Loaded SynClock.nib");
            [[self model] setStatusPoll:[statusPollCB state]];
            
        }
        else NSLog(@"Failed to load SynClock.nib");
    }
    return;
    //[self populatePortListPopup];
    //[super awakeFromNib];
}

- (id) model
{
    return model;
}
- (void) setModel:(ORSynClockModel*)aModel
{
    model = aModel;
    [self registerNotificationObservers];
    [self updateWindow];
}

#pragma mark ***Notifications

- (void) registerNotificationObservers
{
	NSNotificationCenter* notifyCenter = [NSNotificationCenter defaultCenter];
 
		[notifyCenter addObserver : self
		                 selector : @selector(trackModeChanged:)
		                     name : ORSynClockModelTrackModeChanged
                            object: model];

		 [notifyCenter addObserver : self
                          selector : @selector(syncChanged:)
                              name : ORSynClockModelSyncChanged
                             object: model];

		 [notifyCenter addObserver : self
                          selector : @selector(alarmWindowChanged:)
                              name : ORSynClockModelAlarmWindowChanged
                             object: model];

        [notifyCenter addObserver : self
                     selector : @selector(statusChanged:)
                         name : ORSynClockModelStatusChanged
					object: model];

		[notifyCenter addObserver : self
                     selector : @selector(statusPollChanged:)
                         name : ORSynClockModelStatusPollChanged
            					object: self]; //	object: model];


		// [notifyCenter addObserver : self  // todo: not needed/ only output (input deactivated)
		// 								 selector : @selector(statusOutputChanged:)
		// 										 name : ORSynClockModelStatusOutputChanged
		// 				object: model];

		[notifyCenter addObserver : self
						         selector : @selector(deviceIDButtonChanged:)
						             name : ORSynClockModelDeviceIDButtonChanged
					 			object: model];

		[notifyCenter addObserver : self  // todo: not needed/ only output (input deactivated)
                         selector : @selector(resetChanged:)
                             name : ORSynClockModelResetChanged
                            object: model];
    
        [notifyCenter addObserver : self
                     selector : @selector(statusMessageChanged:)
                         name : ORSynClockStatusUpdated 
                        object: nil];

}

- (void) updateWindow
{
   // [super updateWindow];
   [self lockChanged:nil];
    
	// [self statusChanged:nil];
	// [self syncChanged:nil];
	// [self trackModeChanged:nil];
}

- (void) setButtonStates
{
    //BOOL runInProgress = [gOrcaGlobals runInProgress];
    BOOL lockedOrRunningMaintenance = [gSecurity runInProgressButNotType:eMaintenanceRunType orIsLocked:ORRefClockLock];
    //BOOL locked = [gSecurity isLocked:ORRefClockLock];
    BOOL portOpen = [model portIsOpen];

    [trackModePU setEnabled:!lockedOrRunningMaintenance && portOpen];
    [syncPU setEnabled:!lockedOrRunningMaintenance && portOpen];
    [alarmWindowField setEnabled:!lockedOrRunningMaintenance && portOpen];
    [statusButton setEnabled:!lockedOrRunningMaintenance && portOpen];
    [statusPollCB setEnabled:!lockedOrRunningMaintenance && portOpen];
    [deviceIDButton setEnabled:!lockedOrRunningMaintenance && portOpen];
    [resetButton setEnabled:!lockedOrRunningMaintenance && portOpen];
}
- (void) trackModeChanged:(NSNotification*)aNote
{
}

- (void) syncChanged:(NSNotification*)aNote
{
}

- (void) alarmWindowChanged:(NSNotification*)aNote
{
}

- (void) statusChanged:(NSNotification*)aNote
{
}

- (void) statusPollChanged:(NSNotification*)aNote

{
}

- (void) deviceIDButtonChanged:(NSNotification*)aNote
{

}

- (void) resetChanged:(NSNotification*)aNote
{

}


- (void) lockChanged:(NSNotification*)aNotification  // todo
{
    [self setButtonStates];
}


- (void) statusMessageChanged:(NSNotification*)aNote{
    NSLog(@"statusMessageChanged!! updating... \n");
    [statusOutputField setStringValue:[model statusMessages]];
    
}

#pragma mark ***Actions

- (void) trackModeAction:(id)sender
{

}

- (void) syncAction:(id)sender
{

}

- (void) alarmWindowAction:(id)sender
{

}

- (void) statusAction:(id)sender
{
  [model requestStatus];
}

- (void) statusPollAction:(id)sender
{
    [model setStatusPoll:[sender intValue]]; 
    // todo: activate / deactivate timer

}

- (void) deviceIDAction:(id)sender
{

}

- (void) resetAction:(id)sender
{

}


// - (void) frequencyAction:(id)sender
// {
// 	[model setFrequency:[sender floatValue]];
// }
//
// - (void) dutyCycleAction:(id)sender
// {
// 	[model setDutyCycle:[sender intValue]];
// }
//
// - (void) amplitudeAction:(id)sender
// {
// 	[model setAmplitude:[sender floatValue]];
// }
//
// - (void) signalFormAction:(id)sender
// {
// 	[model setSignalForm:[sender indexOfSelectedItem]];
// }


//- (IBAction) portListAction:(id) sender
//{
//    [model setPortName: [portListPopup titleOfSelectedItem]];
//}

- (IBAction) openPortAction:(id)sender
{
    //[model openPort:![[model serialPort] isOpen]];
}
//
// - (IBAction) loadAmpAction:(id)sender
// {
// 	[model commitAmplitude];
// }
//
// - (IBAction) signalFileAction:(id)sender
// {
// 	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
//     [openPanel setPrompt:@"Waveform File"];
//
//     NSString* startingDir;
//     NSString* defaultFile;
//
// 	NSString* fullPath = [model waveformFile];
//     if(fullPath){
//         startingDir = [fullPath stringByDeletingLastPathComponent];
//         defaultFile = [fullPath lastPathComponent];
//     }
//     else {
//         startingDir = NSHomeDirectory();
//         defaultFile = @"Waveform.ktf";
//     }
//
//     [openPanel setDirectoryURL:[NSURL fileURLWithPath:startingDir]];
//     [openPanel setNameFieldLabel:defaultFile];
//     [openPanel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result){
// 				if(result == NSModalResponseOK){
// 				[model setWaveformFile:[[openPanel URL] path]];
// 				NSLog(@"File path: %@ \n", [model waveformFile]);
// 				[self loadWaveAction];
// 			}
//     }];
//
// }
//
// - (void) loadWaveAction
// {
// 	if([model verbose]){
// 		NSLog(@"loadWaveAction.. \n");
// 	}
// 	[model loadValuesFromFile];
// 	[model commitWaveform];
// }

- (IBAction) lockAction:(id) sender
{
    //[gSecurity tryToSetLock:ORSynClockLock to:[sender intValue] forWindow:[self window]];
}

- (IBAction) verboseAction:(id)sender;
{
	//[model setVerbose:[sender intValue]];
}

@end


