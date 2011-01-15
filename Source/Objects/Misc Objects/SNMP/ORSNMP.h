//
//  ORSNMP.h
//  Orca
//
//  Created by Mark Howe on Tues Jan 11,2011
//  Copyright (c) 2011 University of North Carolina. All rights reserved.
//-----------------------------------------------------------
//This program was prepared for the Regents of the University of 
//North Carolina Department of Physics and Astrophysics 
//sponsored in part by the United States 
//Department of Energy (DOE) under Grant #DE-FG02-97ER41020. 
//The University has certain rights in the program pursuant to 
//the contract and the program should not be copied or distributed 
//outside your organization.  The DOE and the University of 
//North Carolina reserve all rights in the program. Neither the authors,
//University of North Carolina, or U.S. Government make any warranty, 
//express or implied, or assume any liability or responsibility 
//for the use of this software.
//-------------------------------------------------------------

#include <net-snmp/net-snmp-config.h>
#include <net-snmp/net-snmp-includes.h>

@interface ORSNMP : NSObject {
	struct snmp_session session; 
	struct snmp_session* sessionHandle;
	NSString* mibName;
}
- (id) initWithMib:(NSString*)aMibName;
- (void) dealloc;
- (void) openGuruSession:(NSString*)ip;  
- (void) openPublicSession:(NSString*)ip;  
- (void) openSession:(NSString*)ip community:(NSString*)aCommunity;
- (NSArray*) readValue:(NSString*)anObjId;
- (NSArray*) readValues:(NSArray*)someObjIds;
- (NSArray*) writeValue:(NSString*)anObjId;
- (void) writeValues:(NSArray*)someObjIds;
- (void) closeSession;

- (void) topLevelParse:(NSString*)s intoDictionary:(NSMutableDictionary*)aDictionary;
- (void) parseParmAndMibName:(NSString*)s intoDictionary:(NSMutableDictionary*)aDictionary;
- (void) parseParameterName:(NSString*)s intoDictionary:(NSMutableDictionary*)aDictionary;
- (void) parseParamTypeAndValue:(NSString*)s intoDictionary:(NSMutableDictionary*)aDictionary;
- (void) parseParamValue:(NSString*)s intoDictionary:(NSMutableDictionary*)aDictionary;
- (void) parseNumberWithUnits:(NSString*)s intoDictionary:(NSMutableDictionary*)aDictionary;

@end
