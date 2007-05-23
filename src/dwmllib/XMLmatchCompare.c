/******************************************************************************
 * XMLmatchCompare() --
 *
 * Paul Hershberg / MDL
 * Linux
 *
 * PURPOSE
 *  Compare match A with B. First compares the sector the match was found in,
 *  then compares "NDFDtype" (or element) enum type, then compares the 
 *  validTime. Routine then orders the entire match structure in this manner.
 *
 * ARGUMENTS
 *         A = First NDFD match for comparison. (Input)
 *         B = Second NDFD match for comparison. (Input)
 *                                         
 * FILES/DATABASES: None
 *
 * RETURNS: int (returns a -1, 0, or 1 depending on comparison).
 *
 * HISTORY
 *   5/2007  Paul Hershberg (MDL): Created
 *
 * NOTES
 ******************************************************************************
 */
#include "xmlparse.h"
int XMLmatchCompare (const void *A, const void *B)
{
   const genMatchType *a = (genMatchType *) A;
   const genMatchType *b = (genMatchType *) B;
   double f_sectA = a->f_sector; /* Temp placeholder */
   double f_sectB = b->f_sector; /* Temp placeholder */
   
   /* Get the match structure in the sector enum order
    * (0 - conus, 5 - nhemi, 1 - peurtori, 2 - hawaii,
    * 3 - guam, 4 - alaska, 6 - undefined for point 
    * processing in XMLParse. Take note if there are
    * any elements from Sector 5 (tropical winds are
    * found in the nhemi sector).
    */
   if (f_sectA == 5)
      f_sectA = 0.5;
   if (f_sectB == 5)
      f_sectB = 0.5;

   /* Sort */
   if (f_sectA < f_sectB)
      return -1;
   if (f_sectA > f_sectB)
      return 1;
   if (a->elem.ndfdEnum < b->elem.ndfdEnum)
      return -1;
   if (a->elem.ndfdEnum > b->elem.ndfdEnum)
      return 1;
   if (a->validTime < b->validTime)
      return -1;
   if (a->validTime > b->validTime)
      return 1;
   return 0;
}