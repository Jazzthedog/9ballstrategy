//+---------------------------------------------------------------------+
//|                                       P4L Check_Price_Discounts.mq4 |
//|                                                           Pips4Life |
//|                                  https://forexfactory.com/pips4life |
//| Compare Order Bid/Ask vs. Chart Bid/Ask prices for broker "discount"|
//+---------------------------------------------------------------------+

// This is a *Script*, not an Indicator!  It goes under:
//   In MT4, first run File->Open Data Folder
//   Then navigate into MQL4/ then Scripts/
//   Put it under Scripts/.   
//   Refresh your MT4 Navigator window, which should compile it and make it availble.  (Else, manually compile it).

#property copyright "Pips4Life"
#property link      "https://forexfactory.com/pips4life"
#property version   "1.00"
#property strict
#property show_inputs // If you just want it to run on the current chart without asking anything, simply comment out this line and re-Compile.

extern string symbol = "current"; //Symbol (Case-sens, incl. suffix/prefix)

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//--- 
    if(symbol=="" || symbol=="current") symbol=Symbol();
    int period = Period();
    if(symbol != Symbol()) period = MathMax(period,PERIOD_M15); //Limit, because missing bars (common on M1/M5) cause iTime-comparison failures when comparing this vs. other chart
    
    string tfs = StringSubstr(EnumToString((ENUM_TIMEFRAMES)period),7); // e.g. MN1,W1,D1,H4,H1,M30,...
    string chartStr = StringConcatenate(symbol,",",tfs," ");
    
    if( MQLInfoInteger(MQL_TRADE_ALLOWED) == 0) Alert(chartStr," NOTE: MQL program is unable-to-trade (offline,weekend,rollover,?). Bid/Ask/spread prices may be unavailable-or-EXTREME values. Run again when market is open.");
    
    double point = MarketInfo(symbol,MODE_POINT);
    if(point == 0.0) 
    {
       Alert("Error.  No MODE_POINT value. Illegal choice for symbol(?): ",symbol," (Check case, spelling, and missing prefix/suffix(if any) )" );
       return;
    }
    
    int digits = (int) MarketInfo(symbol,MODE_DIGITS); 
    double myPoint = point * MathPow(10,digits%2); // Scale for true pips (for Fx), never pipettes
    int pipdigits = 2; // 1 is ok for FX, but using 2 works better for S&P500, commodities, etc.
        
    double ChartBid = iClose(symbol,period,0);
    if( iTime(NULL,period,0) != iTime(symbol,period,0) )
    {
       Sleep(3000); //ms.  Wait a few seconds for requested data to update.  A hack, but mostly seems to work for me/my broker and connection.
       ChartBid = iClose(symbol,period,0);
       if( iTime(NULL,period,0) != iTime(symbol,period,0) )
       {
          Alert(chartStr,"Error: Out-of-date current bar on chart: ",chartStr,"  (or chart ",Symbol(),",",tfs,")  Update these charts first, or run directly on: ",symbol,",(any_timeframe, >=M15 preferred)");
          return;
       }
    }
    double OrderBid = MarketInfo(symbol,MODE_BID); // Same as "Bid" on the same symbol chart
    // Note: For ChartBid based on iClose, if not the current chart, the data must be refreshed to a current bar on the symbol,period chart. (How best?) 
    double BidDiscount = (OrderBid-ChartBid)/myPoint;
    
    double OrderAsk = MarketInfo(symbol,MODE_ASK); // Same as "Ask" on the same symbol chart
    //NO. double ChartAsk = SymbolInfoDouble(symbol,SYMBOL_ASK );//NO. No difference from OrderAsk. I don't how to get the true "Ask" line position on a *chart*.
    //double AskDiscount = (ChartAsk-OrderAsk)/myPoint; // Enable if ChartAsk works.
    double AskDiscount = BidDiscount; // Assuming same as BidDiscount until there is a true method for ChartAsk.
    
    double OrderSpread = (OrderAsk - OrderBid)/myPoint;
    double ChartSpread = (OrderSpread+BidDiscount+AskDiscount);
    
    double mt4Spread = (point/myPoint) * SymbolInfoInteger(symbol,SYMBOL_SPREAD); // This should be same as OrderSpread.
    
    //Alert(chartStr," ChartAsk=",d2sN(ChartAsk,digits),"  vs. OrderAsk=",d2sN(OrderAsk,digits),"    Brokers AskDiscount=",d2sN(AskDiscount, pipdigits)," pips");
    Alert(chartStr," ChartBid=",d2sN(ChartBid,digits),"  vs. OrderBid=",d2sN(OrderBid,digits),"    Brokers BidDiscount=",d2sN(BidDiscount, pipdigits)," pips");
    Alert(chartStr," ChartSpread (Bid/Ask_lines) (Assumes BidDiscount=AskDiscount) = ",d2sN(ChartSpread, pipdigits)," OrderSpread (true spread)= ",d2sN(OrderSpread, pipdigits)," pips" );
    if(BidDiscount==0.0 && AskDiscount==0.0) Alert(chartStr," Lucky(Unlucky?) you. Your broker has 0 'discount', meaning chart and order prices are the same. (Less confusing than some brokers)");
    
    if( MathAbs( OrderSpread - mt4Spread) > 0.00001) Alert(chartStr," Error??  Strange discrepancy in OrderSpread(",d2sN(OrderSpread, pipdigits),") vs. mt4Spread(",mt4Spread,")" );
    
  }
//+------------------------------------------------------------------+

// The d2sN Function is most useful when the desired choice is "1" vs. the DoubleToStr(dVar,8)
string d2sN(double dVar, int iDig=1) { return(DoubleToStr(dVar,iDig)); } 
