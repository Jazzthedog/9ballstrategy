/*-------------------------------------------------------------------
   Name: Xi-Vlines.mq4
   Copyright ©2010, Xaphod, http://forexwhiz.appspot.com
   
   Description: 
     Draws up to 5 vertical lines at the beginning or end of specified hours
   History:
   2010-09-15, Xaphod, v1.02
     - Bug fix: Lines for data between shutdown and startup not being drawn on startup.
   2010-07-20, Xaphod, v1.01
     - Code Formatting & refactoring 
   2010-07-20, Xaphod, v1.01
     - Bug Fix: did not draw line2, line3 and line4 in current time.
     - Added Indicator number so multiple copies of the indicator can be put on the same chart.
     - Added extra Line: Line5.
   2010-04-21- Xaphod, v1.00
     - Initial Release 
-------------------------------------------------------------------*/
#property copyright "Copyright © 2010, forexwhiz.appspot.com"
#property link      "http://forexwhiz.appspot.com"
#property indicator_chart_window

#define INDICATOR_NAME "Xi-VLines"
#define INDICATOR_VERSION "v1.02"

extern int       IndicatorNr=1;       // Nr of this indicator instance on the chart
extern int       NrOfDays=5;          // Nr of past days to draw the session channel for
// Indicator parameters
extern string    Info1="<< Extra Vertical line 1  >>";
extern bool      VLine1Show=true;     // Draw a vertical line for whatever you want
extern int       VLine1Hour=09;       // Draw a vertical line for whatever you want
extern bool      VLine1OnHour=true;  // True: Channel and vline on the first bar of the hour. False: On the previous bar.
extern color     VLine1Color=Silver;    // Color of the session close time line
extern int       VLine1Style=2;       // Style of the session close time line. Value 0-4
extern int       VLine1Width=1;       // Width of the session close time line
extern string    VLine1label="Europe Open";  // Label for session close time line. 

extern string    Info2="<< Extra Vertical line 2  >>";
extern bool      VLine2Show=true;      // Draw a vertical line for whatever you want
extern int       VLine2Hour=10;        // Hour on which to draw line
extern bool      VLine2OnHour=true;   // True: Channel and vline on the first bar of the hour. False: On the previous bar.
extern color     VLine2Color=Silver;     // Color of the session close time line
extern int       VLine2Style=2;        // Style of the session close time line. Value 0-4
extern int       VLine2Width=1;        // Width of the session close time line
extern string    VLine2label="London Open";  // Label for session close time line. 

extern string    Info3="<< Extra Vertical line 3  >>";
extern bool      VLine3Show=true;     // Draw a vertical line for whatwver you want
extern int       VLine3Hour=15;        // Draw a vertical line for whatwver you want
extern bool      VLine3OnHour=true;    // True: Channel and vline on the first bar of the hour. False: On the previous bar.
extern color     VLine3Color=Silver;     // Color of the session close time line
extern int       VLine3Style=2;        // Style of the session close time line. Value 0-4
extern int       VLine3Width=1;        // Width of the session close time line
extern string    VLine3label="New York Open";// Label for session close time line. 

extern string    Info4="<< Extra Vertical line 4  >>";
extern bool      VLine4Show=true;     // Draw a vertical line for whatwver you want
extern int       VLine4Hour=19;        // Draw a vertical line for whatwver you want
extern bool      VLine4OnHour=true;    // True: Channel and vline on the first bar of the hour. False: On the previous bar.
extern color     VLine4Color=Silver;     // Color of the session close time line
extern int       VLine4Style=2;        // Style of the session close time line. Value 0-4
extern int       VLine4Width=1;        // Width of the session close time line
extern string    VLine4label="London Close";// Label for session close time line. 

extern string    Info5="<< Extra Vertical line 5  >>";
extern bool      VLine5Show=true;     // Draw a vertical line for whatwver you want
extern int       VLine5Hour=23;        // Draw a vertical line for whatwver you want
extern bool      VLine5OnHour=true;    // True: Channel and vline on the first bar of the hour. False: On the previous bar.
extern color     VLine5Color=Silver;     // Color of the session close time line
extern int       VLine5Style=2;        // Style of the session close time line. Value 0-4
extern int       VLine5Width=1;        // Width of the session close time line
extern string    VLine5label="Australia Open";// Label for session close time line. 

// Indicator data
bool mbRunOnce;


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init() {
  //---- Set Indicator Name
   IndicatorShortName(INDICATOR_NAME+IndicatorNr+"-"+INDICATOR_VERSION);   
   mbRunOnce=false;
   return(0);
}


//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit() {
  // Clear objects
  for(int i=ObjectsTotal()-1; i>-1; i--)
    if (StringFind(ObjectName(i),INDICATOR_NAME+IndicatorNr)>=0)  ObjectDelete(ObjectName(i));
  return(0);
}


//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start() {
  int iNewBars;
  int iCountedBars;   
 
  // Get unprocessed ticks
  iCountedBars=IndicatorCounted();
  if(iCountedBars < 0) return (-1);
  iNewBars=Bars-iCountedBars;
  
  // Draw old sessions
  if (mbRunOnce==false || iNewBars>3) {
    if (VLine1Show==true) DrawPreviousVLine1();
    if (VLine2Show==true) DrawPreviousVLine2();
    if (VLine3Show==true) DrawPreviousVLine3();
    if (VLine4Show==true) DrawPreviousVLine4(); 
    if (VLine5Show==true) DrawPreviousVLine5(); 
    mbRunOnce=true;
  } //endif  
  
    DrawCurrentVLines(iNewBars);
//----
   return(0);
  }
//+------------------------------------------------------------------+


int DrawCurrentVLines(int iNewTicks) {
  int iLineOnHour;
  int i;
  int iNrOfDays;

  for(i=0; i<=iNewTicks; i++) {
    if (VLine1Show==true && TimeHour(Time[i])==VLine1Hour && TimeMinute(Time[i])==0) {
      if (VLine1OnHour==True) iLineOnHour=0; else iLineOnHour=1;
      DrawLine(Time[i+iLineOnHour],VLine1Style,VLine1Width,VLine1Color,"Line1");
      if (StringLen(VLine1label)>0) DrawTextLabel(Time[i+iLineOnHour],VLine1label,VLine1Color);
    }
    if (VLine2Show==true && TimeHour(Time[i])==VLine2Hour && TimeMinute(Time[i])==0) {
      if (VLine2OnHour==True) iLineOnHour=0; else iLineOnHour=1;
      DrawLine(Time[i+iLineOnHour],VLine2Style,VLine2Width,VLine2Color,"Line2");
      if (StringLen(VLine2label)>0) DrawTextLabel(Time[i+iLineOnHour],VLine2label,VLine2Color);
    }
    if (VLine3Show==true && TimeHour(Time[i])==VLine3Hour && TimeMinute(Time[i])==0) {
      if (VLine3OnHour==True) iLineOnHour=0; else iLineOnHour=1;
      DrawLine(Time[i+iLineOnHour],VLine3Style,VLine3Width,VLine3Color,"Line3");
      if (StringLen(VLine3label)>0) DrawTextLabel(Time[i+iLineOnHour],VLine3label,VLine3Color);
    }
    if (VLine4Show==true && TimeHour(Time[i])==VLine4Hour && TimeMinute(Time[i])==0) {
      if (VLine4OnHour==True) iLineOnHour=0; else iLineOnHour=1;
      DrawLine(Time[i+iLineOnHour],VLine4Style,VLine4Width,VLine4Color,"Line4");
      if (StringLen(VLine4label)>0) DrawTextLabel(Time[i+iLineOnHour],VLine4label,VLine4Color);
    }
    if (VLine5Show==true && TimeHour(Time[i])==VLine5Hour && TimeMinute(Time[i])==0) {
      if (VLine5OnHour==True) iLineOnHour=0; else iLineOnHour=1;
      DrawLine(Time[i+iLineOnHour],VLine5Style,VLine5Width,VLine5Color,"Line5");
      if (StringLen(VLine5label)>0) DrawTextLabel(Time[i+iLineOnHour],VLine5label,VLine5Color);
    }
  }
  return(0);
}


int DrawPreviousVLine1() {
  int iLineOnHour;
  int i;
  int iNrOfDays;
  
  
  // Set the closing bar. On hour bar or on previous bar.    
  // Draw asian session for old data
  i=0;iNrOfDays=0;
  while (i<Bars && iNrOfDays<NrOfDays) {
    if (TimeHour(Time[i])==VLine1Hour && TimeMinute(Time[i])==0) {
      if (VLine1OnHour==True) iLineOnHour=0; else iLineOnHour=1;
      DrawLine(Time[i+iLineOnHour],VLine1Style,VLine1Width,VLine1Color,"VLine1");
      if (StringLen(VLine1label)>0) DrawTextLabel(Time[i+iLineOnHour],VLine1label,VLine1Color);
      iNrOfDays++;  
    }    
    i++;
  }
  return(0);
}

int DrawPreviousVLine2() {
  int iLineOnHour;
  int i;
  int iNrOfDays;  
  
  // Set the closing bar. On hour bar or on previous bar.    
  // Draw asian session for old data
  i=0;iNrOfDays=0;
  while (i<Bars && iNrOfDays<NrOfDays) {
    if (TimeHour(Time[i])==VLine2Hour && TimeMinute(Time[i])==0) {
      if (VLine2OnHour==True) iLineOnHour=0; else iLineOnHour=1;
      DrawLine(Time[i+iLineOnHour],VLine2Style,VLine2Width,VLine2Color,"VLine2");
      if (StringLen(VLine2label)>0) DrawTextLabel(Time[i+iLineOnHour],VLine2label,VLine2Color);
      iNrOfDays++;  
    }
    i++;
  }
  return(0);
}   

int DrawPreviousVLine3() {
  int iLineOnHour;
  int i;
  int iNrOfDays;  
  
  // Set the closing bar. On hour bar or on previous bar.    
  // Draw asian session for old data
  i=0;iNrOfDays=0;
  while (i<Bars && iNrOfDays<NrOfDays) {
    if (TimeHour(Time[i])==VLine3Hour && TimeMinute(Time[i])==0) {
      if (VLine3OnHour==True) iLineOnHour=0; else iLineOnHour=1;
      DrawLine(Time[i+iLineOnHour],VLine3Style,VLine3Width,VLine3Color,"VLine3");
      if (StringLen(VLine3label)>0) DrawTextLabel(Time[i+iLineOnHour],VLine3label,VLine3Color);
      iNrOfDays++;  
    }
    i++;
  }
  return(0);
}   

int DrawPreviousVLine4() {
  int iLineOnHour;
  int i;
  int iNrOfDays;  
  
  // Set the closing bar. On hour bar or on previous bar.    
  // Draw asian session for old data
  i=0;iNrOfDays=0;
  while (i<Bars && iNrOfDays<NrOfDays) {
    if (TimeHour(Time[i])==VLine4Hour && TimeMinute(Time[i])==0) {
      if (VLine4OnHour==True) iLineOnHour=0; else iLineOnHour=1;
      DrawLine(Time[i+iLineOnHour],VLine1Style,VLine4Width,VLine4Color,"VLine4");
      if (StringLen(VLine4label)>0) DrawTextLabel(Time[i+iLineOnHour],VLine4label,VLine4Color);
      iNrOfDays++;  
    }
    i++;
  }
  return(0);
}   

int DrawPreviousVLine5() {
  int iLineOnHour;
  int i;
  int iNrOfDays;  
  
  // Set the closing bar. On hour bar or on previous bar.    
  // Draw asian session for old data
  i=0;iNrOfDays=0;
  while (i<Bars && iNrOfDays<NrOfDays) {
    if (TimeHour(Time[i])==VLine5Hour && TimeMinute(Time[i])==0) {
      if (VLine5OnHour==True) iLineOnHour=0; else iLineOnHour=1;
      DrawLine(Time[i+iLineOnHour],VLine1Style,VLine5Width,VLine5Color,"VLine5");
      if (StringLen(VLine5label)>0) DrawTextLabel(Time[i+iLineOnHour],VLine5label,VLine5Color);
      iNrOfDays++;  
    }
    i++;
  }
  return(0);
}   

//-----------------------------------------------------------------------------
// function: DrawLine()
// Description: Draw a horizontal line at specific price
//----------------------------------------------------------------------------- 
int DrawLine(double tTime, int iLineStyle, int iLineWidth, color cLineColor, string sId) {
  string sLineId;
  
  // Set Line object ID  
  sLineId=INDICATOR_NAME+IndicatorNr+"_"+sId+"_"+TimeToStr(tTime,TIME_DATE );
  
  // Draw line
  if (ObjectFind(sLineId)>=0 ) ObjectDelete(sLineId);
  ObjectCreate(sLineId, OBJ_TREND, 0, tTime, 0, tTime, 10); 
  //ObjectCreate(sLineId, OBJ_VLINE, 0, tTime, 0); 
  ObjectSet(sLineId, OBJPROP_STYLE, iLineStyle);     
  ObjectSet(sLineId, OBJPROP_WIDTH, iLineWidth);
  ObjectSet(sLineId, OBJPROP_BACK, true);
  ObjectSet(sLineId, OBJPROP_COLOR, cLineColor);    
  return(0);
}

//-----------------------------------------------------------------------------
// function: DrawTextLabel()
// Description: Draw a text label for a line
//-----------------------------------------------------------------------------
int DrawTextLabel(double tTime, string sLabel, color cLineColor) {
  double tTextPos=0;
  string sLineLabel="";
  string sLineId;
  color cTextColor;
  
  // Set Line object ID  
  sLineId=INDICATOR_NAME+IndicatorNr+"_"+sLabel+"_"+TimeToStr(tTime,TIME_DATE );
  
  //Set position of text label
  tTextPos=WindowPriceMin()+(WindowPriceMax()-WindowPriceMin())/2;
  //PrintD("tTextPos: "+tTextPos);
  // Draw or text label  
  if (ObjectFind(sLineId)>=0 ) ObjectDelete(sLineId);      
  ObjectCreate(sLineId, OBJ_TEXT, 0, tTime, tTextPos);    
  ObjectSet(sLineId, OBJPROP_ANGLE, 90);
  ObjectSet(sLineId, OBJPROP_BACK, true);
  ObjectSetText(sLineId, sLabel , 8, "Arial", cLineColor);
 
  return(0);
}

