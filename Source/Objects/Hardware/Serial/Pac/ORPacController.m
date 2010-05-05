//--------------------------------------------------------
// ORPacController
// Created by Mark  A. Howe on Tue Jan 6, 2009
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

#pragma mark •••Imported Files

#import "ORPacController.h"
#import "ORPacModel.h"
#import "ORTimeLinePlot.h"
#import "ORPlotView.h"
#import "ORTimeAxis.h"
#import "ORSerialPortList.h"
#import "ORSerialPort.h"
#import "ORTimeRate.h"

@interface ORPacController (private)
- (void) populatePortListPopup;
- (void) selectLogFileDidEnd:(NSOpenPanel *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo;
@end

@implementation ORPacController

#pragma mark •••Initialization

- (id) init
{
	self = [super initWithWindowNibName:@"Pac"];
	return self;
}

- (void) dealloc
{
	[super dealloc];
}

- (void) awakeFromNib
{
		
    [self populatePortListPopup];
	NSNumberFormatter *numberFormatter = [[[NSNumberFormatter alloc] init] autorelease];
	[numberFormatter setFormat:@"0.00"];
	int i;
	for(i=0;i<8;i++){
		NSCell* theCell = [adcMatrix cellAtRow:i column:0];
		[theCell setFormatter:numberFormatter];
	}
	
	[[plotter0 yScale] setRngLow:0.0 withHigh:6.];
	[[plotter0 yScale] setRngLimitsLow:0.0 withHigh:6. withMinRng:1];
    [[plotter1 yScale] setRngLow:0.0 withHigh:6.];
	[[plotter1 yScale] setRngLimitsLow:0.0 withHigh:6. withMinRng:1];
	[[plotter0 yScale] setInteger:NO];
	[[plotter1 yScale] setInteger:NO];
	
    [[plotter0 xScale] setRngLow:0.0 withHigh:10000];
	[[plotter0 xScale] setRngLimitsLow:0.0 withHigh:200000. withMinRng:50];
    [[plotter1 xScale] setRngLow:0.0 withHigh:10000];
	[[plotter1 xScale] setRngLimitsLow:0.0 withHigh:200000. withMinRng:50];

	NSColor* color[4] = {
		[NSColor redColor],
		[NSColor greenColor],
		[NSColor blueColor],
		[NSColor brownColor],
	};

	for(i=0;i<4;i++){
		ORTimeLinePlot* aPlot = [[ORTimeLinePlot alloc] initWithTag:i andDataSource:self];
		[plotter0 addPlot: aPlot];
		[aPlot setLineColor:color[i]];
		[(ORTimeAxis*)[plotter0 xScale] setStartTime: [[NSDate date] timeIntervalSince1970]];
		[aPlot release];
	}
	for(i=0;i<4;i++){
		ORTimeLinePlot* aPlot = [[ORTimeLinePlot alloc] initWithTag:i+4 andDataSource:self];
		[plotter1 addPlot: aPlot];
		[aPlot setLineColor:color[i]];
		[(ORTimeAxis*)[plotter1 xScale] setStartTime: [[NSDate date] timeIntervalSince1970]];
		[aPlot release];
	}
	
	[super awakeFromNib];
}

#pragma mark •••Notifications

- (void) registerNotificationObservers
{
	NSNotificationCenter* notifyCenter = [NSNotificationCenter defaultCenter];
    [super registerNotificationObservers];
	
    [notifyCenter addObserver : self
                     selector : @selector(pollingStateChanged:)
                         name : ORPacModelPollingStateChanged
						object: model];
	
    [notifyCenter addObserver : self
                     selector : @selector(lockChanged:)
                         name : ORRunStatusChangedNotification
                       object : nil];
    
    [notifyCenter addObserver : self
                     selector : @selector(lockChanged:)
                         name : ORPacLock
                        object: nil];

    [notifyCenter addObserver : self
                     selector : @selector(portNameChanged:)
                         name : ORPacModelPortNameChanged
                        object: nil];

    [notifyCenter addObserver : self
                     selector : @selector(portStateChanged:)
                         name : ORSerialPortStateChanged
                       object : nil];
                                              
    [notifyCenter addObserver : self
                     selector : @selector(adcChanged:)
                         name : ORPacModelAdcChanged
                       object : nil];
		
    [notifyCenter addObserver : self
                     selector : @selector(dacValueChanged:)
                         name : ORPacModelDacValueChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(moduleChanged:)
                         name : ORPacModelModuleChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(preAmpChanged:)
                         name : ORPacModelPreAmpChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(lcmEnabledChanged:)
                         name : ORPacModelLcmEnabledChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(rdacChannelChanged:)
                         name : ORPacModelRdacChannelChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(setAllRDacsChanged:)
                         name : ORPacModelSetAllRDacsChanged
						object: model];
	
    [notifyCenter addObserver : self
                     selector : @selector(rdacsChanged:)
                         name : ORPacModelRDacsChanged
						object: model];
	
    [notifyCenter addObserver : self
                     selector : @selector(logToFileChanged:)
                         name : ORPacModelLogToFileChanged
						object: model];
	
    [notifyCenter addObserver : self
                     selector : @selector(logFileChanged:)
                         name : ORPacModelLogFileChanged
						object: model];
	
	[notifyCenter addObserver : self
					 selector : @selector(scaleAction:)
						 name : ORAxisRangeChangedNotification
					   object : nil];
	
    [notifyCenter addObserver : self
					 selector : @selector(miscAttributesChanged:)
						 name : ORMiscAttributesChanged
					   object : model];
	
    [notifyCenter addObserver : self
					 selector : @selector(updateTimePlot:)
						 name : ORRateAverageChangedNotification
					   object : nil];
	
    [notifyCenter addObserver : self
					 selector : @selector(queCountChanged:)
						 name : ORPacModelQueCountChanged
					   object : model];	
}

- (void) setModel:(id)aModel
{
	[super setModel:aModel];
	[[self window] setTitle:[NSString stringWithFormat:@"Power and Control (Unit %d)",[model uniqueIdNumber]]];
}

- (void) updateWindow
{
    [super updateWindow];
    [self lockChanged:nil];
    [self portStateChanged:nil];
    [self portNameChanged:nil];
	[self adcChanged:nil];
	[self dacValueChanged:nil];
	[self moduleChanged:nil];
	[self preAmpChanged:nil];
	[self lcmEnabledChanged:nil];
	[self rdacChannelChanged:nil];
	[self setAllRDacsChanged:nil];
	[self rdacsChanged:nil];
    [self pollingStateChanged:nil];
	[self logToFileChanged:nil];
	[self logFileChanged:nil];
    [self pollingStateChanged:nil];
    [self miscAttributesChanged:nil];
	[self queCountChanged:nil];
}

- (void) scaleAction:(NSNotification*)aNotification
{
	if(aNotification == nil || [aNotification object] == [plotter0 xScale]){
		[model setMiscAttributes:[(ORAxis*)[plotter0 xScale]attributes] forKey:@"XAttributes0"];
	};
	
	if(aNotification == nil || [aNotification object] == [plotter0 yScale]){
		[model setMiscAttributes:[(ORAxis*)[plotter0 yScale]attributes] forKey:@"YAttributes0"];
	};
	
	if(aNotification == nil || [aNotification object] == [plotter1 xScale]){
		[model setMiscAttributes:[(ORAxis*)[plotter1 xScale]attributes] forKey:@"XAttributes1"];
	};
	
	if(aNotification == nil || [aNotification object] == [plotter1 yScale]){
		[model setMiscAttributes:[(ORAxis*)[plotter1 yScale]attributes] forKey:@"YAttributes1"];
	};
}
- (void) miscAttributesChanged:(NSNotification*)aNote
{
	
	NSString*				key = [[aNote userInfo] objectForKey:ORMiscAttributeKey];
	NSMutableDictionary* attrib = [model miscAttributesForKey:key];
	
	if(aNote == nil || [key isEqualToString:@"XAttributes0"]){
		if(aNote==nil)attrib = [model miscAttributesForKey:@"XAttributes0"];
		if(attrib){
			[(ORAxis*)[plotter0 xScale] setAttributes:attrib];
			[plotter0 setNeedsDisplay:YES];
			[[plotter0 xScale] setNeedsDisplay:YES];
		}
	}
	if(aNote == nil || [key isEqualToString:@"YAttributes0"]){
		if(aNote==nil)attrib = [model miscAttributesForKey:@"YAttributes0"];
		if(attrib){
			[(ORAxis*)[plotter0 yScale] setAttributes:attrib];
			[plotter0 setNeedsDisplay:YES];
			[[plotter0 yScale] setNeedsDisplay:YES];
		}
	}
	
	if(aNote == nil || [key isEqualToString:@"XAttributes1"]){
		if(aNote==nil)attrib = [model miscAttributesForKey:@"XAttributes1"];
		if(attrib){
			[(ORAxis*)[plotter1 xScale] setAttributes:attrib];
			[plotter1 setNeedsDisplay:YES];
			[[plotter1 xScale] setNeedsDisplay:YES];
		}
	}
	if(aNote == nil || [key isEqualToString:@"YAttributes1"]){
		if(aNote==nil)attrib = [model miscAttributesForKey:@"YAttributes1"];
		if(attrib){
			[(ORAxis*)[plotter1 yScale] setAttributes:attrib];
			[plotter1 setNeedsDisplay:YES];
			[[plotter1 yScale] setNeedsDisplay:YES];
		}
	}
}
- (void) updateTimePlot:(NSNotification*)aNote
{
	if(!aNote || ([aNote object] == [model timeRate:0])){
		[plotter0 setNeedsDisplay:YES];
	}
	else if(!aNote || ([aNote object] == [model timeRate:1])){
		[plotter1 setNeedsDisplay:YES];
	}
}
- (void) pollingStateChanged:(NSNotification*)aNotification
{
	[pollingButton selectItemAtIndex:[pollingButton indexOfItemWithTag:[model pollingState]]];
}

- (void) queCountChanged:(NSNotification*)aNotification
{
	[cmdQueCountField setIntValue:[model queCount]];
}

- (void) logFileChanged:(NSNotification*)aNote
{
	if([model logFile])[logFileTextField setStringValue: [model logFile]];
	else [logFileTextField setStringValue: @"---"];
}

- (void) logToFileChanged:(NSNotification*)aNote
{
	[logToFileButton setIntValue: [model logToFile]];
}

- (void) rdacsChanged:(NSNotification*)aNote
{
	[rdacTableView reloadData];
}


- (void) setAllRDacsChanged:(NSNotification*)aNote
{
	[setAllRDacsButton setIntValue: [model setAllRDacs]];
}

- (void) rdacChannelChanged:(NSNotification*)aNote
{
	[rdacChannelTextField setIntValue: [model rdacChannel]];
}

- (void) lcmEnabledChanged:(NSNotification*)aNote
{
	[lcmEnabledMatrix selectCellWithTag: [model lcmEnabled]];
}

- (void) preAmpChanged:(NSNotification*)aNote
{
	[preAmpTextField setIntValue: [model preAmp]];
}

- (void) moduleChanged:(NSNotification*)aNote
{
	[moduleTextField setIntValue: [model module]];
}

- (void) dacValueChanged:(NSNotification*)aNote
{
	[dacValueField setIntValue: [model dacValue]];
}

- (void) adcChanged:(NSNotification*)aNote
{
	if(aNote){
		int index = [[[aNote userInfo] objectForKey:@"Index"] intValue];
		[self loadAdcTimeValuesForIndex:index];
	}
	else {
		int i;
		for(i=0;i<8;i++){
			[self loadAdcTimeValuesForIndex:i];
		}
	}
}

- (void) loadAdcTimeValuesForIndex:(int)index
{
	[[adcMatrix cellWithTag:index] setFloatValue:[model convertedAdc:index]];
	unsigned long t = [model timeMeasured:index];
	NSCalendarDate* theDate;
	if(t){
		theDate = [NSCalendarDate dateWithTimeIntervalSince1970:t];
		[theDate setCalendarFormat:@"%m/%d %H:%M:%S"];
		[[timeMatrix cellWithTag:index] setObjectValue:theDate];
	}
	else [[timeMatrix cellWithTag:index] setObjectValue:@"--"];
}

- (void) checkGlobalSecurity
{
    BOOL secure = [[[NSUserDefaults standardUserDefaults] objectForKey:OROrcaSecurityEnabled] boolValue];
    [gSecurity setLock:ORPacLock to:secure];
    [lockButton setEnabled:secure];
}

- (void) lockChanged:(NSNotification*)aNotification
{

    BOOL runInProgress = [gOrcaGlobals runInProgress];
    BOOL lockedOrRunningMaintenance = [gSecurity runInProgressButNotType:eMaintenanceRunType orIsLocked:ORPacLock];
    BOOL locked = [gSecurity isLocked:ORPacLock];

    [lockButton setState: locked];

    [portListPopup setEnabled:!locked];
    [openPortButton setEnabled:!locked];
    [dacValueField setEnabled:!locked];
    [rdacChannelTextField setEnabled:!locked && ![model setAllRDacs]];
    [readDacButton setEnabled:!locked];
	[writeLcmButton setEnabled:!locked];
    [writeDacButton setEnabled:!locked];
    [readDacButton setEnabled:!locked && ![model setAllRDacs]];
    [readAdcsButton setEnabled:!locked];
    [lcmEnabledMatrix setEnabled:!locked];
    [selectModuleButton setEnabled:!locked];
    [loadButtonAll setEnabled:!locked];
    [loadButton0 setEnabled:!locked];
    [loadButton1 setEnabled:!locked];
    [loadButton2 setEnabled:!locked];
    [loadButton3 setEnabled:!locked];
    [rdacTableView setEnabled:!locked];
	
    NSString* s = @"";
    if(lockedOrRunningMaintenance){
        if(runInProgress && ![gSecurity isLocked:ORPacLock])s = @"Not in Maintenance Run.";
    }
    [lockDocField setStringValue:s];

}

- (void) portStateChanged:(NSNotification*)aNotification
{
    if(aNotification == nil || [aNotification object] == [model serialPort]){
        if([model serialPort]){
            [openPortButton setEnabled:YES];

            if([[model serialPort] isOpen]){
                [openPortButton setTitle:@"Close"];
                [portStateField setTextColor:[NSColor colorWithCalibratedRed:0.0 green:.8 blue:0.0 alpha:1.0]];
                [portStateField setStringValue:@"Open"];
            }
            else {
                [openPortButton setTitle:@"Open"];
                [portStateField setStringValue:@"Closed"];
                [portStateField setTextColor:[NSColor redColor]];
            }
        }
        else {
            [openPortButton setEnabled:NO];
            [portStateField setTextColor:[NSColor blackColor]];
            [portStateField setStringValue:@"---"];
            [openPortButton setTitle:@"---"];
        }
    }
}

- (void) portNameChanged:(NSNotification*)aNotification
{
    NSString* portName = [model portName];
    
	NSEnumerator *enumerator = [ORSerialPortList portEnumerator];
	ORSerialPort *aPort;

    [portListPopup selectItemAtIndex:0]; //the default
    while (aPort = [enumerator nextObject]) {
        if([portName isEqualToString:[aPort name]]){
            [portListPopup selectItemWithTitle:portName];
            break;
        }
	}  
    [self portStateChanged:nil];
}

#pragma mark •••Actions

- (IBAction) setAllRDacsAction:(id)sender
{
	[model setSetAllRDacs:[sender intValue]];
	[self lockChanged:nil];
}

- (IBAction) rdacChannelAction:(id)sender
{
	[model setRdacChannel:[sender intValue]];
	[model setDacValue: [model rdac:[sender intValue]]];
}

- (IBAction) dacValueAction:(id)sender
{
	[model setDacValue:[sender intValue]];	
	[model setRdac:[model rdacChannel] withValue:[sender intValue]];
}

- (IBAction) writeLcmEnabledAction:(id)sender
{
	[model enqueLcmEnable];	
}

- (IBAction) lcmEnabledAction:(id)sender
{
	[model setLcmEnabled:[[sender selectedCell]tag]];	
}

- (IBAction) preAmpAction:(id)sender
{
	[model setPreAmp:[sender intValue]];	
}

- (IBAction) moduleAction:(id)sender
{
	[model setModule:[sender intValue]];	
}

- (IBAction) writeDacAction:(id)sender
{
	[self endEditing];
	[model writeDac];
}

- (IBAction) readDacAction:(id)sender
{
	[self endEditing];
	[model readDac];
}

- (IBAction) lockAction:(id) sender
{
    [gSecurity tryToSetLock:ORPacLock to:[sender intValue] forWindow:[self window]];
}

- (IBAction) portListAction:(id) sender
{
    [model setPortName: [portListPopup titleOfSelectedItem]];
}

- (IBAction) openPortAction:(id)sender
{
    [model openPort:![[model serialPort] isOpen]];
}

- (IBAction) readAdcsAction:(id)sender
{
	[self endEditing];
	[model readAdcs];
}

- (IBAction) selectModuleAction:(id)sender
{
	[self endEditing];
	[model selectModule];
}

- (IBAction) loadRdcaAction:(id)sender
{
	int start,end;
	int board = [sender tag];
	if(board == 4){
		start = 0;
		end = 148;
	}
	else {
		start = board + board*37;
		end = start + 37;
	}

	int i;
	for(i=start;i<end;i++){
		[model enqueWriteRdac:i];
	}
}

- (IBAction) selectFileAction:(id)sender
{
	NSSavePanel *savePanel = [NSSavePanel savePanel];
    [savePanel setPrompt:@"Log To File"];
    [savePanel setCanCreateDirectories:YES];
    
    NSString* startingDir;
    NSString* defaultFile;
    
	NSString* fullPath = [[model logFile] stringByExpandingTildeInPath];
    if(fullPath){
        startingDir = [fullPath stringByDeletingLastPathComponent];
        defaultFile = [fullPath lastPathComponent];
    }
    else {
        startingDir = NSHomeDirectory();
        defaultFile = @"OrcaScript";
    }
	
    [savePanel beginSheetForDirectory:startingDir
                                 file:defaultFile
                       modalForWindow:[self window]
                        modalDelegate:self
                       didEndSelector:@selector(selectLogFileDidEnd:returnCode:contextInfo:)
                          contextInfo:NULL];
	
}

- (IBAction) logToFileAction:(id)sender
{
	[model setLogToFile:[sender intValue]];	
}
- (IBAction) setPollingAction:(id)sender
{
    [model setPollingState:(NSTimeInterval)[[sender selectedItem] tag]];
}

#pragma mark •••Table Data Source
- (id) tableView:(NSTableView *) aTableView objectValueForTableColumn:(NSTableColumn *) aTableColumn row:(int) rowIndex
{
	if([[aTableColumn identifier] isEqualToString:@"Channel"]) return [NSNumber numberWithInt:rowIndex];
	else {
		int board;
		if([[aTableColumn identifier] isEqualToString:@"Board0"])board = 0;
		else if([[aTableColumn identifier] isEqualToString:@"Board1"])board = 1;
		else if([[aTableColumn identifier] isEqualToString:@"Board2"])board = 2;
		else board = 3;
		return [NSNumber numberWithInt:[model rdac:rowIndex + board*37]];
	}
}

// just returns the number of items we have.
- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	if(aTableView == aTableView)return 37;
	else return 8;
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	if([[aTableColumn identifier] isEqualToString:@"Channel"]) return;
	int board;
	if([[aTableColumn identifier] isEqualToString:@"Board0"])board = 0;
	else if([[aTableColumn identifier] isEqualToString:@"Board1"])board = 1;
	else if([[aTableColumn identifier] isEqualToString:@"Board2"])board = 2;
	else board = 3;
	[model setRdac:rowIndex+(board*37) withValue:[anObject intValue]];
	if(rowIndex+(board*37) == [model rdacChannel]){
		[model setDacValue:[anObject intValue]];
	}
}

- (void) tabView:(NSTabView*)aTabView didSelectTabViewItem:(NSTabViewItem*)item
{	
    int index = [tabView indexOfTabViewItem:item];
    [[NSUserDefaults standardUserDefaults] setInteger:index forKey:@"orca.Pac.selectedtab"];
}

#pragma mark •••Data Source
- (int) numberPointsInPlot:(id)aPlotter
{
	return [[model timeRate:[aPlotter tag]]   count];
}

- (void) plotter:(id)aPlotter index:(int)i x:(double*)xValue y:(double*)yValue
{
	int set = [aPlotter tag];
	int count = [[model timeRate:set] count];
	int index = count-i-1;
	*yValue = [[model timeRate:set] valueAtIndex:index];
	*xValue = [[model timeRate:set] timeSampledAtIndex:index];
}

#pragma  mark •••Delegate Responsiblities
- (BOOL) outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    return NO;
}
- (BOOL) tableView:(NSTableView *)tableView shouldSelectRow:(int)row
{
	return YES;
}
@end

@implementation ORPacController (private)

- (void) populatePortListPopup
{
	NSEnumerator *enumerator = [ORSerialPortList portEnumerator];
	ORSerialPort *aPort;
    [portListPopup removeAllItems];
    [portListPopup addItemWithTitle:@"--"];

	while (aPort = [enumerator nextObject]) {
        [portListPopup addItemWithTitle:[aPort name]];
	}    
}

- (void) selectLogFileDidEnd:(NSOpenPanel *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo
{
    if(returnCode){
        [model setLogFile:[[[sheet filenames] objectAtIndex:0] stringByAbbreviatingWithTildeInPath]];
    }
}

@end

