//
//  ORCaen965Decoder.m
//  Orca
//
//  Created by Mark Howe on Wed Dec 9, 2009.
//  Copyright (c) 2009 University of North Carolina. All rights reserved.
//-----------------------------------------------------------
//This program was prepared for the Regents of the University of 
//Carolina sponsored in part by the United States 
//Department of Energy (DOE) under Grant #DE-FG02-97ER41020. 
//The University has certain rights in the program pursuant to 
//the contract and the program should not be copied or distributed 
//outside your organization.  The DOE and the University of 
//Carolina reserve all rights in the program. Neither the authors,
//University of Carolina, or U.S. Government make any warranty, 
//express or implied, or assume any liability or responsibility 
//for the use of this software.
//-------------------------------------------------------------

#import "ORCaen965Decoder.h"
#import "ORDataSet.h"

@implementation ORCaen965DecoderForQdc

- (unsigned long) decodeData:(void*) aSomeData fromDecoder:(ORDecoder*)aDecoder intoDataSet:(ORDataSet*) aDataSet
{
    short i;
    long* ptr = (long*) aSomeData;
	long length = ExtractLength(ptr[0]);
	NSString* crateKey = [self getCrateKey:ShiftAndExtract(ptr[1],21,0x0000000f)];
	NSString* cardKey  = [self getCardKey: ShiftAndExtract(ptr[1],16,0x0000001f)];
    for( i = 2; i < length; i++ ){
		int dataType = ShiftAndExtract(ptr[i],24,0x7);
		if(dataType == 0x0){
			int qdcValue = ShiftAndExtract(ptr[i],0,0xfff);
			int chan     = ShiftAndExtract(ptr[i],17,0xf);
			NSString* channelKey  = [self getChannelKey: chan];
			[aDataSet histogram:qdcValue numBins:0xfff sender:self withKeys:@"CAEN965 QDC",crateKey,cardKey,channelKey,nil];
        }
    }
    return length;
}

- (NSString*) dataRecordDescription:(unsigned long*)ptr
{
	long length = ExtractLength(ptr[0]);
    NSString* title= @"CAEN965 QDC Record\n\n";

    NSString* len	=[NSString stringWithFormat: @"# QDC = %d\n",length-2];
    NSString* crate = [NSString stringWithFormat:@"Crate = %d\n",(ptr[1] >> 21)&0x0000000f];
    NSString* card  = [NSString stringWithFormat:@"Card  = %d\n",(ptr[1] >> 16)&0x0000001f];    
   
    NSString* restOfString = [NSString string];
    int i;
    for( i = 2; i < length; i++ ){
		int dataType = ShiftAndExtract(ptr[i],24,0x7);
		if(dataType == 0x0){
			int qdcValue = ShiftAndExtract(ptr[i],0,0xfff);
			int channel  = [self channel:ptr[i]];
			restOfString = [restOfString stringByAppendingFormat:@"Chan  = %d  Value = %d\n",channel,qdcValue];
        }
    }

    return [NSString stringWithFormat:@"%@%@%@%@%@",title,len,crate,card,restOfString];               
}

- (void) printData: (NSString*) pName data:(void*) theData
{
    short i;
    long* ptr = (long*)theData;
    
	long length = ExtractLength(ptr[0]);
	NSString* crateKey = [self getCrateKey:ShiftAndExtract(ptr[1],21,0xf)];
	NSString* cardKey  = [self getCardKey: ShiftAndExtract(ptr[i],16,0x1f)];
	
    if( length == 0 ) NSLog( @"%@ Data Buffer is empty.\n", pName );
    else {
        NSLog(@"Data Buffer for %@ %@\n",crateKey,cardKey);        
        for( i = 2; i < length; i++ ){
            if( ShiftAndExtract(ptr[i],24,0x7) == 0x0){ //is valid data?
                NSLogFont([NSFont fontWithName:@"Monaco" size:12],  @"Chan: %2d  (un:%d ov:%d) qdc: 0x%x\n", 
													[self channel:ptr[i]],
													ShiftAndExtract(ptr[i],13,0x1),
													ShiftAndExtract(ptr[i],12,0x1),
													ShiftAndExtract(ptr[i],0,0xfff));
            }
        }
    }
}

- (unsigned short) channel: (unsigned long) pDataValue
{
    return	ShiftAndExtract(pDataValue,17,0xf);
}

@end

@implementation ORCaen965ADecoderForQdc

- (unsigned short) channel: (unsigned long) pDataValue
{
    return	ShiftAndExtract(pDataValue,18,0x7);
}

@end


