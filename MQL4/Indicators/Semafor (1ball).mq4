//+------------------------------------------------------------------+
//|                                                          Semafor |
//+------------------------------------------------------------------+


#property indicator_chart_window 
#property indicator_buffers 2
#property indicator_color1 Yellow
#property indicator_color2 Yellow 

//---- input parameters 
extern double Period1=5; 

extern string   Dev_Step_1="5,3";

extern int Symbol_1_Kod=251;

//---- buffers 
double FP_BuferUp[];
double FP_BuferDn[]; 


int F_Period;
int Dev1;
int Stp1;


//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int init() 
  { 

   if (Period1>0) F_Period=MathCeil(Period1*Period()); else F_Period=0; 
   
 
   if (Period1>0)
   {
   SetIndexStyle(0,DRAW_ARROW,0,4); 
   SetIndexArrow(0,Symbol_1_Kod); 
   SetIndexBuffer(0,FP_BuferUp); 
   SetIndexEmptyValue(0,0.0); 
   
   SetIndexStyle(1,DRAW_ARROW,0,4); 
   SetIndexArrow(1,Symbol_1_Kod); 
   SetIndexBuffer(1,FP_BuferDn); 
   SetIndexEmptyValue(1,0.0); 
   }

   int CDev=0;
   int CSt=0;
   int Mass[]; 
   int C=0;  
   if (IntFromStr(Dev_Step_1,C, Mass)==1) 
      {
        Stp1=Mass[1];
        Dev1=Mass[0];
      }     
   return(0); 
  } 
//+------------------------------------------------------------------+ 
//| Custor indicator deinitialization function                       | 
//+------------------------------------------------------------------+ 
int deinit() 
  { 
//---- 
    
//---- 
   return(0); 
  } 

//+------------------------------------------------------------------+ 
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+ 
int start() 
  { 
   if (Period1>0) CountZZ(FP_BuferUp,FP_BuferDn,Period1,Dev1,Stp1);
   return(0); 
  } 
//+------------------------------------------------------------------+ 

int CountZZ( double& ExtMapBuffer[], double& ExtMapBuffer2[], int ExtDepth, int ExtDeviation, int ExtBackstep )
  {
   int    shift, back,lasthighpos,lastlowpos;
   double val,res;
   double curlow,curhigh,lasthigh,lastlow;

   for(shift=Bars-ExtDepth; shift>=0; shift--)
     {
      val=Low[Lowest(NULL,0,MODE_LOW,ExtDepth,shift)];
      if(val==lastlow) val=0.0;
      else 
        { 
         lastlow=val; 
         if((Low[shift]-val)>(ExtDeviation*Point)) val=0.0;
         else
           {
            for(back=1; back<=ExtBackstep; back++)
              {
               res=ExtMapBuffer[shift+back];
               if((res!=0)&&(res>val)) ExtMapBuffer[shift+back]=0.0; 
              }
           }
        } 
        
          ExtMapBuffer[shift]=val;
      //--- high
      val=High[Highest(NULL,0,MODE_HIGH,ExtDepth,shift)];
      if(val==lasthigh) val=0.0;
      else 
        {
         lasthigh=val;
         if((val-High[shift])>(ExtDeviation*Point)) val=0.0;
         else
           {
            for(back=1; back<=ExtBackstep; back++)
              {
               res=ExtMapBuffer2[shift+back];
               if((res!=0)&&(res<val)) ExtMapBuffer2[shift+back]=0.0; 
              } 
           }
        }
      ExtMapBuffer2[shift]=val;
     }
   // final cutting 
   lasthigh=-1; lasthighpos=-1;
   lastlow=-1;  lastlowpos=-1;

   for(shift=Bars-ExtDepth; shift>=0; shift--)
     {
      curlow=ExtMapBuffer[shift];
      curhigh=ExtMapBuffer2[shift];
      if((curlow==0)&&(curhigh==0)) continue;
      //---
      if(curhigh!=0)
        {
         if(lasthigh>0) 
           {
            if(lasthigh<curhigh) ExtMapBuffer2[lasthighpos]=0;
            else ExtMapBuffer2[shift]=0;
           }
         //---
         if(lasthigh<curhigh || lasthigh<0)
           {
            lasthigh=curhigh;
            lasthighpos=shift;
           }
         lastlow=-1;
        }
      //----
      if(curlow!=0)
        {
         if(lastlow>0)
           {
            if(lastlow>curlow) ExtMapBuffer[lastlowpos]=0;
            else ExtMapBuffer[shift]=0;
           }
         //---
         if((curlow<lastlow)||(lastlow<0))
           {
            lastlow=curlow;
            lastlowpos=shift;
           } 
         lasthigh=-1;
        }
     }
  
   for(shift=Bars-1; shift>=0; shift--)
     {
      if(shift>=Bars-ExtDepth) ExtMapBuffer[shift]=0.0;
      else
        {
         res=ExtMapBuffer2[shift];
         if(res!=0.0) ExtMapBuffer2[shift]=res;
        }
     }
 }
  
int Str2Massive(string VStr, int& M_Count, int& VMass[])
  {
    int val=StrToInteger( VStr);
    if (val>0)
       {
         M_Count++;
         int mc=ArrayResize(VMass,M_Count);
         if (mc==0)return(-1);
          VMass[M_Count-1]=val;
         return(1);
       }
    else return(0);    
  } 
  
  
int IntFromStr(string ValStr,int& M_Count, int& VMass[])
  {
    
    if (StringLen(ValStr)==0) return(-1);
    string SS=ValStr;
    int NP=0; 
    string CS;
    M_Count=0;
    ArrayResize(VMass,M_Count);
    while (StringLen(SS)>0)
      {
            NP=StringFind(SS,",");
            if (NP>0)
               {
                 CS=StringSubstr(SS,0,NP);
                 SS=StringSubstr(SS,NP+1,StringLen(SS));  
               }
               else
               {
                 if (StringLen(SS)>0)
                    {
                      CS=SS;
                      SS="";
                    }
               }
            if (Str2Massive(CS,M_Count,VMass)==0) 
               {
                 return(-2);
               }
      }
    return(1);    
  }