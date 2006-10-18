      SUBROUTINE UNPK_SECT5(KFILDO,IPACK,ND5,IS5,NS5,L3264B,
     1                      LOCN,IPOS,REF,XMISSP,XMISSS,
     2                      IER,ISEVERE,*)
C
C        MARCH    2000   LAWRENCE  GSC/TDL    ORIGINAL CODING
C        JANUARY  2001   GLAHN     COMMENTS; CHANGED IER = 18 TO 508;
C                                  OMITTED EXISTS FROM CALL SEQUENCE;
C                                  ADDED IER = 501; ADDED TEST FOR
C                                  SECTION LENGTH
C        FEBRUARY 2001   GLAHN     CHECKED SIZE OF NS5; COMMENTS;
C                                  OMITTED UNPAKCING NONSTANDARD
C                                  INTEGER REFERENCE VALUE
C        NOVEMBER 2001   GLAHN     MOVED ISEVERE=2 TO TOP; INSERTED
C                                  IER=509
C
C        PURPOSE
C            UNPACKS SECTION 5, THE DATA REPRESENTATION SECTION, OF
C            A GRIB2 MESSAGE.
C
C        DATA SET USE
C           KFILDO - UNIT NUMBER FOR OUTPUT (PRINT) FILE. (OUTPUT
C                    FILE)
C
C        VARIABLES
C              KFILDO = UNIT NUMBER FOR OUTPUT (PRINT) FILE. (INPUT)
C            IPACK(J) = THE ARRAY THAT HOLDS THE ACTUAL PACKED MESSAGE
C                       (J=1,ND5). (INPUT/OUTPUT)
C                 ND5 = THE SIZE OF THE ARRAY IPACK( ). (INPUT)
C              IS5(J) = THE DATA REPRESENTATION DATA THAT ARE UNPACKED FROM
C                       IPACK( ) ARE PLACED INTO THIS ARRAY (J=1,NS5).
C                       (OUTPUT)
C                 NS5 = SIZE OF IS5( ). (INPUT)
C              L3264B = THE INTEGER WORD LENGTH IN BITS OF THE MACHINE
C                       BEING USED. VALUES OF 32 AND 64 ARE
C                       ACCOMMODATED. (INPUT)
C                LOCN = THE WORD POSITION FROM WHICH TO UNPACK THE
C                       NEXT VALUE. (INPUT/OUTPUT)
C                IPOS = THE BIT POSITION IN LOCN FROM WHICH TO START
C                       UNPACKING THE NEXT VALUE.  (INPUT/OUTPUT)
C                 REF = THE REFERENCE VALUE OF THE FIELD WHEN
C                       THE DATA FIELD IS FLOATING POINT. (OUTPUT)
C              XMISSP = THE PRIMARY MISSING VALUE REPRESENTATION. 
C                       (INPUT/OUTPUT)
C              XMISSS = THE SECONDARY MISSING VALUE REPRESENTATION.
C                       (INPUT/OUTPUT)
C                 IER = RETURN STATUS CODE. (OUTPUT)
C                         0 = GOOD RETURN.
C                       6-8 = ERROR CODES GENERATED BY UNPKBG. SEE THE
C                             DOCUMENTATION IN THE PKBG ROUTINE.
C                       501 = IS5(5) DOES NOT INDICATE SECTION 5.
C                       502 = IS5( ) HAS NOT BEEN DIMENSIONED LARGE
C                             ENOUGH TO CONTAIN THE TEMPLATE.
C                       508 = UNRECOGNIZED TYPE OF PACKING IN IS5(10).
C                       509 = UNRECOGNIZED TYPE OF DATA IN IS5(21). 
C                       599 = UNEXPECTED END OF MESSAGE.
C             ISEVERE = THE SEVERITY LEVEL OF THE ERROR.  THE ONLY
C                       VALUE RETUNED IS:
C                       2 = A FATAL ERROR  (OUTPUT)
C                   * = ALTERNATE RETURN WHEN IER NE 0.
C
C             LOCAL VARIABLES
C             LOCN5_1 = SAVES THE WORD POSITION LOCN IN IPACK
C                       UPON ENTRY TO STORE BACK TO LOCN IN CASE
C                       THERE IS A FATAL ERROR.
C             IPOS5_1 = SAVES THE BIT POSITION IPOS IN LOCN
C                       UPON ENTRY TO STORE BACK TO IPOS IN CASE
C                       THERE IS A FATAL ERROR.
C               LSECT = CONTAINS THE LENGTH OF SECTION 5
C                       AS UNPACKED FROM THE FIRST FOUR
C                       BYTES IN THE SECTION.
C               NSECT = SECTION NUMBER.
C             IEEEREF = THE INTEGER EQUIVALENCE OF THE 'IEEE'
C                       REAL NUMBER CONTAINED IN RVALUE.
C                IREF = THE REFERENCE VALUE OF THE FIELD WHEN
C                       THE DATA FIELD IS INTEGER.
C                   K = A LOOPING INDEX VARIABLE.
C                   N = L3264B = THE INTEGER WORD LENGTH IN BITS OF
C                       THE MACHINE BEING USED. VALUES OF 32 AND
C                       64 ARE ACCOMMODATED.
C              RVALUE = CONTAINS AN 'IEEE' REAL NUMBER.
C               ISIGN = SIGN OF VALUE BEING UNPACKED, 0 = POSITIVE,
C                       1 = NEGATIVE.  THE SIGN ALWAYS GOES IN THE
C                       LEFTMOST BIT OF THE AREA ASSIGNED TO THAT VALUE.
C
C        NON SYSTEM SUBROUTINES CALLED
C           ENDOMESS, RDI3E, UNPKBG
C
      LOGICAL ENDOMESS
C
      DIMENSION IPACK(ND5),IS5(NS5)
C
      EQUIVALENCE (RVALUE,IEEEREF)
C
      N=L3264B
      IER=0
C
C        ALL ERRORS GENERATED BY THIS ROUTINE ARE FATAL.
      ISEVERE=2
C
C        CHECK SIZE OF IS5( ).
C
      IF(NS5.LT.21)THEN
C           NS5 IS THE SIZE FOR TEMPLATE 5.0 (SIMPLE PACKING)
C           WHICH IS CONTAINED IN ALL OTHER DEFINED TEMPLATES.
         IER=502
         GO TO 900
      ENDIF
C
      LOCN5_1=LOCN
      IPOS5_1=IPOS
c
C        UNPACK THE LENGTH OF THE SECTION, LSECT.
      CALL UNPKBG(KFILDO,IPACK,ND5,LOCN,IPOS,LSECT,32,N,IER,*900)
C
C        CHECK FOR AN UNEXPECTED END OF MESSAGE,
C        ACCOMMODATING FOR A 64-BIT WORD.
      IF(ENDOMESS(LSECT,N))THEN
         IER=599
         GO TO 900
      ENDIF
C
C        UNPACK THE NUMBER OF THE SECTION, NSECT. CHECK
C        TO MAKE SURE THAT THIS IS SECTION 5.
      CALL UNPKBG(KFILDO,IPACK,ND5,LOCN,IPOS,NSECT,8,N,IER,*900)
C
      IF(NSECT.NE.5)THEN
         IER=501
         LOCN=LOCN5_1
         IPOS=IPOS5_1
         GO TO 900
      ENDIF
C
      DO K=1,NS5
         IS5(K)=0
      ENDDO
C
      IS5(1)=LSECT
      IS5(5)=NSECT
C
C        UNPACK THE NUMBER OF ACTUAL DATA POINTS WHERE
C        ONE OR MORE VALUES ARE SPECIFIED IN SECTION 7.
      CALL UNPKBG(KFILDO,IPACK,ND5,LOCN,IPOS,IS5(6),32,N,IER,*900)
C
C        UNPACK THE DATA REPRESENTATION TEMPLATE NUMBER.
C
      CALL UNPKBG(KFILDO,IPACK,ND5,LOCN,IPOS,IS5(10),16,N,IER,*900)
C
      CALL UNPKBG(KFILDO,IPACK,ND5,LOCN,IPOS,IEEEREF,32,N,IER,*900)
C        THE REFERENCE VALUE IS ALWAYS PACKED AS FLOATING POINT.
C        RVALUE AND IEEEREF ARE EQIVALENCED.

      REF=RDI3E(RVALUE)
      IS5(12)=INT(REF)
C
C        UNPACK THE BINARY AND DECIMAL SCALE FACTORS,
C        TAKING INTO ACCOUNT THAT THEY MAY BE NEGATIVE.
      CALL UNPKBG(KFILDO,IPACK,ND5,LOCN,IPOS,ISIGN,1,N,IER,*900)
      CALL UNPKBG(KFILDO,IPACK,ND5,LOCN,IPOS,IS5(16),15,N,IER,*900)
      IF(ISIGN.EQ.1)IS5(16)=-IS5(16)
      CALL UNPKBG(KFILDO,IPACK,ND5,LOCN,IPOS,ISIGN,1,N,IER,*900)
      CALL UNPKBG(KFILDO,IPACK,ND5,LOCN,IPOS,IS5(18),15,N,IER,*900)
      IF(ISIGN.EQ.1)IS5(18)=-IS5(18)
C
C        UNPACK THE FIELD WIDTH OF THE PACKED VALUES.
      CALL UNPKBG(KFILDO,IPACK,ND5,LOCN,IPOS,IS5(20),8,N,IER,*900)
C
C        UNPACK THE TYPE OF ORIGINAL FIELD VALUES
      CALL UNPKBG(KFILDO,IPACK,ND5,LOCN,IPOS,IS5(21),8,N,IER,*900)
C
C        UNPACK THE REMAINDER OF SECTION 5 DEPENDING ON
C        WHICH PACKING METHOD WAS USED TO ORIGINALLY
C        PACK THE DATA.
C
      IF(IS5(10).EQ.1)THEN
C
C           CHECK SIZE OF IS5( ) FOR MATRIX OF VALUES.
C
         IF(NS5.LT.36)THEN
            IER=502
            GO TO 900
         ENDIF
C
C           SIMPLE PACKING - MATRIX VALUES AT A GRID POINT
C
         CALL UNPKBG(KFILDO,IPACK,ND5,LOCN,IPOS,IS5(22),8,N,IER,*900)
         CALL UNPKBG(KFILDO,IPACK,ND5,LOCN,IPOS,IS5(23),32,N,IER,*900)
         CALL UNPKBG(KFILDO,IPACK,ND5,LOCN,IPOS,IS5(27),16,N,IER,*900)
         CALL UNPKBG(KFILDO,IPACK,ND5,LOCN,IPOS,IS5(29),16,N,IER,*900)
         CALL UNPKBG(KFILDO,IPACK,ND5,LOCN,IPOS,IS5(31),8,N,IER,*900)
         CALL UNPKBG(KFILDO,IPACK,ND5,LOCN,IPOS,IS5(32),8,N,IER,*900)
         CALL UNPKBG(KFILDO,IPACK,ND5,LOCN,IPOS,IS5(33),8,N,IER,*900)
         CALL UNPKBG(KFILDO,IPACK,ND5,LOCN,IPOS,IS5(34),8,N,IER,*900)
         CALL UNPKBG(KFILDO,IPACK,ND5,LOCN,IPOS,IS5(35),8,N,IER,*900)
         CALL UNPKBG(KFILDO,IPACK,ND5,LOCN,IPOS,IS5(36),8,N,IER,*900)
C
C           CHECK SIZE OF IS5( ) FOR MATRIX OF VALUES.
C
         IF(NS5.LT.37+IS5(32)*4+(4*(IS5(32)+IS5(34))))THEN
            IER=502
            GO TO 900
         ENDIF
C
         DO L=37,36+(IS5(32)*4),4
            CALL UNPKBG(KFILDO,IPACK,ND5,LOCN,IPOS,IS5(L),32,N,IER,*900)
         ENDDO
C
         DO L=37+IS5(32)*4,37+IS5(32)*4+(4*(IS5(32)+IS5(34))),4
            CALL UNPKBG(KFILDO,IPACK,ND5,LOCN,IPOS,IS5(L),32,N,IER,*900)
         ENDDO
C
C        CHECK FOR GRIDPOINT DATA.
C
      ELSE IF((IS5(10).EQ.2).OR.(IS5(10).EQ.3))THEN
C     
C           CHECK FOR SIZE OF IS5( ).
C   
         IF(IS5(10).EQ.2)THEN
C          
            IF(NS5.LT.47)THEN
               IER=502
               GO TO 900
            ENDIF
C
         ELSE
            IF(ND5.LT.49)THEN
               IER=502
               GO TO 900
            ENDIF
C
         ENDIF  
C
C           COMPLEX PACKING WITH OR WITHOUT SPATIAL DIFFERENCING
C           IS TO BE USED
C
         CALL UNPKBG(KFILDO,IPACK,ND5,LOCN,IPOS,IS5(22),8,N,IER,*900)
         CALL UNPKBG(KFILDO,IPACK,ND5,LOCN,IPOS,IS5(23),8,N,IER,*900)
C
C           UNPACK THE PRIMARY AND SECONDARY MISSING VALUE SUBSTITUTES.
C           HOW THESE VALUES WERE PACKED DEPENDS ON THE TYPE OF
C           THE DATA FIELD.
C
         IF(IS5(21).EQ.0)THEN
C
C              THE DATA FIELD WAS PACKED AS FLOATING POINT.
            CALL UNPKBG(KFILDO,IPACK,ND5,LOCN,IPOS,IEEEREF,32,N,
     1                  IER,*900)
            XMISSP=RDI3E(RVALUE)
C
            CALL UNPKBG(KFILDO,IPACK,ND5,LOCN,IPOS,IEEEREF,32,N,
     1                  IER,*900)
            XMISSS=RDI3E(RVALUE)
C
            IS5(24)=INT(XMISSP)
            IS5(28)=INT(XMISSS)
         ELSEIF(IS5(21).EQ.1)THEN
C              
C              THE DATA FIELD WAS PACKED AS INTEGER.
            CALL UNPKBG(KFILDO,IPACK,ND5,LOCN,IPOS,JSIGN,1,N,IER,*900)
            CALL UNPKBG(KFILDO,IPACK,ND5,LOCN,IPOS,MISSP,31,N,IER,*900)
            IF(JSIGN.EQ.1)MISSP=-MISSP
            CALL UNPKBG(KFILDO,IPACK,ND5,LOCN,IPOS,JSIGN,1,N,IER,*900)
            CALL UNPKBG(KFILDO,IPACK,ND5,LOCN,IPOS,MISSS,31,N,IER,*900)
            IF(JSIGN.EQ.1)MISSS=-MISSS
            IS5(24)=MISSP
            IS5(28)=MISSS
            XMISSP=FLOAT(MISSP)
            XMISSS=FLOAT(MISSS)
         ELSE
            IER=509
C              UNRECOGNIZED TYPE OF DATA.
            GO TO 900
         ENDIF
C
         CALL UNPKBG(KFILDO,IPACK,ND5,LOCN,IPOS,IS5(32),32,N,IER,*900)
         CALL UNPKBG(KFILDO,IPACK,ND5,LOCN,IPOS,IS5(36),8,N,IER,*900)
         CALL UNPKBG(KFILDO,IPACK,ND5,LOCN,IPOS,IS5(37),8,N,IER,*900)
         CALL UNPKBG(KFILDO,IPACK,ND5,LOCN,IPOS,IS5(38),32,N,IER,*900)
         CALL UNPKBG(KFILDO,IPACK,ND5,LOCN,IPOS,IS5(42),8,N,IER,*900)
         CALL UNPKBG(KFILDO,IPACK,ND5,LOCN,IPOS,IS5(43),32,N,IER,*900)
         CALL UNPKBG(KFILDO,IPACK,ND5,LOCN,IPOS,IS5(47),8,N,IER,*900)
C
         IF(IS5(10).EQ.3)THEN
C
C              SECOND ORDER SPATIAL DIFFERENCES
C              WE NEED TO UNPACK THE ORDER OF THE SPATIAL DIFFERENCES
C              AND THE NUMBER OF OCTETS THAT THE FIRST AND SECOND
C              ORIGINAL VALUES AND THE MINIMUM OF THE FIELD OF SECOND
C              ORDER DIFFERENCES ARE PACKED IN.
            CALL UNPKBG(KFILDO,IPACK,ND5,LOCN,IPOS,IS5(48),8,N,
     1                  IER,*900)
            CALL UNPKBG(KFILDO,IPACK,ND5,LOCN,IPOS,IS5(49),8,N,
     1                  IER,*900)
         ENDIF
C
      ELSE IF(IS5(10).NE.0) THEN
         IER = 508
C           THE METHOD OF UNPACKING IS NOT SUPPORTED.  NOTE THAT
C           IS5(10) = 0 FOR SIMPLE PACKING DOES NOT REQUIRE ANY MORE
C           UNPACKING HERE.
      ENDIF
C
C        ERROR RETURN SECTION
C
 900  IF(IER.NE.0)RETURN 1
C
      RETURN
      END
