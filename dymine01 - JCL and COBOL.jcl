//DYMINE01 JOB (COBOL),
//             'Calgary Crime',
//             CLASS=A,
//             MSGCLASS=H,
//             REGION=8M,TIME=1440,
//             MSGLEVEL=(1,1)
//********************************************************************
//*
//* Name: HERC02.TEST.ASM(DYMINE01)
//*
//* Description:  This job reads a file of City of Calgary crime 
//*       data for one month, prepared by a Python script on Linux.
//*       It sorts the file by crime category and rate (step 1), and
//*       creates a report showing the details by community plus 
//*       Calgary totals by category.
//*
//********************************************************************
//STEP1    EXEC PGM=SORT,REGION=512K,PARM='MSG=AP'
//SYSOUT   DD  SYSOUT=A
//SYSUDUMP DD  SYSOUT=A
//SYSPRINT DD  SYSOUT=A
//*SORTDIAG DD  DUMMY
//SORTLIB  DD  DSNAME=SYS1.SORTLIB,DISP=SHR
//SORTWK01 DD  UNIT=2314,SPACE=(CYL,(5,5)),VOL=SER=SORT01
//SORTWK02 DD  UNIT=2314,SPACE=(CYL,(5,5)),VOL=SER=SORT02
//SORTWK03 DD  UNIT=2314,SPACE=(CYL,(5,5)),VOL=SER=SORT03
//SORTWK04 DD  UNIT=2314,SPACE=(CYL,(5,5)),VOL=SER=SORT04
//SORTWK05 DD  UNIT=2314,SPACE=(CYL,(5,5)),VOL=SER=SORT05
//SORTWK06 DD  UNIT=2314,SPACE=(CYL,(5,5)),VOL=SER=SORT06
//SYSIN    DD  *
  SORT FIELDS=(31,30,CH,A,77,9,CH,D)
/*
//SORTIN   DD DSN=HERC02.DATA.CALCRIME,DISP=(OLD,KEEP,KEEP)
//SORTOUT  DD DSN=&&CRIMESRT,DISP=(NEW,PASS),
//             UNIT=SYSDA,
//             SPACE=(TRK,15),
//             DCB=(RECFM=FB,LRECL=86,BLKSIZE=860)
//*
//********************************************************************
//STEP2    EXEC COBUCG,
//         PARM.COB='FLAGW,LOAD,SUPMAP,SIZE=2048K,BUF=1024K'
//COB.SYSPUNCH DD DUMMY
//COB.SYSIN    DD *
    5 ***
   10 * //////////////////////////////////////////////////////////         
   20 * // Name: David Young                                           
   30 * // Program: Calgary Crime Stats                                  
   40 * //////////////////////////////////////////////////////////         
  150 ***                                                                  
  180  IDENTIFICATION DIVISION.
  190  PROGRAM-ID.  'DYMINE01'.
  200 ***
  230  ENVIRONMENT DIVISION.
  250 **
  260  CONFIGURATION SECTION.
  270  SOURCE-COMPUTER.  IBM-360.
  280  OBJECT-COMPUTER.  IBM-360.
  300 **
  310  INPUT-OUTPUT SECTION.
  320  FILE-CONTROL.
  330      SELECT CRIME-DATA-IN-FILE       ASSIGN TO UT-S-CRIMEIN.
  340      SELECT DETAIL-REPORT-OUT-FILE   ASSIGN TO UT-S-DETRPT.
  370 ***
  380  DATA DIVISION.
  400 **
  410  FILE SECTION.
  420  FD  CRIME-DATA-IN-FILE
  430      RECORDING MODE IS F
  440      RECORD CONTAINS 86 CHARACTERS
  442      BLOCK CONTAINS 10 RECORDS
  444      DATA RECORD IS CRIME-DATA-IN-RECORD
  460      LABEL RECORDS ARE OMITTED.
  470  01  CRIME-DATA-IN-RECORD.
  480        05 COMMUNITY-NAME-IN    PIC X(30).
  482        05 CRIME-CATEGORY-IN    PIC X(30).
  484        05 CRIME-COUNT-IN       PIC 9(4).
  486        05 RESIDENT-COUNT-IN    PIC 9(6).
  488        05 YEAR-IN              PIC 9(4).
  490        05 MONTH-IN             PIC X(3).
  492        05 RATE-PER-100K-IN     PIC X(9).
  500  FD  DETAIL-REPORT-OUT-FILE
  530      RECORDING MODE IS F
  540      RECORD CONTAINS 91 CHARACTERS
  560      LABEL RECORDS ARE OMITTED.
  570  01  DETAIL-REPORT-OUT-RECORD.
  580        05 FILLER               PIC X(91).
  590 **
  600  WORKING-STORAGE SECTION.
  610      77   OLD-CRIME-CATEGORY   PIC X(30) VALUE SPACES.
  620      77   END-OF-FILE          PIC X(1)  VALUE SPACES.
  630      77   CALGARY-POP-DIV-100K PIC 99V99 VALUE 15.47.
  640      77   CATEGORY-COUNT-ACCUM PIC 9(6)  VALUE ZEROS.
  642 **
  644      01   REPORT-HEADER-LINE-1.
  650        05 FILLER  PIC X(20)  VALUE SPACES.
  660        05 FILLER  PIC X(28) VALUE '*** CALGARY CRIME STATS FOR '.
  670        05 HEADER-MONTH       PIC X(3).
  680        05 FILLER  PIC X      VALUE SPACES.
  690        05 HEADER-YEAR        PIC 9(4).
  695        05 FILLER  PIC X(4)   VALUE ' ***'.
  697        05 FILLER  PIC X(30)  VALUE SPACES.
  700      01   REPORT-HEADER-LINE-2.
  710        05 FILLER  PIC X(1)   VALUE SPACES.
  715        05 FILLER  PIC X(14)  VALUE 'CRIME CATEGORY'.
  720        05 FILLER  PIC X(18)  VALUE SPACES.
  730        05 FILLER  PIC X(10)  VALUE 'RATE /100K'.
  740        05 FILLER  PIC X(2)   VALUE SPACES.
  750        05 FILLER  PIC X(14)  VALUE 'COMMUNITY NAME'.
  760        05 FILLER  PIC X(18)  VALUE SPACES.
  770        05 FILLER  PIC X(5)   VALUE 'OCCUR'.
  780        05 FILLER  PIC X(2)   VALUE SPACES.
  790        05 FILLER  PIC X(7)   VALUE 'RESIDNT'.
  800      01   REPORT-DETAIL-LINE.
  810        05 FILLER             PIC X(1) VALUE SPACES.
  815        05 CRIME-CATEGORY-OUT PIC X(30).
  820        05 FILLER             PIC X(2) VALUE SPACES.
  825        05 RATE-PER-100K-OUT  PIC ZZZ,ZZ9.99.
  827        05 FILLER             PIC X(2) VALUE SPACES.
  830        05 COMMUNITY-NAME-OUT PIC X(30).
  840        05 FILLER             PIC X(2) VALUE SPACES.
  850        05 CRIME-COUNT-OUT    PIC Z,ZZ9.
  860        05 FILLER             PIC X(2) VALUE SPACES.
  870        05 RESIDENT-COUNT-OUT PIC ZZZ,ZZ9.
  880      01   REPORT-CATEGORY-SUM-LINE.
  890        05 FILLER      PIC X(22) VALUE '  ==> CALGARY TOTAL:  '.
  900        05 FILLER            PIC X(16) VALUE 'RATE PER 100K = '.
  910        05 CALGARY-RATE-100K  PIC ZZZ,ZZ9.99.
  920        05 FILLER            PIC X(16) VALUE '  OCCURRENCES = '.
  930        05 CALGARY-COUNT-OUT  PIC ZZZ,ZZ9.
  933        05 FILLER            PIC X(20) VALUE SPACES.
  940      01   REPORT-LINE-SEPARATOR.
  942        05 DASHES  PIC X(91)  VALUE SPACES.
  944 **
  950 **
 1000  PROCEDURE DIVISION.
 1010 **
 1020  MAIN-PROGRAM.
 1030      PERFORM INITIALIZATION THRU END-INITIALIZATION.
 1040      PERFORM PROCESS-INPUT THRU END-PROCESS-INPUT
 1045        UNTIL END-OF-FILE = 'Y'.
 1050      PERFORM END-OF-PROGRAM.
 1060 **
 1100  INITIALIZATION.
 1105      MOVE ALL '-' TO DASHES.
 1107      OPEN INPUT CRIME-DATA-IN-FILE.
 1110      OPEN OUTPUT DETAIL-REPORT-OUT-FILE.
 1115      READ CRIME-DATA-IN-FILE
 1120        AT END DISPLAY '*** EMPTY INPUT FILE ***' UPON CONSOLE
 1125        STOP RUN.
 1130      IF YEAR-IN IS NOT NUMERIC THEN
 1135        DISPLAY '** NON-NUMERIC YEAR ON 1ST REC **' UPON CONSOLE
 1140        STOP RUN.
 1145      MOVE YEAR-IN TO HEADER-YEAR.
 1150      MOVE MONTH-IN TO HEADER-MONTH.
 1155      WRITE DETAIL-REPORT-OUT-RECORD FROM REPORT-HEADER-LINE-1
 1156        AFTER ADVANCING 1 LINES.
 1157      WRITE DETAIL-REPORT-OUT-RECORD FROM REPORT-LINE-SEPARATOR
 1158        AFTER ADVANCING 1 LINES.
 1160      WRITE DETAIL-REPORT-OUT-RECORD FROM REPORT-HEADER-LINE-2
 1165        AFTER ADVANCING 1 LINES.
 1170      MOVE CRIME-CATEGORY-IN TO OLD-CRIME-CATEGORY.
 1180  END-INITIALIZATION.
 1190      EXIT.
 1195 **
 1200  PROCESS-INPUT.
 1205      IF CRIME-CATEGORY-IN IS NOT = OLD-CRIME-CATEGORY THEN
 1210        PERFORM CHANGE-OF-CATEGORY THRU END-CHANGE-OF-CATEGORY.
 1215      MOVE COMMUNITY-NAME-IN TO COMMUNITY-NAME-OUT.
 1220      MOVE CRIME-CATEGORY-IN TO CRIME-CATEGORY-OUT.
 1225      MOVE CRIME-COUNT-IN TO CRIME-COUNT-OUT.
 1230      COMPUTE RATE-PER-100K-OUT ROUNDED = (CRIME-COUNT-IN * 100000)
 1231        / RESIDENT-COUNT-IN.
 1235      MOVE RESIDENT-COUNT-IN TO RESIDENT-COUNT-OUT.
 1240      WRITE DETAIL-REPORT-OUT-RECORD FROM REPORT-DETAIL-LINE
 1245        AFTER ADVANCING 1 LINES.
 1250      ADD CRIME-COUNT-IN TO CATEGORY-COUNT-ACCUM.
 1260      READ CRIME-DATA-IN-FILE
 1265        AT END MOVE 'Y' TO END-OF-FILE.
 1270  END-PROCESS-INPUT.
 1275      EXIT.
 1280 **
 1300  CHANGE-OF-CATEGORY.
 1305      COMPUTE CALGARY-RATE-100K ROUNDED = 
 1310        CATEGORY-COUNT-ACCUM / CALGARY-POP-DIV-100K.
 1315      MOVE CATEGORY-COUNT-ACCUM TO CALGARY-COUNT-OUT.
 1320      MOVE CRIME-CATEGORY-IN TO CRIME-CATEGORY-OUT.
 1340      WRITE DETAIL-REPORT-OUT-RECORD 
 1341        FROM REPORT-CATEGORY-SUM-LINE
 1345        AFTER ADVANCING 1 LINES.
 1350      WRITE DETAIL-REPORT-OUT-RECORD FROM REPORT-LINE-SEPARATOR
 1355        AFTER ADVANCING 1 LINES.
 1360      IF END-OF-FILE NOT = 'Y' THEN
 1362        WRITE DETAIL-REPORT-OUT-RECORD FROM REPORT-HEADER-LINE-2
 1364          AFTER ADVANCING 1 LINES.
 1370      MOVE ZEROS TO CATEGORY-COUNT-ACCUM.
 1375      MOVE CRIME-CATEGORY-IN TO OLD-CRIME-CATEGORY.
 1380  END-CHANGE-OF-CATEGORY.
 1385      EXIT.
 1390 **
 1400  END-OF-PROGRAM.
 1405      PERFORM CHANGE-OF-CATEGORY THRU END-CHANGE-OF-CATEGORY.
 1410      CLOSE CRIME-DATA-IN-FILE.
 1415      CLOSE DETAIL-REPORT-OUT-FILE.
 1420      DISPLAY '--- SUCCESSFUL END OF PROGRAM DYMINE01 ---' 
 1421        UPON CONSOLE.
 1425      STOP RUN.
 1430 **
/*
//COB.SYSLIB  DD DSNAME=SYS1.COBLIB,DISP=SHR
//GO.SYSOUT   DD SYSOUT=*,DCB=(RECFM=FBA,LRECL=161,BLKSIZE=16100)
//GO.CRIMEIN  DD DSN=&&CRIMESRT,DISP=(OLD,PASS)
//GO.DETRPT   DD SYSOUT=A
//
