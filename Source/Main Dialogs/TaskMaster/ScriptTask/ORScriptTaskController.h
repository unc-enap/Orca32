//-------------------------------------------------------------------------
//  ORScriptTaskController.h
//
//  Created by Mark A. Howe on Tuesday 12/26/2006.
//  Copyright (c) 2006 CENPA, University of Washington. All rights reserved.
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

//-------------------------------------------------------------------------

#pragma mark ***Imported Files
#import <Cocoa/Cocoa.h>
#import "OrcaObjectController.h";

@class ORTimedTextField;
@class ORScriptView;

@interface ORScriptTaskController : OrcaObjectController {
	IBOutlet ORTimedTextField*	statusField;
	IBOutlet NSButton*			showSuperClassButton;
	IBOutlet NSTextField*		nameField;
	IBOutlet NSTextField*		runStatusField;
	IBOutlet ORScriptView*		scriptView;
	IBOutlet NSButton*			checkButton;
	IBOutlet NSButton*			runButton;
	IBOutlet NSMatrix*			argsMatrix;
	IBOutlet NSView*			argsView;
	IBOutlet NSView*			panelView;
	IBOutlet NSButton*			breakChainButton;
	IBOutlet id					loadSaveView;
	IBOutlet NSButton*			loadSaveButton;
	IBOutlet NSTextView*		helpView;
	IBOutlet NSDrawer*			helpDrawer;
    IBOutlet NSTextField*		classNameField;
    IBOutlet NSTextField*		lastFileField;
    IBOutlet NSTextField*		lastFileField1;
}

#pragma mark ¥¥¥Initialization
- (id)   init;
- (void) registerNotificationObservers;
- (void) updateWindow;

#pragma mark ¥¥¥Interface Management
- (void) showSuperClassChanged:(NSNotification*)aNote;
- (void) scriptChanged:(NSNotification*)aNote;
- (void) runningChanged:(NSNotification*)aNote;
- (void) nameChanged:(NSNotification*)aNote;
- (void) textDidChange:(NSNotification*)aNote;
- (void) argsChanged:(NSNotification*)aNote;
- (void) breakChainChanged:(NSNotification*)aNote;
- (void) errorChanged:(NSNotification*)aNote;
- (void) lastFileChanged:(NSNotification*)aNote;

#pragma mark ¥¥¥Actions
- (IBAction) showSuperClassAction:(id)sender;
- (IBAction) listMethodsAction:(id) sender;
- (IBAction) cancelLoadSaveAction:(id)sender;
- (IBAction) loadSaveAction:(id)sender;
- (IBAction) parseScript:(id) sender;
- (IBAction) runScript:(id) sender;
- (IBAction) nameAction:(id) sender;
- (IBAction) argAction:(id) sender;
- (IBAction) loadFileAction:(id) sender;
- (IBAction) saveAsFileAction:(id) sender;
- (IBAction) saveFileAction:(id) sender;
- (IBAction) breakChainAction:(id) sender;

@end
