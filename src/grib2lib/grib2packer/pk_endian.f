      LOGICAL FUNCTION PK_ENDIAN( )
C
C        MARCH  2001    MATTISON/LAWRENCE  GSC/MDL   ORIGINAL CODING
C        OCTOBER 2002   LAWRENCE           WHFS/OHD  
C                       FIXED A BUG THAT WAS PREVENTING THE
C                       DETERMINATION OF THE CORRECT OPERATING 
C                       SYSTEM.
C
C        PURPOSE
C           RETURNS A VALUE OF "TRUE" IF THE MACHINE THAT 
C           THIS ROUTINE IS BEING RUN ON IS USING 
C           BIG ENDIAN MEMORY ARCHITECTURE.  THIS ROUTINE
C           WILL RETURN A VALUE OF "FALSE" IF THE MACHINE
C           THAT THIS ROUTINE IS BEING RUN ON IS USING
C           LITTLE ENDIAN MEMORY ARCHITECTURE.
C
C           ON BIG ENDIAN SYSTEMS (SUCH AS THE HP-9000 WORKSTATIONS),
C           THE LAST BYTE OF AN INTEGER*4 VALUE IS THE LEAST 
C           SIGNIFICANT BYTE.  ON LITTLE ENDIAN SYSTEMS (SUCH AS
C           INTEL PENTIUM SYSTEMS) THE LAST BYTE OF AN INTEGER*4
C           VALUE IS THE MOST SIGNIFICANT BYTE.
C
C           THIS ROUTINE FUNCTIONS AS FOLLOWS:
C
C           THE INTEGER*4 VARIABLE, "I", IS SET TO "0".  THIS
C           ZEROS OUT EACH OF THE FOUR BYTES IN "I".  THIS ALSO
C           SETS EACH OF THE CHARACTERS IN "LETTER" TO "0" SINCE
C           THIS CHARACTER STRING IS EQUIVALENCED TO "I".  THEN,
C           THE FOURTH CHARACTER OF "LETTER" IS SET TO THE CHARACTER
C           WITH AN ASCII VALUE OF "1".  BECAUSE OF THE EQUIVALENCE,
C           THIS SETS THE FOURTH BYTE OF "I" TO CONTAIN A VALUE
C           OF "1".
C
C           ON A BIG ENDIAN SYSTEM, WITH I's LAST (LEAST SIGNIFICANT)
C           BYTE BEING "1", "I" IS SEEN TO HAVE THE VALUE "1".  
C           HOWEVER, ON A LITTLE ENDIAN SYSTEM WITH I's LAST
C           (MOST SIGNIFICANT) BYTE BEING "1", "I" IS SEEN TO HAVE 
C           THE VALUE OF 2**24 (16777216).  THUS, BY TESTING ON THE
C           VALUE OF "I", THIS ROUTINE CAN DETERMINE WHICH TYPE
C           OF HARDWARE THIS ROUTINE IS BEING RUN ON.
C
C        DATA SET USE
C           NONE
C        VARIABLES
C           NONE
C
C             LOCAL VARIABLES
C                   I = CONTAINS THE VALUE OF "1" TO BE USED IN
C                       DETERMINING THE "ENDIANESS" OF THE 
C                       HARDWARE THAT THIS ROUTINE IS BEING
C                       RUN ON.  (INTEGER*4)
C              LETTER = EQUIVALENCED TO "I".  THIS FOUR-BYTE
C                       CHARACTER STRING ALLOWS THIS ROUTINE
C                       TO MANIPULATE THE INDIVIDUAL BYTE
C                       VALUES IN "I".
C
C        NON SYSTEM SUBROUTINES CALLED
C           NONE

      INTEGER*4 I
      CHARACTER*4 LETTER
      EQUIVALENCE (LETTER, I)
C
      I = 0
      LETTER(4:4) = CHAR(1)
C
      IF (I.EQ.1) THEN
         PK_ENDIAN=.TRUE.
      ELSE
         PK_ENDIAN=.FALSE.
      ENDIF
C
      RETURN
      END
