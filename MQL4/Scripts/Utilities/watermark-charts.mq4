//+------------------------------------------------------------------+
//|                                             watermark-charts.mq4 |
//|                                     Copyright 2020, Ryan Sheehy. |
//|                                    https://robottradingforex.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Ryan Sheehy"
#property link      "https://robottradingforex.com/watermark-mql4/"
#property version   "1.00"
#property strict

extern int height_pixels=640;
extern int width_pixels=1280; 
extern int font_size=80;

int OnInit() {
   createWatermark();
   return(INIT_SUCCEEDED);
}

bool createWatermark() {
  // unique name given to the object label
  string name = "watermark";
  // check if we already have it on the chart, if so delete it
  ObjectDelete( 0, name );
  string txt = "";
  // change the periods to a string label
  if (Period() == PERIOD_MN1) txt = "MONTH";
  if (Period() == PERIOD_W1) txt = "WEEK";
  if (Period() == PERIOD_D1) txt = "DAY";
  if (Period() == PERIOD_H4) txt = "4 HOUR";
  if (Period() == PERIOD_H1) txt = "1 HOUR";
  if (Period() == PERIOD_M30) txt = "30 MIN";
  if (Period() == PERIOD_M15) txt = "15 MIN";
  if (Period() == PERIOD_M5) txt = "5 MIN";
  if (Period() == PERIOD_M1) txt = "1 MIN";
  // preparing for error
  ResetLastError();
  // create the object shell and report any errors
  if (!ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0)) {
  	Print(__FUNCTION__, ": failed to create text label! Error code = ",GetLastError());
	return(false);
  }
  // add the symbol to the text
  txt = txt + "  " + Symbol();
  // set the text
  ObjectSetString(0, name, OBJPROP_TEXT, txt);
  // set the corner reference of X & Y axis
  ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
  // set the anchor reference of the label
  ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_CENTER); 
  // set the X & Y co-ordinates
  ObjectSetInteger(0, name, OBJPROP_XDISTANCE, width_pixels/2);
  ObjectSetInteger(0, name, OBJPROP_YDISTANCE, height_pixels/2);
  // set the font
  ObjectSetString(0, name, OBJPROP_FONT, "Arial");
  // set the size of the font
  ObjectSetInteger(0, name, OBJPROP_FONTSIZE, font_size);
  // set the color of the font
  ObjectSetInteger(0, name, OBJPROP_COLOR, clrLightGray);
  // set the object into the background, behind price
  ObjectSetInteger(0, name, OBJPROP_BACK, true);
  // turn off the ability to select the object
  ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
  ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
  // make it hidden from the object list
  ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
  return(true);  	
}