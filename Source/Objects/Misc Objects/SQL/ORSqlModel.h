//-------------------------------------------------------------------------
//  ORSqlModel.h
//
//  Created by Mark A. Howe on Wednesday 10/18/2006.
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

#pragma mark ***Imported Files

@interface ORSqlModel : OrcaObject
{
  @private
	BOOL		dbConnectionVerified;
	NSString*	hostName;
    NSString*	userName;
    NSString*	password;
    NSString*	dataBaseName;
	NSMutableData* responseData;
    NSString* webSitePath;
	NSMutableArray* dataMonitors;
}

#pragma mark ***Initialization
- (id)   init;
- (void) dealloc;
- (void) registerNotificationObservers;


#pragma mark ***Accessors
- (NSString*) webSitePath;
- (void) setWebSitePath:(NSString*)aWebSitePath;
- (void) setConnected:(BOOL) aState;
- (NSString*) dataBaseName;
- (void) setDataBaseName:(NSString*)aDataBaseName;
- (NSString*) password;
- (void) setPassword:(NSString*)aPassword;
- (NSString*) userName;
- (void) setUserName:(NSString*)aUserName;
- (NSString*) hostName;
- (void) setHostName:(NSString*)aHostName;

#pragma mark ***Archival
- (id)   initWithCoder:(NSCoder*)decoder;
- (void) encodeWithCoder:(NSCoder*)encoder;

- (BOOL) dbConnectionVerified;
-(void) apply;

@end

extern NSString* ORSqlModelWebSitePathChanged;
extern NSString* ORSqlDataBaseNameChanged;
extern NSString* ORSqlPasswordChanged;
extern NSString* ORSqlUserNameChanged;
extern NSString* ORSqlHostNameChanged;
extern NSString* ORDBConnectionVerifiedChanged;
extern NSString* ORSqlLock;
