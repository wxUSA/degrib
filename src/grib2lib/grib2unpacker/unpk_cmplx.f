      SUBROUTINE UNPK_CMPLX(KFILDO,jmin,lbit,nov,iwork,A,ND2X3,NX,NY,
     1                      IPACK,ND5,LOCN,IPOS,IS5,NS5,LX,lsect,
     2                      IBITMAP,IB,IUNPKOPT,BOUST,L3264B,REF,
     3                      XMISSP,XMISSS,IER,*)
C
C        OCTOBER   1994   GLAHN    TDL   HP
C        FEBRUARY  1995   MOELLER  TDL   HP
C        APRIL     1995   GLAHN    ADDED CAPABILITY TO UNPACK DATA
C                                  VALUES WITH BINARY SCALE FACTOR,
C                                  ISCALEB
C        APRIL     1995   MOELLER  RENAMED SUBROUTINE AND CHANGED
C                                  STATEMENT TO UNPACK LBIT
C        DECEMBER  1995   MOELLER  REMOVED KFILDO FROM CALL SEQUENCE
C        JANUARY   1996   CALKINS  ADDED KFILDO TO CALL SEQUENCE
C        JUNE      1999   LAWRENCE UPDATED FOR UNPK_GRIB2; MODIFIED
C                                  CALLING ARGUMENTS TO BE MORE CONSISTENT
C                                  WITH OTHER ROUTINES; MODIFIED THE
C                                  INTERNAL DOCUMENTATION
C        APRIL     2000   LAWRENCE MODIFIED TO REFLECT THE LATEST GRIB2
C                                  STANDARDS
C        JANUARY   2001   GLAHN    COMMENTS; CHANGED IER = 17 TO 705;
C                                  ELIMINATED IA( ), NUMOCTET, IS7( ),
C                                  NS7; ADDED ALTERNATE RETURN IN CALLS
C                                  TO UNPKLX
C        FEBRUARY  2001   GLAHN    REMOVED XMISSX FROM CALL TO UNPKSECDIF
C        FEBRUARY  2001   GLAHN    DEFINED ISCAL AND PUT IT INTO CALL TO
C                                  UNPKSECDIF AND UNPKCMBM; COMMENTS;
C                                  INSERTED CALL TO BOUNDARY; CHANGED
C                                  (-1)* TO - IN 3 PLACES
C        NOVEMBER  2001   GLAHN    ADDED MAXGPREF TO CALL TO UNPKCMBM
C                                  AND UNPKSECDIF; DIMENSIONS OF JMIN( ),
C                                  LBIT( ), AND NOV( ) CHANGED FROM ND2X3
C                                  TO IS5(32)
C        MARCH     2002   GLAHN    ADDED IF(IER.NE.0)GO TO 900 AFTER CALL
C                                  TO UNPKCMBM
C        SEPTEMBER 2002   GLAHN    ADDED LX TO CALL; REMOVED LX=IS5(32);
C                                  DIMENSIONS OF JMIN( ), LBIT( ), AND
C                                  NOV( ) CHANGED FROM IS5(32) TO LX
C        DECEMBER 2004    TAYLOR   ADDED CHECK TO MAKE SURE GROUPS WERE
C                                  CONSISTENT WITH SIZE OF STORAGE ARRAY
C                                  AND THE SIZE OF SECTION 7. 
C
C        PURPOSE
C            UNPACKS DATA THAT WAS PACKED USING THE COMPLEX PACKING
c            SCHEME IN GRIB2.  ND2X3 UNPACKED VALUES ARE RETURNED
C            IN A( ).  THE ROUTINE GIVES THE USER THE OPTION TO PASS IN
C            A BIT MAP WHICH WILL SHOW WHERE MISSING VALUES ARE, OR
C            THE ROUTINE WILL GENERATE A BIT MAP AUTOMATICALLY
C            AS LONG AS THE USER SUPPLIES THE VALUE THAT WILL
C            REPRESENT MISSING IN THE GRIDDED FIELD.
C
C            NOTE THAT THIS SUBROUTINE USES THE FOLLOWING EQUATION
C            TO RECOVER THE PACKED VALUE:
C               Y = R + [(X1 + X2) * (2 ** E) * (10 ** D)]
C               WHERE:
C                     Y = THE VALUE WE ARE UNPACKING
C                     R = THE REFERENCE VALUE (FIRST ORDER MINIMA)
C                    X1 = THE PACKED VALUE
C                    X2 = THE SECOND ORDER MINIMA
C                     E = THE BINARY SCALE FACTOR
C                     D = THE DECIMAL SCALE FACTOR
C
C        DATA SET USE
C           KFILDO - UNIT NUMBER FOR OUTPUT (PRINT) FILE. (OUTPUT)
C
C        VARIABLES 
C              KFILDO = UNIT NUMBER FOR OUTPUT (PRINT) FILE.  (INPUT)
C                A(K) = UNPACKED DATA RETURNED (K=1,ND2X3). THE DATA
C                       ARE IN THIS LINEAR ARRAY IN THE ORDER OF A
C                       FORTRAN 2-DIMENSIONAL ARRAY LIKE A(IX,JY)
C                       (IX=1,NX) (JY=1,NY).(OUTPUT)
C               ND2X3 = THE MAXIMUM SIZE OF ARRAYS A( ) AND IB( ).
C                       (INPUT)
C                  NX = THE ACTUAL NUMBER OF COLUMNS IN THIS
C                       GRIDDED PRODUCT. (INPUT)
C                  NY = THE ACTUAL NUMBER OF ROWS IN THIS GRIDDED
C                       PRODUCT. (INPUT)
C            IPACK(J) = THE ARRAY HOLDING THE ACTUAL PACKED MESSAGE
C                       (J=1,ND5).  (INPUT)
C                 ND5 = DIMENSION OF IPACK( ).  (INPUT)
C                LOCN = THE WORD POSITION FROM WHICH TO UNPACK THE
C                       NEXT VALUE. (INPUT/OUTPUT)
C                IPOS = THE BIT POSITION IN LOCN FROM WHICH TO START
C                       UNPACKING THE NEXT VALUE.  (INPUT/OUTPUT)
C              IS5(L) = THE ARRAY CORRESPONDING TO SECTION 5
C                       OF THE GRIB2 CODE. (INPUT)
C                 NS5 = DIMENSION OF IS5( ). (INPUT)
C                  LX = IS5(32) = DIMESNION OF JMIIN( ), ETC.
C                       (INPUT)
C             IBITMAP = 1 IF THERE WAS A BIT-MAP PACKED INTO
C                       THIS GRIB2 MESSAGE.
C                       0 IF THERE WAS NOT A BIT-MAP IN THIS
C                       GRIB2 MESSAGE.  (INPUT)
C               IB(K) = HOLDS PRIMARY BIT MAP, IF ONE IS PRESENT
C                       (K=1,ND2X3).  (INPUT)
C            IUNPKOPT = 0 DON'T UNPACK THIS DATA GRID. AN ERROR
C                         WAS ENCOUNTERED.
C                       3 UNPACK THIS GRID USING THE COMPLEX METHOD,
C                         LEAVE THE MISSING VALUES IN THE GRID,
C                         DO NOT RETURN A BIT-MAP.
C                       4 UNPACK THIS GRID USING THE COMPLEX METHOD,
C                         REMOVE THE MISSING VALUES FROM THE GRID,
C                         RETURN A BIT-MAP INDICATING MISSING VALUE
C                         LOCATIONS.  (INPUT)
C               BOUST = .TRUE. IF THE DATA FIELD WAS SCANNED
C                       BOUSTROPHEDONICALLY. .FALSE. OTHERWISE.
C                       (LOGICAL) (INPUT)
C              L3264B = THE NUMBER OF BITS IN A WORD ON THIS MACHINE.
C                       THIS IS A PLATFORM DEPENDENT VALUE AND CAN
C                       EITHER BE 32 FOR A FOUR BYTE MACHINE, OR 64
C                       FOR AN EIGHT BYTE MACHINE. (INPUT)
C                 REF = THE REFERENCE VALUE THAT WE WILL BE USING TO
C                       UNPACK THE DATA VALUES. (INPUT)
C              XMISSP = THE PRIMARY MISSING VALUE. (INPUT)
C              XMISSS = THE SECONDARY MISSING VALUE. (INPUT)
C                 IER = ERROR RETURN CODE. (OUTPUT)
C                         0 = GOOD RETURN ... THE ROUTINE PROBABLY
C                             WORKED.
C                       6-8 = ERROR RETURN CODES FROM UNPKBG, UNPKLX,
C                             UNPKCMBM, AND UNPKSECDIF. SEE INTERNAL
C                             DOCUMENTATION IN THESE ROUTINES.
C                       705 = ND2X3 IS TOO SMALL OF A DIMENSION
C                             TO ALLOW FOR PROPER PROCESSING OF
C                             THE GRID.
C                   * = ALTERNATE ERROR RETURN. 
C
C        LOCAL VARIABLES
C             JMIN(M) = THE MINIMUM VALUE SUBTRACTED FOR EACH GROUP
C                       M BEFORE PACKING (M=1,LX).  (AUTOMATIC)
C             LBIT(M) = THE NUMBER OF BITS NECESSARY TO HOLD THE
C                       PACKED VALUES FOR EACH GROUP M (M=1,LX). 
C                       (AUTOMATIC)
C              NOV(M) = THE NUMBER OF VALUES IN EACH GROUP M (M=1,LX).
C                       (AUTOMATIC)
C                  LX = THE NUMBER OF VALUES IN LBIT( ), JMIN( ), AND
C                       NOV( ) = IS5(32).  (INPUT)
C               LSECT = Length of section 7 for error checking.
C            IMISSING = REPRESENTS OCTET 23 OF SECTION 5. DETERMINES
C                       IF THERE ARE NO MISSING VALUES, PRIMARY MISSING
C                       VALUES, OR PRIMARY AND SECONDARY MISSING VALUES.
C             ISCALED = IS5(18) IN CALLING PROGRAM.  THE DECIMAL SCALING
C                       FACTOR.
C             ISCALEB = IS5(16) IN CALLING PROGRAM.  THE BINARY SCALING
C                       FACTOR.
C               ISIGN = A FLAG INDICATING WHETHER AN UNPACKED VALUE
C                       IS POSITIVE OR NEGATIVE.
C                IREF = REFERENCE FOR FIELD WIDTH = IS5(36).
C             IREFBIT = NUMBER OF BITS REQUIRED TO STORE THE FIELD
C                       WIDTHS AFTER THE REMOVAL OF IREF = IS5(37). 
C             ILENREF = REFERENCE FOR THE GROUP LENGTHS = IS5(38).
C             ILENINC = LENGTH INCREMENT FOR THE GROUP LENGTHS = IS5(42).
C            ITRUELEN = TRUE LENGTH OF THE LAST GROUP = IS5(43).
C             ILENBIT = FIELD WIDTH NEEDED TO STORE THE GROUP LENGTHS
C                       ONCE THE REFERENCE HAS BEEN REMOVED = IS5(47).
C             NUMBITS = NUMBER OF BITS TO UNPACK INFORMATION SPECIFIC
C                       TO SECOND ORDER DIFFERENCES SANS THE SIGN BIT
C                       = IS5(49)*8-1.
C               ISCAL = INDICATES COMBINATIONS OF SCALING.
C                       0 = NONE
C                       1 = DECIMAL ONLY
C                       2 = BINARY ONLY
C                       3 = BOTH DECIMAL AND BINARY
C              SCAL10 = THE DECIMAL SCALING FACTOR.
C               SCAL2 = THE BINARY SCALING FACTOR.
C               CLEAN = TRUE WHEN THE USER DOESN'T WANT MISSING VALUES
C                       IN THE UNPACKED DATA FIELD.  FALSE OTHERWISE.
C                       (LOGICAL)
C            MAXGPREF = THE MAXIMUM VALUE OF THE GROUP REFERENCES.
C
C        NON SYSTEM SUBROUTINES CALLED
C           UNBOUSTRO, UNPKBG, UNPKLX, UNPKCMBM, UNPKSECDIF, BOUNDARY
C
      LOGICAL BOUST, CLEAN
C
      DIMENSION A(ND2X3),IB(ND2X3)
      DIMENSION IPACK(ND5)
      DIMENSION IS5(NS5)
      DIMENSION JMIN(LX),LBIT(LX),NOV(LX)
C        JMIN( ), LBIT( ), AND NOV( ) ARE AUTOMATIC ARRAYS.
C
      IER=0
C
      N=L3264B
C
C        SET NXY EQUAL TO THE NUMBER OF GRID POINTS IN THE
C        GRID THAT WE ARE PROCESSING.
C
      NXY=NX*NY
C
C        CHECK TO MAKE SURE THAT THIS VALUE IS .LE. ND2X3.
C
      IF(NXY.GT.ND2X3)THEN
         IER=705
         GO TO 900
      ENDIF
C
C        RETRIEVE THE INFORMATION THAT IS PERTINENT
C        TO UNPACKING DATA THAT WAS PACKED USING THE
C        COMPLEX METHOD.
C
C        INTIALIZE THE SCALE FACTORS.
      ISCALED=IS5(18)
      ISCALEB=IS5(16)
C
C        INITIALIZE THE FIELD WIDTH THAT WAS USED TO PACK
C        THE GROUP REFERENCES.
      IWIDTH=IS5(20)
C
C        INITIALIZE THE USE OF EXPLICIT MISSING VALUES.
      IMISSING=IS5(23)
C
C        DETERMINE THE REFERENCE FOR THE FIELD WIDTHS (IN BITS)
C        USED TO STORE THE VALUES IN THE GROUPS.
      IREF=IS5(36)
C
C        DETERMINE THE NUMBER OF BITS REQUIRED
C        TO STORE THE FIELD WIDTHS AFTER THE REMOVAL
C        OF THE ABOVE REFERENCE VALUE. 
      IREFBIT=IS5(37)
      MAXGPREF=2**IWIDTH-1
C        MAXBIT IS THE MAXIMUM NUMBER THAT CAN BE STORED
C        IN LBIT( ).
C
C        DETERMINE THE REFERENCE FOR THE GROUP LENGTHS.
      ILENREF=IS5(38)
C
C        DETERMINE THE LENGTH INCREMENT FOR THE GROUP
C        LENGTHS.
      ILENINC=IS5(42)
C
C        DETERMINING THE TRUE LENGTH OF THE LAST GROUP.
      ITRUELEN=IS5(43)
C
C        DETERMINE THE FIELD WIDTH NEEDED TO STORE THE
C        GROUP LENGTHS ONCE THE ABOVE REFERENCE HAS BEEN
C        REMOVED.
      ILENBIT=IS5(47)
C
C        IF SECOND ORDER DIFFERENCES WERE DONE, THEN
C        UNPACK THE INFORMATION SPECIFIC TO SECOND
C        ORDER DIFFERENCES.
C
      IF(IS5(10).EQ.3)THEN
         NUMBITS=(IS5(49)*8)-1
         CALL UNPKBG(KFILDO,IPACK,ND5,LOCN,IPOS,ISIGN,1,N,IER,*900)
         CALL UNPKBG(KFILDO,IPACK,ND5,LOCN,IPOS,IFIRST,NUMBITS,N,
     1               IER,*900)
         IF(ISIGN.EQ.1)IFIRST=(-1)*IFIRST
         CALL UNPKBG(KFILDO,IPACK,ND5,LOCN,IPOS,ISIGN,1,N,IER,*900)
         CALL UNPKBG(KFILDO,IPACK,ND5,LOCN,IPOS,ISECOND,NUMBITS,N,
     1               IER,*900)
         IF(ISIGN.EQ.1)ISECOND=(-1)*ISECOND
         CALL UNPKBG(KFILDO,IPACK,ND5,LOCN,IPOS,ISIGN,1,N,IER,*900)
         CALL UNPKBG(KFILDO,IPACK,ND5,LOCN,IPOS,ISECMIN,NUMBITS,N,
     1               IER,*900)
         IF(ISIGN.EQ.1)ISECMIN=(-1)*ISECMIN
      ENDIF
C
C***      WRITE(KFILDO,994)ILENREF,ILENINC,ITRUELEN,ILENBIT,
C***     1      NUMBITS,IFIRST,ISECOND,ISECMIN,LOCN,IPOS
C*** 994  FORMAT(/' UNPK_CMPLX AT 994--ILENREF,ILENINC,ITRUELEN,ILENBIT,
C***     1      NUMBITS,IFIRST,ISECOND,ISECMIN,LOCN,IPOS'/10I10)
C***      WRITE(KFILDO,990)(IS5(J),J=32,49)
C*** 990  FORMAT(/' AT 990 IN UNPK_CMPLX--(IS5(J),J=32,49)',
C***     1         (/20I6))
C
C        UNPACK THE REFERENCE VALUES OF THE GROUPS.
      CALL UNPKLX(KFILDO,IPACK,ND5,LOCN,IPOS,JMIN,LX,IWIDTH,N,IER,*900)
      CALL BOUNDARY(IPOS,LOCN)
C
C***      WRITE(KFILDO,995)(JMIN(J),J=1,200)
C*** 995  FORMAT(/' UNPK_CMPLX AT 995--(JMIN(J),J=1,200)'/(20I6))
C
C        UNPACK THE WIDTH INCREMENTS OF THE DATA FIELD.
      CALL UNPKLX(KFILDO,IPACK,ND5,LOCN,IPOS,LBIT,LX,IREFBIT,N,IER,*900)
      CALL BOUNDARY(IPOS,LOCN)
C
C***      WRITE(KFILDO,996)(LBIT(J),J=1,200)
C*** 996  FORMAT(/' UNPK_CMPLX AT 996--(LBIT(J),J=1,200)'/(20I6))
C
C        ADD THE REFERENCE TO ALL OF THE GROUP WIDTHS
C
      IF(IREF.NE.0)THEN
         DO K=1,LX
            LBIT(K)=LBIT(K)+IREF
         ENDDO
      ENDIF
C
C***      WRITE(KFILDO,997)IREF,(LBIT(J),J=1,200)
C*** 997  FORMAT(/' UNPK_CMPLX AT 997--IREF,(LBIT(J),J=1,200)',I4/(20I6))
C
C        UNPACK THE LENGTHS OF THE GROUPS
      CALL UNPKLX(KFILDO,IPACK,ND5,LOCN,IPOS,NOV,LX,ILENBIT,N,IER,*900)
      CALL BOUNDARY(IPOS,LOCN)
C
C***      WRITE(KFILDO,998)(NOV(J),J=1,1200)
C*** 998  FORMAT(/' UNPK_CMPLX AT 998--(NOV(J),J=1,1200)'/(20I6))
C
C        ADD THE REFERENCE GROUP LENGTH TO ALL OF THE GROUP LENGTHS
C        EXCEPT FOR THE LAST GROUP.  THE ACTUAL LENGTH OF THE LAST
C        GROUP IS KNOWN.
C
      IF((ILENREF.NE.0).OR.(ILENINC.GT.1))THEN
         DO K=1,(LX-1)
            NOV(K)=(NOV(K)*ILENINC)+ILENREF
         ENDDO
      ENDIF
C
C***      WRITE(KFILDO,999)(NOV(J),J=1,200)
C*** 999  FORMAT(/' UNPK_CMPLX AT 999--(NOV(J),J=1,200)'/(20I6))
C
      NOV(LX)=ITRUELEN
C
C        DEFINE ISCAL AND COMPUTE SCAL10 AND SCAL2.
C
      IF(ISCALED.EQ.0.AND.ISCALEB.EQ.0)THEN
         ISCAL=0
         SCAL10=1.
         SCAL2=1.
      ELSEIF(ISCALED.NE.0.AND.ISCALEB.EQ.0)THEN
         ISCAL=1
         SCAL10=10.**ISCALED
         SCAL2=1.
      ELSEIF(ISCALED.EQ.0.AND.ISCALEB.NE.0)THEN
         ISCAL=2
         SCAL10=1.
         SCAL2=2.**ISCALEB
      ELSEIF(ISCALED.NE.0.AND.ISCALEB.NE.0)THEN
         ISCAL=3
         SCAL10=10.**ISCALED
         SCAL2=2.**ISCALEB
      ENDIF
C
C        SET CLEAN.
C
      IF(IUNPKOPT.EQ.3)THEN
         CLEAN=.FALSE.
      ELSE
         CLEAN=.TRUE.
      ENDIF
C
C        UNPACK THE SECOND ORDER PACKED VALUES.
C        DEPENDING ON THE METHOD USED TO PACK THE DATA
C        CALL THE APPROPRIATE ROUTINE.
C
      iTotBit=0
      iTotLen=0
      DO K=1,LX
         iTotBit=iTotBit+(LBIT(K)*NOV(K))
         iTotLen=iTotLen+NOV(K)
      ENDDO
      IF (iTotLen.GT.ND2X3)THEN
C         write(*,*) "Total number packed > storage array size"
         IER=705
         GO TO 900
      ENDIF
      IF (iTotBit.GT.(LSECT*8))THEN
C         write(*,*) "Total bits used > section length * 8"
         IER=705
         GO TO 900
      ENDIF
      IF(IS5(10).EQ.3)THEN
C
C           COMPLEX PACKING WITH SPATIAL DIFFERENCING
C           WAS USED.
         CALL UNPKSECDIF(KFILDO,iwork,A,ND2X3,JMIN,LBIT,NOV,LX,NX,NY,
     1                   IPACK,ND5,IFIRST,ISECOND,ISECMIN,REF,
     2                   LOCN,IPOS,MAXGPREF,IMISSING,XMISSP,XMISSS,
     3                   ISCAL,SCAL10,SCAL2,L3264B,IER)
      ELSE
C
C           COMPLEX PACKING WITHOUT SPATIAL DIFFERENCING
C           WAS USED.
         CALL UNPKCMBM(KFILDO,IPACK,ND5,LOCN,IPOS,A,IB,NXY,LBIT,
     1                 JMIN,NOV,LX,MAXGPREF,IMISSING,XMISSP,XMISSS,
     2                 REF,IBITMAP,SCAL10,SCAL2,CLEAN,L3264B,IER)
      ENDIF
C
      IF(IER.NE.0)GO TO 900
C
C        MAKE SURE THAT WE ARE POINTING TO A BYTE BOUNDARY.
C
      IFILL=MOD(33-IPOS,8)
C
      IF (IFILL.NE.0) THEN
         IPOS=IPOS+IFILL
C
         IF(IPOS.GT.32) THEN
           IPOS=1
           LOCN=LOCN+1
         END IF
C
      END IF
C
C        CHECK TO SEE IF THE DATA WAS SCANNED BOUSTROPHEDONICALLY
C        BEFORE IT WAS PACKED. IF IT WAS, THEN REARRANGE THE ROWS 
C        IN THE CORRECT ORDER TO RETURN THE DATA FIELD TO
C        ITS ORIGINAL STATE.
C
      IF(BOUST)THEN
         CALL UNBOUSTRO(A,NX,NY)
      ENDIF
C
 900  IF(IER.NE.0)RETURN 1
      RETURN
      END
