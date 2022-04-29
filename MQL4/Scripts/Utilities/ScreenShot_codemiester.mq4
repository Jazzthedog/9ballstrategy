//+------------------------------------------------------------------+
//|                                                   ScreenShot.mq4 |
//|                                                      Ted Goulden |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Ted Goulden"
#property link      ""

extern string     FileName="Screen";
extern string     ChartType="Candle";

int  chartType=1;
datetime    barStart = 0;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
   
   chartType = -1;
   if (ChartType == "Bar") chartType = 0;
   else if (ChartType == "Candle") chartType = 1;
   else if (ChartType == "Line") chartType = 2;
   else Print (" Invalid Chart Type, must be Bar, Candle or Line. ", ChartType);
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
//----
   if (barStart < Time[0]) //start of new bar 
   {
      string timeStamp = TimeToStr(TimeCurrent(), TIME_DATE|TIME_MINUTES);
      string newstr = StringSetChar(timeStamp, 13, '_');
      //WindowScreenShot(FileName + "_" + Symbol() + "_" + Period() + "_" + newstr + ".gif", 640, 480, -1, -1, chartType);
      WindowScreenShot(FileName + "_" + Symbol() + "_" + Period() + "_" + newstr + ".gif", 800, 800, -1, -1, chartType);
            
      barStart = Time[0];
   }   
//----
   PlaySound ("ok.wav");    
   return(0);
  }
//+------------------------------------------------------------------+