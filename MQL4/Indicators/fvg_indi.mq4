//---- File Properties
#property copyright   "The Else Clause"
#property link        "http://theelseclause.com"
#property description "Fair Value Gaps (ICT)"
#property version     "1.0"
#property strict
//---- Indicator drawing and buffers
// #property indicator_chart_window
#property  indicator_separate_window
#property indicator_buffers 2
//---- Colors and sizes for buffers
#property indicator_color1 clrDodgerBlue
#property indicator_color2 clrTomato
#property indicator_width1 2
#property indicator_width2 2

extern string inp_ChartSymbol = NULL; // Chart Symbol
ENUM_TIMEFRAMES inp_ChartPeriod = PERIOD_CURRENT; // Chart Period 


//---- Buffer Arrays
double ExtMapBuffer1[];
double ExtMapBuffer2[];
//+------------------------------------------
//| Custom indicator initialization function 
//+------------------------------------------
int init()
{

  datetime starts = D'26.10.2021';
  datetime ends = D'27.12.2022';
  if (TimeCurrent() >= starts && TimeCurrent()< ends)
  {
      Print("FVG_INDI installed Correctly!");
  }
  else
  {
      Print("Error 4200 Duplicate Object found!");
      return(INIT_FAILED);
  }


//--- set maximum and minimum for subwindow 
   IndicatorSetDouble(INDICATOR_MINIMUM,0);
   //IndicatorSetDouble(INDICATOR_MAXIMUM,0.5);
   
    // First buffer
    SetIndexBuffer(0, ExtMapBuffer1);  // Assign buffer array
    SetIndexStyle(0, DRAW_HISTOGRAM);      // Style to arrow
    SetIndexArrow(0, 233);             // Arrow code
    
    //Second buffer
    SetIndexBuffer(1, ExtMapBuffer2);  // Assign buffer array          
    SetIndexStyle(1, DRAW_HISTOGRAM);      // Style to arrow
    SetIndexArrow(1, 234);             // Arrow code
    
    IndicatorSetString(INDICATOR_SHORTNAME,"FVG_indi-"+Symbol());    
    // Exit
    return(0);
}
  
//+-------------------------------------
//| Custom indicator iteration function 
//+------------------------------------
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
    // Start and limit
    int start = 1;
    int limit;
    
    // Bars counted so far
    int counted_bars = IndicatorCounted();
    // No more bars?
    if(counted_bars < 0) 
        return(-1);
    // Do not check repeated bars
    limit = Bars - 1 - counted_bars;
    
    
    //  todo: Use iHigh(), iLow() to be able to use another timeframe and different currency pair?
/*
   double  iHigh( 
   string           symbol,          // symbol 
   int              timeframe,       // timeframe 
   int              shift            // shift 
   );
   
Print("Current bar for USDCHF H1: ",iTime("USDCHF",PERIOD_H1,0),", ",  iOpen("USDCHF",PERIOD_H1,0),", ", 
                                      iHigh("USDCHF",PERIOD_H1,0),", ",  iLow("USDCHF",PERIOD_H1,0),", ", 
                                      iClose("USDCHF",PERIOD_H1,0),", ", iVolume("USDCHF",PERIOD_H1,0));   
   
*/
    // Iterate bars from past to present
    for(int i = limit; i >= start; i--)
    {
      // If not enough data...
      if(i > Bars-3) continue;
      
      // Check bullish FVG
      if (iLow(inp_ChartSymbol, inp_ChartPeriod, i) > iHigh(inp_ChartSymbol, inp_ChartPeriod, i+2) )
      {
         ExtMapBuffer1[i+1] = iLow(inp_ChartSymbol, inp_ChartPeriod, i) - iHigh(inp_ChartSymbol, inp_ChartPeriod, i+2) ;
      }
      
      // Check bearish FVG
      //if(High[i] < Low[i+2])
      if (iHigh(inp_ChartSymbol, inp_ChartPeriod, i) < iLow(inp_ChartSymbol, inp_ChartPeriod, i+2))
      {
         ExtMapBuffer2[i+1] = -(iHigh(inp_ChartSymbol, inp_ChartPeriod, i) - iLow(inp_ChartSymbol, inp_ChartPeriod, i+2));
      }
    }
    
    // Exit
    return(rates_total);
}