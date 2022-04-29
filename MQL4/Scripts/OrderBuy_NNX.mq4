//+------------------------------------------------------------------+
//|                                                 OrderBuy_NNX.mq4 |
//|                                     Copyright 2020, TheElseClause|
//|                                        https://theelseclause.com |
//| This code uses the pos_size indicator functionality to create 1  |
//| Order for a SELL. This was done to quickly have a script which   |
//| Just drag to the chart and it would just create the correct order|
//| with TP and SL according to the NNFX rules using the ATR / Risk  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, TheElseClause"
#property link      "https://theelseclause.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+

int               InpATRperiod=14;         // ATR Periods
float             InpRisk=1;               // Risk Size %
float             InpSLfactor=1.5;         // Stop Loss as a factor of ATR was 1.5
float             InpTPfactor=1.0;         // Take Profit as a factor of ATR
//int               InpFontSize=9;          // Font size
//color             InpColor=clrMagenta;     // Color
//int               InpBaseCorner=CORNER_RIGHT_UPPER;         // Base Corner 0=UL,1=UR,2=LL,3=LR
float             InpFixedATR=0;           // Fixed ATR points
//bool              InpBack=false;           // Background object
//bool              InpSelection=false;      // Highlight to move
//bool              InpHidden=true;          // Hidden in the object list
//long              InpZOrder=0;             // Priority for mouse click

string AccntC=AccountCurrency();                   //Currency of Acount eg USD,GBP,EUR
string CounterC=StringSubstr(Symbol(),3,3);        //The Count Currency eg GBPUSD is USD
string ExC=AccntC+CounterC; 

string     FileName="Screen";
string     ChartType="Candle";

int  chartType=1;

void OnStart()
  {
//---
   chartType = -1;
   if (ChartType == "Bar") chartType = 0;
   else if (ChartType == "Candle") chartType = 1;
   else if (ChartType == "Line") chartType = 2;
   else Print (" Invalid Chart Type, must be Bar, Candle or Line. ", ChartType);
//---
   RefreshRates();
   
   double ExCRate=1;                                            //Assume Account is same as counter so ExCRate=1
   AccntC=AccountCurrency();                                      //Currency of Acount eg USD,GBP,EUR
   CounterC=StringSubstr(Symbol(),3,3);                           //The Count Currency eg GBPUSD is USD
   ExC=AccntC+CounterC;                                           //Create the Pair for account eg USDGBP
   if(AccntC!=CounterC)
      ExCRate= MarketInfo(ExC,MODE_ASK);                          //Get the correct FX rate for the Account to Counter conversion
   if(ExCRate ==0) ExCRate=1.0;
   double ATRPoints=iATR(NULL,0,InpATRperiod,0);                  //Get the ATR in points to calc SL and TP
   if(InpFixedATR!=0)
      ATRPoints=InpFixedATR;                                      //Override ATR for times when you have had a Flash crash
   double riskVAccntC=AccountEquity()*(InpRisk/100);
   double riskvalue=(ExCRate/1)*riskVAccntC;                      //Risk in Account Currency
   double slpoints=(ATRPoints*InpSLfactor);                      //Risk in Counter Currency
   double riskperpoint=(riskvalue/slpoints)*Point;
   double lotSize=riskperpoint;                                  //Risk in currency per point
   
   int pipMult=10000;
   if(CounterC=="JPY") {
      lotSize=riskperpoint/100;
      pipMult=100;
   }
   double ATRpips=MathCeil(pipMult*ATRPoints);

//calculate time left this period
   int thisbarminutes=Period();
   double thisbarseconds=thisbarminutes*60;
   double seconds=thisbarseconds -(TimeCurrent()-Time[0]); // seconds left in bar 

   double minutes= MathFloor(seconds/60);
   double hours  = MathFloor(seconds/3600);

   minutes = minutes -  hours*60;
   seconds = seconds - minutes*60 - hours*3600;

/*
   string sText=DoubleToStr(seconds,0);
   if(StringLen(sText)<2) sText="0"+sText;
   string mText=DoubleToStr(minutes,0);
   if(StringLen(mText)<2) mText="0"+mText;
   string hText=DoubleToStr(hours,0);
   if(StringLen(hText)<2) hText="0"+hText;

   if(Period()<240) ObjectSetString(ChartID(),"texttimeleft",OBJPROP_TEXT,"Time Left:"+mText+":"+sText);
   else ObjectSetString(ChartID(),"texttimeleft",OBJPROP_TEXT,"Time Left:"+hText+":"+mText+":"+sText);


   if(InpFixedATR!=0)ObjectSetString(ChartID(),"textATR",OBJPROP_TEXT,StringFormat("*FIXED*ATR(%.0f):%.0f %s", InpATRperiod,ATRpips,"pips"));
   else ObjectSetString(ChartID(),"textATR",OBJPROP_TEXT,StringFormat("ATR(%.0f):%.0f %s", InpATRperiod,ATRpips,"pips"));
   ObjectSetString(ChartID(),"textBAL",OBJPROP_TEXT,StringFormat("Equity:%.2f%s",AccountEquity(),AccntC));
   ObjectSetString(ChartID(),"textRISK",OBJPROP_TEXT,StringFormat("Risk %.1f%%:%.0f %s",InpRisk,riskVAccntC,AccntC));
   if (CounterC=="JPY") ObjectSetString(ChartID(),"textBuySL",OBJPROP_TEXT,StringFormat("Buy SL:%.2f",Ask-(ATRPoints*InpSLfactor)));
   else ObjectSetString(ChartID(),"textBuySL",OBJPROP_TEXT,StringFormat("Buy SL:%.4f",Ask-(ATRPoints*InpSLfactor)));
   if (CounterC=="JPY") ObjectSetString(ChartID(),"textBuyTP",OBJPROP_TEXT,StringFormat("Buy TP:%.2f",Ask+(ATRPoints*InpTPfactor)));
   else ObjectSetString(ChartID(),"textBuyTP",OBJPROP_TEXT,StringFormat("Buy TP:%.4f",Ask+(ATRPoints*InpTPfactor)));
   if (CounterC=="JPY") ObjectSetString(ChartID(),"textSellSL",OBJPROP_TEXT,StringFormat("Sell SL:%.2f",Ask+(ATRPoints*InpSLfactor)));
   else ObjectSetString(ChartID(),"textSellSL",OBJPROP_TEXT,StringFormat("Sell SL:%.4f",Ask+(ATRPoints*InpSLfactor)));
   if (CounterC=="JPY") ObjectSetString(ChartID(),"textSellTP",OBJPROP_TEXT,StringFormat("Sell TP:%.2f",Ask-(ATRPoints*InpTPfactor)));
   else ObjectSetString(ChartID(),"textSellTP",OBJPROP_TEXT,StringFormat("Sell TP:%.4f",Ask-(ATRPoints*InpTPfactor)));
   ObjectSetString(ChartID(),"textlotsize",OBJPROP_TEXT,StringFormat("Volume:%.2f",lotSize));

*/
  color sArrow;
  int ticket1, iSlipage,iSLPips,iTPPips;
  //double dStopLoss, dTakeProfit;
  
  iSLPips=100;        //Stop Loss in Pips
  iTPPips=150;        //Take Profit in Pips
  
  iSlipage=3;
  string sText="OrderBuy_NNX";
  sArrow=CLR_NONE;   //Order Arrow Color
  
  //dStopLoss=Bid-NormalizeDouble(iSLPips*Point,MarketInfo(Symbol(),MODE_DIGITS));
  //dTakeProfit=Ask + NormalizeDouble(iTPPips*Point,MarketInfo(Symbol(),MODE_DIGITS));  
  ticket1=OrderSend(Symbol(), OP_BUY, lotSize, Ask, iSlipage, Ask-(ATRPoints*InpSLfactor), Ask+(ATRPoints*InpTPfactor), sText, 192, 0, sArrow);
  if(ticket1<0)
  {
     Alert("OrderBuy_NNX ticket 1 returned the error of: ", GetErrorDescription(GetLastError()));
     Print("OrderBuy_NNX ticket 1 returned the error of: ", GetErrorDescription(GetLastError()));
  }
  else
  {
   PlaySound ("ok.wav");
  }   

   // screenshot of order
   string timeStamp = TimeToStr(TimeCurrent(), TIME_DATE|TIME_MINUTES);
   string newstr = StringSetChar(timeStamp, 13, '_');
   //WindowScreenShot(FileName + "_" + Symbol() + "_" + Period() + "_" + newstr + ".gif", 640, 480, -1, -1, chartType);
   WindowScreenShot(FileName + "_BUY_" + Symbol() + "_" + IntegerToString(Period()) + "_" + newstr + ".gif", 800, 800, -1, -1, chartType);
   Print("Screenshot created at ", FileName + "_" + Symbol() + "_" + IntegerToString(Period()) + "_" + newstr + ".gif");
   PlaySound ("ok.wav"); 
}
//+------------------------------------------------------------------+

//+-----------------------------------------------------------------------------------------------------------------+
//| Error description function                                                                                      |
//+-----------------------------------------------------------------------------------------------------------------+
string GetErrorDescription(int ErrorCode)
  {
   //--- Local variable
   string ErrorMsg;
   switch(ErrorCode)
     {
      //--- Codes returned from trade server
      case 0:    ErrorMsg="No error returned.";                                             break;
      case 1:    ErrorMsg="No error returned, but the result is unknown.";                  break;
      case 2:    ErrorMsg="Common error.";                                                  break;
      case 3:    ErrorMsg="Invalid trade parameters.";                                      break;
      case 4:    ErrorMsg="Trade server is busy.";                                          break;
      case 5:    ErrorMsg="Old version of the client terminal.";                            break;
      case 6:    ErrorMsg="No connection with trade server.";                               break;
      case 7:    ErrorMsg="Not enough rights.";                                             break;
      case 8:    ErrorMsg="Too frequent requests.";                                         break;
      case 9:    ErrorMsg="Malfunctional trade operation.";                                 break;
      case 64:   ErrorMsg="Account disabled.";                                              break;
      case 65:   ErrorMsg="Invalid account.";                                               break;
      case 128:  ErrorMsg="Trade timeout.";                                                 break;
      case 129:  ErrorMsg="Invalid price.";                                                 break;
      case 130:  ErrorMsg="Invalid stops.";                                                 break;
      case 131:  ErrorMsg="Invalid trade volume.";                                          break;
      case 132:  ErrorMsg="Market is closed.";                                              break;
      case 133:  ErrorMsg="Trade is disabled.";                                             break;
      case 134:  ErrorMsg="Not enough money.";                                              break;
      case 135:  ErrorMsg="Price changed.";                                                 break;
      case 136:  ErrorMsg="Off quotes.";                                                    break;
      case 137:  ErrorMsg="Broker is busy.";                                                break;
      case 138:  ErrorMsg="Requote.";                                                       break;
      case 139:  ErrorMsg="Order is locked.";                                               break;
      case 140:  ErrorMsg="Buy orders only allowed.";                                       break;
      case 141:  ErrorMsg="Too many requests.";                                             break;
      case 145:  ErrorMsg="Modification denied because order is too close to market.";      break;
      case 146:  ErrorMsg="Trade context is busy.";                                         break;
      case 147:  ErrorMsg="Expirations are denied by broker.";                              break;
      case 148:  ErrorMsg="The amount of open and pending orders has reached the limit.";   break;
      case 149:  ErrorMsg="An attempt to open an order opposite when hedging is disabled."; break;
      case 150:  ErrorMsg="An attempt to close an order contravening the FIFO rule.";       break;
      //--- Mql4 errors
      case 4000: ErrorMsg="No error returned.";                                             break;
      case 4001: ErrorMsg="Wrong function pointer.";                                        break;
      case 4002: ErrorMsg="Array index is out of range.";                                   break;
      case 4003: ErrorMsg="No memory for function call stack.";                             break;
      case 4004: ErrorMsg="Recursive stack overflow.";                                      break;
      case 4005: ErrorMsg="Not enough stack for parameter.";                                break;
      case 4006: ErrorMsg="No memory for parameter string.";                                break;
      case 4007: ErrorMsg="No memory for temp string.";                                     break;
      case 4008: ErrorMsg="Not initialized string.";                                        break;
      case 4009: ErrorMsg="Not initialized string in array.";                               break;
      case 4010: ErrorMsg="No memory for array string.";                                    break;
      case 4011: ErrorMsg="Too long string.";                                               break;
      case 4012: ErrorMsg="Remainder from zero divide.";                                    break;
      case 4013: ErrorMsg="Zero divide.";                                                   break;
      case 4014: ErrorMsg="Unknown command.";                                               break;
      case 4015: ErrorMsg="Wrong jump (never generated error).";                            break;
      case 4016: ErrorMsg="Not initialized array.";                                         break;
      case 4017: ErrorMsg="Dll calls are not allowed.";                                     break;
      case 4018: ErrorMsg="Cannot load library.";                                           break;
      case 4019: ErrorMsg="Cannot call function.";                                          break;
      case 4020: ErrorMsg="Expert function calls are not allowed.";                         break;
      case 4021: ErrorMsg="Not enough memory for temp string returned from function.";      break;
      case 4022: ErrorMsg="System is busy (never generated error).";                        break;
      case 4023: ErrorMsg="Dll-function call critical error.";                              break;
      case 4024: ErrorMsg="Internal error.";                                                break;
      case 4025: ErrorMsg="Out of memory.";                                                 break;
      case 4026: ErrorMsg="Invalid pointer.";                                               break;
      case 4027: ErrorMsg="Too many formatters in the format function.";                    break;
      case 4028: ErrorMsg="Parameters count exceeds formatters count.";                     break;
      case 4029: ErrorMsg="Invalid array.";                                                 break;
      case 4030: ErrorMsg="No reply from chart.";                                           break;
      case 4050: ErrorMsg="Invalid function parameters count.";                             break;
      case 4051: ErrorMsg="Invalid function parameter value.";                              break;
      case 4052: ErrorMsg="String function internal error.";                                break;
      case 4053: ErrorMsg="Some array error.";                                              break;
      case 4054: ErrorMsg="Incorrect series array using.";                                  break;
      case 4055: ErrorMsg="Custom indicator error.";                                        break;
      case 4056: ErrorMsg="Arrays are incompatible.";                                       break;
      case 4057: ErrorMsg="Global variables processing error.";                             break;
      case 4058: ErrorMsg="Global variable not found.";                                     break;
      case 4059: ErrorMsg="Function is not allowed in testing mode.";                       break;
      case 4060: ErrorMsg="Function is not allowed for call.";                              break;
      case 4061: ErrorMsg="Send mail error.";                                               break;
      case 4062: ErrorMsg="String parameter expected.";                                     break;
      case 4063: ErrorMsg="Integer parameter expected.";                                    break;
      case 4064: ErrorMsg="Double parameter expected.";                                     break;
      case 4065: ErrorMsg="Array as parameter expected.";                                   break;
      case 4066: ErrorMsg="Requested history data is in updating state.";                   break;
      case 4067: ErrorMsg="Internal trade error.";                                          break;
      case 4068: ErrorMsg="Resource not found.";                                            break;
      case 4069: ErrorMsg="Resource not supported.";                                        break;
      case 4070: ErrorMsg="Duplicate resource.";                                            break;
      case 4071: ErrorMsg="Custom indicator cannot initialize.";                            break;
      case 4072: ErrorMsg="Cannot load custom indicator.";                                  break;
      case 4073: ErrorMsg="No history data.";                                               break;
      case 4074: ErrorMsg="No memory for history data.";                                    break;
      case 4075: ErrorMsg="Not enough memory for indicator calculation.";                   break;
      case 4099: ErrorMsg="End of file.";                                                   break;
      case 4100: ErrorMsg="Some file error.";                                               break;
      case 4101: ErrorMsg="Wrong file name.";                                               break;
      case 4102: ErrorMsg="Too many opened files.";                                         break;
      case 4103: ErrorMsg="Cannot open file.";                                              break;
      case 4104: ErrorMsg="Incompatible access to a file.";                                 break;
      case 4105: ErrorMsg="No order selected.";                                             break;
      case 4106: ErrorMsg="Unknown symbol.";                                                break;
      case 4107: ErrorMsg="Invalid price.";                                                 break;
      case 4108: ErrorMsg="Invalid ticket.";                                                break;
      case 4109: ErrorMsg="Trade is not allowed in the Expert Advisor properties.";         break;
      case 4110: ErrorMsg="Longs are not allowed in the Expert Advisor properties.";        break;
      case 4111: ErrorMsg="Shorts are not allowed in the Expert Advisor properties.";       break;
      case 4112: ErrorMsg="Automated trading disabled by trade server.";                    break;
      case 4200: ErrorMsg="Object already exists.";                                         break;
      case 4201: ErrorMsg="Unknown object property.";                                       break;
      case 4202: ErrorMsg="Object does not exist.";                                         break;
      case 4203: ErrorMsg="Unknown object type.";                                           break;
      case 4204: ErrorMsg="No object name.";                                                break;
      case 4205: ErrorMsg="Object coordinates error.";                                      break;
      case 4206: ErrorMsg="No specified subwindow.";                                        break;
      case 4207: ErrorMsg="Graphical object error.";                                        break;
      case 4210: ErrorMsg="Unknown chart property.";                                        break;
      case 4211: ErrorMsg="Chart not found.";                                               break;
      case 4212: ErrorMsg="Chart subwindow not found.";                                     break;
      case 4213: ErrorMsg="Chart indicator not found.";                                     break;
      case 4220: ErrorMsg="Symbol select error.";                                           break;
      case 4250: ErrorMsg="Notification error.";                                            break;
      case 4251: ErrorMsg="Notification parameter error.";                                  break;
      case 4252: ErrorMsg="Notifications disabled.";                                        break;
      case 4253: ErrorMsg="Notification send too frequent.";                                break;
      case 4260: ErrorMsg="FTP server is not specified.";                                   break;
      case 4261: ErrorMsg="FTP login is not specified.";                                    break;
      case 4262: ErrorMsg="FTP connection failed.";                                         break;
      case 4263: ErrorMsg="FTP connection closed.";                                         break;
      case 4264: ErrorMsg="FTP path not found on server.";                                  break;
      case 4265: ErrorMsg="File not found in the Files directory to send on FTP server.";   break;
      case 4266: ErrorMsg="Common error during FTP data transmission.";                     break;
      case 5001: ErrorMsg="Too many opened files.";                                         break;
      case 5002: ErrorMsg="Wrong file name.";                                               break;
      case 5003: ErrorMsg="Too long file name.";                                            break;
      case 5004: ErrorMsg="Cannot open file.";                                              break;
      case 5005: ErrorMsg="Text file buffer allocation error.";                             break;
      case 5006: ErrorMsg="Cannot delete file.";                                            break;
      case 5007: ErrorMsg="Invalid file handle (file closed or was not opened).";           break;
      case 5008: ErrorMsg="Wrong file handle (handle index is out of handle table).";       break;
      case 5009: ErrorMsg="File must be opened with FILE_WRITE flag.";                      break;
      case 5010: ErrorMsg="File must be opened with FILE_READ flag.";                       break;
      case 5011: ErrorMsg="File must be opened with FILE_BIN flag.";                        break;
      case 5012: ErrorMsg="File must be opened with FILE_TXT flag.";                        break;
      case 5013: ErrorMsg="File must be opened with FILE_TXT or FILE_CSV flag.";            break;
      case 5014: ErrorMsg="File must be opened with FILE_CSV flag.";                        break;
      case 5015: ErrorMsg="File read error.";                                               break;
      case 5016: ErrorMsg="File write error.";                                              break;
      case 5017: ErrorMsg="String size must be specified for binary file.";                 break;
      case 5018: ErrorMsg="Incompatible file (for string arrays-TXT, for others-BIN).";     break;
      case 5019: ErrorMsg="File is directory, not file.";                                   break;
      case 5020: ErrorMsg="File does not exist.";                                           break;
      case 5021: ErrorMsg="File cannot be rewritten.";                                      break;
      case 5022: ErrorMsg="Wrong directory name.";                                          break;
      case 5023: ErrorMsg="Directory does not exist.";                                      break;
      case 5024: ErrorMsg="Specified file is not directory.";                               break;
      case 5025: ErrorMsg="Cannot delete directory.";                                       break;
      case 5026: ErrorMsg="Cannot clean directory.";                                        break;
      case 5027: ErrorMsg="Array resize error.";                                            break;
      case 5028: ErrorMsg="String resize error.";                                           break;
      case 5029: ErrorMsg="Structure contains strings or dynamic arrays.";                  break;
      case 5200: ErrorMsg="Invalid URL.";                                                   break;
      case 5201: ErrorMsg="Failed to connect to specified URL.";                            break;
      case 5202: ErrorMsg="Timeout exceeded.";                                              break;
      case 5203: ErrorMsg="HTTP request failed.";                                           break;
      default:   ErrorMsg="Unknown error.";
     }
   return(ErrorMsg);
  } 