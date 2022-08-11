// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=72114

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2022, Gehtsoft USA LLC  |
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                              Support our efforts by donating   |
//|                                                                 Paypal: https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |
//+------------------------------------------------------------------------------------------------+

//Your donations will allow the service to continue onward.
//+------------------------------------------------------------------------------------------------+
//|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
//|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
//|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |
//|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
//|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |
//|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 |
//|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2022, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property strict

#property strict
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_width1 3
#property indicator_width2 3

extern color colorBulls = Blue;
extern color colorBears = Red;
extern int Distance = 20; //Distance from Hi/Lo
extern bool DrawLevel = true;
extern int MaxPrevLevel = 3;
extern int LevelExtendBar = 15;
extern color SupportColor = clrBlue;
extern int SupportWidth = 2;
extern ENUM_LINE_STYLE SupportStlye = 0;
extern color ResistanceColor = clrRed;
extern int ResistanceWidth = 2;
extern ENUM_LINE_STYLE ResistanceStlye = 0;

double BufferUP[];
double BufferLOW[];
int candle[];
string objPreFix = "eng";
//+------------------------------------------------------------------+
int init()
  {
   SetIndexStyle(0, DRAW_ARROW);
   SetIndexStyle(1, DRAW_ARROW);
   SetIndexArrow(0, 233);
   SetIndexArrow(1, 234);
   SetIndexBuffer(0, BufferUP);
   SetIndexBuffer(1, BufferLOW);
   SetIndexLabel(0, "UP");
   SetIndexLabel(1, "DOWN");
   SetIndexEmptyValue(0, 0.0);
   IndicatorShortName("Englufing");
   ObjectsDeleteAll(0, objPreFix, 0, OBJ_TREND);
   return(0);
  }
//+------------------------------------------------------------------+
int deinit()
  {
   ObjectsDeleteAll(0, objPreFix, 0, OBJ_TREND);
   return(0);
  }
//+------------------------------------------------------------------+
int start()
  {
   bool nb = IsNewBar();
   int    counted_bars = IndicatorCounted();
   int S;
   int Rcount = 0, Scount = 0;
   if(counted_bars > 0)
      counted_bars--;
   int limit = Bars - counted_bars;
   if(nb)
     {
      ObjectsDeleteAll(0, objPreFix, 0, OBJ_TREND);
      limit = Bars - 1;
     }
   for(int i = 0; i < limit - 1; i++)
     {
      S = Figura(i);
      switch(S)
        {
         case 1:
            BufferUP[i] = Low[i] - Distance * Point;
            if(DrawLevel && (MaxPrevLevel == 0 || (MaxPrevLevel > Scount && MaxPrevLevel > 0)))
              {
               LevelDraw(1, i);
               Scount++;
              }
            break;
         case -1:
            BufferLOW[i] = High[i] + Distance * Point;
            if(DrawLevel && (MaxPrevLevel == 0 || (MaxPrevLevel > Rcount && MaxPrevLevel > 0)))
              {
               LevelDraw(-1, i);
               Rcount++;
              }
            break;
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Figura(int bar)
  {
   if(High[bar + 1] < High[bar] && Low[bar + 1] > Close[bar] &&
      Open[bar + 1] < Close[bar + 1] && Open[bar] > Close[bar])
     {
      return(-1);
     }
   if(Low[bar + 1] > Low[bar] && High[bar + 1] < Close[bar] &&
      Open[bar + 1] > Close[bar + 1] && Open[bar] < Close[bar])
     {
      return(1);
     }
   return(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LevelDraw(int dir, int bar)
  {
   string cname = objPreFix + "_" + (string)dir + "_" + (string)bar;
   int end;
   if(LevelExtendBar == 0 || (LevelExtendBar > 0 && bar - LevelExtendBar < 0))
      end = 0;
   else
      end = bar - LevelExtendBar;
   ObjectCreate(0, cname, OBJ_TREND, 0, 0, 0);
   ObjectSetInteger(0, cname, OBJPROP_TIME, 0, iTime(Symbol(), Period(), bar));
   ObjectSetInteger(0, cname, OBJPROP_TIME, 1, iTime(Symbol(), Period(), end));
   ObjectSetInteger(0, cname, OBJPROP_RAY_RIGHT, 0);
   if(dir == 1)
     {
      ObjectSetDouble(0, cname, OBJPROP_PRICE, 0, Low[bar]);
      ObjectSetDouble(0, cname, OBJPROP_PRICE, 1, Low[bar]);
      ObjectSetInteger(0, cname, OBJPROP_COLOR, SupportColor);
      ObjectSetInteger(0, cname, OBJPROP_WIDTH, SupportWidth);
      ObjectSetInteger(0, cname, OBJPROP_STYLE, SupportStlye);
     }
   else
     {
      ObjectSetDouble(0, cname, OBJPROP_PRICE, 0, High[bar]);
      ObjectSetDouble(0, cname, OBJPROP_PRICE, 1, High[bar]);
      ObjectSetInteger(0, cname, OBJPROP_COLOR, ResistanceColor);
      ObjectSetInteger(0, cname, OBJPROP_WIDTH, ResistanceWidth);
      ObjectSetInteger(0, cname, OBJPROP_STYLE, ResistanceStlye);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsNewBar()
  {
   static datetime lastbar;
   datetime curbar = (datetime)SeriesInfoInteger(_Symbol, _Period, SERIES_LASTBAR_DATE);
   if(lastbar != curbar)
     {
      lastbar = curbar;
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
