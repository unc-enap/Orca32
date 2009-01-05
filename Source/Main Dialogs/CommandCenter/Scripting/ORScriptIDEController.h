//-------------------------------------------------------------------------
//  ORScriptIDEController.h
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

@class ORTimedTextField;
@class ORScriptView;

@interface ORScriptIDEController : OrcaObjectController {
	IBOutlet NSButton*			breakChainButton;
	IBOutlet ORTimedTextField*	statusField;
	IBOutlet NSTextView*		commentsView;
	IBOutlet NSButton*			showSuperClassButton;
	IBOutlet NSTextField*		nameField;
	IBOutlet NSTextField*		runStatusField;
	IBOutlet ORScriptView*		scriptView;
	IBOutlet NSButton*			checkButton;
	IBOutlet NSButton*			runButton;
	IBOutlet NSMatrix*			argsMatrix;
	IBOutlet id					loadSaveView;
	IBOutlet NSButton*			loadSaveButton;
	IBOutlet NSTextView*		helpView;
	IBOutlet NSDrawer*			helpDrawer;
	IBOutlet NSDrawer*			debuggerDrawer;
    IBOutlet NSTextField*		classNameField;
    IBOutlet NSTextField*		lastFileField;
    IBOutlet NSTextField*		lastFileField1;
	IBOutlet NSTableView*		inputVariablesTableView;
	IBOutlet NSTableView*		debuggerTableView;
	IBOutlet NSButton*			addInputButton;
	IBOutlet NSButton*			removeInputButton;
    IBOutlet NSButton*			lockButton;
    IBOutlet NSTextField*		debugStatusField;
	IBOutlet NSButton*			pauseButton;
	IBOutlet NSButton*			stepButton;
	IBOutlet NSButton*			stepInButton;
	IBOutlet NSButton*			stepOutButton;
	IBOutlet NSPopUpButton*		codeHelperPU;
}

#pragma mark •••Initialization
- (id)   init;
- (void) registerNotificationObservers;
- (void) updateWindow;

#pragma mark •••Interface Management
- (void) breakChainChanged:(NSNotification*)aNote;
- (void) breakpointsChanged:(NSNotification*)aNote;
- (void) commentsChanged:(NSNotification*)aNote;
- (void) tableViewSelectionDidChange:(NSNotification *)aNote;
- (void) showSuperClassChanged:(NSNotification*)aNote;
- (void) scriptChanged:(NSNotification*)aNote;
- (void) runningChanged:(NSNotification*)aNote;
- (void) nameChanged:(NSNotification*)aNote;
- (void) textDidChange:(NSNotification*)aNote;
- (void) errorChanged:(NSNotification*)aNote;
- (void) lastFileChanged:(NSNotification*)aNote;
- (void) lockChanged:(NSNotification*)aNote;
- (void) debuggingChanged:(NSNotification*)aNote;
- (void) debuggerStateChanged:(NSNotification*)aNote;

#pragma mark •••Actions
- (IBAction) clearAllBreakpoints:(id) sender;
- (IBAction) breakChainAction:(id) sender;
- (IBAction) debuggerAction:(id)sender;
- (IBAction) lockAction:(id)sender;
- (IBAction) showSuperClassAction:(id)sender;
- (IBAction) listMethodsAction:(id) sender;
- (IBAction) cancelLoadSaveAction:(id)sender;
- (IBAction) loadSaveAction:(id)sender;
- (IBAction) parseScript:(id) sender;
- (IBAction) runScript:(id) sender;
- (IBAction) nameAction:(id) sender;
- (IBAction) loadFileAction:(id) sender;
- (IBAction) saveAsFileAction:(id) sender;
- (IBAction) saveFileAction:(id) sender;
- (IBAction) addInput:(id)sender;
- (IBAction) removeInput:(id)sender;
- (IBAction) stepScript:(id) sender;
- (IBAction) stepIn:(id) sender;
- (IBAction) stepOut:(id) sender;
- (IBAction) pauseScript:(id) sender;
- (IBAction) insertCode:(id) sender;

@end
