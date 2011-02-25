//--------------------------------------------------------
// ORAdeiLoader
// Created by Mark  A. Howe on Sun Oct 11 2009
// Code partially generated by the OrcaCodeWizard. Written by Mark A. Howe.
// Copyright (c) 2009 University of North Carolina. All rights reserved.
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

#define kSensorType	0
#define kControlType	1
#define kRequestStringType	2
#define kcsvFormat 0
#define kxmlFormat 1
#define kmsgFormat 2  //this is for messages like <result>Ok</result> or <result>Error</result>

#define kTimeoutInterval 10.0
// #define kTimeoutInterval 15.0

#if defined(MAC_OS_X_VERSION_10_6) && MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_6 // 10.6-specific
@interface ORAdeiLoader : NSObject <NSXMLParserDelegate> {
#else																						// pre-10.6 fallback
@interface ORAdeiLoader : NSObject {
#endif
	NSString*			host;
	NSURLConnection*	theAdeiConnection;
	NSMutableData*		receivedData;
	NSMutableArray*		resultArray;
	BOOL				recursive;
	int					adeiType;
	id					delegate;
	NSMutableString*	path;
	SEL					didFinishSelector;
	BOOL				dataFormat;
	BOOL				fastGenOption;
	NSArray*			setupOptions;
    
	BOOL				showDebugOutput;
}

+ (id)	 loaderWithAdeiHost:(NSString*)aHost adeiType:(int)aType delegate:(id)aDelegate didFinishSelector:(SEL)aSelector setupOptions:(NSArray*)setupOptions;
+ (id)	 loaderWithAdeiHost:(NSString*)aHost adeiType:(int)aType delegate:(id)aDelegate didFinishSelector:(SEL)aSelector;
+ (id)	 loaderWithAdeiType:(int)aType delegate:(id)aDelegate didFinishSelector:(SEL)aSelector;
- (id)	 initWithAdeiHost:(NSString*)aHost adeiType:(int)aType delegate:(id)aDelegate didFinishSelector:(SEL)aSelector;
- (id)	 initWithAdeiHost:(NSString*)aHost adeiType:(int)aType delegate:(id)aDelegate didFinishSelector:(SEL)aSelector setupOptions:(NSArray*)setupOptions;
- (void) dealloc;
- (void) parseXMLData:(NSData *)xmlData;
- (void) parseCSVData:(NSData *)xmlData;
- (void) loadPath:(NSString*)aPath recursive:(BOOL)aFlag;
- (void) requestItem:(NSString*)aPath;
- (void) requestSensorItem:(NSString*)aPath;
- (void) requestControlItem:(NSString*)aPath;
- (void) setControlSetpoint:(NSString*)aPath value:(double)aValue;
- (void) sendControlSetpoint:(NSString*)aPath value:(double)aValue;
- (void) sendRequestString:(NSString*)requestString;
- (void) setShowDebugOutput:(BOOL) aOption;
- (BOOL) showDebugOutput;

#pragma mark •••Helpers
+ (NSString*) controlItemRequestStringUrl:(NSString*)aUrl itemPath:(NSString*)aPath;
+ (NSString*) sensorItemRequestStringUrl:(NSString*)aUrl itemPath:(NSString*)aPath;
+ (NSString*) webRequestStringUrl:(NSString*)url itemPath:(NSString*)path;

#pragma mark ***Delegate Methods for connection
- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void) connection:(NSURLConnection *)connection  didFailWithError:(NSError *)error;
- (void) connectionDidFinishLoading:(NSURLConnection *)connection;

#pragma mark ***Delegate Methods for XML parsing
- (void) parser:(NSXMLParser*) parser
didStartElement:(NSString*) elementName
   namespaceURI:(NSString*) namespaceURI
  qualifiedName:(NSString*) qName
	 attributes:(NSDictionary*) attributeDict;

@end
