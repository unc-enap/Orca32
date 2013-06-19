/***************************************************************************
    ipe4tbtools.cpp  -  description: tools for the IPE4 Edelweiss readout ipe4reader
                        AND Orca
	history: see below

    begin                : July 07 2012
    copyright            : (C) 2011 by Till Bergmann, KIT
    email                : Till.Bergmann@kit.edu
 ***************************************************************************/







// DO NOT COMPILE THIS FILE!!!


// INCLUDE IT FROM OTHER *.cpp/*.cc files, 
// include ipe4tbtools.h in the according *. files
// -tb- 2013-01







//This is the version of the IPE4 readout code (display is: version/1000, so cew_controle will display 1934003 as 1934.003) -tb-
// VERSION_IPE4_HW is 1934 which means IPE4  (1=I, 9=P, 3=E, 4=4)
// VERSION_IPE4_SW is the version of the readout software (this file)
#define VERSION_IPE4_HW      1934200
#define VERSION_IPE4_SW           10
#define VERSION_IPE4READOUT (VERSION_IPE4_HW + VERSION_IPE4_SW)

/* History:
version 2: 2013 June
           multi FIFO on SLT; FLT-Trigger
version 1: 2013 January
           changed name from ipe4reader6 to ipe4reader;
           added ipe4reader to Orca svn repository
               in shell use:
               (cd ORCA;make -f Makefile.ipe4reader; cd ..)
               (cd ORCA; ./ipe4reader ; cd ..)
           veto flag setting for ipe4reader config file
           FiberOutMask (FLT register) -> Orca GUI
           prohibit write access to not existing FLTs (Orca and ipe4reader)
           sending crate and BB status packet with ipe4reader and receiving it with Orca
           
*/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <time.h>
#include <errno.h>
#include <libgen.h> //for basename
#include <stdint.h>  //for uint32_t etc.

#include <signal.h> //for kill/SIGTERM

/*--------------------------------------------------------------------
 *    functions
 *       
 *--------------------------------------------------------------------*/ //-tb-


// return slot associated to a address (1..20=FLT #1..#20, slot>=21 means SLT address); address = PCI-address
int slotOfPCIAddr(uint32_t address)
{
    return (address >> 19) & 0x1f;
}

// return slot associated to a address (1..20=FLT #1..#20, slot>=21 means SLT address); address = PCI-address>>2
int slotOfAddr(uint32_t address)
{
    return (address >> 17) & 0x1f;
}

int numOfBits(uint32_t val)
{
    int i,num=0;
    for(i=0; i<32;i++){
        if(val & (0x1<<i)) num++;
    }
    //printf("numOfBits: val 0x%08x has %i bits\n",val,num);
    return num;
}

int count_ipe4reader_instances(void)
{
	char buf[1024 * 4];
	char *cptr;
	FILE *p;
	int counter = 0;
	p = popen("ps -e |grep ipe4reader | wc -l","r");
	if(p==0){ fprintf(stderr, "could not start popen... -tb-\n"); return counter; }
	
	while (!feof(p)){
	    fscanf(p,"%s",buf);
        counter = atoi(buf);
	    //printf("count_ipe4reader_instances is: %i\n",counter);
		if(feof(p)) break; //??? is this necessary??? -tb-
	};

	pclose(p);
	//printf("count_ipe4reader_instances is: %i\n",counter);
	return counter;
}

//kill all ipe4reader* instances except myself
//
//shell commands to get the list of IP addresses, each in a single line
//ps -e | awk '/bergmann/{ print $1 }'
//  -> removes leading whitespace
//ps -e | grep bergmann | cut  -c 1-6
int kill_ipe4reader_instances(void)
{
	    printf("running 'int kill_ipe4reader_instances(void)'\n");
    int pid = getpid();
	    printf("    kill_ipe4reader_instances()': my own PID is %i\n",pid);
	char buf[1024 * 4];
	char *cptr;
	FILE *p;
	int val = 0;
	p = popen("ps -e | awk '/ipe4reader/{ print $1 }'","r");
	if(p==0){ fprintf(stderr, "could not start popen... -tb-\n"); return -1; }
	sleep(1);
	while (!feof(p)){
	    fscanf(p,"%s",buf);
		//if(feof(p)) printf("... if(feof(p))  ...\n"); //I think on Mac this was to early and we would have lost one line of return values -tb-
        val = atoi(buf);
	    printf("Found PID >%s<; kill_ipe4reader_instances: PID is: %i\n",buf,val);
        if(pid != val){
	        printf("kill -s SIGTERM %i\n",val);
            kill(val,SIGTERM);
        }
		if(feof(p)){
            printf("... if(feof(p))  ...  break\n");
            break; //??? is this necessary??? -tb-
        }
	};

	pclose(p);
	//printf("kill_ipe4reader_instances is: %i\n",counter);
	return val;
}


   /* 
     fifoReadsFLTIndex: FIFO-to-FLT mapping
     --------------------------------------------------------------------*/
//FIFO-to-FLT mapping 
int fifoReadsFLTIndexChecker(int fltIndex, int numfifo, int availableNumFIFO, int maxNumFIFO)
{
    if(availableNumFIFO==0) return 1;//this was the 'old' firmware: all FLTs to one FIFO (however, 'availableNumFIFO' should be 1)
    
    if(availableNumFIFO==1){
        if(numfifo==0 && fltIndex>=0 && fltIndex<maxNumFIFO)
            return 1;
        else
            return 0;
    }
    
    if(availableNumFIFO==8){//mapping: fifo0=FLT0,1; fifo1=FLT2,3; fifo2=FLT4,5; fifo3=FLT6,7; ...
        if(fltIndex>=0 && fltIndex<maxNumFIFO){
            return (fltIndex >>1) == numfifo;
        }else
            return 0;
    }
    
    if(availableNumFIFO==4){//mapping: fifo0=FLT0,1,2,3; fifo1=FLT4,5,6,7; fifo2=FLT8,9,10,11; fifo3=FLT12,13,14,15
        if(fltIndex>=0 && fltIndex<maxNumFIFO){
            return (fltIndex >> 2) == numfifo;
        }else
            return 0;
    }
    
    if(availableNumFIFO==2){//mapping: fifo0=FLT0,1,2,3,4,5,6,7; fifo1=FLT8,9,10,11,12,13,14,15
        if(fltIndex>=0 && fltIndex<maxNumFIFO){
            return (fltIndex >> 3) == numfifo;
        }else
            return 0;
    }
    
    return 0;
}

/*--------------------------------------------------------------------
  includes
  --------------------------------------------------------------------*/


/*--------------------------------------------------------------------
  globals and functions for hardware access
  --------------------------------------------------------------------*/
#include <Pbus/Pbus.h>
#include <akutil/semaphore.h>

#pragma warning TODO remove -lkatrinhw4 in Makefile
//#include "hw4/baseregister.h"
//#include "Pbus/pbusimp.h"
//#include "katrinhw4/subrackkatrin.h"
//#include "katrinhw4/sltkatrin.h"
//#include "katrinhw4/fltkatrin.h"









#if 0
//defined in ipe4tbtools.h

//TODO: use this for ipe4reader AND Orca -tb-


    //SLT registers
	static const uint32_t SLTControlReg			= 0xa80000 >> 2;
	static const uint32_t SLTStatusReg			= 0xa80004 >> 2;
	static const uint32_t SLTCommandReg			= 0xa80008 >> 2;
	static const uint32_t SLTInterruptMaskReg	= 0xa8000c >> 2;
	static const uint32_t SLTInterruptRequestReg= 0xa80010 >> 2;
	static const uint32_t SLTVersionReg			= 0xa80020 >> 2;

	static const uint32_t SLTPixbusPErrorReg     = 0xa80024 >> 2;
	static const uint32_t SLTPixbusEnableReg     = 0xa80028 >> 2;
	static const uint32_t SLTBBOpenedReg         = 0xa80034 >> 2;

	
	static const uint32_t SLTSemaphoreReg    = 0xb00000 >> 2;
	
	static const uint32_t CmdFIFOReg         = 0xb00004 >> 2;
	static const uint32_t CmdFIFOStatusReg   = 0xb00008 >> 2;
	static const uint32_t OperaStatusReg0    = 0xb0000c >> 2;
	static const uint32_t OperaStatusReg1    = 0xb00010 >> 2;
	static const uint32_t OperaStatusReg2    = 0xb00014 >> 2;
	
	static const uint32_t FIFO0Addr         = 0xd00000 >> 2;
	
	//TODO: multiple FIFOs are obsolete, remove it -tb-
	static const uint32_t FIFO0ModeReg      = 0xe00000 >> 2;//obsolete 2012-10 
	static const uint32_t FIFO0StatusReg    = 0xe00004 >> 2;//obsolete 2012-10
	static const uint32_t BB0PAEOffsetReg   = 0xe00008 >> 2;//obsolete 2012-10
	static const uint32_t BB0PAFOffsetReg   = 0xe0000c >> 2;//obsolete 2012-10
	static const uint32_t BB0csrReg         = 0xe00010 >> 2;//obsolete 2012-10
	
	#if 0
	static const uint32_t FIFOModeReg       = 0xe00000 >> 2;
	static const uint32_t FIFOStatusReg     = 0xe00004 >> 2;
	static const uint32_t PAEOffsetReg      = 0xe00008 >> 2;
	static const uint32_t PAFOffsetReg      = 0xe0000c >> 2;
	static const uint32_t FIFOcsrReg        = 0xe00010 >> 2;
    #endif

	static const uint32_t SLTTimeLowReg     = 0xb00018 >> 2;
	static const uint32_t SLTTimeHighReg    = 0xb0001c >> 2;




    //FLT registers
	static const uint32_t FLTStatusRegBase      = 0x000000 >> 2;
	static const uint32_t FLTControlRegBase     = 0x000004 >> 2;
	static const uint32_t FLTCommandRegBase     = 0x000008 >> 2;
	static const uint32_t FLTVersionRegBase     = 0x00000c >> 2;
	
	static const uint32_t FLTFiberSet_1RegBase  = 0x000024 >> 2;
	static const uint32_t FLTFiberSet_2RegBase  = 0x000028 >> 2;
	static const uint32_t FLTStreamMask_1RegBase  = 0x00002c >> 2;
	static const uint32_t FLTStreamMask_2RegBase  = 0x000030 >> 2;
	static const uint32_t FLTTriggerMask_1RegBase  = 0x000034 >> 2;
	static const uint32_t FLTTriggerMask_2RegBase  = 0x000038 >> 2;

	static const uint32_t FLTAccessTestRegBase     = 0x000040 >> 2;
	
	static const uint32_t FLTTotalTriggerNRegBase  = 0x000084 >> 2;

	static const uint32_t FLTBBStatusRegBase    = 0x00001400 >> 2;

	static const uint32_t FLTRAMDataRegBase     = 0x00003000 >> 2;









#endif



//SLT registers

	
inline uint32_t FIFOStatusReg(int numFIFO){
    return FIFO0StatusReg | ((numFIFO & 0xf) <<14);  //PCI adress would be <<16, but we use Pbus adress -tb-
}

inline uint32_t FIFOModeReg(int numFIFO){
    return FIFO0ModeReg | ((numFIFO & 0xf) <<14);  //PCI adress would be <<16, but we use Pbus adress -tb-
}

inline uint32_t FIFOAddr(int numFIFO){
    return FIFO0Addr | ((numFIFO & 0xf) <<14);  //PCI adress would be <<16, but we use Pbus adress -tb-
}

inline uint32_t PAEOffsetReg(int numFIFO){
    return BB0PAEOffsetReg | ((numFIFO & 0xf) <<14);  //PCI adress would be <<16, but we use Pbus adress -tb-
}

inline uint32_t PAFOffsetReg(int numFIFO){
    return BB0PAFOffsetReg | ((numFIFO & 0xf) <<14);  //PCI adress would be <<16, but we use Pbus adress -tb-
}

inline uint32_t BBcsrReg(int numFIFO){
    return BB0csrReg | ((numFIFO & 0xf) <<14);  //PCI adress would be <<16, but we use Pbus adress -tb-
}







//FLT registers


	
// 
// NOTE: numFLT from 1...20  !!!!!!!!!!!!
//
// (NOT from 0 ... 19!!!)
//
	//TODO: 0x3f or 0x1f?????????????
inline uint32_t FLTStatusReg(int numFLT){
    return FLTStatusRegBase | ((numFLT & 0x3f) <<17);  //PCI adress would be <<16, but we use Pbus adress -tb-
}

inline uint32_t FLTControlReg(int numFLT){
    return FLTControlRegBase | ((numFLT & 0x3f) <<17);  
}

inline uint32_t FLTCommandReg(int numFLT){
    return FLTCommandRegBase | ((numFLT & 0x3f) <<17);  
}

inline uint32_t FLTVersionReg(int numFLT){
    return FLTVersionRegBase | ((numFLT & 0x3f) <<17);  
}

inline uint32_t FLTFiberSet_1Reg(int numFLT){
    return FLTFiberSet_1RegBase | ((numFLT & 0x3f) <<17);  
}

inline uint32_t FLTFiberSet_2Reg(int numFLT){
    return FLTFiberSet_2RegBase | ((numFLT & 0x3f) <<17);  
}

inline uint32_t FLTStreamMask_1Reg(int numFLT){
    return FLTStreamMask_1RegBase | ((numFLT & 0x3f) <<17);  
}

inline uint32_t FLTStreamMask_2Reg(int numFLT){
    return FLTStreamMask_2RegBase | ((numFLT & 0x3f) <<17);  
}

inline uint32_t FLTTriggerMask_1Reg(int numFLT){
    return FLTTriggerMask_1RegBase | ((numFLT & 0x3f) <<17);  
}

inline uint32_t FLTTriggerMask_2Reg(int numFLT){
    return FLTTriggerMask_2RegBase | ((numFLT & 0x3f) <<17);  
}

inline uint32_t FLTAccessTestReg(int numFLT){
    return FLTAccessTestRegBase | ((numFLT & 0x3f) <<17); 
}

inline uint32_t FLTBBStatusReg(int numFLT, int numChan){
    return FLTBBStatusRegBase | ((numFLT & 0x3f) <<17) | ((numChan & 0x1f) <<12); 
}

inline uint32_t FLTTotalTriggerNReg(int numFLT){
    return FLTTotalTriggerNRegBase | ((numFLT & 0x3f) <<17);  
}


inline uint32_t FLTRAMDataReg(int numFLT, int numChan){
    return FLTRAMDataRegBase | ((numFLT & 0x3f) <<17) | ((numChan & 0x1f) <<12); 
}





/*--------------------------------------------------------------------
  globals and functions for hardware access
  --------------------------------------------------------------------*/
 
 
 /*--------------------------------------------------------------------
 *    function prototypes (moved from ipe4reader to provide access for OrcaReadout)
 *--------------------------------------------------------------------*/ //-tb-

 
/*--------------------------------------------------------------------
 *    function:     requestHWSemaphore, requestHWSemaphoreWaitUsec, releaseHWSemaphore
 *    purpose:      request/release HW semaphore on SLT to avoid conflicts 
 *                  on writing to command FIFO from 2 or more concurrent processes
 *    author:       Till Bergmann, 2011
 *
 *--------------------------------------------------------------------*/ //-tb-
int requestHWSemaphore(void)
{
    uint32_t sltSemaphore;
    sltSemaphore = pbus->read(SLTSemaphoreReg);
    return sltSemaphore;
 }

//request semaphore, if no succes, wait 1 usec and try again; retry max. usec times
uint32_t requestHWSemaphoreWaitUsec(int usec)
{
    uint32_t sltSemaphore=0;
	int i;
	for(i=0; i<usec; i++){
        sltSemaphore = pbus->read(SLTSemaphoreReg);// or ... = requestHWSemaphore()
		if(sltSemaphore) return sltSemaphore;
		usleep(1);
	}
    
    return sltSemaphore;
}


void releaseHWSemaphore(void)
{
	pbus->write(SLTSemaphoreReg ,  0x00000001);
}

void releaseHWSemaphoreWith(uint32_t bitmap)
{
	pbus->write(SLTSemaphoreReg ,  bitmap);
}

/*--------------------------------------------------------------------
 *    function:     sendCommandFifo
 *    purpose:      write command to command FIFO
 *    author:       taken from envoie_commande from cew.c, modified by Till Bergmann, 2011
 *
 *--------------------------------------------------------------------*/ //-tb-
//write_word to FPGA: Inbuf: will be sent to FPGA, status=number of bytes to be sent -tb-
//this is the counterpart of void	envoie_commande(unsigned char * Inbuf,int status) in cew.c
//
// NOTE: the first byte should be 'W' or 'h' (or anything else - it will be dropped/ignored!) 
//
void sendCommandFifo(unsigned char * buffer, int len)
{

    uint32_t cmdFifoStatus;
    unsigned char Code_Commande;
    uint32_t b;
    int i;
	
	//wait until command FIFO is empty
	const int MAXWAIT=25;
	for(i=0; i< MAXWAIT; i++){
	    cmdFifoStatus = pbus->read(CmdFIFOStatusReg);
		if (cmdFifoStatus & 0x8000) {
			break; //cmd FIFO empty, leave loop
		}
		usleep(10);
	}
	if(i==MAXWAIT){
	    printf("WARNING: cmd FIFO still not empty, continue to send command anyway! This may be caused by a error!\n");
	}
	
    //this errourously was sent out for each FIFO command, removed 2011-12-23
	//pbus->write(CmdFIFOReg ,  0x00f0);
	
	//try to request the HW semaphore
    uint32_t sltSemaphore=0;
    sltSemaphore = requestHWSemaphoreWaitUsec(100);// argument is 'usec': "wait max usec time" (e.g. usec = 100 means wait max. 100 usec = 0.1 msec)
	if(!sltSemaphore){
	    printf("ERROR: HW semaphore request timeout in void sendCommandFifo()! Could not send command! ERROR!\n");//TODO: use debug level setting -tb-
		return;
	}
	
	//now write command to cmd FIFO
    Code_Commande = buffer[1];
 	//  d'abord un mot de 8 bit precede de 0 en bit 9 pour indiquer le 1er mot
	//write_word(driver_fpga,REG_CMD, (unsigned long) Code_Commande);
	pbus->write(CmdFIFOReg ,  Code_Commande);  //this is either 255/0xff or 240/0xf0 (commande 'W')

	printf("cmd %u (%d octets) ",Code_Commande,len-2);//TODO: use debug level setting -tb-
	//  les mots suivants par mots de 8 bit
	for(i=2;i<len;i++){
		b=buffer[i];
        // En fait, c'est le msb d'abors
		printf("%lX ",b);
		b=b+0x0100;
		//write_word(driver_fpga,REG_CMD, b);
		pbus->write(CmdFIFOReg ,  b);
	}
	b=0x200;
	pbus->write(CmdFIFOReg ,  b);
	printf("\n");

    //release semaphore
	//if(sltSemaphore){	    releaseHWSemaphore();	}
	releaseHWSemaphoreWith(sltSemaphore);
}





/*--------------------------------------------------------------------
  globals
  --------------------------------------------------------------------*/

/*--------------------------------------------------------------------
  UDP communication
  --------------------------------------------------------------------*/

/*--------------------------------------------------------------------
  UDP communication - 1.) client communication
  --------------------------------------------------------------------*/








