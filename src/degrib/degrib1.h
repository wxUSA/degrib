#ifndef DEGRIB1_H
#define DEGRIB1_H

#include <stdio.h>
#include "type.h"
#include "meta.h"
#include "degrib2.h"
#include "inventory.h"

typedef struct {
	char *name, *comment, *unit;
   unit_convert convert;
} GRIB1ParmTable;

typedef struct {
   char *name, *comment, *unit;
   char f_twoPart;
} GRIB1SurfTable;


int GRIB1_Inventory (FILE *fp, uInt4 gribLen, inventoryType * inv);

int GRIB1_RefTime (FILE * fp, uInt4 gribLen, double *refTime);

int ReadGrib1Record (FILE * fp, sChar f_unit, double **Grib_Data,
                     uInt4 *grib_DataLen, grib_MetaData * meta,
                     IS_dataType * IS, sInt4 sect0[SECT0LEN_WORD],
                     uInt4 gribLen, double majEarth, double minEarth,
                     double usrUnitM, double usrUnitB);
#endif
