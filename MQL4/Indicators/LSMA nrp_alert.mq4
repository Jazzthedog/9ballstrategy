//+------------------------------------------------------------------+
//|                                                     LSMA nrp.mq4 |
//|                                                           mladen |
//+------------------------------------------------------------------+
#property  copyright "copyleft mladen"
#property  link      "mladenfx@gmail.com"

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 White
#property indicator_color2 Blue
#property indicator_color3 Blue
#property indicator_color4 Red
#property indicator_color5 Red
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2
#property indicator_width4 2
#property indicator_width5 2


extern int    LSMAPeriod      = 24;
extern int    LSMAPrice       =  0;
extern string note            = "turn on Alert = true; turn off = false";
extern bool   alertsOn        = true;
extern bool   alertsOnCurrent = true;
extern bool   alertsMessage   = true;
extern bool   alertsSound     = true;
extern bool   alertsEmail     = false;
extern string soundfile       = "alert2.wav";

//
//
//
//
//

double lsma_0[];
double lsma_1[];
double lsma_2[];
double lsma_3[];
double lsma_4[];
double slope[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//

int init()
{
   IndicatorBuffers(6);
   SetIndexBuffer(0,lsma_0);
   SetIndexBuffer(1,lsma_1);
   SetIndexBuffer(2,lsma_2);
   SetIndexBuffer(3,lsma_3);
   SetIndexBuffer(4,lsma_4);
   SetIndexBuffer(5,slope);
   return(0);
}

int start()
{ 
   int      counted_bars=IndicatorCounted();
   int      limit,i;

   if(counted_bars < 0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit = MathMin(Bars-counted_bars,Bars-1);
   
   //
   //
   //
   //
   //
   
   if (slope[limit] == 1) CleanPoint(limit,lsma_1,lsma_2);
   if (slope[limit] ==-1) CleanPoint(limit,lsma_3,lsma_4);
   for(i = limit; i >= 0; i--)
   {
      lsma_0[i] = 3.0*iMA(NULL,0,LSMAPeriod,0,MODE_LWMA,LSMAPrice,i)-2.0*iMA(NULL,0,LSMAPeriod,0,MODE_SMA,LSMAPrice,i);
      lsma_1[i] = EMPTY_VALUE;
      lsma_2[i] = EMPTY_VALUE;
      lsma_3[i] = EMPTY_VALUE;
      lsma_4[i] = EMPTY_VALUE;
      slope[i]  = slope[i+1];
         if (lsma_0[i] > lsma_0[i+1]) slope[i] = 1;
         if (lsma_0[i] < lsma_0[i+1]) slope[i] =-1;
         if (slope[i] == 1) PlotPoint(i,lsma_1,lsma_2,lsma_0);
         if (slope[i] ==-1) PlotPoint(i,lsma_3,lsma_4,lsma_0);
         } 
   
         //
         //
         //
         //
         //
      
         if (alertsOn)
         {
         
         if (alertsOnCurrent)
              int whichBar = 0;
         else     whichBar = 1;
         if (slope[whichBar] != slope[whichBar+1])
         if (slope[whichBar] == 1)
               doAlert("Buy");
         else  doAlert("Sell");       
   }

return(0);
}
  
//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

void doAlert(string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
      if (previousAlert != doWhat || previousTime != Time[0]) {
          previousAlert  = doWhat;
          previousTime   = Time[0];

          //
          //
          //
          //
          //

          message =  StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," LSMA ",doWhat);
             if (alertsMessage) Alert(message);
             if (alertsEmail)   SendMail(StringConcatenate(Symbol()," LSMA "),message);
             if (alertsSound)   PlaySound(soundfile);
      }
}
       
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

void CleanPoint(int i,double& first[],double& second[])
{
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}

//
//
//
//
//

void PlotPoint(int i,double& first[],double& second[],double& from[])
{
   if (first[i+1] == EMPTY_VALUE)
      {
      if (first[i+2] == EMPTY_VALUE) {
          first[i]    = from[i];
          first[i+1]  = from[i+1];
          second[i]   = EMPTY_VALUE;
         }
      else {
          second[i]   = from[i];
          second[i+1] = from[i+1];
          first[i]    = EMPTY_VALUE;
         }
      }
   else
      {
         first[i]   = from[i];
         second[i]  = EMPTY_VALUE;
      }
}

//
//
//
//
//


