//+------------------------------------------------------------------+
//|                                               output_history.mq4 |
//|                      Copyright © 2008, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
  out_hist("GBPUSD",PERIOD_D1);  // This will produce daily history for GBPUSD
// Copy the above line of code for each currency pair and timeframe, and then press F5 to recompile (or restart MT4)
// First parameter must be a valid currency pair, e.g. GBPUSD, enclosed in double quotes
// Second parameter must be valid timeframe, i.e. one of PERIOD_M1, PERIOD_M5, PERIOD_M15, PERIOD_M30, PERIOD_H1, PERIOD_H4, PERIOD_D1, PERIOD_W1, PERIOD_MN1
// To use the currently displayed chart: out_hist(Symbol(),Period());

  return(0);
  }

//+------------------------------------------------------------------+
//| Main history output engine                                       |
//+------------------------------------------------------------------+
int out_hist(string ccy, int tf)
{
  string fname = ccy + "," + tf + ".csv";                         // Same folder (...\experts\files) for each timeframe
//string fname = "TF-" + tf + "\\" + ccy + "," + tf + ".csv";     // Different subfolder for each timeframe
  int handle = FileOpen(fname, FILE_CSV|FILE_WRITE, ",");         // "," means that output data will be separated by commas; change if necessary
  if(handle>0)
    {
     FileWrite(handle,"Date,Time,Open,High,Low,Close,Volume");    // This writes the Header record to the file (change or remove to suit)
//   for(int i=0; i<iBars(ccy,tf); i++)                           // Use descending date sequence
     for(int i=iBars(ccy,tf)-1; i>=0; i--)                        // Use ascending date sequence
       {
       string date1 = TimeToStr(iTime(ccy,tf,i),TIME_DATE);
       date1 = StringSubstr(date1,5,2) + "-" + StringSubstr(date1,8,2) + "-" + StringSubstr(date1,0,4);
// NOTE: StringSubstr(date1,5,2) is the MONTH
//       StringSubstr(date1,8,2) is the DAY
//       StringSubstr(date1,0,4) is the YEAR (4 digits)
//       "-" means the separator will be a hyphen
//       So if, for example, you want to change the output date format to DD/MM/YYYY, change the above line of code to:
//     date1 = StringSubstr(date1,8,2) + "/" + StringSubstr(date1,5,2) + "/" + StringSubstr(date1,0,4);

       string time1 = TimeToStr(iTime(ccy,tf,i),TIME_MINUTES);
       FileWrite(handle, date1, time1, iOpen(ccy,tf,i), iHigh(ccy,tf,i), iLow(ccy,tf,i), iClose(ccy,tf,i), iVolume(ccy,tf,i)); 
// The above line writes the data to the file in the order: date, time, open, low, high, close, volume. Change the order to suit, if necessary
// Or you can add indicator based outputs, e.g. iMA(); iRSI(); iMACD(); etc
// Examples:  iMACD(ccy,tf,12,26,9,PRICE_CLOSE,MODE_MAIN,i)
//            iADX(ccy,tf,14,PRICE_CLOSE,MODE_MAIN,i)
       }
     FileClose(handle);
     Comment("History output complete");     // Display a comment in the upper left corner of the chart to advise that process is complete
    }
   return(0);
  }
  
//+------------------------------------------------------------------+