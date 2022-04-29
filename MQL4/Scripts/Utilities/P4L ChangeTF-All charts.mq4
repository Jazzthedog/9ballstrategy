//+------------------------------------------------------------------+
//|                                      P4L ChangeTF-All charts.mq4 |
//|  Modified and improved upon earlier version.                     |
//+------------------------------------------------------------------+

/* 
INSTRUCTIONS:  This is a *script*, not an indicator.  In MT4, do:
   File -> Open Data Folder
   Navigate into MQL4 -> Scripts and copy it there. (NOT in Indicators!)
   In MT4 Navigator, RMB then "Refresh".  Or open in MetaEditor and "Compile" it.

Usage (v2):   
   Use Navigator to find it under "Scripts".
   Optional: Right-click over the script and "Set hotkey" if desired.
   When used, "Allow DLL Imports" *must* be enabled, else fails with Error: "DLL is not allowed"
   To always enable DLL's by default, Tools->Options->Expert Advisors->check_"Allow DLL imports"
   BEST use model is to change any chart to the desired timeframe, then
      drop this script onto that chart, and "Ok" it as-is.  All OTHER charts
      will be changed to match the current chart timeframe. (Caution!! Changes *ALL* charts!)
   Or... change the Inputs "newTF" value before doing the "Ok".
   

2017-Apr-8  v2  Mods by pips4life.   
   New/improved use model: Change other charts to match the current chart you drop the script onto.
   Default "newTF" (string) value is the "Current" timeframe, OR, enter #minutes or any standard timeframe name.
   Compiled with MT4 b1065 (>=b600+, New MT4 with MT5 features).
   
2010: Original, "ChangeTF-All.mq4", Copyright © 2010, zznbrm -- MAIN CREDIT BELONGS TO THIS AUTHOR!
   Also called by many names including "Change Time Frame All.mq4", "ChgTFAll.mq4", "Change TF All charts.mq4"

FUTURE_MODIFICATIONS(?):
   Consider using the new MT4 function:  ChartSetSymbolPeriod instead of the current PostMessageA method.
      (So long as this current method works, not much reason to change it, unless all user32.dll calls can be replaced).
   Q: Is this compatible for sessions with Offline charts?  Typically those cannot change TF and should be skipped.
      If not compatible, look for a fix.  A: So far, it seems to ignore (leave alone) Offline charts, which is good.

*/

#property copyright "Copyright © 2017 v2 mods by pips4life. Original: 2010, zznbrm"
#property show_inputs

#import "user32.dll"
   int      PostMessageA(int hWnd,int Msg,int wParam,int lParam);
   int      GetWindow(int hWnd,int uCmd);
   int      GetParent(int hWnd);
#import

#define GW_HWNDFIRST 0
#define GW_HWNDNEXT  2
#define WM_COMMAND   0x0111

extern string INFO__TF_choice = "Current=All_match_this_chart, or: 1 5 15 30 H1 H4 Daily Weekly Monthly"; // Ex: 60 M60 or H1 all work the same.
extern string newTF           = "Current"; //Current, or 0, is change all charts to match current-chart TF.
                   
int start()
{      
   int eintTF = stringToTimeFrame(newTF);
   bool blnContinue = true;   
   int intParent = GetParent( WindowHandle( Symbol(), Period() ) );   
   int intChild = GetWindow( intParent, GW_HWNDFIRST );  
   int intCmd; 
   
   if( eintTF==0) eintTF = Period();
   
   switch( eintTF )
   {
      case PERIOD_M1:   intCmd = 33137;  break;
      case PERIOD_M5:   intCmd = 33138;  break;
      case PERIOD_M15:  intCmd = 33139;  break;
      case PERIOD_M30:  intCmd = 33140;  break;
      case PERIOD_H1:   intCmd = 35400;  break;
      case PERIOD_H4:   intCmd = 33136;  break;
      case PERIOD_D1:   intCmd = 33134;  break;
      case PERIOD_W1:   intCmd = 33141;  break;
      case PERIOD_MN1:  intCmd = 33334;  break;
   }
   
   if ( intChild > 0 )   
   {
      if ( intChild != intParent )   PostMessageA( intChild, WM_COMMAND, intCmd, 0 );
   }
   else      blnContinue = false;   
   
   while( blnContinue )
   {
      intChild = GetWindow( intChild, GW_HWNDNEXT );   
   
      if ( intChild > 0 )   
      { 
         if ( intChild != intParent )   PostMessageA( intChild, WM_COMMAND, intCmd, 0 );
      }
      else   blnContinue = false;   
   }
   
   // Now do the current window
   PostMessageA( intParent, WM_COMMAND, intCmd, 0 );
   return(0);
}



//+------------------------------------------------------------------+
int stringToTimeFrame(string tfs)
{
   int tf=0;
   StringToUpper(tfs); // This changes value of the var.
   tfs = StringTrimLeft(StringTrimRight(tfs)); 
   if      (tfs=="M0" || tfs=="0" || StringFind(tfs,"CUR",0) >= 0)     tf=Period(); // "CUR" *anywhere* in string, e.g. "0-CURRENT" or "CUR" 
   else if (tfs=="M1" || tfs=="1")     tf=PERIOD_M1;
   else if (tfs=="M5" || tfs=="5")     tf=PERIOD_M5;
   else if (tfs=="M15"|| tfs=="15")    tf=PERIOD_M15;
   else if (tfs=="M30"|| tfs=="30")    tf=PERIOD_M30;
   else if (tfs=="H1" || tfs=="60")    tf=PERIOD_H1;
   else if (tfs=="H4" || tfs=="240")   tf=PERIOD_H4;
   else if (tfs=="DAILY" || tfs=="D1"|| tfs=="D" || tfs=="1440")  tf=PERIOD_D1;
   else if (tfs=="WEEKLY" || tfs=="W1" || tfs=="W" || tfs=="10080") tf=PERIOD_W1;
   else if (tfs=="MONTHLY" || tfs=="MN1" || tfs=="MN" || tfs=="43200") tf=PERIOD_MN1;
   else tf=Period();   // Default if no other legal value.
   return(tf);
} // end of stringToTimeFrame