//--------------------------------------------------------
// ORListenerModel
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
#import "ORDataChainObject.h"

#pragma mark ***Forward Declarations
@class NetSocket;
@class ORDecoder;

@interface ORListenerModel : ORDataChainObject
{
	unsigned short remotePort;
	NSString* remoteHost;
	BOOL isConnected;
	unsigned long byteCount;
	NetSocket* socket;

    BOOL threadRunning;
    NSMutableData* dataToProcess;
    BOOL docLoaded;
	BOOL autoReconnect;
	BOOL connectAtStart;
	BOOL firstTime;
	BOOL needToSwap;
	unsigned long runDataID;
	ORDecoder* currentDecoder;
	NSMutableDictionary* runInfo;
	NSMutableArray* dataArray;
	BOOL runEnded;
	BOOL scheduledForUpdate;
    BOOL timeToQuit;
}

#pragma mark ***Initialization
- (id)   init;
- (void) dealloc;

#pragma mark •••Notifications
- (void) registerNotificationObservers;
- (void) connectionChanged:(NSNotification*)aNotification;
- (void) documentLoaded:(NSNotification*)aNotification;

#pragma mark ***Accessors
- (BOOL) connectAtStart;
- (void) setConnectAtStart:(BOOL)aConnectAtStart;
- (BOOL) autoReconnect;
- (void) setAutoReconnect:(BOOL)aAutoReconnect;
- (NetSocket*) socket;
- (void) setSocket:(NetSocket*)aSocket;

- (unsigned short) remotePort;
- (void) setRemotePort:(unsigned short)aNewRemotePort;
- (NSString*) remoteHost;
- (void) setRemoteHost:(NSString*)aNewRemoteHost;
- (BOOL) isConnected;
- (void) setIsConnected:(BOOL)aNewIsConnected;
- (unsigned long) byteCount;
- (void) setByteCount:(unsigned long)aNewByteCount;
- (void) incByteCount:(unsigned long)anAmount;
- (void) clearByteCount;
- (void) connectSocket:(BOOL)state;

#pragma mark ***Delegate Methods
- (void) netsocketConnected:(NetSocket*)inNetSocket;
- (void) netsocket:(NetSocket*)inNetSocket dataAvailable:(unsigned)inAmount;
- (void) netsocketDisconnected:(NetSocket*)inNetSocket;

@end

extern NSString* ORListenerRemotePortChanged;
extern NSString* ORListenerRemoteHostChanged;
extern NSString* ORListenerIsConnectedChanged;
extern NSString* ORListenerByteCountChanged;
extern NSString* ORListenerLock;
extern NSString* ORListenerQueueCountChanged;
extern NSString* ORListenerAutoReconnectChanged;
extern NSString* ORListenerConnectAtStartChanged;
