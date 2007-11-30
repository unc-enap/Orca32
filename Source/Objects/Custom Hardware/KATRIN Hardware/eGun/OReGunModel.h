//--------------------------------------------------------
// OReGunModel
// Created by Mark  A. Howe on Wed Nov 28, 2007
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

@class ORObjectProxy;

#define kNumTrackPoints 100

@interface OReGunModel : OrcaObject
{
    @private
		id				x220Object;
		id				y220Object;
        NSPoint         cmdPosition;
        NSPoint         goalPosition;
        int             pollCount;
        BOOL            absMotion;
        BOOL            goingHome;
        unsigned        currentTrackIndex;
        unsigned        validTrackCount;
        NSPoint         track[kNumTrackPoints];
		float			voltsPerMillimeter;
        BOOL            moving;
		unsigned short	chanX;
		unsigned short	chanY;
		BOOL			noHysteresis;
    int viewType;
 }

#pragma mark ***Initialization

- (id)   init;
- (void) dealloc;

#pragma mark ***Accessors
- (int) viewType;
- (void) setViewType:(int)aViewType;
- (BOOL) noHysteresis;
- (void) setNoHysteresis:(BOOL)aNoHysteresis;
- (float) voltsPerMillimeter;
- (void) setVoltsPerMillimeter:(float)aVoltsPerMillimeter;
- (unsigned short) chanY;
- (void) setChanY:(unsigned short)aChanY;
- (unsigned short) chanX;
- (void) setChanX:(unsigned short)aChanX;
- (ORObjectProxy*) x220Object;
- (ORObjectProxy*) y220Object;
- (BOOL) moving;
- (void) setMoving:(BOOL)aMoving;
- (unsigned)currentTrackIndex;
- (unsigned)validTrackCount;
- (NSPoint) track:(unsigned)i;

- (BOOL) absMotion;
- (void) setAbsMotion:(BOOL)aAbsMotion;
- (NSPoint) cmdPosition;
- (void) setCmdPosition:(NSPoint)aCmdPosition;
- (NSPoint) xyVoltage;
- (void) updateTrack;
- (void) resetTrack;

#pragma mark ***eGun Commands
- (void) getPosition;
- (void) go;
- (void) moveToPoint:(NSPoint)aPoint;
- (void) move:(NSPoint)delta;
- (void) stopMotion;

- (id)   initWithCoder:(NSCoder*)decoder;
- (void) encodeWithCoder:(NSCoder*)encoder;
@end

extern NSString* OReGunModelViewTypeChanged;
extern NSString* OReGunModelNoHysteresisChanged;
extern NSString* OReGunModelVoltsPerMillimeterChanged;
extern NSString* OReGunModelChanYChanged;
extern NSString* OReGunModelChanXChanged;
extern NSString* OReGunModelEndEditing;
extern NSString* OReGunModelMovingChanged;

extern NSString* OReGunModelAbsMotionChanged;
extern NSString* OReGunModelCmdPositionChanged;
extern NSString* OReGunModelPositionChanged;
extern NSString* OReGunX220NameChanged;
extern NSString* OReGunY220NameChanged;
extern NSString* OReGunX220ObjectChanged;
extern NSString* OReGunY220ObjectChanged;

extern NSString* OReGunLock;
