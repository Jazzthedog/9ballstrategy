//+------------------------------------------------------------------+
//|                                                 !TMA True v2.mq4 |
//|                                  Copyright © 2011, John Wustrack |
//|                                        john_wustrack@hotmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, John Wustrack"
#property link      "john_wustrack@hotmail.com"

#property indicator_chart_window

#property indicator_buffers 3
#property indicator_color1 DarkGray
#property indicator_color2 Red
#property indicator_color3 DodgerBlue
//#property indicator_style4 STYLE_SOLID
//#property indicator_style5 STYLE_SOLID

extern int TMA_Period = 30;
extern int ATR_Period = 60;
extern double ATR_Mult = 2.0;
//extern color xc_Text = LightGray;

double IB_TMA[], IB_TMA_Up[], IB_TMA_Dn[];
double IB_Upper[], IB_Lower[];

int gi_PipsDecimal;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- 
   IndicatorBuffers(3);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,IB_TMA);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,IB_Upper);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,IB_Lower);
   
   SetIndexDrawBegin(0,TMA_Period);
   SetIndexDrawBegin(1,TMA_Period);
   SetIndexDrawBegin(2,TMA_Period);
   
   SetIndexLabel(0,"TMA Mid line");
   SetIndexLabel(1,"TMA Upper line");
   SetIndexLabel(2,"TMA Lower line");
   
   IndicatorDigits(Digits);

   gi_PipsDecimal = Get_Pips_Decimal();
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   ObjectDelete("!TMA True v2 Range");
   ObjectDelete("!TMA True v2 Trend");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
//----
   int counted_bars = IndicatorCounted();
   
   if (counted_bars < 0) return (-1);
   if (counted_bars > 0) counted_bars--;
   int limit = Bars - counted_bars;
   double ld_Range;
   
   for (int i=limit; i>=0; i--)
      {
      IB_TMA[i] = EMPTY_VALUE;
      IB_TMA_Up[i] = EMPTY_VALUE;
      IB_TMA_Dn[i] = EMPTY_VALUE;
      
      IB_TMA[i] = iMA(NULL,0,TMA_Period,0,MODE_LWMA,PRICE_CLOSE,i);
      
  /*    // Color 
      if (IB_TMA[i] > IB_TMA[i+1])
         IB_TMA_Up[i] = IB_TMA[i];
      if (IB_TMA[i] < IB_TMA[i+1])
         IB_TMA_Dn[i] = IB_TMA[i];
  */       
      // Draw upper & lower boundaries
      ld_Range = iATR(NULL,0,ATR_Period,i+10);
      IB_Upper[i] = IB_TMA[i] + (ld_Range * ATR_Mult);
      IB_Lower[i] = IB_TMA[i] - (ld_Range * ATR_Mult);
      
      }
      
 /*     // Calculate the distances between bid & bands
      double ld_Dist_Pts, ld_Dist_Pips;
      
      // Distance to mid
      ld_Dist_Pts = MathAbs(Bid - IB_TMA[0]);
      ld_Dist_Pips = Convert_2_Pips(ld_Dist_Pts);
      ObjectCreate("!Mid",OBJ_TEXT,0,0,0);
      ObjectSet("!Mid",OBJPROP_TIME1,Time[0]+(3*TMA_Period()*60));
      ObjectSet("!Mid",OBJPROP_PRICE1,IB_TMA[0]);
      ObjectSetText("!Mid",DoubleToStr(ld_Dist_Pips,gi_PipsDecimal),8,"Arial",xc_Text);
      
      // Distance to upper
      ld_Dist_Pts = MathAbs(Bid - IB_Upper[0]);
      ld_Dist_Pips = Convert_2_Pips(ld_Dist_Pts);
      ObjectCreate("!Upp",OBJ_TEXT,0,0,0);
      ObjectSet("!Upp",OBJPROP_TIME1,Time[0]+(3*TMA_Period()*60));
      ObjectSet("!Upp",OBJPROP_PRICE1,IB_Upper[0]);
      ObjectSetText("!Upp",DoubleToStr(ld_Dist_Pips,gi_PipsDecimal),8,"Arial",xc_Text);
      
      // Distance to lower
      ld_Dist_Pts = MathAbs(Bid - IB_Lower[0]);
      ld_Dist_Pips = Convert_2_Pips(ld_Dist_Pts);
      ObjectCreate("!Low",OBJ_TEXT,0,0,0);
      ObjectSet("!Low",OBJPROP_TIME1,Time[0]+(3*TMA_Period()*60));
      ObjectSet("!Low",OBJPROP_PRICE1,IB_Lower[0]);
      ObjectSetText("!Low",DoubleToStr(ld_Dist_Pips,gi_PipsDecimal),8,"Arial",xc_Text);
 */
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| get TMA trend range                                              |
//+------------------------------------------------------------------+
double Get_Trend_Range()
  {
//----
   double pd_Range;
   int i;
   
   // Going up
   if (IB_TMA_Up[1] != EMPTY_VALUE)
      {
      for (i=2; i<Bars; i++)
         if (IB_TMA_Up[i] == EMPTY_VALUE) break;
      }
   
   // Going down   
   if (IB_TMA_Dn[1] != EMPTY_VALUE)
      {
      for (i=2; i<Bars; i++)
         if (IB_TMA_Dn[i] == EMPTY_VALUE) break;
      }
      
   pd_Range = MathAbs(IB_TMA[1]-IB_TMA[i-1]);   
//----
   return(pd_Range);
  }
//+------------------------------------------------------------------+
//| create screen objects                                            |
//+------------------------------------------------------------------+
void Object_Create(string ps_name,int pi_x,int pi_y,string ps_text=" ",int pi_size=12,
                  string ps_font="Arial",color pc_colour=CLR_NONE)
  {
//----
   
//   if (colour==CLR_NONE) colour=xcBackground;
      
   ObjectCreate(ps_name,OBJ_LABEL,0,0,0,0,0);
   ObjectSet(ps_name,OBJPROP_CORNER,3);
   ObjectSet(ps_name,OBJPROP_COLOR,pc_colour);
   ObjectSet(ps_name,OBJPROP_XDISTANCE,pi_x);
   ObjectSet(ps_name,OBJPROP_YDISTANCE,pi_y);
   
   ObjectSetText(ps_name,ps_text,pi_size,ps_font,pc_colour);

//----
   //return(0);
  }
//+------------------------------------------------------------------+
//| convert to points                                                |
//+------------------------------------------------------------------+
double Convert_2_Pts(double pd_Pips)
  {
//----
   int pd_Points=pd_Pips;  // Default - no conversion
   
 	if (Digits == 5 || (Digits == 3 && StringFind(Symbol(), "JPY") != -1)) 
 	   pd_Points=pd_Pips*10;
 	   
 	if (Digits == 6 || (Digits == 4 && StringFind(Symbol(), "JPY") != -1)) 
 	   pd_Points=pd_Pips*100;
//----
   return(pd_Points);
  }
//+------------------------------------------------------------------+
//| convert to pips                                                  |
//+------------------------------------------------------------------+
double Convert_2_Pips(double pd_Points)
  {
//----
   double pd_Pips=pd_Points/Point;  // Default - no conversion
   
 	if (Digits == 5 || (Digits == 3 && StringFind(Symbol(), "JPY") != -1)) 
 	   {
 	   pd_Pips=pd_Points/Point/10;
 	   }
 	   
 	if (Digits == 6 || (Digits == 4 && StringFind(Symbol(), "JPY") != -1)) 
 	   {
 	   pd_Pips=pd_Points/Point/100;
 	   }
//----
   return(pd_Pips);
  }
//+------------------------------------------------------------------+
//| get the pips decimal places                                      |
//+------------------------------------------------------------------+
int Get_Pips_Decimal()
  {
//----
   int pi_PipsDecimal = 0;  // Default - no decimals
   
 	if (Digits == 5 || (Digits == 3 && StringFind(Symbol(), "JPY") != -1)) 
 	   {
 	   pi_PipsDecimal = 1;
 	   }
 	   
 	if (Digits == 6 || (Digits == 4 && StringFind(Symbol(), "JPY") != -1)) 
 	   {
 	   pi_PipsDecimal = 2;
 	   }
//----
   return(pi_PipsDecimal);
  }
//+------------------------------------------------------------------+