//+------------------------------------------------------------------+
//|                                                    II_SupDem.mq4 |
//|                            Copyright © 2010, Insanity Industries |
//|                                http://www.insanityindustries.net |
//| v.2.3.1 21/7/2010                                                  |
//| code by bredin, except where noted                               |
//| donations can be made via PayPal to bredin@lpemail.com           |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, Insanity Industries"
#property link      "https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=JEHPJ5XSPPN62"

#property indicator_chart_window
#property indicator_buffers 2
extern int forcedtf = 0;
extern bool drawzones = true;
extern bool solidzones = true;
extern bool solidretouch = true;
extern bool recolorretouch = true;
extern bool recolorweakretouch = true;
extern bool zonestrength = true;
extern bool noweakzones = true;
extern bool drawedgeprice = true;
extern int zonewidth = 2;
extern bool zonefibs = false;
extern int fibstyle = 0;
extern bool HUDon = false;
extern bool timeron = false;
extern int layerzone = 0;
extern int layerHUD = 20;
extern int cornerHUD = 2;
extern int posx = 100;
extern int posy = 20;
extern bool alerton = true;
extern bool alertpopup = true;
extern string alertsound = "alert.wav";
extern color colorsupstrong = C'189,219,181';
extern color colorsupweak = C'207,220,203';
extern color colorsupretouch = C'207,220,203';
extern color colordemstrong = C'201,218,237';
extern color colordemweak = C'187,208,232';
extern color colordemretouch = C'187,208,232';
extern color colorfib = DodgerBlue;
extern color colorHUDtf = Navy;
extern color colorarrowup = SeaGreen;
extern color colorarrowdn = Crimson;
extern color colortimerback = DarkGray;
extern color colortimerbar = Red;
extern color colorshadow = DarkSlateGray;

extern bool limitzonevis = false;
extern bool sametfvis = true;
extern bool showonm1 = false;
extern bool showonm5 = true;
extern bool showonm15 = false;
extern bool showonm30 = false;
extern bool showonh1 = false;
extern bool showonh4 = false;
extern bool showond1 = false;
extern bool showonw1 = false;
extern bool showonmn = false;


extern int Price_Width = 1;

extern int timeoffset = 0;

extern bool globals = false;

double BuferUp1[];
double BuferDn1[];

double supRR[4];
double demRR[4];
double supwidth,demwidth;

string lhud,lzone;
int HUDx;
string fontHUD = "Comic Sans MS";
int fontHUDsize = 20;
string fontHUDprice = "Arial Bold";
int fontHUDpricesize = 12;
int arrowUP = 0x70;
int arrowDN = 0x71;
string fontarrow = "WingDings 3";
int fontarrowsize = 40;
int fontpairsize = 8;


string arrowglance;
color colorarrow;
int visible;
int rotation=270;
int lenbase;
string s_base="|||||||||||||||||||||||";
string timerfont="Arial Bold";
int sizetimerfont=8;

double min,max;
double iPeriod[4] = {3,8,13,34}; 
int Dev[4] = {2,5,8,13};
int Step[4] = {2,3,5,8};
datetime t1,t2;
double p1,p2;
string pair;
double point;
int digits;
int tf;
string TAG;

double fibsup,fibdem;
int SupCount,DemCount;
int SupAlert,DemAlert;
double upcur,dncur;
double fiblevelarray[13]={0,0.236,0.386,0.5,0.618,0.786,1,1.276,1.618,2.058,2.618,3.33,4.236};
string fibleveldesc[13]={"0","23.6%","38.6%","50%","61.8%","78.6%","100%","127.6%","161.8%","205.8%","261.80%","333%","423.6%"};

int hudtimerx,hudtimery,hudarrowx,hudarrowy,hudtfx,hudtfy;
int hudsupx,hudsupy,huddemx,huddemy;
int hudtimersx,hudtimersy,hudarrowsx,hudarrowsy,hudtfsx,hudtfsy;
int hudsupsx,hudsupsy,huddemsx,huddemsy;

int init()
{
   SetIndexBuffer(1,BuferUp1); 
   SetIndexEmptyValue(1,0.0);
   SetIndexStyle(1,DRAW_NONE);
   SetIndexBuffer(0,BuferDn1); 
   SetIndexEmptyValue(0,0.0); 
   SetIndexStyle(0,DRAW_NONE);

   if(layerHUD > 25) layerHUD = 25;
   lhud = CharToStr(0x61+layerHUD);
   if(layerzone > 25) layerzone = 25;
   lzone = CharToStr(0x61+layerzone);

   pair=Symbol();   
   if(forcedtf != 0) tf = forcedtf;
      else tf = Period();
   point = Point;
   digits = Digits;
   if(digits == 3 || digits == 5) point*=10;
   if(HUDon && !drawzones) TAG = "II_HUD"+tf;
   else TAG = "II_SupDem"+tf;
   lenbase=StringLen(s_base);
   
   if(HUDon) setHUD();
   if(limitzonevis) setVisibility();
   ObDeleteObjectsByPrefix(lhud+TAG);
   ObDeleteObjectsByPrefix(lzone+TAG);
  
   return(0);
}

int deinit()
{
   ObDeleteObjectsByPrefix(lhud+TAG);
   ObDeleteObjectsByPrefix(lzone+TAG);
   Comment(""); 
   return(0);
}

int start()
{
   if(NewBar()==true)
   {
      SupAlert = 1;
      DemAlert = 1;
      ObDeleteObjectsByPrefix(lzone+TAG);
      CountZZ(BuferUp1,BuferDn1,iPeriod[0],Dev[0],Step[0]);
      GetValid(BuferUp1,BuferDn1);
      Draw();
      if(HUDon) HUD();
   }
   if(HUDon && timeron) BarTimer();
   if(alerton) CheckAlert();
   return(0);
}

void CheckAlert(){
//   SupCount DemCount
//   SupAlert DemAlert
   double price = ObjectGet(lzone+TAG+"UPAR"+SupAlert,OBJPROP_PRICE1);
   if(Close[0] > price && price > point){
      if(alertpopup) Alert(pair+" "+TimeFrameToString(tf)+" Supply Zone Entered at "+DoubleToStr(price,Digits));
      PlaySound(alertsound);
      SupAlert++;
   }
   price = ObjectGet(lzone+TAG+"DNAR"+DemAlert,OBJPROP_PRICE1);
   if(Close[0] < price){
      Alert(pair+" "+TimeFrameToString(tf)+" Demand Zone Entered at "+DoubleToStr(price,Digits));
      PlaySound(alertsound);
      DemAlert++;
   }
}

void Draw()
{
   int fibsuphit=0;
   int fibdemhit=0;

   int sc=0,dc=0; 
   int i,j,countstrong,countweak;
   color c;
   string s;
   bool exit,draw,fle,fhe,retouch;
   bool valid;
   double val;
   fhe=false;
   fle=false;
   SupCount=0;
   DemCount=0;
   fibsup=0;
   fibdem=0;
   for(i=0;i<iBars(pair,tf);i++){
      if(BuferDn1[i] > point){
         retouch = false;
         valid = false;
         t1 = iTime(pair,tf,i);
         t2 = Time[0];
         p2 = MathMin(iClose(pair,tf,i),iOpen(pair,tf,i));
         if(i>0) p2 = MathMax(p2,MathMax(iLow(pair,tf,i-1),iLow(pair,tf,i+1)));
         if(i>0) p2 = MathMax(p2,MathMin(iOpen(pair,tf,i-1),iClose(pair,tf,i-1)));
         p2 = MathMax(p2,MathMin(iOpen(pair,tf,i+1),iClose(pair,tf,i+1)));
         
         draw=true;
         if(recolorretouch || !solidretouch){
            exit = false;
            for(j=i;j>=0;j--){
               if(j==0 && !exit) {draw=false;break;}
               if(!exit && iHigh(pair,tf,j)<p2) {exit=true;continue;}
               if(exit && iHigh(pair,tf,j)>p2) {
                  retouch = true;
                  if(zonefibs && fibsuphit==0){ fibsup = p2; fibsuphit = j;}
                  break;
               }
            }
         }
         if(SupCount != 0) val = ObjectGet(TAG+"UPZONE"+SupCount,OBJPROP_PRICE2); //final sema cull
            else val=0;
         if(drawzones && draw && BuferDn1[i]!=val) {
            valid=true;
            c = colorsupstrong;
            if(zonestrength && (retouch || !recolorretouch)){
               countstrong=0;
               countweak=0;
               for(j=i;j<1000000;j++){
                  if(iHigh(pair,tf,j+1)<p2) countstrong++;
                  if(iHigh(pair,tf,j+1)>BuferDn1[i]) countweak++;
                  if(countstrong > 1) break;
                     else if(countweak > 1){
                        c=colorsupweak;
                        if(noweakzones) draw = false;
                        break;
                     }                 
               }
            }
//         if(c == colorsupweak && !noweakzones) draw = false;
         if(draw){
            if(recolorretouch && retouch && countweak<2) c = colorsupretouch;
               else if(recolorweakretouch && retouch && countweak>1) c = colorsupretouch;
            SupCount++;
            if(drawedgeprice){
               s = lzone+TAG+"UPAR"+SupCount;
               ObjectCreate(s,OBJ_ARROW,0,0,0);
               ObjectSet(s,OBJPROP_ARROWCODE,SYMBOL_RIGHTPRICE);
               ObjectSet(s, OBJPROP_TIME1, t2);
               ObjectSet(s, OBJPROP_PRICE1, p2);
               ObjectSet(s,OBJPROP_COLOR,c);
               ObjectSet(s,OBJPROP_WIDTH,Price_Width);
               if(limitzonevis) ObjectSet(s,OBJPROP_TIMEFRAMES,visible);
            }
            s = lzone+TAG+"UPZONE"+SupCount;
            ObjectCreate(s,OBJ_RECTANGLE,0,0,0,0,0);
            ObjectSet(s,OBJPROP_TIME1,t1);
            ObjectSet(s,OBJPROP_PRICE1,BuferDn1[i]);
            ObjectSet(s,OBJPROP_TIME2,t2);
            ObjectSet(s,OBJPROP_PRICE2,p2);
            ObjectSet(s,OBJPROP_COLOR,c);
            ObjectSet(s,OBJPROP_BACK,true);
            if(limitzonevis) ObjectSet(s,OBJPROP_TIMEFRAMES,visible);
            if(!solidzones) {ObjectSet(s,OBJPROP_BACK,false);ObjectSet(s,OBJPROP_WIDTH,zonewidth);}
            if(!solidretouch && retouch) {ObjectSet(s,OBJPROP_BACK,false);ObjectSet(s,OBJPROP_WIDTH,zonewidth);}
            
            if(globals){
               GlobalVariableSet(TAG+"SPH"+SupCount,BuferDn1[i]);
               GlobalVariableSet(TAG+"SPL"+SupCount,p2);
               GlobalVariableSet(TAG+"ST"+SupCount,iTime(pair,tf,i));
            }
            if(!fhe && c!=colordemretouch){fhe=true;GlobalVariableSet(TAG+"GOSHORT",p2);}
            }
         }
         if(draw && sc<4 && HUDon && valid){
            if(sc==0) supwidth = BuferDn1[i] - p2;
            supRR[sc] = p2;
            sc++;
         }

      }
      
      if(BuferUp1[i] > point){
         retouch = false;
         valid=false;
         t1 = iTime(pair,tf,i);
         t2 = Time[0];
         p2 = MathMax(iClose(pair,tf,i),iOpen(pair,tf,i));
         if(i>0) p2 = MathMin(p2,MathMin(iHigh(pair,tf,i+1),iHigh(pair,tf,i-1)));
         if(i>0) p2 = MathMin(p2,MathMax(iOpen(pair,tf,i-1),iClose(pair,tf,i-1)));
         p2 = MathMin(p2,MathMax(iOpen(pair,tf,i+1),iClose(pair,tf,i+1)));
         
         c = colordemstrong;
         draw=true;
         if(recolorretouch || !solidretouch){
            exit = false;
            for(j=i;j>=0;j--) {
               if(j==0 && !exit) {draw=false;break;}
               if(!exit && iLow(pair,tf,j)>p2) {exit=true;continue;}
               if(exit && iLow(pair,tf,j)<p2) {
                  retouch = true;
                  if(zonefibs && fibdemhit==0){fibdem = p2; fibdemhit = j; }
                  break;
               }
            }
         }
         if(DemCount != 0) val = ObjectGet(TAG+"DNZONE"+DemCount,OBJPROP_PRICE2); //final sema cull
            else val=0;
         if(drawzones && draw && BuferUp1[i]!=val){
            valid = true;
            if(zonestrength && (retouch || !recolorretouch)){
               countstrong=0;
               countweak=0;
               for(j=i;j<1000000;j++){
                  if(iLow(pair,tf,j+1)>p2) countstrong++;
                  if(iLow(pair,tf,j+1)<BuferUp1[i]) countweak++;
                  if(countstrong > 1) break;
                     else if(countweak > 1){
                        if(noweakzones) draw = false;
                        c=colordemweak;
                        break;
                     }                 
               }
            }
            
            if(draw){
            if(recolorretouch && retouch && countweak<2) c = colordemretouch;
               else if(recolorweakretouch && retouch && countweak>1) c = colordemretouch;

            DemCount++;
            if(drawedgeprice){
               s = lzone+TAG+"DNAR"+DemCount;
               ObjectCreate(s,OBJ_ARROW,0,0,0);
               ObjectSet(s,OBJPROP_ARROWCODE,SYMBOL_RIGHTPRICE);
               ObjectSet(s, OBJPROP_TIME1, t2);
               ObjectSet(s, OBJPROP_PRICE1, p2);
               ObjectSet(s,OBJPROP_COLOR,c);
               ObjectSet(s,OBJPROP_WIDTH,Price_Width);  
               if(limitzonevis) ObjectSet(s,OBJPROP_TIMEFRAMES,visible);
            }
            s = lzone+TAG+"DNZONE"+DemCount;
            ObjectCreate(s,OBJ_RECTANGLE,0,0,0,0,0);
            ObjectSet(s,OBJPROP_TIME1,t1);
            ObjectSet(s,OBJPROP_PRICE1,p2);
            ObjectSet(s,OBJPROP_TIME2,t2);
            ObjectSet(s,OBJPROP_PRICE2,BuferUp1[i]);
            ObjectSet(s,OBJPROP_COLOR,c);
            ObjectSet(s,OBJPROP_BACK,true);
            if(limitzonevis) ObjectSet(s,OBJPROP_TIMEFRAMES,visible);
            if(!solidzones) {ObjectSet(s,OBJPROP_BACK,false);ObjectSet(s,OBJPROP_WIDTH,zonewidth);}
            if(!solidretouch && retouch) {ObjectSet(s,OBJPROP_BACK,false);ObjectSet(s,OBJPROP_WIDTH,zonewidth);}
            if(globals){
               GlobalVariableSet(TAG+"DPL"+DemCount,BuferUp1[i]);
               GlobalVariableSet(TAG+"DPH"+DemCount,p2);
               GlobalVariableSet(TAG+"DT"+DemCount,iTime(pair,tf,i));
            }
            if(!fle && c!=colordemretouch){fle=true;GlobalVariableSet(TAG+"GOLONG",p2);}
            }
         }
         if(draw && dc<4 && HUDon && valid){
            if(dc==0) demwidth = p2-BuferUp1[i];
            demRR[dc] = p2;
            dc++;
         }
      }
   }
   if(zonefibs || HUDon){
      double a,b;
      int dr=0;
      int sr=0;
      int d1=0;
      int s1=0;
      int t;
      for(i=0;i<100000;i++){
         if(iHigh(pair,tf,i)>fibsup && sr==0) sr = i;
         if(iHigh(pair,tf,i)>supRR[0] && s1==0) s1 = i;
         if(iLow(pair,tf,i)<fibdem && dr==0) dr = i;
         if(iLow(pair,tf,i)<demRR[0] && d1==0) d1 = i;
         if(sr!=0&&s1!=0&&dr!=0&&d1!=0) break;
      }
   }
      
      if(zonefibs){
      
         if(dr<sr) {b = fibdem;a = supRR[0];}
            else {b = fibsup;a = demRR[0];}

      
         s = lzone+TAG+"FIBO";
         ObjectCreate(s, OBJ_FIBO, 0,Time[0],a,Time[0],b);
	      ObjectSet(s, OBJPROP_COLOR, CLR_NONE);
	      ObjectSet(s, OBJPROP_STYLE, fibstyle);
	      ObjectSet(s, OBJPROP_RAY, true);
	      ObjectSet(s, OBJPROP_BACK, true);
         if(limitzonevis) ObjectSet(s,OBJPROP_TIMEFRAMES,visible);
         int level_count=ArraySize(fiblevelarray);
   
         ObjectSet(s, OBJPROP_FIBOLEVELS, level_count);
         ObjectSet(s, OBJPROP_LEVELCOLOR, colorfib);
   
         for(j=0; j<level_count; j++){
            ObjectSet(s, OBJPROP_FIRSTLEVEL+j, fiblevelarray[j]);
            ObjectSetFiboDescription(s,j,fibleveldesc[j]);
         }
      }
      if(HUDon) {
         if(d1<s1) {b = demRR[0];a = supRR[0]; arrowglance = CharToStr(arrowUP); colorarrow = colorarrowup;}
            else {b = supRR[0];a = demRR[0]; arrowglance = CharToStr(arrowDN); colorarrow = colorarrowdn;}      
         min = MathMin(a,b);
         max = MathMax(a,b);
      }
   
   
}

bool NewBar() {
	static datetime LastTime = 0;
	if (iTime(pair,tf,0)+timeoffset != LastTime) {
		LastTime = iTime(pair,tf,0)+timeoffset;		
		return (true);
	} else
		return (false);
}

void ObDeleteObjectsByPrefix(string Prefix){
   int L = StringLen(Prefix);
   int i = 0; 
   while(i < ObjectsTotal()) {
      string ObjName = ObjectName(i);
      if(StringSubstr(ObjName, 0, L) != Prefix) {
         i++;
         continue;
      }
      ObjectDelete(ObjName);
   }
}

int CountZZ( double& ExtMapBuffer[], double& ExtMapBuffer2[], int ExtDepth, int ExtDeviation, int ExtBackstep ){ // based on code (C) metaquote{
   int    shift, back,lasthighpos,lastlowpos;
   double val,res;
   double curlow,curhigh,lasthigh,lastlow;
   int count = iBars(pair,tf)-ExtDepth;

   for(shift=count; shift>=0; shift--){
      val = iLow(pair,tf,iLowest(pair,tf,MODE_LOW,ExtDepth,shift));
      if(val==lastlow) val=0.0;
      else { 
         lastlow=val; 
         if((iLow(pair,tf,shift)-val)>(ExtDeviation*Point)) val=0.0;
         else{
            for(back=1; back<=ExtBackstep; back++){
               res=ExtMapBuffer[shift+back];
               if((res!=0)&&(res>val)) ExtMapBuffer[shift+back]=0.0; 
              }
           }
        } 
        
          ExtMapBuffer[shift]=val;
      //--- high
      val=iHigh(pair,tf,iHighest(pair,tf,MODE_HIGH,ExtDepth,shift));
      
      if(val==lasthigh) val=0.0;
      else {
         lasthigh=val;
         if((val-iHigh(pair,tf,shift))>(ExtDeviation*Point)) val=0.0;
         else{
            for(back=1; back<=ExtBackstep; back++){
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

   for(shift=count; shift>=0; shift--){
      curlow=ExtMapBuffer[shift];
      curhigh=ExtMapBuffer2[shift];
      if((curlow==0)&&(curhigh==0)) continue;
      //---
      if(curhigh!=0){
         if(lasthigh>0) {
            if(lasthigh<curhigh) ExtMapBuffer2[lasthighpos]=0;
            else ExtMapBuffer2[shift]=0;
           }
         //---
         if(lasthigh<curhigh || lasthigh<0){
            lasthigh=curhigh;
            lasthighpos=shift;
           }
         lastlow=-1;
        }
      //----
      if(curlow!=0){
         if(lastlow>0){
            if(lastlow>curlow) ExtMapBuffer[lastlowpos]=0;
            else ExtMapBuffer[shift]=0;
           }
         //---
         if((curlow<lastlow)||(lastlow<0)){
            lastlow=curlow;
            lastlowpos=shift;
           } 
         lasthigh=-1;
        }
     }
  
   for(shift=iBars(pair,tf)-1; shift>=0; shift--){
      if(shift>=count) ExtMapBuffer[shift]=0.0;
         else {
            res=ExtMapBuffer2[shift];
            if(res!=0.0) ExtMapBuffer2[shift]=res;
         }
   }


}
 
void GetValid(double& ExtMapBuffer[], double& ExtMapBuffer2[]){
   upcur = 0;
   int upbar = 0;
   dncur = 0;
   int dnbar = 0;
   double curhi = 0;
   double curlo = 0;
   double lastup = 0;
   double lastdn = 0;
   double lowdn = 0;
   double hiup = 0;
   int i;
   for(i=0;i<iBars(pair,tf);i++) if(ExtMapBuffer[i] > 0){
      upcur = ExtMapBuffer[i];
      curlo = ExtMapBuffer[i];
      lastup = curlo;
      break;
   }
   for(i=0;i<iBars(pair,tf);i++) if(ExtMapBuffer2[i] > 0){
      dncur = ExtMapBuffer2[i];
      curhi = ExtMapBuffer2[i];
      lastdn = curhi;
      break;
   }

   for(i=0;i<iBars(pair,tf);i++) // remove higher lows and lower highs
   {
      if(ExtMapBuffer2[i] >= lastdn) {
         lastdn = ExtMapBuffer2[i];
         dnbar = i;
      }
         else ExtMapBuffer2[i] = 0.0;
      if(ExtMapBuffer2[i] <= dncur && ExtMapBuffer[i] > 0.0) ExtMapBuffer2[i] = 0.0;
      if(ExtMapBuffer[i] <= lastup && ExtMapBuffer[i] > 0) {
         lastup = ExtMapBuffer[i];
         upbar = i;
      }
         else ExtMapBuffer[i] = 0.0;
      if(ExtMapBuffer[i] > upcur) ExtMapBuffer[i] = 0.0;
   }
   lowdn = MathMin(iOpen(pair,tf,dnbar),iClose(pair,tf,dnbar));
   hiup = MathMax(iOpen(pair,tf,upbar),iClose(pair,tf,upbar));         
   for(i=MathMax(upbar,dnbar);i>=0;i--) {// work back to zero and remove reentries into s/d
      if(ExtMapBuffer2[i] > lowdn && ExtMapBuffer2[i] != lastdn) ExtMapBuffer2[i] = 0.0;
         else if(ExtMapBuffer2[i] > 0) {
            lastdn = ExtMapBuffer2[i];
         lowdn = MathMin(iClose(pair,tf,i),iOpen(pair,tf,i));
         if(i>0) lowdn = MathMax(lowdn,MathMax(iLow(pair,tf,i-1),iLow(pair,tf,i+1)));
         if(i>0) lowdn = MathMax(lowdn,MathMin(iOpen(pair,tf,i-1),iClose(pair,tf,i-1)));
         lowdn = MathMax(lowdn,MathMin(iOpen(pair,tf,i+1),iClose(pair,tf,i+1)));
         }
      if(ExtMapBuffer[i] <= hiup && ExtMapBuffer[i] > 0 && ExtMapBuffer[i] != lastup) ExtMapBuffer[i] = 0.0;
         else if(ExtMapBuffer[i] > 0){
            lastup = ExtMapBuffer[i];
            hiup = MathMax(iClose(pair,tf,i),iOpen(pair,tf,i));
            if(i>0) hiup = MathMin(hiup,MathMin(iHigh(pair,tf,i+1),iHigh(pair,tf,i-1)));
            if(i>0) hiup = MathMin(hiup,MathMax(iOpen(pair,tf,i-1),iClose(pair,tf,i-1)));
            hiup = MathMin(hiup,MathMax(iOpen(pair,tf,i+1),iClose(pair,tf,i+1)));
         }
   }
}

void HUD()
{
   string s = TimeFrameToString(tf);
   string u = DoubleToStr(ObjectGet(lzone+TAG+"UPAR"+1,OBJPROP_PRICE1),Digits);
   string d = DoubleToStr(ObjectGet(lzone+TAG+"DNAR"+1,OBJPROP_PRICE1),Digits);
   string l = "b";
   DrawText(l,s,hudtfx,hudtfy,colorHUDtf,fontHUD,fontHUDsize,cornerHUD);
   DrawText(l,arrowglance,hudarrowx,hudarrowy,colorarrow,fontarrow,fontarrowsize,cornerHUD,0,true);
   DrawText(l,u,hudsupx,hudsupy,colorsupstrong,fontHUDprice,fontHUDpricesize,cornerHUD);
   DrawText(l,d,huddemx,huddemy,colordemstrong,fontHUDprice,fontHUDpricesize,cornerHUD);

   l = "a";
   DrawText(l,s,hudtfsx,hudtfsy,colorshadow,fontHUD,fontHUDsize,cornerHUD);
   DrawText(l,arrowglance,hudarrowsx,hudarrowsy,colorshadow,fontarrow,fontarrowsize,cornerHUD,0,true);
   DrawText(l,u,hudsupsx,hudsupsy,colorshadow,fontHUDprice,fontHUDpricesize,cornerHUD);
   DrawText(l,d,huddemsx,huddemsy,colorshadow,fontHUDprice,fontHUDpricesize,cornerHUD);
   
}

void BarTimer() // Original Code by Vasyl Gumenyak, I just fucked it up
{
   int i=0,sec=0;
   double pc=0.0;
   string time="",s_end="",s;
   s = lhud+TAG+"btimerback";
   if (ObjectFind(s) == -1) {
      ObjectCreate(s , OBJ_LABEL,0,0,0);
      ObjectSet(s, OBJPROP_XDISTANCE, hudtimerx);
      ObjectSet(s, OBJPROP_YDISTANCE, hudtimery);
      ObjectSet(s, OBJPROP_CORNER, cornerHUD);
      ObjectSet(s, OBJPROP_ANGLE, rotation);
      ObjectSetText(s, s_base, sizetimerfont, timerfont, colortimerback);
   }

   sec=TimeCurrent()-iTime(pair,tf,0);
   i=(lenbase-1)*sec/(tf*60);
   pc=100-(100.0*sec/(tf*60));
   if(i>lenbase-1) i=lenbase-1;
   if(i<lenbase-1) s_end=StringSubstr(s_base,i+1,lenbase-i-1);
   time=StringConcatenate("|",s_end);

   s = lhud+TAG+"timerfront";
   if (ObjectFind(s) == -1) {
     ObjectCreate(s , OBJ_LABEL,0,0,0);
     ObjectSet(s, OBJPROP_XDISTANCE, hudtimerx);
     ObjectSet(s, OBJPROP_YDISTANCE, hudtimery);
     ObjectSet(s, OBJPROP_CORNER, cornerHUD);
     ObjectSet(s, OBJPROP_ANGLE, rotation);
   }
   ObjectSetText(s, time, sizetimerfont, timerfont, colortimerbar);   
}

void DrawText(string l, string t, int x, int y, color c, string f, int s, int k=0, int a=0, bool b=false)
{
   string tag = lhud+TAG+l+x+y;
   ObjectDelete(tag);
   ObjectCreate(tag,OBJ_LABEL,0,0,0);
   ObjectSetText(tag,t,s,f,c);
   ObjectSet(tag,OBJPROP_XDISTANCE,x);
   ObjectSet(tag,OBJPROP_YDISTANCE,y);
   ObjectSet(tag,OBJPROP_CORNER,k);
   ObjectSet(tag,OBJPROP_ANGLE,a);
   if(b) ObjectSet(tag,OBJPROP_BACK,true);
}

string TimeFrameToString(int tf) //code by TRO
{
   string tfs;
   switch(tf) {
      case PERIOD_M1:  tfs="M1"  ; break;
      case PERIOD_M5:  tfs="M5"  ; break;
      case PERIOD_M15: tfs="M15" ; break;
      case PERIOD_M30: tfs="M30" ; break;
      case PERIOD_H1:  tfs="H1"  ; break;
      case PERIOD_H4:  tfs="H4"  ; break;
      case PERIOD_D1:  tfs="D1"  ; break;
      case PERIOD_W1:  tfs="W1"  ; break;
      case PERIOD_MN1: tfs="MN";
   }
   return(tfs);
}

void setHUD()
{
   switch(tf) {
      case PERIOD_M1:  HUDx=7 ; break;
      case PERIOD_M5:  HUDx=7 ; break;
      case PERIOD_M15: HUDx=3 ; break;
      case PERIOD_M30: HUDx=2 ; break;
      case PERIOD_H1:  HUDx=12 ; break;
      case PERIOD_H4:  HUDx=8 ; break;
      case PERIOD_D1 : HUDx=12 ; break;
      case PERIOD_W1:  HUDx=8 ; break;
      case PERIOD_MN1: HUDx=7 ; break;
   }
   if(cornerHUD > 3) cornerHUD=0;
   if(cornerHUD == 0 || cornerHUD == 2) rotation = 90;
   switch(cornerHUD){
      case 0 : hudtfx = posx-HUDx+10;
               hudtfy = posy+18;
               hudarrowx = posx-2;
               hudarrowy = posy+7;
               hudsupx = posx;
               hudsupy = posy;
               huddemx = posx;
               huddemy = posy+56;
               hudtimerx = posx+50;
               hudtimery = posy+72;
               hudtfsx = hudtfx+1;
               hudtfsy = hudtfy+1;
               hudarrowsx = hudarrowx+1;
               hudarrowsy = hudarrowy+1;
               hudsupsx = hudsupx+1;
               hudsupsy = hudsupy+1;
               huddemsx = huddemx+1;
               huddemsy = huddemy+1;
               break;
      case 1 : hudtfx = posx+HUDx;
               hudtfy = posy+18;
               hudarrowx = posx+2;
               hudarrowy = posy+7;
               hudsupx = posx;
               hudsupy = posy;
               huddemx = posx;
               huddemy = posy+56;
               hudtimerx = posx-15;
               hudtimery = posy+71;
               hudtfsx = hudtfx-1;
               hudtfsy = hudtfy+1;
               hudarrowsx = hudarrowx-1;
               hudarrowsy = hudarrowy+1;
               hudsupsx = hudsupx-1;
               hudsupsy = hudsupy+1;
               huddemsx = huddemx-1;
               huddemsy = huddemy+1;
               break;
      case 2 : hudtfx = posx-HUDx;
               hudtfy = posy+20;
               hudarrowx = posx-2;
               hudarrowy = posy+7;
               hudsupx = posx;
               hudsupy = posy+56;
               huddemx = posx;
               huddemy = posy;
               hudtimerx = posx+62;
               hudtimery = posy+3;
               hudtfsx = hudtfx+1;
               hudtfsy = hudtfy-1;
               hudarrowsx = hudarrowx+1;
               hudarrowsy = hudarrowy-1;
               hudsupsx = hudsupx+1;
               hudsupsy = hudsupy-1;
               huddemsx = huddemx+1;
               huddemsy = huddemy-1;
               break;
      case 3 : hudtfx = posx+HUDx;
               hudtfy = posy+20;
               hudarrowx = posx+2;
               hudarrowy = posy+7;
               hudsupx = posx;
               hudsupy = posy+56;
               huddemx = posx;
               huddemy = posy;
               hudtimerx = posx-2;
               hudtimery = posy+3;
               hudtfsx = hudtfx-1;
               hudtfsy = hudtfy-1;
               hudarrowsx = hudarrowx-1;
               hudarrowsy = hudarrowy-1;
               hudsupsx = hudsupx-1;
               hudsupsy = hudsupy-1;
               huddemsx = huddemx-1;
               huddemsy = huddemy-1;
               break;
   }
}

void DoLogo(){
   string TAG = CharToStr(0x61+27)+"II_Logo";
   if( ObjectFind(TAG+"ZZ"+0) >= 0 && ObjectFind(TAG+"ZZ"+1) >= 0 && ObjectFind(TAG+"ZZ"+2) >= 0  && 
       ObjectFind(TAG+"AZ"+0) >= 0 && ObjectFind(TAG+"AZ"+1) >= 0 && ObjectFind(TAG+"AZ"+2) >= 0 ) return;
   string str[3] = {"$","Insanity","Industries"};
   int size[3] = {25,10,10};
   int posx[3] = {47,19,17};
   int posy[3] = {10,25,15};
   int posxs[3] = {46,18,16};
   int posys[3] = {9,24,14};
   for(int i=0;i<3;i++){
      string n = TAG+"ZZ"+i;
      ObjectDelete(n);
      ObjectCreate(n,OBJ_LABEL,0,0,0);
      ObjectSetText(n,str[i],size[i],"Pieces Of Eight",AliceBlue);
      ObjectSet(n,OBJPROP_XDISTANCE,posx[i]);
      ObjectSet(n,OBJPROP_YDISTANCE,posy[i]);
      ObjectSet(n,OBJPROP_CORNER,3);
      n = TAG+"AZ"+i;
      ObjectDelete(n);
      ObjectCreate(n,OBJ_LABEL,0,0,0);
      ObjectSetText(n,str[i],size[i],"Pieces Of Eight",Black);
      ObjectSet(n,OBJPROP_XDISTANCE,posxs[i]);
      ObjectSet(n,OBJPROP_YDISTANCE,posys[i]);
      ObjectSet(n,OBJPROP_CORNER,3);
   }
}

void setVisibility()
{
   int per = Period();
   visible=0;
   if(sametfvis){
  	   if(forcedtf == per || forcedtf == 0){
  	      switch(per){
            case PERIOD_M1:  visible= 0x0001 ; break;
            case PERIOD_M5:  visible= 0x0002 ; break;
            case PERIOD_M15: visible= 0x0004 ; break;
            case PERIOD_M30: visible= 0x0008 ; break;
            case PERIOD_H1:  visible= 0x0010 ; break;
            case PERIOD_H4:  visible= 0x0020 ; break;
            case PERIOD_D1:  visible= 0x0040 ; break;
            case PERIOD_W1:  visible= 0x0080 ; break;
            case PERIOD_MN1: visible= 0x0100 ;  	   
  	      }
  	   }
  	} else {
  	  if(showonm1) visible += 0x0001;
	  if(showonm5) visible += 0x0002;
	  if(showonm15) visible += 0x0004;
	  if(showonm30) visible += 0x0008;
	  if(showonh1) visible += 0x0010;
	  if(showonh4) visible += 0x0020;
	  if(showond1) visible += 0x0040;
	  if(showonw1) visible += 0x0080;
	  if(showonmn) visible += 0x0100;
   }

}