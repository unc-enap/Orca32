//--------------------------------------------------------
// PCM_Link
// Created by Andreas Kopmann on 17.3.2008
// Code partially generated by the OrcaCodeWizard. Written by Mark A. Howe.
// Copyright (c) 2006 CENPA, University of Washington. All rights reserved.
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

#pragma mark ���Imported Files

#import "PCM_Link.h"


@implementation PCM_Link

#pragma mark ���Accessors

- (void) readLongBlockPbus:(unsigned long *) buffer
				 atAddress:(unsigned int) aPbusAddress
				 numToRead:(unsigned int) numberLongs
{
	@try {
		[socketLock lock]; //begin critical section
		SBC_Packet aPacket;
		aPacket.cmdHeader.destination			= kSBC_Process;
		aPacket.cmdHeader.cmdID					= kSBC_ReadBlock;
		aPacket.cmdHeader.numberBytesinPayload	= sizeof(SBC_IPEv4ReadBlockStruct);
		
		SBC_IPEv4ReadBlockStruct* readBlockPtr = (SBC_IPEv4ReadBlockStruct*)aPacket.payload;
		readBlockPtr->address			= aPbusAddress;
		readBlockPtr->numItems			= numberLongs;
		
        NSLog(@"Addr = %08x, n=%d\n", readBlockPtr->address<<2, readBlockPtr->numItems);
		
		//Do NOT call the combo send:receive method here... we have the locks already in place
		[self write:socketfd buffer:&aPacket];	//write the packet
        NSLog(@"-tb- Sending a packet, waiting for response ...\n");
		[self read:socketfd buffer:&aPacket];		//read the response
        NSLog(@"-tb- Got the response ...\n");
		
		SBC_IPEv4ReadBlockStruct* rp = (SBC_IPEv4ReadBlockStruct*)aPacket.payload;
        NSLog(@"Addr = %08x, n=%d (err=%d)\n", rp->address, rp->numItems, rp->errorCode);
		
		if(!rp->errorCode){		
			int num = rp->numItems;
			
			rp++;
			memcpy(buffer,rp,num*sizeof(long));
            NSLog(@"n=%d: %08x\n", num, buffer[0]);
		}
		else [self throwError:rp->errorCode address:aPbusAddress];
		[socketLock unlock]; //end critical section
	}
	@catch(NSException* localException) {
		[socketLock unlock]; //end critical section
		[localException raise];
	}
}



- (void) writeLongBlockPbus:(unsigned long *) buffer
				  atAddress:(unsigned int) aPbusAddress
				 numToWrite:(unsigned int) numberLongs
{
	
	@try {
		[socketLock lock]; //begin critical section
		
		SBC_Packet aPacket;
		aPacket.cmdHeader.destination			= kSBC_Process;
		aPacket.cmdHeader.cmdID					= kSBC_WriteBlock;
		aPacket.cmdHeader.numberBytesinPayload	= sizeof(SBC_VmeWriteBlockStruct) + numberLongs*sizeof(long);
		
		SBC_IPEv4WriteBlockStruct* writeBlockPtr = (SBC_IPEv4WriteBlockStruct*)aPacket.payload;
		writeBlockPtr->address			= aPbusAddress;
		writeBlockPtr->numItems			= numberLongs;
		writeBlockPtr++;				//point to the payload
		memcpy(writeBlockPtr,buffer,numberLongs*sizeof(long));
		
		//Do NOT call the combo send:receive method here... we have the locks already in place
		[self write:socketfd buffer:&aPacket];	//write the packet
		[self read:socketfd buffer:&aPacket];		//read the response
		
		SBC_IPEv4ReadBlockStruct* rp = (SBC_IPEv4ReadBlockStruct*)aPacket.payload;
		if(rp->errorCode)[self throwError:rp->errorCode address:aPbusAddress];
		[socketLock unlock]; //end critical section
	}
	@catch(NSException* localException) {
		[socketLock unlock]; //end critical section
		[localException raise];
	}
	
}


@end