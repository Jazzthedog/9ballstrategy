//+------------------------------------------------------------------+
//|                                     HeikenAshiCandles(MTFD)I.mq4 |
//|                                           Copyright 2016, Hombre |
//|                                         https://www.xandrafx.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Hombre"
#property link      "https://www.xandrafx.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

//#include <Hombre/Expiration.mqh>

//Expiration expiry("HeikenAshiCandles(MTFD)I");

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 clrMagenta
#property indicator_color2 clrAqua
#property indicator_color3 clrFireBrick
#property indicator_color4 clrDarkGreen

#property indicator_width1 7
#property indicator_width2 7
#property indicator_width3 7
#property indicator_width4 7

extern bool EnableAlert    = true;
extern bool SendNotifications = true;
extern bool EmailAlert     = false;
extern bool ShowCandles = true;
extern bool ShowOpenLineOnly = false;
extern int TimeFrameOnM1 = PERIOD_M15;
extern int TimeFrameOnM5 = PERIOD_M30;
extern int TimeFrameOnM15 = PERIOD_H1;
extern int TimeFrameOnM30 = PERIOD_H4;
extern int TimeFrameOnH1 = PERIOD_D1;
extern int TimeFrameOnH4 = PERIOD_W1;
extern int TimeFrameOnDaily = PERIOD_MN1;
extern int TimeFrameOnWeekly = PERIOD_MN1;
extern int TimeFrameOnMonthly = PERIOD_MN1;

int    TimeFrame=0;

double shortHigh[];
double longHigh[];
double haBodyOpen[];
double haBodyClose[];

double sellArrow[];
double buyArrow[];

int drawbegin;

int lastBuyAlert = 0;
int lastSellAlert = 0;
int lastAlert = 0; //-1 sell, 1 buy
bool afterInit;

int MaxCandles = 1000;
double globalAlerting = 1;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   //expiry.Init(WindowExpertName(), TimeCurrent());

   TimeFrame = -1;
   
   switch (Period())
   {
   case PERIOD_M1 : TimeFrame = TimeFrameOnM1; break;
   case PERIOD_M5 : TimeFrame = TimeFrameOnM5; break;
   case PERIOD_M15 : TimeFrame = TimeFrameOnM15; break;
   case PERIOD_M30 : TimeFrame = TimeFrameOnM30; break;
   case PERIOD_H1 : TimeFrame = TimeFrameOnH1; break;
   case PERIOD_H4 : TimeFrame = TimeFrameOnH4; break;
   case PERIOD_D1 : TimeFrame = TimeFrameOnDaily; break;
   case PERIOD_W1 : TimeFrame = TimeFrameOnWeekly; break;
   case PERIOD_MN1 : TimeFrame = TimeFrameOnMonthly; break;
   }

   IndicatorDigits(Digits);

   SetIndexBuffer(0, sellArrow);
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexLabel(0, "sellArrow");
   SetIndexArrow(0,238); 
   
   SetIndexBuffer(1, buyArrow);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexLabel(1, "buyArrow");
   SetIndexArrow(1,236); 

   if (!ShowOpenLineOnly)
   {
      //in this case higher value redraws lower 
      
      SetIndexLabel(2, "haBodyOpen");
      SetIndexBuffer(2, haBodyOpen);
      SetIndexStyle(2,DRAW_HISTOGRAM);

      SetIndexLabel(3, "haBodyClose");
      SetIndexBuffer(3, haBodyClose);
      SetIndexStyle(3,DRAW_HISTOGRAM);
   }else
   {
      //in this case we need switch it
      SetIndexLabel(2, "haBodyOpenDN");
      SetIndexBuffer(2, haBodyClose);
      SetIndexStyle(2,DRAW_LINE);

      SetIndexLabel(3, "haBodyOpenUP");
      SetIndexBuffer(3, haBodyOpen);
      SetIndexStyle(3,DRAW_LINE);
   }
   
      
   
   if (!ShowCandles)
   {
      SetIndexStyle(2,DRAW_NONE);
      SetIndexStyle(3,DRAW_NONE);
   }


   SetIndexEmptyValue(0,EMPTY_VALUE);
   SetIndexEmptyValue(1,EMPTY_VALUE);
   SetIndexEmptyValue(2,EMPTY_VALUE);
   SetIndexEmptyValue(3,EMPTY_VALUE);
   SetIndexEmptyValue(4,EMPTY_VALUE);
   SetIndexEmptyValue(5,EMPTY_VALUE);
   SetIndexEmptyValue(6,EMPTY_VALUE);
   SetIndexEmptyValue(7,EMPTY_VALUE);
   SetIndexEmptyValue(8,EMPTY_VALUE);
   SetIndexEmptyValue(9,EMPTY_VALUE);
   


   drawbegin = 10;
   
   SetIndexDrawBegin(0,drawbegin);
   SetIndexDrawBegin(1,drawbegin);
   SetIndexDrawBegin(2,drawbegin);
   SetIndexDrawBegin(3,drawbegin);

   IndicatorShortName("HeikenAshiCandles(MTFD)I("+Utils_TimeFrameToStr(TimeFrame)+")");

   lastBuyAlert = 0;
   lastSellAlert = 0;
   lastAlert = 0;
   afterInit = true;

   //setup max candles
   double maxcandles;
   if (!GlobalVariableGet("MaxCandles", maxcandles))
      maxcandles = 1000;
      
   MaxCandles = (int)maxcandles;
   
   //Print(MaxCandles);
   
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   //if (expiry.Expired()) return 0;
   if (TimeFrame == -1) return 0;
   if (prev_calculated == -1) return 0;
   
//   Print(iTime(NULL, TimeFrame,0));
//   Print(iBarShift(NULL,0,iTime(NULL, TimeFrame,0)));
   int limit = MathMin(rates_total-2,MathMax(MathMin(MaxCandles,rates_total - prev_calculated-1),iBarShift(NULL,0,iTime(NULL, TimeFrame,0))) );
   
   if (limit >MaxCandles)
   {
      //something is wrong cant be find proper time on higher timeframe for candle 0
      Print("need reload");
      ArrayInitialize(haBodyClose,EMPTY_VALUE);
      ArrayInitialize(haBodyClose,EMPTY_VALUE);
      ArrayInitialize(buyArrow,EMPTY_VALUE);
      ArrayInitialize(sellArrow,EMPTY_VALUE);
      return (0);
   }
   //Print(limit);
   for (int candle = limit; candle >=0; candle--)
   {
      buyArrow[candle] = EMPTY_VALUE;
      sellArrow[candle] = EMPTY_VALUE;

      haBodyOpen[candle] = EMPTY_VALUE;
      haBodyClose[candle] = EMPTY_VALUE;

      int candleTF = iBarShift(NULL,TimeFrame,Time[candle]);

      double haOpen  = iCustom(NULL,TimeFrame,"HeikenAshiCandlesI",2,candleTF);
      double haClose = iCustom(NULL,TimeFrame,"HeikenAshiCandlesI",3,candleTF);

      if (!ShowOpenLineOnly)
      {
         haBodyOpen[candle]  = haOpen;
         haBodyClose[candle] = haClose;
         //arrows
         if ((haBodyClose[candle] > haBodyOpen[candle]) && (haBodyClose[candle+1] < haBodyOpen[candle+1]))
            buyArrow[candle] = haBodyClose[candle+1]-2*(Ask-Bid);
         //sell arrow
         if ((haBodyClose[candle] < haBodyOpen[candle]) && (haBodyClose[candle+1] > haBodyOpen[candle+1]))
            sellArrow[candle] = haBodyClose[candle+1]+2*(Ask-Bid);

      }else
      {
      /*
         SetIndexLabel(2, "haBodyOpenDN");
         SetIndexBuffer(2, haBodyClose);
   
         SetIndexLabel(3, "haBodyOpenUP");
         SetIndexBuffer(3, haBodyOpen);
      */
         if (haOpen < haClose)
         {
            haBodyOpen[candle] = haOpen;
            if (haBodyOpen[candle+1] == EMPTY_VALUE) //fill gap
            {//trend changed to up
               haBodyClose[candle] = haBodyOpen[candle];
               buyArrow[candle] = haBodyOpen[candle]-(Ask-Bid);
            }
         }
         else
         {
            haBodyClose[candle] = haOpen;
            if (haBodyClose[candle+1] == EMPTY_VALUE) //fill gap
            {//trend changed to down
               haBodyOpen[candle] = haBodyClose[candle];
               sellArrow[candle] = haBodyClose[candle]+(Ask-Bid);
            }
         }
      }
      
      if ((haBodyOpen[candle] == EMPTY_VALUE && haBodyClose[candle] == EMPTY_VALUE) ||
          (haBodyOpen[candle] == 0 && haBodyClose[candle] == 0))
      {
         Print("need reload because of empty val");
         ArrayInitialize(haBodyClose,EMPTY_VALUE);
         ArrayInitialize(haBodyClose,EMPTY_VALUE);
         ArrayInitialize(buyArrow,EMPTY_VALUE);
         ArrayInitialize(sellArrow,EMPTY_VALUE);
         return (0);
      }
   //Print(haBodyOpen[candle]);
         
//      if (candle == 0)
//         continue;

      //buy arrow
   }   
   
   //check alerting
   if (!GlobalVariableGet("ALERTS", globalAlerting) && !GlobalVariableGet("alerts", globalAlerting))
      globalAlerting = 1;

   if (EnableAlert)
   {
      int arrowCandle = iBarShift(NULL, 0, iTime(NULL, TimeFrame, 0));
      
      bool alerted = false;
      
      if ((buyArrow[arrowCandle] != EMPTY_VALUE )&& (lastAlert != 1|| lastBuyAlert != Time[arrowCandle]))
      {
         DoAlert(TimeFrame, true, "HA("+Utils_TimeFrameToStr(TimeFrame)+")buy", arrowCandle);
         alerted  =true;
      }
         
      if ((sellArrow[arrowCandle] != EMPTY_VALUE) && (lastAlert != -1 || lastSellAlert != Time[arrowCandle]))
      {
         DoAlert(TimeFrame, false, "HA("+Utils_TimeFrameToStr(TimeFrame)+")sell", arrowCandle);
         alerted  =true;
      }
         
         
         
      if (afterInit && !alerted)
      {
         arrowCandle = iBarShift(NULL, 0, iTime(NULL, TimeFrame, 1));
//         Print("TimeFrame = "+TimeFrame+"   arrowCandle = "+arrowCandle);
         
         if ((buyArrow[arrowCandle] != EMPTY_VALUE )&& (lastAlert != 1|| lastBuyAlert != Time[arrowCandle]))
         {
            DoAlert(TimeFrame, true, "HA("+Utils_TimeFrameToStr(TimeFrame)+")buy", arrowCandle);
            alerted  =true;
         }
            
         if ((sellArrow[arrowCandle] != EMPTY_VALUE) && (lastAlert != -1 || lastSellAlert != Time[arrowCandle]))
         {
            DoAlert(TimeFrame, false, "HA("+Utils_TimeFrameToStr(TimeFrame)+")sell", arrowCandle);
            alerted  =true;
         }


         afterInit = false;
      }
   }      
      
   return(rates_total);
  }
//+------------------------------------------------------------------+
void DoAlert(int timeframe, bool up, string txt, int arrowCandle)
{
   
   string touchtxt = AccountCompany()+"["+DoubleToStr(AccountNumber(),0)+"]-"+Symbol()+"["+Utils_TimeFrameToStr(Period())+"]";
   string touchtxt1 = Symbol()+"["+Utils_TimeFrameToStr(Period())+"]";
   if (up)
   {
      touchtxt = touchtxt + "- "+txt;
      touchtxt1 = touchtxt1 + "- "+txt;
      lastBuyAlert = (int)Time[arrowCandle];
      lastSellAlert = 0;
      lastAlert=1;
   }else
   {
      touchtxt = touchtxt + "- "+txt;
      touchtxt1 = touchtxt1 + "- "+txt;
      lastSellAlert = (int)Time[arrowCandle];
      lastBuyAlert = 0;
      lastAlert=-1;
   }
      
   if (globalAlerting != 1)
      return;
      
   if (EnableAlert)
      Alert(touchtxt);
         
   if (EmailAlert)
      SendMail(touchtxt, touchtxt);
      
   if (SendNotifications)
         SendNotification(touchtxt1);
}

string Utils_TimeFrameToStr(int tf)
{
   switch (tf)
   {
   case PERIOD_M1  : return (" M1");
   case PERIOD_M5  : return (" M5");
   case PERIOD_M15 : return ("M15");
   case PERIOD_M30 : return ("M30");
   case PERIOD_H1  : return (" H1");
   case PERIOD_H4  : return (" H4");
   case PERIOD_D1  : return (" D1");
   case PERIOD_W1  : return (" W1");
   case PERIOD_MN1  : return ("MN1");
   }
  return ("");
}
