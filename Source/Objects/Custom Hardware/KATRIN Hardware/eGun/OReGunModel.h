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
        NSPoint         degaussPosition;
        int             pollCount;
        BOOL            absMotion;
        BOOL            goingHome;
        unsigned        currentTrackIndex;
        unsigned        validTrackCount;
        NSPoint         track[kNumTrackPoints];
		float			millimetersPerVolt;
        BOOL            moving;
		unsigned short	chanX;
		unsigned short	chanY;
		BOOL			firstPoint;
		int				viewType;
		float			excursion;
		float			decayRate;
		float			decayTime;
		int				state;
    NSString* stateString;
    float overshoot;
    float stepTime;
 }

#pragma mark ***Initialization

- (id)   init;
- (void) dealloc;

#pragma mark ***Accessors
- (float) stepTime;
- (void) setStepTime:(float)aStepTime;
- (float) overshoot;
- (void) setOvershoot:(float)aOvershoot;
- (NSString*) stateString;
- (void) setStateString:(NSString*)aStateString;
- (float) decayTime;
- (void) setDecayTime:(float)aDecayTime;
- (float) decayRate;
- (void) setDecayRate:(float)aDecayRate;
- (float) excursion;
- (void) setExcursion:(float)aExcursion;
- (int) viewType;
- (void) setViewType:(int)aViewType;
- (float) millimetersPerVolt;
- (void) setMillimetersPerVolt:(float)aMillimetersPerVolt;
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
- (void) stopMotion;
- (void) loadBoard;
- (void) degauss;

- (id)   initWithCoder:(NSCoder*)decoder;
- (void) encodeWithCoder:(NSCoder*)encoder;
@end

extern NSString* OReGunModelStepTimeChanged;
extern NSString* OReGunModelOvershootChanged;
extern NSString* OReGunModelStateStringChanged;
extern NSString* OReGunModelDecayTimeChanged;
extern NSString* OReGunModelDecayRateChanged;
extern NSString* OReGunModelExcursionChanged;
extern NSString* OReGunModelViewTypeChanged;
extern NSString* OReGunModelMillimetersPerVoltChanged;
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
