//--------------------------------------------------------
// ORMotoGPSModel
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
//for the use of this software.
//-------------------------------------------------------------

#pragma mark ***Imported Files

@class ORRefClockModel;

// #define kWGRemoteCmd	'R'
// #define kWGFreqCmd 'F'
// #define kWGAttCmd 'Q'
// #define kWGAmpltCmd 'A'
// #define kWGDutyCCmd 'D'
// #define kWGFormCmd 'K'
// #define kWGProgModCmd 'C'
// #define kWGStartProgCmd 'B'
// #define kWGRdyPrgrmCmd 'b'
// #define kWGStopPrgrmCmd 'U'
// #define kWGFinPrgrmCmd 'u'

@interface ORMotoGPSModel : NSObject
{
    @private
        ORRefClockModel* refClock;

        // int reTxCount;  // in case of errors or timeout retransmit; if retransmit
        // // is required, put last command to cmdQueue and dequeueFromBottom
        //
        int  cableDelayNs;
        BOOL statusPoll;
        NSString* lastRecTelegram;
}

#pragma mark ***Initialization
- (void) dealloc;

#pragma mark ***Accessors
- (void) setRefClock:(ORRefClockModel*)aRefClock;
- (void) setDefaults;
- (void) requestStatus;
- (BOOL) portIsOpen;
- (BOOL) statusPoll;
- (void) setStatusPoll:(BOOL)aStatusPoll;
- (int) CableDelay;
- (void) setCableDelay:(int)aDelay;
- (NSString*) lastReceived;

#pragma mark ***Commands
- (void) writeData:(NSDictionary*)aDictionary;
- (void) processResponse:(NSData*)someData;
- (NSDictionary*) defaultsCommand;

#pragma mark ***Archival
- (id)   initWithCoder:(NSCoder*)decoder;
- (void) encodeWithCoder:(NSCoder*)encoder;
@end

extern NSString* ORMotoGPSModelSetDefaultsChanged;
extern NSString* ORMotoGPSModelTrackModeChanged;
extern NSString* ORMotoGPSModelSyncChanged;
extern NSString* ORMotoGPSModelAlarmWindowChanged;
extern NSString* ORMotoGPSModelStatusChanged;
extern NSString* ORMotoGPSModelStatusPollChanged;
extern NSString* ORMotoGPSModelReceivedMessageChanged;

