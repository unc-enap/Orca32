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

#import "ORListenerModel.h"
#import "NetSocket.h"
#import "ORDataPacket.h"
#import "ORDataTaker.h"
#import "ORSafeQueue.h"
#import "ORDataTaker.h"
#import "ORDataTypeAssigner.h"

#pragma mark ***External Strings
NSString* ORListenerConnectAtStartChangedNotification = @"ORListenerConnectAtStartChangedNotification";
NSString* ORListenerAutoReconnectChangedNotification = @"ORListenerAutoReconnectChangedNotification";
NSString* ORListenerQueueCountChangedNotification = @"ORListenerQueueCountChangedNotification";
NSString* ORListenerRemotePortChangedNotification  = @"ORListenerRemotePortChangedNotification";
NSString* ORListenerRemoteHostChangedNotification  = @"ORListenerRemoteHostChangedNotification";
NSString* ORListenerIsConnectedChangedNotification = @"ORListenerIsConnectedChangedNotification";
NSString* ORListenerByteCountChangedNotification   = @"ORListenerByteCountChangedNotification";
NSString* ORListenerLock                           = @"ORListenerLock";

static NSString* ORListenerConnector = @"ORListenerConnector";

#define kProcessingBusy 1
#define kProcessingDone 0
#define kMaxQueueSize   10*1024

@interface ORListenerModel (processThread)
- (void) processDataFromQueue;
- (void) process:(NSMutableData*)dataChunk;
- (void) processRecords:(NSMutableData*)dataChunk;
- (void) startProcessing;
- (void) stopProcessing;
- (void) reConnect;
@end

@interface ORListenerModel (private)
- (void) sendRunTaskStarted:(ORDataPacket*)aDataPacket;
@end

@implementation ORListenerModel
- (id) init
{
	self = [super init];
    readingLock = [[NSLock alloc] init];
    processLock = [[NSConditionLock alloc] init];
	return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	[timeToStopProcessThread release];
    [processLock release];
    [readingLock release];
    [dataPacket release];
	[remoteHost release];
	[socket release];
	[dataPacket release];
	[transferQueue release];
	[super dealloc];
}

- (void) setUpImage
{
	[self setImage:[NSImage imageNamed:@"Listener"]];
}

- (void) makeMainController
{
	[self linkToController:@"ORListenerController"];
}

- (void) makeConnectors
{
    ORConnector* aConnector = [[ORConnector alloc] initAt:NSMakePoint([self frame].size.width-kConnectorSize,[self frame].size.height/2 - kConnectorSize/2) withGuardian:self withObjectLink:self];
    [[self connectors] setObject:aConnector forKey:ORListenerConnector];
	[aConnector setIoType:kOutputConnector];
    [aConnector release];
    
}

#pragma mark •••Notifications
- (void) registerNotificationObservers
{
    NSNotificationCenter* notifyCenter = [NSNotificationCenter defaultCenter];
    
    [notifyCenter addObserver : self
                     selector : @selector(connectionChanged:)
                         name : ORConnectionChanged
                       object : nil];
    
    [notifyCenter addObserver : self
                     selector : @selector(documentLoaded:)
                         name : ORDocumentLoadedNotification
                       object : nil];
    
    
}


- (void) documentLoaded:(NSNotification*)aNotification
{
    if([self objectConnectedTo:ORListenerConnector] && connectAtStart){
        docLoaded = YES;
        [self connectSocket:YES];
    }
}

- (void) connectionChanged:(NSNotification*)aNotification
{
    if([aNotification object] == self){
        if([self objectConnectedTo:ORListenerConnector]){
            theNextObject =  [self objectConnectedTo: ORListenerConnector];
            if(docLoaded){
                [self connectSocket:YES];
            }
        }
        else {
            [self connectSocket:NO];
            //theNextObject = nil;
        }
    }
}

#pragma mark ***Accessors
- (BOOL) connectAtStart
{
	return connectAtStart;
}
- (void) setConnectAtStart:(BOOL)aConnectAtStart
{
	[[[self undoManager] prepareWithInvocationTarget:self] setConnectAtStart:connectAtStart];
    
	connectAtStart = aConnectAtStart;
    
	[[NSNotificationCenter defaultCenter]
		postNotificationName:ORListenerConnectAtStartChangedNotification
                      object:self];
}
- (BOOL) autoReconnect
{
	return autoReconnect;
}
- (void) setAutoReconnect:(BOOL)aAutoReconnect
{
	[[[self undoManager] prepareWithInvocationTarget:self] setAutoReconnect:autoReconnect];
    
	autoReconnect = aAutoReconnect;
    
	[[NSNotificationCenter defaultCenter]
		postNotificationName:ORListenerAutoReconnectChangedNotification
                      object:self];
}

- (ORSafeQueue*) transferQueue
{
	return transferQueue;
}

- (void) setTransferQueue:(ORSafeQueue*)aTransferQueue
{
	[aTransferQueue retain];
	[transferQueue release];
	transferQueue = aTransferQueue;
}

- (unsigned long) queueCount
{
	return queueCount;
}
- (void) setQueueCount:(unsigned long)aQueueCount
{
	queueCount = aQueueCount;
    
	[[NSNotificationCenter defaultCenter]
		postNotificationName:ORListenerQueueCountChangedNotification
                      object:self];
}
- (ORDataPacket*) dataPacket
{
    return dataPacket;
}

- (void) setDataPacket:(ORDataPacket*)aDataPacket
{
    [aDataPacket retain];
    [dataPacket release];
    dataPacket = aDataPacket;
}

- (NetSocket*) socket
{
	return socket;
}
- (void) setSocket:(NetSocket*)aSocket
{
	[aSocket retain];
	[socket release];
	socket = aSocket;
    [socket setDelegate:self];
}

- (unsigned short) remotePort
{
	return remotePort;
}
- (void) setRemotePort:(unsigned short)aNewRemotePort
{
	[[[self undoManager] prepareWithInvocationTarget:self] setRemotePort:remotePort];
    
	remotePort = aNewRemotePort;
    
	[[NSNotificationCenter defaultCenter] 
			postNotificationName:ORListenerRemotePortChangedNotification 
                          object: self];
}

- (NSString*) remoteHost
{
	return remoteHost;
}
- (void) setRemoteHost:(NSString*)aNewRemoteHost
{
    if(!aNewRemoteHost)aNewRemoteHost = @"";
    
    NSString* thisHostAdress    = [[NSHost currentHost] address];
    NSString* remoteHostAddress = [[NSHost hostWithName:aNewRemoteHost] address];
    
    if([thisHostAdress isEqualToString:remoteHostAddress]){
        aNewRemoteHost = @"";   
        NSLog(@"Sorry, you can not connect a Listener to the local host.\n"); 
        NSLog(@"The remote host must be a different computer.\n"); 
    }
    
	[[[self undoManager] prepareWithInvocationTarget:self] setRemoteHost:remoteHost];
    
	[remoteHost autorelease];
	remoteHost = [aNewRemoteHost copy];
    
	[[NSNotificationCenter defaultCenter] 
			postNotificationName:ORListenerRemoteHostChangedNotification 
                          object: self ];
}

- (BOOL) isConnected
{
	return isConnected;
}
- (void) setIsConnected:(BOOL)aNewIsConnected
{
	isConnected = aNewIsConnected;
    
	[[NSNotificationCenter defaultCenter] 
			postNotificationName:ORListenerIsConnectedChangedNotification 
                          object: self ];
    
}

- (unsigned long) byteCount
{
	return byteCount;
}
- (void) setByteCount:(unsigned long)aNewByteCount
{
	byteCount = aNewByteCount;
    
	[[NSNotificationCenter defaultCenter] 
			postNotificationName:ORListenerByteCountChangedNotification 
                          object: self ];
}

- (void) clearByteCount
{
    [self setByteCount:0];
}

- (void) incByteCount:(unsigned long)anAmount
{
    unsigned long newAmount = byteCount + anAmount;
	[self setByteCount:newAmount];
}

- (void) connectSocket:(BOOL)state
{
    if(state){
		expectingHeader = YES;
        [self setSocket:[NetSocket netsocketConnectedToHost:remoteHost port:remotePort]];
    }
    else {
		expectingHeader = NO;
        [socket close];
        [self stopProcessing];
        [self setIsConnected:[socket isConnected]];
    }
}



#pragma mark ***Delegate Methods
- (void) netsocketConnected:(NetSocket*)inNetSocket
{
    if(inNetSocket == socket){
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reConnect) object:nil];
        [self startProcessing];
        [self setIsConnected:[socket isConnected]];
        [self setIsConnected:YES];
    }
}

- (void) netsocket:(NetSocket*)inNetSocket dataAvailable:(unsigned)inAmount
{
    if(inNetSocket == socket){
        id theData = [socket readData];
        if(theData){
            [transferQueue enqueue:theData];
            [self incByteCount:inAmount];
        }
    }
}

- (void) netsocketDisconnected:(NetSocket*)inNetSocket
{
    if(inNetSocket == socket){
        [self stopProcessing];
        [self setIsConnected:[socket isConnected]];
        if(autoReconnect)[self performSelector:@selector(reConnect) withObject:nil afterDelay:10];
        [self setIsConnected:NO];
    }
}


#pragma mark ***Archival

- (id) initWithCoder:(NSCoder*)decoder
{
	self = [super initWithCoder:decoder];
	[[self undoManager] disableUndoRegistration];
    
	[self setRemoteHost:[decoder decodeObjectForKey:@"ORListenerRemoteHost"]];
    [self setConnectAtStart:[decoder decodeBoolForKey:@"ConnectAtStart"]];
    [self setAutoReconnect:[decoder decodeBoolForKey:@"AutoReconnect"]];
	[self setRemotePort:[decoder decodeIntForKey:@"ORListenerRemotePort"]];
    
	[[self undoManager] enableUndoRegistration];
    
    if(remotePort==0)remotePort = 44666;
	[self registerNotificationObservers];
    readingLock = [[NSLock alloc] init];
    processLock = [[NSConditionLock alloc] init];
    
	return self;
}
- (void) encodeWithCoder:(NSCoder*)encoder
{
    [super encodeWithCoder:encoder];
	[encoder encodeObject:remoteHost forKey:@"ORListenerRemoteHost"];
    [encoder encodeBool:connectAtStart forKey:@"ConnectAtStart"];
    [encoder encodeBool:autoReconnect forKey:@"AutoReconnect"];
	[encoder encodeInt:remotePort forKey:@"ORListenerRemotePort"];
}

- (NSMutableDictionary*) addParametersToDictionary:(NSMutableDictionary*)dictionary
{
	NSMutableDictionary* objDictionary = [NSMutableDictionary dictionary];
    if(remoteHost)[objDictionary setObject:remoteHost forKey:@"RemoteHost"];
    [objDictionary setObject:[NSNumber numberWithInt:connectAtStart] forKey:@"ConnectAtStart"];
    [objDictionary setObject:[NSNumber numberWithInt:autoReconnect] forKey:@"AutoReconnect"];
    [objDictionary setObject:[NSNumber numberWithInt:remotePort] forKey:@"RemotePort"];
    [dictionary setObject:objDictionary forKey:@"Listener"];
    
    return objDictionary;
}


@end

@implementation ORListenerModel (processThread)
//-----------------------------------------------------------
//processDataFromQueue runs out of the processing thread
//-----------------------------------------------------------
- (void) processDataFromQueue
{
    
    if(![socket isConnected])return;
    
    if(!dataPacket){
        ORDataPacket* aDataPacket= [[ORDataPacket alloc] init];
        [self setDataPacket: aDataPacket];
        [aDataPacket release];
    }
    
    [processLock lock];
	[NSThread setThreadPriority:1.0];
	BOOL flushMessagePrintedOnce = NO;
    BOOL timeToQuit              = NO;
    threadRunning                = YES;
    do {
        NSAutoreleasePool *pool = [[NSAutoreleasePool allocWithZone:nil] init];
        [[NSRunLoop currentRunLoop] run];
        queueCount = [transferQueue count];
        if(queueCount){
			[dataToProcess appendData:[transferQueue dequeue]];
            [self process:dataToProcess];
        }
        if([timeToStopProcessThread condition]){
            queueCount = [transferQueue count];
            if(!flushMessagePrintedOnce){
                if(queueCount){
                    NSLog(@"flushing %d block%@ from listening queue\n",queueCount,(queueCount>1)?@"s ":@" ");
                }
                flushMessagePrintedOnce = YES;						
            }
            if(queueCount == 0){
                timeToQuit = YES;
            }
        }
        [pool release];
    } while(!timeToQuit);
    
	[[NSRunLoop currentRunLoop] run];
    [processLock unlockWithCondition:kProcessingDone];
    threadRunning = NO;
}

- (void) process:(NSMutableData*)dataChunk
{
	[self processRecords:dataChunk];    
}

- (void) processRecords:(NSMutableData*)dataChunk
{
    char* buffer = (char*)[dataChunk bytes];
    char* endPtr = buffer + [dataChunk length];
    while (buffer<endPtr) {
		NSAutoreleasePool* outerPool = [[NSAutoreleasePool allocWithZone:nil] init];
		unsigned long* lptr = (unsigned long*)buffer;
		
		if(expectingHeader){
			//this could be a header. Check it and see if we have to swap or not
			//the only way to do it effectively is to check for the <?xml string
			if([dataChunk length] >= 32){
				char* cptr = (char*)lptr;
				if(!strncmp(cptr+8,"<?xml ve",8)){
					expectingHeader = NO;
					//OK, we know this is a header.
					if((*lptr & 0xffff0000) != 0x0000){
						//the dataID for the header is always zero the length of the record is always non-zero -- this
						//gives us a way to determine endian-ness 
						[dataPacket setNeedToSwap:YES];
						CFSwapInt32(*lptr);			//swap the record header
						CFSwapInt32(*(lptr+1));		//swap the header byte length
					}
				}
			}
			else {
				[outerPool release];
				break;
			}
		}
		
		unsigned long recordHeader = *lptr;
		unsigned long dataId = ExtractDataId(recordHeader);
		if(dataId == 0x00000000){
			//new style headers always have a id of zero.
			unsigned long length = ExtractLength(recordHeader)*4; //bytes
			if(buffer + length <= endPtr){
				buffer+=4;	 //point to header length
				unsigned long headerLength = *((unsigned long*)buffer); //bytes
				//we have the whole header, extract it for use
				buffer+=4;	 //point to header itself

				NSString* theHeader = [[NSString alloc] initWithBytes:buffer length:headerLength encoding:NSASCIIStringEncoding];
				[dataPacket setFileHeader:[theHeader propertyList]]; 
				[theHeader release];
                [dataPacket generateObjectLookup];
				buffer += length-4-4;
				runDataID = [[dataPacket headerObject:@"dataDescription",@"ORRunModel",@"Run",@"dataId",nil] longValue];
				
			}
		}
		else {
			BOOL endOfRun = NO;
		    while (buffer<endPtr) {
				NSAutoreleasePool* innerPool = [[NSAutoreleasePool allocWithZone:nil] init];

				//OK, regular record
				lptr = (unsigned long*)buffer;
				recordHeader = *lptr;
				dataId = ExtractDataId(recordHeader);
				unsigned long length = ExtractLength(recordHeader)*4; //bytes
				if(buffer + length <= endPtr){
					if(dataId == runDataID){
						lptr++;
						unsigned long firstWord = *lptr;
						if(!(firstWord & 0x8)){
							if(firstWord & 0x1){
								NSLog(@"Listener: Run Start on Host: %@\n",remoteHost);
							}
							else {
								//it's an end of run record --  we have some end of run cleanup to handle
								NSLog(@"Listener: Run Ended on Host: %@\n",remoteHost);
								//OK end of run received
								endOfRun = YES;
							}
						}
					}
					[dataPacket addData:[NSMutableData dataWithBytes:buffer length:length]];
					
					[theNextObject processData:dataPacket userInfo:nil];
					if(endOfRun){
						[self performSelectorOnMainThread:@selector(sendRunTaskStopped:) withObject:dataPacket waitUntilDone:YES];
						[dataPacket clearData];
						[self performSelectorOnMainThread:@selector(sendCloseOutRun:)    withObject:dataPacket waitUntilDone:YES];
						[self performSelectorOnMainThread:@selector(clearByteCount)      withObject:nil        waitUntilDone:YES];
						expectingHeader = YES;
					}
					[dataPacket clearData];
					buffer += length;
				}
				else {
					[innerPool release];
					break;
				}
				[innerPool release];
			}
			
			//remove processed data
			unsigned long newLength = endPtr - buffer;
			[dataToProcess replaceBytesInRange:NSMakeRange(0,(unsigned long)(endPtr-buffer)) withBytes:buffer];
			[dataToProcess setLength:newLength];
			break;
		}
		[outerPool release];
	}
}

- (void) startProcessing
{
    if(!threadRunning && [socket isConnected]){
        theNextObject =  [self objectConnectedTo: ORListenerConnector];
        [self setByteCount:0];
        if(!transferQueue){
            [self setTransferQueue:[[[ORSafeQueue alloc] init] autorelease]];
        }
        dataToProcess = [[NSMutableData alloc] init];
        //set up the process thread control lock
        if( timeToStopProcessThread ) [ timeToStopProcessThread release ];
        timeToStopProcessThread  = [[ NSConditionLock alloc ] initWithCondition: NO ];
        [timeToStopProcessThread lockWhenCondition:NO];
        [NSThread detachNewThreadSelector:@selector(processDataFromQueue) toTarget:self withObject:nil];
    }        
}

- (void) stopProcessing
{
    if(threadRunning){
        [timeToStopProcessThread unlockWithCondition: YES];
        
        //....wait for processing to finish.....
        //wait for the processing thread to exit.
        BOOL timeout = NO;
        NSTimeInterval t0 = [NSDate timeIntervalSinceReferenceDate];
        while(![processLock tryLockWhenCondition:kProcessingDone]){
            [NSThread sleepUntilDate:[[NSDate date] addTimeInterval:.01]];
            if([NSDate timeIntervalSinceReferenceDate]-t0 > 10){
                timeout = YES;
                threadRunning = NO;
                break;
            }
        }
        if(!timeout)[processLock unlock];
        //
        [dataToProcess release];
		dataToProcess = nil;
        [self setByteCount:0];
        [dataPacket release];
        dataPacket = nil;
        [socket readData];
    }
}

- (void) reConnect
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reConnect) object:nil];
    [self connectSocket:YES];
}


@end

@implementation ORListenerModel (private)
//these exist so the process thread can do some work in the main thread
- (void) sendRunTaskStarted:(ORDataPacket*)aDataPacket
{
	[theNextObject runTaskStarted:aDataPacket userInfo:nil];
}

- (void) sendRunTaskStopped:(ORDataPacket*)aDataPacket
{
	[theNextObject runTaskStopped:aDataPacket userInfo:nil];
}

- (void) sendCloseOutRun:(ORDataPacket*)aDataPacket
{
	[theNextObject closeOutRun:aDataPacket userInfo:nil];
}

@end