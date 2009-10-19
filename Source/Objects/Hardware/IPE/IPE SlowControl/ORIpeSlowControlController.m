//--------------------------------------------------------
// ORIpeSlowControlController
// Created by Mark  A. Howe on Mon Apr 11 2005
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
#import <WebKit/WebKit.h>
#import "ORIpeSlowControlController.h"
#import "ORIpeSlowControlModel.h"
#import "ORTimedTextField.h"
#import "ORPlotter1D.h"
#import "ORAdeiLoader.h"

@implementation ORIpeSlowControlController

#pragma mark ***Initialization
- (id) init
{
	self = [super initWithWindowNibName:@"IpeSlowControl"];
	return self;
}

- (void) awakeFromNib
{
	[super awakeFromNib];
	[ipNumberComboBox setUsesDataSource:YES];
	[ipNumberComboBox setDataSource:self];
	[lastRequestField setTimeOut:1];
	[ipNumberComboBox reloadData];
	[viewItemInWebButton setEnabled:NO];
	[setPointField setEnabled:NO];
	[setPointButton setEnabled:NO];
	[webViewButton setTitle:@"See Web View"];
	[treeViewButton setTitle:@"See ADEI Tree"];
	[treeDetailsView setAlignment:NSLeftTextAlignment];
	[itemDetailsView setAlignment:NSLeftTextAlignment];
	
	[[timingPlotter yScale] setRngLimitsLow:0 withHigh:1e10 withMinRng:5];
    [[timingPlotter yScale] setRngLow:0 withHigh:200];
    [[timingPlotter yScale] setLog:NO];
    [[timingPlotter xScale] setRngLimitsLow:0 withHigh:kResponseTimeHistogramSize withMinRng:100];
    [[timingPlotter xScale] setRngLow:0 withHigh:kResponseTimeHistogramSize];
    [[timingPlotter xScale] setLog:NO];
	
    [itemTreeOutlineView setVerticalMotionCanBeginDrag:YES];
    [itemTableView registerForDraggedTypes:[NSArray arrayWithObjects:@"ORItemType",NSStringPboardType, nil]];
	[itemTreeOutlineView setDraggingSourceOperationMask:NSDragOperationEvery forLocal:NO];
	[itemTableView setDraggingSourceOperationMask:NSDragOperationEvery forLocal:NO];
    [itemTableView setVerticalMotionCanBeginDrag:YES];
}

#pragma mark ***Notifications
- (void) registerNotificationObservers
{
	NSNotificationCenter* notifyCenter = [NSNotificationCenter defaultCenter];
    [super registerNotificationObservers];
    
    [notifyCenter addObserver : self
                     selector : @selector(lockChanged:)
                         name : ORIpeSlowControlLock
                       object : nil];
                                              
	[notifyCenter addObserver : self
                      selector: @selector(treeChanged:)
                          name: ORIpeSlowItemTreeChanged
                       object : model];
                       
	[notifyCenter addObserver : self
                      selector: @selector(itemListChanged:)
                          name: ORIpeSlowControlItemListChanged
                       object : model];
                                                                                            
	[notifyCenter addObserver : self
                     selector : @selector(pollTimeChanged:)
                         name : ORIpeSlowControlPollTimeChanged
                       object : nil];
	
	[notifyCenter addObserver : self
                     selector : @selector(lastRequestChanged:)
                         name : ORIpeSlowControlLastRequestChanged
                       object : nil];
	
	[notifyCenter addObserver : self
                     selector : @selector(ipNumberChanged:)
                         name : ORIpeSlowControlIPNumberChanged
                       object : nil];
	
	[notifyCenter addObserver : self
                     selector : @selector(tableViewSelectionDidChange:)
                         name : NSTableViewSelectionDidChangeNotification
                       object : nil];
	
	[notifyCenter addObserver : self
                     selector : @selector(drawDidClose:)
                         name : NSDrawerDidCloseNotification
                       object : nil];
	
	[notifyCenter addObserver : self
                     selector : @selector(drawDidOpen:)
                         name : NSDrawerDidOpenNotification
                       object : nil];
	
    [notifyCenter addObserver : self
                     selector : @selector(viewItemNameChanged:)
                         name : ORIpeSlowControlModelViewItemNameChanged
						object: model];

	[notifyCenter addObserver : self
                     selector : @selector(outlineViewSelectionDidChange:)
                         name : NSOutlineViewSelectionDidChangeNotification
                       object : itemTreeOutlineView];
	
    [notifyCenter addObserver : self
                     selector : @selector(itemTypeChanged:)
                         name : ORIpeSlowControlModelItemTypeChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(setPointChanged:)
                         name : ORIpeSlowControlModelSetPointChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(fastGenSetupChanged:)
                         name : ORIpeSlowControlModelFastGenSetupChanged
						object: model];
	
    [notifyCenter addObserver : self
                     selector : @selector(histoPlotChanged:)
                         name : ORIpeSlowControlModelHistogramChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(pendingRequestsChanged:)
                         name : ORIpeSlowControlPendingRequestsChanged
						object: model];
	
    [notifyCenter addObserver : self
                     selector : @selector(timeOutCountChanged:)
                         name : ORIpeSlowControlModelTimeOutCountChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(totalRequestCountChanged:)
                         name : ORIpeSlowControlModelTotalRequestCountChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(shipRecordsChanged:)
                         name : ORIpeSlowControlModelShipRecordsChanged
						object: model];

}

- (void) updateWindow
{
    [super updateWindow];
    [self setWindowTitle];
	[self pollTimeChanged:nil];
	[self lastRequestChanged:nil];
	[self ipNumberChanged:nil];
	[self histoPlotChanged:nil];
	
    [itemTableView reloadData];
    [itemTableView setNeedsDisplay: YES];
    [itemTreeOutlineView setNeedsDisplay: YES];
    
	[self viewItemNameChanged:nil];
	[self itemTypeChanged:nil];
	[self setPointChanged:nil];
	[self fastGenSetupChanged:nil];
	[self pendingRequestsChanged:nil];
	[self timeOutCountChanged:nil];
	[self totalRequestCountChanged:nil];
	[self shipRecordsChanged:nil];
}

- (void) shipRecordsChanged:(NSNotification*)aNote
{
	[shipRecordsCB setIntValue: [model shipRecords]];
}

- (void) totalRequestCountChanged:(NSNotification*)aNote
{
	[totalRequestCountField setIntValue: [model totalRequestCount]];
}

- (void) timeOutCountChanged:(NSNotification*)aNote
{
	[timeOutCountField setIntValue: [model timeOutCount]];
}

- (void) pendingRequestsChanged:(NSNotification*)aNote
{
	[pendingRequestsTable reloadData];
}

- (void) fastGenSetupChanged:(NSNotification*)aNote
{
	[fastGenSetupButton setIntValue: [model fastGenSetup]];
}

- (void) setPointChanged:(NSNotification*)aNote
{
	[setPointField setDoubleValue: [model setPoint]];
}

- (void) itemTypeChanged:(NSNotification*)aNote
{
	[itemTypeMatrix selectCellWithTag: [model itemType]];
}

- (void) viewItemNameChanged:(NSNotification*)aNote
{
	[viewItemNameMatrix selectCellWithTag: [model viewItemName]];
	[itemTableView reloadData];
}


- (void) setWindowTitle
{
	[[self window] setTitle: [NSString stringWithFormat:@"IPE-ADEI Slow Control - %d",[model uniqueIdNumber]]];
}


- (void) drawDidOpen:(NSNotification*)aNote
{
	if([aNote object] == webDrawer)		  [webViewButton setTitle:@"Hide Web View"];
	else if([aNote object] == treeDrawer) [treeViewButton setTitle:@"Hide ADEI Tree"];
}

- (void) drawDidClose:(NSNotification*)aNote
{
	if([aNote object] == webDrawer)		  [webViewButton setTitle:@"See Web View"];
	else if([aNote object] == treeDrawer) [treeViewButton setTitle:@"See ADEI Tree"];
}

- (void) ipNumberChanged:(NSNotification*)aNotification
{
	[ipNumberComboBox setStringValue:[model IPNumber]];
}

- (void) histoPlotChanged:(NSNotification*)aNotification
{
	[timingPlotter setNeedsDisplay:YES];
}


- (void) lastRequestChanged:(NSNotification*)aNotification
{
	[lastRequestField setStringValue:[model lastRequest]];
}

- (void) pollTimeChanged:(NSNotification*)aNotification
{
	[pollTimePopup selectItemWithTag:[model pollTime]];
}

- (void) treeChanged:(NSNotification*)aNote
{
    [itemTreeOutlineView reloadData];
}

- (void) itemListChanged:(NSNotification*)aNote
{
    [itemTableView reloadData];
	[self tableViewSelectionDidChange:nil];
}

- (void) tableViewSelectionDidChange:(NSNotification *)aNote
{
	if(([aNote object] == itemTableView) || (aNote==nil)){
		NSIndexSet* selectedSet = [itemTableView selectedRowIndexes];
		if([selectedSet count] == 1){
			unsigned index = [selectedSet firstIndex];
			if([model itemExists:index]){
				[viewItemInWebButton setEnabled:YES];
				[itemDetailsView setString: [model itemDetails:index]]; 
				if([model isControlItem:index]){
					[setPointField setEnabled:YES];
					[setPointButton setEnabled:YES];
				}
				else {
					[setPointField setEnabled:NO];
					[setPointButton setEnabled:NO];
				}
			}
			else {
				[itemDetailsView setString: @"<Empty Item Slot>"]; 
				[viewItemInWebButton setEnabled:NO];
				[setPointField setEnabled:NO];
				[setPointButton setEnabled:NO];
			}
		}
		else {
			[viewItemInWebButton setEnabled:NO];
			[setPointField setEnabled:NO];
			[setPointButton setEnabled:NO];
			[itemDetailsView setString: @"<Nothing Selected>"]; 
		}
	}
}

- (void) outlineViewSelectionDidChange:(NSNotification *)notification
{
    if([notification object] == itemTreeOutlineView){
		id item = [itemTreeOutlineView selectedItem];
		if(item){
			if([item objectForKey:@"Children"]){
				NSString* s = [NSString stringWithFormat:@"%@ = %@\n",@"URL",[item objectForKey:@"URL"]];
				s = [s stringByAppendingFormat:@"%@ = %@\n",@"Path",[item objectForKey:@"Path"]];
				[treeDetailsView setString: s]; 
			}
			else {
				NSString* s = [[itemTreeOutlineView selectedItem] description];
				s = [s stringByReplacingOccurrencesOfString:@"{" withString:@""];
				s = [s stringByReplacingOccurrencesOfString:@"}" withString:@""];
				s = [s stringByReplacingOccurrencesOfString:@";" withString:@""];
				[treeDetailsView setString: s]; 
			}
		}
		else [treeDetailsView setString: @"<Nothing Selected>"]; 
    }
}

- (void) lockChanged:(NSNotification*)aNote
{
    BOOL locked = [gSecurity isLocked:ORIpeSlowControlLock];
    [lockButton setState: locked];
    [itemTableView setEnabled:!locked];
	[ipNumberComboBox setEnabled:!locked];
	[setPointField setEnabled:!locked];
	[setPointButton setEnabled:!locked];
}

#pragma mark ***Actions

- (void) shipRecordsAction:(id)sender
{
	[model setShipRecords:[sender intValue]];	
}
- (void) fastGenSetupAction:(id)sender
{
	[model setFastGenSetup:[sender intValue]];	
}

- (void) setPointAction:(id)sender
{
	 [model setSetPoint:[sender doubleValue]];	
}

- (IBAction) writeSetPointAction:(id) sender
{
	[self endEditing];
	NSIndexSet* selectedSet = [itemTableView selectedRowIndexes];
	if([selectedSet count] == 1){
		unsigned index = [selectedSet firstIndex];
		[model writeSetPoint:index value:[model setPoint]];
	}
}

- (IBAction) itemTypeAction:(id)sender
{
	[model setItemType:[[sender selectedCell]tag]];	
}

- (void) viewItemNameAction:(id)sender
{
	[model setViewItemName:[[sender selectedCell]tag]];	
}

- (IBAction) viewItemInWebAction:(id)sender
{	
	NSIndexSet* selectedSet = [itemTableView selectedRowIndexes];
	if([selectedSet count] == 1){
		unsigned index = [selectedSet firstIndex];
		NSString* requestString = [model createWebRequestForItem:index];
		[[webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString: requestString ]]];
		[webDrawer open: nil];
	}
}

- (IBAction) loadItemTree:(id)sender
{
	[model loadItemTree];
}

- (IBAction) delete:(id)sender
{
    [self removeItemAction:nil];
}

- (IBAction) cut:(id)sender
{
    [self removeItemAction:nil];
}

- (IBAction) removeItemAction:(id)sender
{
	[model removeSet:[itemTableView selectedRowIndexes]];
    [itemTableView deselectAll:nil];
	[itemTableView reloadData];
}

- (IBAction) ipNumberAction:(id)sender
{
	[model setIPNumber:[sender stringValue]];
}

- (IBAction) clearHistory:(id) sender
{
	[model clearHistory];
}

- (void) checkGlobalSecurity
{
    BOOL secure = [gSecurity globalSecurityEnabled];
    [gSecurity setLock:ORIpeSlowControlLock to:secure];
    [lockButton setEnabled:secure];
}

- (IBAction) lockAction:(id)sender
{
    [gSecurity tryToSetLock:ORIpeSlowControlLock to:[sender intValue] forWindow:[self window]];
}

- (IBAction) pollTimeAction:(id)sender
{
	[model setPollTime:[[sender selectedItem] tag]];
}

- (IBAction) pollNowAction:(id)sender
{
	[model pollSlowControls];
}

- (IBAction) dumpSensorAction:(id)sender
{
    [model dumpSensorlist];
}

#pragma mark •••Drawer Actions
/* We do not use [NSDrawer open:] to open the drawer, because that method will
autoselect an edge, and we want this drawer to open only on specific edges. */
- (IBAction) toggleTreeDrawer:(id)sender 
{
    NSDrawerState state = [treeDrawer state];
    if (NSDrawerOpeningState == state || NSDrawerOpenState == state) {
        [treeDrawer close];
    } 
	else {
        [treeDrawer openOnEdge:NSMinYEdge];
    }
}

- (IBAction) toggleWebDrawer:(id)sender 
{
    NSDrawerState state = [webDrawer state];
    if (NSDrawerOpeningState == state || NSDrawerOpenState == state){
		[webDrawer close];
	}
	else {
		[webDrawer openOnEdge:NSMaxXEdge];
	}
}

#pragma mark •••Data Source Methods  (OutlineView)
- (int) outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item 
{
	if (item == nil)return [[model itemTreeRoot] count];
	else {
		if ([item isKindOfClass:[NSArray class]]) {
			return [item count];
		}
		else if ([item isKindOfClass:[NSDictionary class]]) {
			return [[item objectForKey:@"Children"] count];
		}
		else return 0;
	}
}

- (BOOL) outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item 
{
	if ([item isKindOfClass:[NSArray class]]) {
		return [item count]>0;
	}
	else if ([item isKindOfClass:[NSDictionary class]]) {
		return [[item objectForKey:@"Children"] count]>0;
	}
    return NO;
}

- (id) outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item 
{
	if (item == nil)item = [model itemTreeRoot];
    
    if ([item isKindOfClass:[NSArray class]]) {
        return [item objectAtIndex:index];
    }
    else if ([item isKindOfClass:[NSDictionary class]]) {
        return [[item objectForKey:@"Children"] objectAtIndex:index];
    }
	return nil;
}

- (id) outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item 
{
	id root = [model itemTreeRoot];
	id parentObject = [outlineView parentForItem:item] ? [outlineView parentForItem:item] : root;
	
	if ([[tableColumn identifier] isEqual:@"Name"]) {
        if ([item isKindOfClass:[NSDictionary class]]) {
			if([item objectForKey:@"Children"])return [item objectForKey:@"Name"];
			else return [item objectForKey:@"name"]; //lower case!
        } 
        else if ([item isKindOfClass:[NSArray class]]) {
			return [parentObject objectForKey:@"Name"];
        }
		else return @"";
    } 
    return nil;
}

- (BOOL) outlineView:(NSOutlineView *)ov writeItems:(NSArray*)writeItems toPasteboard:(NSPasteboard*)pboard
{
    draggedNodes = [[NSMutableArray array] retain]; 
	if(ov == itemTreeOutlineView){
		NSArray *types   = [NSArray arrayWithObjects: @"ORItemType", NSStringPboardType, nil];
		[pboard declareTypes:types owner:self];
		NSString* s = @"";
		for(id obj in writeItems){
			int componentCount = [[[obj objectForKey:@"Path"] componentsSeparatedByString:@"/"] count];
			if(componentCount==4){
				[draggedNodes addObject:[[obj mutableCopy] autorelease]];
				NSString* aUrl = [obj objectForKey:@"URL"];
				NSString* aPath = [obj objectForKey:@"Path"];
				s = [s stringByAppendingFormat:@"url  = %@\n",aUrl];
				s = [s stringByAppendingFormat:@"path = %@\n",aPath];
				s = [s stringByAppendingFormat:@"webRequest = %@\n",[ORAdeiLoader webRequestStringUrl:aUrl itemPath:aPath]];
			}
		}
		[pboard declareTypes:[NSArray arrayWithObjects:@"ORItemType", NSStringPboardType,nil] owner:self];
		[pboard setData:[NSData data] forType:@"ORItemType"];	//put in a NSData placeholder.... we'll provide the actual data thru other means	

		if([s length]){
			[pboard setString:s forType:NSStringPboardType];
		}
		return YES;
	}
	else return NO;
}

- (BOOL) validateMenuItem:(NSMenuItem*)menuItem
{
    if ([menuItem action] == @selector(cut:)) {
        return [itemTableView selectedRow] >= 0 ;
    }
    else if ([menuItem action] == @selector(delete:)) {
        return [itemTableView selectedRow] >= 0 ;
    }
	return [super validateMenuItem:menuItem];
}
	
#pragma mark •••Data Source Methods (ComboBox)
- (NSInteger) numberOfItemsInComboBox:(NSComboBox *)aComboBox 
{
    return [model connectionHistoryCount];
}

- (id) comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index 
{
    return [model connectionHistoryItem:index];
}

#pragma mark •••Data Source Methods (TableView)
- (int) numberOfRowsInTableView:(NSTableView *)tableView
{
    if(tableView==itemTableView){
        return [model pollingLookUpCount];
    }
	else if(tableView == pendingRequestsTable){
		return [model pendingRequestsCount];
	}
	return 0;
}

- (id) tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row
{
    if(tableView==itemTableView){
		if(row<[model pollingLookUpCount]){
			//things are slightly complicated because some of the items are in the topLevelDictionary and some are in the item's dictionary
			NSString*		itemKey				= [model requestCacheItemKey:row];
			NSDictionary*	topLevelDictionary	= [model topLevelPollingDictionary:itemKey];
			NSDictionary*	itemDictionary		= [topLevelDictionary objectForKey:itemKey];
			BOOL isControl						= [[itemDictionary objectForKey:@"Control"] boolValue];
			NSString* theIdentifier				= [tableColumn identifier];
			if([theIdentifier isEqual:@"Path"]){
				if([model viewItemName]) {
					if(isControl) return [itemDictionary objectForKey:@"name"];
					else		  return [itemDictionary objectForKey:@"Name"];
				}
				else					 return  [itemDictionary objectForKey:@"Path"];
			}
			else if([theIdentifier isEqual:@"Value"]){
				if(isControl) return [NSNumber numberWithDouble:[[itemDictionary objectForKey:@"value"] doubleValue]];
				else          return [NSNumber numberWithDouble:[[itemDictionary objectForKey:@"Value"] doubleValue]];
			}
			else if([theIdentifier isEqual:@"Name"]){
				if(isControl) return [itemDictionary objectForKey:@"name"];
				else		  return [itemDictionary objectForKey:@"Name"];
			}
			else {
				id aDisplayValue = [topLevelDictionary objectForKey:theIdentifier];
				if(aDisplayValue)return aDisplayValue;
				else {
					aDisplayValue = [itemDictionary objectForKey:theIdentifier];
					if(aDisplayValue)return aDisplayValue;
					else return @"--";
				}
			}
			
		}
	}
	else if(tableView == pendingRequestsTable){
		return [model pendingRequest:[tableColumn identifier] forIndex:row];
	}
    return @"-";
}

- (void) tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(int)row
{
	if(tableView==itemTableView){
		if(row<[model pollingLookUpCount]){
			//only items that can be changed are in the topLevelDictionary
			NSString* itemKey = [model requestCacheItemKey:row];
			NSMutableDictionary*	topLevelDictionary	= [model topLevelPollingDictionary:itemKey];
			[topLevelDictionary setObject:object forKey:[tableColumn identifier]];
		}
		[self tableViewSelectionDidChange:nil];
    }
}

- (NSDragOperation) tableView: (NSTableView *) view
				 validateDrop: (id <NSDraggingInfo>) info
				  proposedRow: (int) row
		proposedDropOperation: (NSTableViewDropOperation) operation
{	
	if (nil == [info draggingSource]){
		[(ORIpeSlowControlController*)([[info draggingSource] dataSource]) dragDone];
		return NSDragOperationNone;
	}
	else if (itemTableView == [info draggingSource]){
		[(ORIpeSlowControlController*)([[info draggingSource] dataSource]) dragDone];
		return NSDragOperationNone;
	}
	else {
		[view setDropRow: row dropOperation: NSTableViewDropAbove];
		return NSDragOperationCopy;
	}
}

- (BOOL) tableView: (NSTableView *) view
		acceptDrop: (id <NSDraggingInfo>) info
			   row: (int) row
	 dropOperation: (NSTableViewDropOperation) operation
{
	if (nil == [info draggingSource]){
        [(ORIpeSlowControlController*)([[info draggingSource] dataSource]) dragDone];
		return NO;
	}
	else if (itemTableView == [info draggingSource]){
        [(ORIpeSlowControlController*)([[info draggingSource] dataSource]) dragDone];
		return NO;
	}
	else {
		[model addItems:draggedNodes];
        [(ORIpeSlowControlController*)([[info draggingSource] dataSource]) dragDone];
		return YES;
	}
	return NO;
}

- (NSColor*) tableView:(id)aTableView backgroundColorForRow:(unsigned)row
{
    if(aTableView==itemTableView){
		if(row<[model pollingLookUpCount]){
			if([model isControlItem:row]) return [NSColor colorWithCalibratedRed:1.0 green:.5 blue:.5 alpha:.3];
			else return nil;
		}
    }
	return nil;
}

- (BOOL) tableView:(NSTableView *)tv writeRowsWithIndexes:(NSIndexSet*)rowIndexes toPasteboard:(NSPasteboard*)pboard
{
	unsigned current_index = [rowIndexes firstIndex];
	NSString* s = @"";
    while (current_index != NSNotFound) {
		NSDictionary* itemDictionary = [model requestCacheItem:current_index];
		if(itemDictionary){
			int componentCount = [[[itemDictionary objectForKey:@"Path"] componentsSeparatedByString:@"/"] count];
			if(componentCount==4){
				NSString* aUrl = [itemDictionary objectForKey:@"URL"];
				NSString* aPath = [itemDictionary objectForKey:@"Path"];
				s = [s stringByAppendingFormat:@"url  = %@\n",aUrl];
				s = [s stringByAppendingFormat:@"path = %@\n",aPath];
				s = [s stringByAppendingFormat:@"webRequest = %@\n",[ORAdeiLoader webRequestStringUrl:aUrl itemPath:aPath]];
			}
		}
		current_index = [rowIndexes indexGreaterThanIndex: current_index];
    }
	
	if([s length]){
		[pboard declareTypes:[NSArray arrayWithObjects:NSStringPboardType,nil] owner:self];	
		[pboard setString:s forType:NSStringPboardType];
		return YES;
	}
	else return NO;
}

- (void) dragDone
{
    [draggedNodes release];
    draggedNodes = nil;
}

- (NSArray*)draggedNodes
{ 
    return draggedNodes; 
}

#pragma mark •••Histogram DataSource
- (int) numberOfPointsInPlot:(id)aPlotter dataSet:(int)set
{
    return kResponseTimeHistogramSize;
}

- (float) plotter:(id) aPlotter dataSet:(int)set dataValue:(int) x
{
	return [model dataTimeHist:x];
}

@end

@implementation ORIpeTableView
//sub class of NSTableView so we can draw the control items with a different color.
- (void)drawRow:(NSInteger)row clipRect:(NSRect)clipRect;
{
	NSColor *color = [[self dataSource] tableView:self backgroundColorForRow:row];
	if (color && [self isRowSelected:row] == NO) {
		[NSGraphicsContext saveGraphicsState];
		NSRectClip(clipRect);
		NSRect rowRect = [self rectOfRow:row];
		// draw over the alternating row color
		[[NSColor whiteColor] setFill];
		NSRectFill(NSIntersectionRect(rowRect, clipRect));
		// draw with rounded end caps
		CGFloat radius = NSHeight(rowRect) / 2.0;
		NSBezierPath *p = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(rowRect, 1.0, 0.0) xRadius:radius yRadius:radius];		[color setFill];
		[p fill];
		[NSGraphicsContext restoreGraphicsState];
	}
	[super drawRow:row clipRect:clipRect];
}
@end

