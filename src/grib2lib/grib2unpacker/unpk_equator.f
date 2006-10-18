      SUBROUTINE UNPK_EQUATOR(KFILDO,IPACK,ND5,IS3,NS3,L3264B,
     1                        LOCN,IPOS,BOUST,IER,*)
C
C        MARCH    2000   LAWRENCE  GSC/TDL    ORIGINAL CODING
C        JANUARY  2001   GLAHN     COMMENTS; ADDED * ARGUMENT
C                                  TO CALL TO UNEARTH; CHANGED
C                                  COMPUTATION OF NEGATIVE VALUE;
C                                  CHANGED TO STANDARD RETURN SEQUENCE   
C        FEBRUARY 2001   GLAHN     CHECKED SIZE OF NS3; COMMENTS
C        NOVEMBER 2001   GLAHN     COMMENT ON IS3( ) SIZE
C
C
C        PURPOSE
C            UNPACKS TEMPLATE 3.110, AN EQUATORIAL AZIMUTHAL
C            EQUIDISTANT MAP PROJECTION, FROM SECTION 3 OF A GRIB2
C            MESSAGE.  DATA ARE PLACED INTO THE IS3( ) ARRAY.
C            IT IS THE RESPONSIBILITY OF THE CALLING ROUTINE
C            TO UNPACK THE FIRST 14 OCTETS IN SECTION 3.
C
C        DATA SET USE
C           KFILDO - UNIT NUMBER FOR OUTPUT (PRINT) FILE. (OUTPUT)
C
C        VARIABLES
C              KFILDO = UNIT NUMBER FOR OUTPUT (PRINT) FILE. (INPUT)
C            IPACK(J) = THE ARRAY THAT HOLDS THE ACTUAL PACKED MESSAGE
C                       (J=1,ND5). (INPUT/OUTPUT)
C                 ND5 = THE SIZE OF THE ARRAY IPACK( ). (INPUT)
C              IS3(J) = THE EQUATORIAL AZIMUTHAL EQUIDISTANT 
C                       INFORMATION IS WRITTEN TO ELEMENTS 15 THROUGH
C                       57 AS IT IS UNPACKED FROM IPACK( ) (J=1,NS3).
C                       (INPUT/OUTPUT)
C                 NS3 = SIZE OF IS3( ). (INPUT) 
C              L3264B = THE INTEGER WORD LENGTH IN BITS OF THE MACHINE
C                       BEING USED. VALUES OF 32 AND 64 ARE
C                       ACCOMMODATED. (INPUT)
C                LOCN = THE WORD POSITION FROM WHICH TO UNPACK THE
C                       NEXT VALUE. (INPUT/OUTPUT)
C                IPOS = THE BIT POSITION IN LOCN FROM WHICH TO START
C                       UNPACKING THE NEXT VALUE.  (INPUT/OUTPUT)
C               BOUST = .TRUE. IF THE DATA FIELD WAS SCANNED
C                       BOUSTROPHEDONICALLY. .FALSE. OTHERWISE. 
C                       (LOGICAL) (OUTPUT)
C                 IER = RETURN STATUS CODE. (OUTPUT)
C                         0 = GOOD RETURN.
C                       6-8 = ERROR CODES GENERATED BY UNPKBG. SEE THE 
C                             DOCUMENTATION IN THE UNPKBG ROUTINE.
C                       302 = IS3( ) NOT DIMENSIONED LARGE ENOUGH.
C                       303 = UNSUPPORTED GRID TEMPLATE INDICATED 
C                             BY IS3(13).
C                       307 = UNRECOGNIZED OR UNSUPPORTED SHAPE OF
C                             EARTH CODE IN IS3(15) RETURNED FROM UNEARTH.
C                   * = ALTERNATE RETURN WHEN IER .NE. 0.
C
C             LOCAL VARIABLES
C               ISIGN = A FLAG INDICATING WHETHER AN UNPACKED VALUE
C                       IS POSITIVE OR NEGATIVE. 
C                   N = L3264B = THE INTEGER WORD LENGTH IN BITS OF 
C                       THE MACHINE BEING USED. VALUES OF 32 AND
C                       64 ARE ACCOMMODATED. 
C
C        NON SYSTEM SUBROUTINES CALLED
C           UNEARTH, UNPKBG
C
      LOGICAL BOUST
C
      DIMENSION IPACK(ND5),IS3(NS3)
C
      N=L3264B
      IER=0
C
C        CHECK TO MAKE SURE THAT AN EQUATORIAL AZIMUTHAL
C        EQUIDISTANT PROJECTION IS PACKED IN THIS MESSAGE.
      IF (IS3(13).NE.110)THEN
D        WRITE(KFILDO,10)IS3(13)
D10      FORMAT(/' MAP PROJECTION CODE ',I4,' INDICATED BY IS3(13)'/
D    1           ' IS NOT EQUATORIAL AZIMUTHAL. PLEASE REFER'/
D    2           ' TO THE GRIB2 DOCUMENTATION TO DETERMINE THE'/
D    3           ' CORRECT MAP PROJECTION PACKER TO CALL.'/)
         IER=303
         GO TO 900
      ENDIF
C
C        CHECK SIZE OF IS3( ).
C
      IF(NS3.LT.57)THEN
         IER=302
         GO TO 900
      ENDIF
C
C        UNPACK THE SHAPE OF THE EARTH.
      CALL UNEARTH(KFILDO,IPACK,ND5,IS3,NS3,N,LOCN,IPOS,IER,*900)
      IF(IER.NE.0)GOTO 900
C
C        UNPACK THE NUMBER OF POINTS ALONG THE X AND Y AXES
C        (Nx, Ny)
      CALL UNPKBG(KFILDO,IPACK,ND5,LOCN,IPOS,IS3(31),32,N,IER,*900)
      CALL UNPKBG(KFILDO,IPACK,ND5,LOCN,IPOS,IS3(35),32,N,IER,*900)
C
C        UNPACK THE LATITUDE & LONGITUDE OF THE TANGENCY POINT
      CALL UNPKBG(KFILDO,IPACK,ND5,LOCN,IPOS,ISIGN,1,N,IER,*900)
      CALL UNPKBG(KFILDO,IPACK,ND5,LOCN,IPOS,IS3(39),
     1          31,N,IER,*900)
      IF(ISIGN.EQ.1)IS3(39)=-IS3(39)
C
      CALL UNPKBG(KFILDO,IPACK,ND5,LOCN,IPOS,ISIGN,1,N,IER,*900)
      CALL UNPKBG(KFILDO,IPACK,ND5,LOCN,IPOS,IS3(43),
     1          31,N,IER,*900)
      IF(ISIGN.EQ.1)IS3(43)=-IS3(43)
C
C        UNPACK THE RESOLUTION AND COMPONENT FLAG.
      CALL UNPKBG(KFILDO,IPACK,ND5,LOCN,IPOS,IS3(47),8,N,IER,*900)
C
C        UNPACK Dx - X-DIRECTION GRID LENGTH IN UNITS OF 10-5 M
C        AS MEASURED AT THE POINT OF THE AXIS.
      CALL UNPKBG(KFILDO,IPACK,ND5,LOCN,IPOS,IS3(48),32,N,IER,*900)
C
C        UNPACK Dy - Y-DIRECTION GRID LENGTH IN UNITS OF 10-5 M
C        AS MEASURED AT THE POINT OF THE AXIS.
      CALL UNPKBG(KFILDO,IPACK,ND5,LOCN,IPOS,IS3(52),32,N,IER,*900)
C
C        UNPACK THE PROJECTION CENTER FLAG.
      CALL UNPKBG(KFILDO,IPACK,ND5,LOCN,IPOS,IS3(56),8,N,IER,*900)
C
C        UNPACK THE SCANNING MODE.
      CALL UNPKBG(KFILDO,IPACK,ND5,LOCN,IPOS,IS3(57),8,N,IER,*900)
C
      IF(IAND(IS3(57),16).EQ.16)THEN
C           THE MASK GETS BIT 4 (FROM THE LEFT); WHEN IT IS 1,
C           BOUST IS TRUE.; OTHERWISE BOUST IS FALSE.
         BOUST=.TRUE.
         IS3(57)=IAND(IS3(57),239)
C           BIT 4 IS SET = 0, BECAUSE THE DATA ARE RETURNED
C           NON-BOUSTROPHEDONICALLY ORDERED EVEN THOUGH THEY WERE
C           PACKED THAT WAY.  239 DECIMAL = 357 OCTAL PRESERVES
C           ALL OTHER BITS IN THE OCTET.
      ELSE
         BOUST=.FALSE.
      ENDIF
C
C       ERROR RETURN SECTION
C
 900  IF(IER.NE.0)RETURN 1 
C
      RETURN
      END
