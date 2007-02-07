#ifndef GENPROBE_H
#define GENPROBE_H

#include "type.h"
#include "meta.h"

/* Need missing values, so we can match some but not all things. */
#define MISSING_1 (int) (0xff)
#define MISSING_2 (int) (0xffff)
#define MISSING_4 (sInt4) (0xffffffff)

/* Need to redo the following with respect to GRIB1 TDLP or GRIB2.
printf ("Need ability to get elem string from what we store in match.\n");
printf ("Version (GRIB1 GRIB2 TDLPACK info?\n");
printf ("GRIB1_Table2LookUp()\n");
printf ("TDLP just has an ASCII descriptor\n");
*/
typedef struct {
   uChar ndfdEnum;           /* NDFD_UNDEF or the NDFD enumarated value. */
   sChar version;            /* 1 GRIB1, 2 GRIB2, -1 Tdlp, 0 undef */

/* Who produced it */
   uShort2 center;           /* Who produced it. */
   uShort2 subcenter;        /* Who produced it. */
   uChar genID;              /* More info on what what produced it */

/* What is it? */
   uShort2 templat;          /* The section 4 template number. */
   uChar prodType;           /* 0 is meteo product, 1 is hydro, 2 is land
                                3 is space, 10 is oceanographic. */
   uChar cat;                /* General category of Meteo Product. */
   uChar subcat;             /* Specific subcategory of Meteo Product. */

              /* NOTE: lenTime may be more trouble than it is worth. */
   sInt4 lenTime;            /* duration of event (APCP06 vs APCP12) */

   /* Where is it? */
   uChar surfType;
   double value;
   double sndValue;

/* Probability info. */
/* uChar probType,
   double lowerProb,
   double upperProb,
*/
} genElemDescript;

/* What about missing values? */
typedef struct {
   sChar valueType;          /* 0 = double, 1 = char array,
                              * 2 = Missing (data has missing value)
                              *    (for wx str=("%.0f", missValue))
                              */
   double data;
   char * str;               /* Used for weather strings. */
} genValueType;

typedef struct {
   genElemDescript elem;
   size_t numValue;
   genValueType *value;
   char *unit;
/*
   char *elemName;
   char *file that matched it (to determine sector?)
   char *gds info... enumerated NDFD gds. to determine sector?
*/
   char f_sector;      /* Enumerated sector that this match was in */
   double refTime;
   double validTime;
} genMatchType;

uChar genNdfdVar_Lookup (char *str, char f_toLower, char f_fileConven);
const char *genNdfdEnumToStr (uChar ndfdEnum, char f_fileConven);

void genElemInit (genElemDescript *elem);
void genElemFree (genElemDescript *elem);

#ifdef OLD_176
void genElemListInit (size_t numElem, genElemDescript *elem,
                      uChar f_validNDFD);
#endif
void genElemListInit2 (uChar varFilter[NDFD_MATCHALL + 1],
                       size_t numNdfdVars, const uChar * ndfdVars,
                       size_t * numElem, genElemDescript ** elem);

void genMatchInit (genMatchType *match);
void genMatchFree (genMatchType *match);

int genProbe (size_t numPnts, Point * pnts, sChar f_pntType,
              size_t numInFiles, char **inFiles, uChar f_fileType,
              uChar f_interp, sChar f_unit, double majEarth, double minEarth,
              sChar f_WxParse, sChar f_SimpleVer, size_t numElem,
              genElemDescript * elem, sChar f_valTime, double startTime,
              double endTime, size_t * numMatch, genMatchType ** match,
              char *f_inTypes, char *gribFilter, size_t numSector,
              char ** sector, sChar f_ndfdConven);

#include "userparse.h"
int Grib2DataProbe (userType * usr, int numPnts, Point * pnts, char **labels,
                    char **pntFiles);

int ProbeCmd (sChar f_Command, userType * usr);

#endif
