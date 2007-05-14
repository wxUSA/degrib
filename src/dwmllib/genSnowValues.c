/******************************************************************************
 * genSnowValues() --
 *
 * Paul Hershberg / MDL
 * Linux
 *
 * PURPOSE
 *  This code formats the Snow Amount element in the "time-series" DWMLgen 
 *  product.
 *
 * ARGUMENTS
 *         pnt = Current Point index. (Input)
 *   layoutKey = The key linking the Snow Amounts to their valid times 
 *               (ex. k-p3h-n42-3). (Input)
 *       match = Pointer to the array of element matches from degrib. (Input) 
 *  parameters = An xml Node Pointer denoting the <parameters> node to which 
 *               these values will be attached (child node). (Output)
 *     numRows = Structure containing members: (Input)
 *                    total: Total number of rows data is formatted for in the 
 *                           output XML. Used in DWMLgenByDay's "12 hourly" and 
 *                           "24 hourly" products. "numRows" is determined 
 *                           using numDays and is used as an added criteria
 *                           (above and beyond simply having data exist for a 
 *                           certain row) in formatting XML for these two 
 *                           products. (Input)
 *                  skipBeg: the number of beginning rows not formatted due 
 *                           to a user supplied reduction in time (startTime
 *                           arg is not = 0.0)
 *                  skipEnd: the number of end rows not formatted due to a 
 *                           user supplied reduction in time (endTime arg
 *                           is not = 0.0)
 *            firstUserTime: the first valid time interested per element, 
 *                           taking into consideration any data values 
 *                           (rows) skipped at beginning of time duration.
 *             lastUserTime: the last valid time interested per element, 
 *                           taking into consideration any data values 
 *                           (rows) skipped at end of time duration.
 *    startNum = First index in match structure an individual point's data 
 *               matches can be found. (Input)
 *      endNum = Last index in match structure an individual point's data
 *               matches can be found. (Input) 
 *
 * FILES/DATABASES: None
 *
 * RETURNS: void
 *
 * HISTORY
 *   3/2006 Paul Hershberg (MDL): Created
 *
 * NOTES
 ******************************************************************************
 */
#include "xmlparse.h"
void genSnowValues(size_t pnt, char *layoutKey, genMatchType *match,
                   xmlNodePtr parameters, numRowsInfo numRows, int startNum, 
                   int endNum)
{
   int i;                     /* Counter thru match structure. */
   int roundedSnowData;       /* Returned rounded data. */
   xmlNodePtr precipitation = NULL; /* Xml Node Pointer for <precipitation>
                                     * element. */
   xmlNodePtr value = NULL;   /* Xml Node Pointer for <value> element. */
   char strBuff[30];          /* Temporary string buffer holding rounded
                               * data. */

   /* Format the <precipitation> element. */
   precipitation = xmlNewChild(parameters, NULL, BAD_CAST "precipitation",
                               NULL);
   xmlNewProp(precipitation, BAD_CAST "type", BAD_CAST "snow");
   xmlNewProp(precipitation, BAD_CAST "units", BAD_CAST "inches");
   xmlNewProp(precipitation, BAD_CAST "time-layout", BAD_CAST layoutKey);

   /* Format the display <name> element. */
   xmlNewChild(precipitation, NULL, BAD_CAST "name", BAD_CAST "Snow Amount");

   /* Loop over all the data values and format them. */
   for (i = startNum; i < endNum; i++)
   {
      if (match[i].elem.ndfdEnum == NDFD_SNOW && 
	  match[i].validTime >= numRows.firstUserTime &&
	  match[i].validTime <= numRows.lastUserTime)
      {

         /* If the data is missing, so indicate in the XML (nil=true). */
         if (match[i].value[pnt].valueType == 2)
         {
            value = xmlNewChild(precipitation, NULL, BAD_CAST "value", NULL);
            xmlNewProp(value, BAD_CAST "xsi:nil", BAD_CAST "true");
         }
         else if (match[i].value[pnt].valueType == 0) /* Format good data. */
         {
            roundedSnowData = (int)myRound(match[i].value[pnt].data, 0);
            sprintf(strBuff, "%d", roundedSnowData);
            xmlNewChild(precipitation, NULL, BAD_CAST "value", BAD_CAST
                        strBuff);
         }
      }
   }
   return;
}
