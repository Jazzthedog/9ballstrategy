//+------------------------------------------------------------------+
//|                                   Period_Converter_ALL_Rev01.mq4 |
//|                 Copyright © 2005-2007, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
//#property show_inputs
#include <WinUser32.mqh>

int        ExtHandle=-1,ix,ExtPeriodMultiplier;

int start()
   {
// Write the M5-D1 History Files
   for(ix=2;ix<=7;ix++)
      {
      if(ix==7) ExtPeriodMultiplier=1440;
      if(ix==6) ExtPeriodMultiplier=240;
      if(ix==5) ExtPeriodMultiplier=60;
      if(ix==4) ExtPeriodMultiplier=30;
      if(ix==3) ExtPeriodMultiplier=15;
      if(ix==2) ExtPeriodMultiplier=5;
      
      int    i, start_pos, i_time, time0, last_fpos, periodseconds;
      double d_open, d_low, d_high, d_close, d_volume, last_volume;
      int    hwnd=0,cnt=0;
   //---- History header
      int    version=400;
      string c_copyright;
      string c_symbol=Symbol();
      int    i_period=Period()*ExtPeriodMultiplier;
      int    i_digits=Digits;
      int    i_unused[13];
   //----
      ExtHandle=FileOpenHistory(c_symbol+i_period+".hst", FILE_BIN|FILE_WRITE);
      if(ExtHandle < 0) return(-1);
   //---- write history file header
      c_copyright="(C)opyright 2003, MetaQuotes Software Corp.";
      FileWriteInteger(ExtHandle, version, LONG_VALUE);
      FileWriteString(ExtHandle, c_copyright, 64);
      FileWriteString(ExtHandle, c_symbol, 12);
      FileWriteInteger(ExtHandle, i_period, LONG_VALUE);
      FileWriteInteger(ExtHandle, i_digits, LONG_VALUE);
      FileWriteInteger(ExtHandle, 0, LONG_VALUE);       //timesign
      FileWriteInteger(ExtHandle, 0, LONG_VALUE);       //last_sync
      FileWriteArray(ExtHandle, i_unused, 0, 13);
   //---- write history file
      periodseconds=i_period*60;
      start_pos=Bars-1;
      d_open=Open[start_pos];
      d_low=Low[start_pos];
      d_high=High[start_pos];
      d_volume=Volume[start_pos];
      //---- normalize open time
      i_time=Time[start_pos]/periodseconds;
      i_time*=periodseconds;
      for(i=start_pos-1;i>=0; i--)
         {
         time0=Time[i];
         if(time0>=i_time+periodseconds || i==0)
            {
            if(i==0 && time0<i_time+periodseconds)
              {
               d_volume+=Volume[0];
               if (Low[0]<d_low)   d_low=Low[0];
               if (High[0]>d_high) d_high=High[0];
               d_close=Close[0];
              }
            last_fpos=FileTell(ExtHandle);
            last_volume=Volume[i];
            FileWriteInteger(ExtHandle, i_time, LONG_VALUE);
            FileWriteDouble(ExtHandle, d_open, DOUBLE_VALUE);
            FileWriteDouble(ExtHandle, d_low, DOUBLE_VALUE);
            FileWriteDouble(ExtHandle, d_high, DOUBLE_VALUE);
            FileWriteDouble(ExtHandle, d_close, DOUBLE_VALUE);
            FileWriteDouble(ExtHandle, d_volume, DOUBLE_VALUE);
            FileFlush(ExtHandle);
            cnt++;
            if(time0>=i_time+periodseconds)
               {
               i_time=time0/periodseconds;
               i_time*=periodseconds;
               d_open=Open[i];
               d_low=Low[i];
               d_high=High[i];
               d_close=Close[i];
               d_volume=last_volume;
               }
            }
         else
            {
            d_volume+=Volume[i];
            if (Low[i]<d_low)   d_low=Low[i];
            if (High[i]>d_high) d_high=High[i];
            d_close=Close[i];
            }
         }
      FileFlush(ExtHandle);
      Print(cnt," record(s) written");
      FileClose(ExtHandle);
      }

// Write the Weekly History File
   ExtPeriodMultiplier=10080;
   
   hwnd=0;
   cnt=0;
   //---- History header
   i_period=Period()*ExtPeriodMultiplier;
   i_digits=Digits;
   //----
   ExtHandle=FileOpenHistory(c_symbol+i_period+".hst", FILE_BIN|FILE_WRITE);
   if(ExtHandle < 0) return(-1);
   //---- write history file header
   c_copyright="(C)opyright 2003, MetaQuotes Software Corp.";
   FileWriteInteger(ExtHandle, version, LONG_VALUE);
   FileWriteString(ExtHandle, c_copyright, 64);
   FileWriteString(ExtHandle, c_symbol, 12);
   FileWriteInteger(ExtHandle, i_period, LONG_VALUE);
   FileWriteInteger(ExtHandle, i_digits, LONG_VALUE);
   FileWriteInteger(ExtHandle, 0, LONG_VALUE);       //timesign
   FileWriteInteger(ExtHandle, 0, LONG_VALUE);       //last_sync
   FileWriteArray(ExtHandle, i_unused, 0, 13);
   //---- write history file
   periodseconds=i_period*60;
   start_pos=Bars-1;
   d_open=Open[start_pos];
   d_low=Low[start_pos];
   d_high=High[start_pos];
   d_volume=Volume[start_pos];
   //---- normalize open time
   i_time=Time[start_pos];
   for(i=start_pos-1;i>=0; i--)
      {
      time0=Time[i];
      if((TimeDayOfWeek(time0)==1 && TimeDayOfWeek(Time[i+1])==5) || i==0)
         {
         if(i==0)
            {
            d_volume+=Volume[0];
            if (Low[0]<d_low)   d_low=Low[0];
            if (High[0]>d_high) d_high=High[0];
            d_close=Close[0];
            }
         last_fpos=FileTell(ExtHandle);
         FileWriteInteger(ExtHandle, i_time, LONG_VALUE);
         FileWriteDouble(ExtHandle, d_open, DOUBLE_VALUE);
         FileWriteDouble(ExtHandle, d_low, DOUBLE_VALUE);
         FileWriteDouble(ExtHandle, d_high, DOUBLE_VALUE);
         FileWriteDouble(ExtHandle, d_close, DOUBLE_VALUE);
         FileWriteDouble(ExtHandle, d_volume, DOUBLE_VALUE);
         FileFlush(ExtHandle);
         cnt++;
         i_time=time0;
         d_open=Open[i];
         d_low=Low[i];
         d_high=High[i];
         d_close=Close[i];
         d_volume=Volume[i];
         }
      else
         {
         d_volume+=Volume[i];
         if (Low[i]<d_low)   d_low=Low[i];
         if (High[i]>d_high) d_high=High[i];
         d_close=Close[i];
         }
      }
   FileFlush(ExtHandle);
   Print(cnt," record(s) written");
   FileClose(ExtHandle);

// Write the Monthly History File
   ExtPeriodMultiplier=43200;
   
   hwnd=0;
   cnt=0;
   //---- History header
   i_period=Period()*ExtPeriodMultiplier;
   i_digits=Digits;
   //----
   ExtHandle=FileOpenHistory(c_symbol+i_period+".hst", FILE_BIN|FILE_WRITE);
   if(ExtHandle < 0) return(-1);
   //---- write history file header
   c_copyright="(C)opyright 2003, MetaQuotes Software Corp.";
   FileWriteInteger(ExtHandle, version, LONG_VALUE);
   FileWriteString(ExtHandle, c_copyright, 64);
   FileWriteString(ExtHandle, c_symbol, 12);
   FileWriteInteger(ExtHandle, i_period, LONG_VALUE);
   FileWriteInteger(ExtHandle, i_digits, LONG_VALUE);
   FileWriteInteger(ExtHandle, 0, LONG_VALUE);       //timesign
   FileWriteInteger(ExtHandle, 0, LONG_VALUE);       //last_sync
   FileWriteArray(ExtHandle, i_unused, 0, 13);
   //---- write history file
   periodseconds=i_period*60;
   start_pos=Bars-1;
   d_open=Open[start_pos];
   d_low=Low[start_pos];
   d_high=High[start_pos];
   d_volume=Volume[start_pos];
   //---- normalize open time
   i_time=Time[start_pos];
   for(i=start_pos-1;i>=0; i--)
      {
      time0=Time[i];
      if(TimeMonth(time0)!=TimeMonth(Time[i+1]) || i==0)
         {
         if(i==0)
            {
            d_volume+=Volume[0];
            if (Low[0]<d_low)   d_low=Low[0];
            if (High[0]>d_high) d_high=High[0];
            d_close=Close[0];
            }
         last_fpos=FileTell(ExtHandle);
         FileWriteInteger(ExtHandle, i_time, LONG_VALUE);
         FileWriteDouble(ExtHandle, d_open, DOUBLE_VALUE);
         FileWriteDouble(ExtHandle, d_low, DOUBLE_VALUE);
         FileWriteDouble(ExtHandle, d_high, DOUBLE_VALUE);
         FileWriteDouble(ExtHandle, d_close, DOUBLE_VALUE);
         FileWriteDouble(ExtHandle, d_volume, DOUBLE_VALUE);
         FileFlush(ExtHandle);
         cnt++;
         i_time=time0;
         d_open=Open[i];
         d_low=Low[i];
         d_high=High[i];
         d_close=Close[i];
         d_volume=Volume[i];
         }
      else
         {
         d_volume+=Volume[i];
         if (Low[i]<d_low)   d_low=Low[i];
         if (High[i]>d_high) d_high=High[i];
         d_close=Close[i];
         }
      }
   FileFlush(ExtHandle);
   Print(cnt," record(s) written");
   FileClose(ExtHandle);
   }

