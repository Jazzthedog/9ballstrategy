#property copyright "dimicr"
#property link      "http://www.signalsbg.com"
#property show_inputs // ������� �� extern-������

#include <OrderReliable_V1_1_1.mqh>
//+------------------------------------------------------------------+
extern int    Interest   = 20;  // �������� �� FreeMargin
extern int    DistSL     = 15;   // ���������� �� SL
extern int    DistTP     = 150;   // ���������� �� TP
extern bool   StopLoss   = true; // �� ��� �� �������
extern bool   TakeProfit = false; // �� ��� �� ����������
//+------------------------------------------------------------------+
void start() 
{
int    ticket;
double SL=0,TP=0;
int    Dgts=MarketInfo(Symbol(),MODE_DIGITS);     
   if(StopLoss==true) SL=Ask-DistSL*Point;
   if(TakeProfit==true) TP=Ask+DistTP*Point;
   ticket=OrderSendReliableMKT(Symbol(),OP_BUY,LotsOptimized(),Ask,Ask-Bid,
                    NormalizeDouble(SL,Dgts),
                    NormalizeDouble(TP,Dgts),
                    "Hotkey",123456,0,CLR_NONE);
   if(ticket<=0) Alert("Error Open_BUY: ",ErrorDescription(OrderReliableLastErr())); 
   return(0);
}
//+------------------------------------------------------------------+


double LotsOptimized()
{
//----
   double Lots=NormalizeDouble(AccountBalance()*Interest/100000.0,1);
   if(AccountFreeMargin()<(1000*Lots)){Lots=NormalizeDouble(AccountFreeMargin()*Interest/100000.0,1);}
   if(Lots>MarketInfo(Symbol(),MODE_MAXLOT)){Lots=MarketInfo(Symbol(),MODE_MAXLOT);}
   if(Lots<MarketInfo(Symbol(),MODE_MINLOT)){Lots=MarketInfo(Symbol(),MODE_MINLOT);}
//----
   return(Lots);
}