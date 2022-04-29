


//+------------------------------------------------------------------+
//|                                           (SendPendingOrder).mq4 |
//|                                      Copyright © 2005, komposter |
//|                                      mailto:komposterius@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, komposter"
#property link      "mailto:komposterius@mail.ru"

/*
-----------------------------Â-Í-È-Ì-À-Í-È-Å---------------------------------
Ïåðåä çàïóñêîì ñêðèïòà íàñòîÿòåëüíî ðåêîìåíäóþ èçó÷èòü ñëåäóþùåå ðóêîâîäñòâî:

Ñêðèïò ïðåäíàçíà÷åí äëÿ óñòàíîâêè îòëîæåííîãî îðäåðà.
Äëÿ ýòîãî íåîáõîäèìî:
 1) Îçíàêîìèòüñÿ ñ äàííûì ðóêîâîäñòâîì =), !óñòàíîâèòü çíà÷åíèÿ ïî óìîë÷àíèþ! (íàõîäÿòñÿ ïîä îïèñàíèåì,
 	 íà÷èíàþòñÿ è çàêàí÷èâàþòñÿ ñòðîêîé //+----------------------------------------------+ ),
 	 ðàçðåøèòü èìïîðò âíåøíèõ ýêñïåðòîâ ÷åðåç ìåíþ
 	 "Ñåðâèñ" -> "Íàñòðîéêè" -> "Ñîâåòíèêè" -> "Ðàçðåøèòü èìïîðòèðîâàíèå âíåøíèõ ýêñïåðòîâ"
 	 (íåîáõîäèìî äëÿ îïèñàíèÿ îøèáêè, êîòîðàÿ ìîæåò âîçíèêíóòü ïðè óñòàíîâêå îðäåðà)
 2) Ïåðåòàùèòü ñêðèïò íà ãðàôèê. Ïðè ýòîì ó÷èòûâàòü, ÷òî ìåñòî ïðèêðåïëåíèÿ - ýòî áóäóùàÿ
 	 öåíà îòêðûòèÿ (OpenPrice). Â ïðîöåññå óñòàíîâêè å¸ ìîæíî áóäåò ìåíÿòü, íî äëÿ óïðîùåíèÿ
 	 ðàáîòû ðåêîìåíäóþ ïåðåòàñêèâàòü ñêðèïò ñðàçó íà íóæíûé óðîâåíü.
 3) Ïåðåìåñòèòü âñå ëèíèè íà íåîáõîäèìûå óðîâíè:
		- Open_Price_Line (ïî óìîë÷àíèþ - áåëàÿ) - öåíà îòêðûòèÿ  (ÎÁßÇÀÒÅËÜÍÀß ëèíèÿ)
		- Stop_Loss_Line (êðàñíàÿ) - óðîâåíü Ñòîï Ëîññ (ÎÁßÇÀÒÅËÜÍÀß)
		- Take_Profit_Line (çåë¸íàÿ) - óðîâåíü Òåéê Ïðîôèò (íåîáÿçàòåëüíàÿ)
		- Expiration_Line (æ¸ëòàÿ) - âðåìÿ èñòå÷åíèÿ (íåîáÿçàòåëüíàÿ)
		(íåîáÿçàòåëüíûå ëèíèè ìîæíî óäàëÿòü)
		- "````" - ðàçìåð ïîçèöèè. Íåîáõîäèìî óñòàíîâèòü íàïðîòèâ íóæíîãî çíà÷åíèÿ (îò 0,1 äî 10 ëîòîâ)
	Â çàâèñèìîñòè îò ðàñïîëîæåíèÿ ëèíèé Open_Price è Stop_Loss âûáèðàåòñÿ òèï îðäåðà:
	Open_Price  >  Bid è Open_Price  >  Stop_Loss  -  BUYSTOP-îðäåð,
	Open_Price  >  Bid è Open_Price  <  Stop_Loss  -  SELLLIMIT-îðäåð,
	Open_Price  <  Ask è Open_Price  >  Stop_Loss  -  BUYLIMIT-îðäåð,
	Open_Price  <  Ask è Open_Price  <  Stop_Loss  -  SELLSTOP-îðäåð.
 4) Êîãäà âñ¸ áóäåò ãîòîâî, â ïîÿâèâøåìñÿ îêíå íàæàòü êíîïêó "ÎÊ".
 
 
 Äëÿ ïðåêðàùåíèÿ ðàáîòû ñêðèïòà â ëþáîé ìîìåíò ìîæíî âîñïîëüçîâàòüñÿ êíîïêîé "Îòìåíà".
 Åñëè Âàìè áóäåò íàéäåíà îøèáêà â êîäå, èëè â ëîãèêå ðàáîòû ñêðèïòà, ïðîñüáà ñîîáùèòü íà komposterius@mail.ru
*/
//+------------------------------------------------------------------+
// Âñå íèæåîïèñàííûå ïåðåìåííûå ìîæíî áóäåò èçìåíèòü â îêíå ñâîéñòâ ñêðèïòà,
// êîòîðîå îòêðîåòñÿ ïðè ïðèêðåïëåíèè. Ýòî ïîëåçíî, íàïðèìåð, ïðè íåîáõîäèìîñòè âûáðàòü
// íåïðåäñòàâëåííûé â ñïèñêå "Lots" ðàçìåð ïîçèöèè. Äëÿ ýòîãî, íàïèñàâ íóæíóþ öèôðó â îêíå ñâîéñòâ (íàïðèìåð, 1.5),
// ÍÅ ÄÂÈÃÀÉÒÅ óêàçàòåëü ðàçìåðà ëîòà ( "````" ).
// Åñëè îêíî ñâîéñòâ íå íóæíî, íàäî çàêîììåíòèðîâàòü ñëåäóþùóþ ñòðîêó (ïîñòàâèòü â íà÷àëî //)
#property show_inputs


// Òèï îðäåðà ïî óìîë÷àíèþ (âëèÿåò íà íà÷àëüíîå ðàñïîëîæåíèå ëèíèé ñòîï-ëîññ è òåéê-ïðîôèò)
extern int _OrderType = 1; //( "1" - BUYSTOP èëè BUYLIMIT, "-1" - SELLSTOP èëè SELLLIMIT )

// Îáü¸ì ñäåëêè ïî óìîë÷àíèþ (ìîæíî ìåíÿòü â ïðîöåññå ðàáîòû)
// îò 0.1 äî 1.0 ñ øàãîì 0.1, îò 1 äî 10 ñ øàãîì 1
extern double Lots = 0.1;

// Ðàññòîÿíèå ìåæäó ëèíèåé Take_Profit/Stop_Loss è ëèíèåé Open_Price â ïóíêòàõ ïî óìîë÷àíèþ.
// Åñëè Take_Profit èñïîëüçîâàòüñÿ íå áóäåò, óñòàíîâèòå 0
extern int Stop_Loss = 50;
extern int Take_Profit = 50;

// Ìàêñèìàëüíîå îòêëîíåíèå îò çàïðîøåííîé öåíû
extern int Slippage = 5;

// Êîììåíòàðèé ê îðäåðó
extern string _Comment = "Opened by script";

// Order ID
extern int MagicNumber = 0;

// Âðåìÿ èñòå÷åíèÿ îðäåðà, âûðàæåííîå â ñâå÷àõ
// Äëÿ ïåðèîäà ãðàôèêà H4 è Expiration_Shift = 3 âðåìÿ èñòå÷åíèÿ íàñòóïèò ÷åðåç 12 ÷àñîâ ïîñëå óñòàíîâêè
// Åñëè íåîáõîäèìî ñòàíäàðòíîå âðåìÿ èñòå÷åíèÿ äëÿ âñåõ ïåðèîäîâ ãðàôèêà, óêàæèòå "0" (áåç êàâû÷åê), è ïåðåõîäèòå ê ñëåäóþùåé íàñòðîéêå
// Åñëè âðåìÿ èñòå÷åíèÿ îðäåðà èñïîëüçîâàòüñÿ íå áóäåò, óñòàíîâèòå 0
extern int Expiration_Shift = 0;
// Âðåìÿ èñòå÷åíèÿ îðäåðà, âûðàæåííîå â ÷àñàõ
// Äëÿ òîãî, ÷òîá èñïîëüçîâàòü ýòó íàñòðîéêó, íåîáõîäèìî óñòàíîâèòü Expiration_Shift (ñì. âûøå íà 2 ñòðîêè) "0" (áåç êàâû÷åê)
// Åñëè âðåìÿ èñòå÷åíèÿ îðäåðà èñïîëüçîâàòüñÿ íå áóäåò, óñòàíîâèòå 0
extern int Expiration_Shift_H = 0;

extern string Order_Color = "----------------------------------------------------------------------------------------";
// Öâåòà îòîáðàæåíèÿ îðäåðîâ íà ãðàôèêå
extern color Buy_Color = Lime; //( äëÿ îðäåðîâ BUYSTOP è BUYLIMIT )
extern color Sell_Color = Red; //( äëÿ îðäåðîâ SELLLIMIT è SELLSTOP )

extern string Line_Color = "----------------------------------------------------------------------------------------";
// Öâåòà ëèíèé:
extern color Open_Price_Line_Color = White;
extern color Stop_Loss_Line_Color = Red;
extern color Take_Profit_Line_Color = Lime;
extern color Expiration_Line_Color = Yellow;

//+------------------------------------------------------------------+

#include <stdlib.mqh>
int first = 1;
int start()
{
// Óñòàíîâêà íà÷àëüíûõ çíà÷åíèé:
double Open_Price_Level, Stop_Loss_Level, Take_Profit_Level;
datetime Expiration_Time;
// ---Open_Price_Level
	Open_Price_Level = PriceOnDropped();
	if ( Open_Price_Level <= 0 )
		{ Open_Price_Level = Bid + MarketInfo( Symbol(), MODE_STOPLEVEL )*Point; }
// ---Stop_Loss_Level
	Stop_Loss_Level = Open_Price_Level - Stop_Loss * Point;
// ---Take_Profit_Level
	if ( Take_Profit > 0 )
	{ Take_Profit_Level = Open_Price_Level + Take_Profit * Point; }

if ( _OrderType == -1 )
{
// ---Open_Price_Level
	Open_Price_Level = PriceOnDropped();
	if ( Open_Price_Level <= 0 )
		{ Open_Price_Level = Ask - MarketInfo( Symbol(), MODE_STOPLEVEL )*Point; }
// ---Stop_Loss_Level
	Stop_Loss_Level = Open_Price_Level + Stop_Loss * Point;
// ---Take_Profit_Level
	if ( Take_Profit > 0 )
	{ Take_Profit_Level = Open_Price_Level - Take_Profit * Point; }
}

// ---Expiration_Time
	if ( Expiration_Shift > 0 )
	{ Expiration_Time = CurTime() + Period()*60*Expiration_Shift; }
	else
	{
		if ( Expiration_Shift_H > 0 )
			{ Expiration_Time = CurTime() + 3600*Expiration_Shift_H; }
	}
// Ñîçäàíèå ëèíèé:
if ( first == 1 )
{
	ObjectCreate( "Open_Price_Line", OBJ_HLINE, 0, 0, Open_Price_Level, 0, 0, 0, 0 );
	ObjectSet( "Open_Price_Line", OBJPROP_COLOR, Open_Price_Line_Color );
	ObjectSetText( "Open_Price_Line", "Open_Price_Line", 6, "Arial", Open_Price_Line_Color );

	ObjectCreate( "Stop_Loss_Line", OBJ_HLINE, 0, 0, Stop_Loss_Level, 0, 0, 0, 0 );
	ObjectSet( "Stop_Loss_Line", OBJPROP_COLOR, Stop_Loss_Line_Color );
	ObjectSetText( "Stop_Loss_Line", "Stop_Loss_Line", 6, "Arial", Stop_Loss_Line_Color );

	if ( Take_Profit_Level > 0 )
	{
		ObjectCreate( "Take_Profit_Line", OBJ_HLINE, 0, 0, Take_Profit_Level, 0, 0, 0, 0 );
		ObjectSet( "Take_Profit_Line", OBJPROP_COLOR, Take_Profit_Line_Color );
		ObjectSetText( "Take_Profit_Line", "Take_Profit_Line", 6, "Arial", Take_Profit_Line_Color );
	}

	if ( Expiration_Time > 0 )
	{
		ObjectCreate( "Expiration_Line", OBJ_VLINE, 0, Expiration_Time, 0, 0, 0, 0, 0 );
		ObjectSet( "Expiration_Line", OBJPROP_COLOR, Expiration_Line_Color );
		ObjectSetText( "Expiration_Line", "Expiration_Line", 6, "Arial", Expiration_Line_Color );
	}
// ñîçäàíèå "Øêàëû ðàçìåðà ëîòà" è óñòàíîâêà íà çíà÷åíèå ïî óìîë÷àíèþ
	int Lots_value_y = 30;
	switch ( Lots )
	{
		case 0.2: Lots_value_y = 45; break;
		case 0.3: Lots_value_y = 60; break;
		case 0.4: Lots_value_y = 75; break;
		case 0.5: Lots_value_y = 90; break;
		case 0.6: Lots_value_y = 105; break;
		case 0.7: Lots_value_y = 120; break;
		case 0.8: Lots_value_y = 135; break;
		case 0.9: Lots_value_y = 150; break;
		case 1.0: Lots_value_y = 165; break;
		case 2.0: Lots_value_y = 180; break;
		case 3.0: Lots_value_y = 195; break;
		case 4.0: Lots_value_y = 210; break;
		case 5.0: Lots_value_y = 225; break;
		case 6.0: Lots_value_y = 240; break;
		case 7.0: Lots_value_y = 255; break;
		case 8.0: Lots_value_y = 270; break;
		case 9.0: Lots_value_y = 285; break;
		case 10.0: Lots_value_y = 300; break;
	}
	if ( Lots > 10.0 ) Lots_value_y = 315;
	int Lots_value_y_start_position = Lots_value_y;
	
	ObjectCreate( "Lots", OBJ_LABEL, 0,0,0,0,0,0,0);
	ObjectSet( "Lots", OBJPROP_CORNER, 1);
	ObjectSet( "Lots", OBJPROP_XDISTANCE, 1);
	ObjectSet( "Lots", OBJPROP_YDISTANCE, 10);
	ObjectSetText(  "Lots", "Lots", 10, "Arial", Open_Price_Line_Color);

	ObjectCreate( "Lots_value", OBJ_LABEL, 0,0,0,0,0,0,0);
	ObjectSet( "Lots_value", OBJPROP_CORNER, 1);
	ObjectSet( "Lots_value", OBJPROP_XDISTANCE, 25);
	ObjectSet( "Lots_value", OBJPROP_YDISTANCE, Lots_value_y);
	ObjectSetText(  "Lots_value", "`````", 10, "Arial", Open_Price_Line_Color);

	int y = 25;
	for ( double z = 0.1; z <= 1; z += 0.1 )
	{
		ObjectCreate( DoubleToStr( z, 1 ), OBJ_LABEL, 0,0,0,0,0,0,0);
		ObjectSet( DoubleToStr( z, 1 ), OBJPROP_CORNER, 1);
		ObjectSet( DoubleToStr( z, 1 ), OBJPROP_XDISTANCE, 1);
		ObjectSet( DoubleToStr( z, 1 ), OBJPROP_YDISTANCE, y);
		ObjectSetText(  DoubleToStr( z, 1 ), DoubleToStr( z, 1 ), 10, "Arial", Open_Price_Line_Color);
		y += 15;
	}
	y = 160;
	for ( z = 1; z <= 10; z ++ )
	{
		ObjectCreate( DoubleToStr( z, 1 ), OBJ_LABEL, 0,0,0,0,0,0,0);
		ObjectSet( DoubleToStr( z, 1 ), OBJPROP_CORNER, 1);
		ObjectSet( DoubleToStr( z, 1 ), OBJPROP_XDISTANCE, 1);
		ObjectSet( DoubleToStr( z, 1 ), OBJPROP_YDISTANCE, y);
		ObjectSetText(  DoubleToStr( z, 1 ), DoubleToStr( z, 1 ), 10, "Arial", Open_Price_Line_Color);
		y += 15;
	}
	ObjectCreate( ">", OBJ_LABEL, 0,0,0,0,0,0,0);
	ObjectSet( ">", OBJPROP_CORNER, 1);
	ObjectSet( ">", OBJPROP_XDISTANCE, 1);
	ObjectSet( ">", OBJPROP_YDISTANCE, 310);
	ObjectSetText(  ">", ">10", 10, "Arial", Open_Price_Line_Color);

// âûâîä ìåññåäæáîêñà
	string Question = "Äëÿ óñòàíîâêè îðäåðà ïåðåìåñòèòå ëèíèè íà íåîáõîäèìûå óðîâíè è íàæìèòå \"ÎÊ\".\n" + 
							"×òîá îòêàçàòüñÿ îò óñòàíîâêè, íàæìèòå \"Îòìåíà\".";
	int  Answer = MessageBox( Question, "Óñòàíîâêà îòëîæåííîãî îðäåðà", 0x00000001 | 0x00000040 | 0x00040000 );
	first = 0;
	// åñëè íàæàòà ëþáàÿ êðîìå "ÎÊ" êíîïêà - âûõîäèì
	if ( Answer != 1 ) { deinit(); return(0); }
}

// ñ÷èòûâàåì çíà÷åíèÿ ñ îáúåêòîâ è íîðìàëèçóåì:

// ðàçìåð ëîòà
	Lots_value_y = ObjectGet( "Lots_value", OBJPROP_YDISTANCE );
	if ( Lots_value_y_start_position != Lots_value_y )
	{
		Lots = 0.1;
		if ( Lots_value_y >= 35  && Lots_value_y < 50  ) Lots = 0.2;
		if ( Lots_value_y >= 50  && Lots_value_y < 65  ) Lots = 0.3;
		if ( Lots_value_y >= 65  && Lots_value_y < 80  ) Lots = 0.4;
		if ( Lots_value_y >= 80  && Lots_value_y < 95  ) Lots = 0.5;
		if ( Lots_value_y >= 95  && Lots_value_y < 110 ) Lots = 0.6;
		if ( Lots_value_y >= 110 && Lots_value_y < 125 ) Lots = 0.7;
		if ( Lots_value_y >= 125 && Lots_value_y < 140 ) Lots = 0.8;
		if ( Lots_value_y >= 140 && Lots_value_y < 155 ) Lots = 0.9;
		if ( Lots_value_y >= 155 && Lots_value_y < 170 ) Lots = 1.0;
		if ( Lots_value_y >= 170 && Lots_value_y < 185 ) Lots = 2.0;
		if ( Lots_value_y >= 185 && Lots_value_y < 200 ) Lots = 3.0;
		if ( Lots_value_y >= 200 && Lots_value_y < 215 ) Lots = 4.0;
		if ( Lots_value_y >= 215 && Lots_value_y < 230 ) Lots = 5.0;
		if ( Lots_value_y >= 230 && Lots_value_y < 245 ) Lots = 6.0;
		if ( Lots_value_y >= 245 && Lots_value_y < 260 ) Lots = 7.0;
		if ( Lots_value_y >= 260 && Lots_value_y < 275 ) Lots = 8.0;
		if ( Lots_value_y >= 275 && Lots_value_y < 290 ) Lots = 9.0;
		if ( Lots_value_y >= 290 							  ) Lots = 10.0;
	}
	Lots = NormalizeDouble( Lots, 1 );
// Open_Price
	Open_Price_Level = NormalizeDouble( ObjectGet( "Open_Price_Line", OBJPROP_PRICE1 ), MarketInfo( Symbol(), MODE_DIGITS ) );
// Stop_Loss
	Stop_Loss_Level = NormalizeDouble( ObjectGet( "Stop_Loss_Line", OBJPROP_PRICE1 ), MarketInfo( Symbol(), MODE_DIGITS ) );
// Take_Profit
	Take_Profit_Level = NormalizeDouble( ObjectGet( "Take_Profit_Line", OBJPROP_PRICE1 ), MarketInfo( Symbol(), MODE_DIGITS ) );
// Expiration_Time
	Expiration_Time = ObjectGet( "Expiration_Line", OBJPROP_TIME1 );
	
// îïðåäåëÿåì òèï îðäåðà
	if ( Open_Price_Level - Bid >= 0 )
	{
		if ( Open_Price_Level - Stop_Loss_Level > 0 )
		{ _OrderType = OP_BUYSTOP; }
		else
		{ _OrderType = OP_SELLLIMIT; }
	}
	else
	{
		if ( Open_Price_Level - Stop_Loss_Level > 0 )
		{ _OrderType = OP_BUYLIMIT; }
		else
		{ _OrderType = OP_SELLSTOP; }
	}

color _Color;
// ïðîâåðÿåì âñå çíà÷åíèÿ
	if ( _OrderType == OP_BUYLIMIT || _OrderType == OP_BUYSTOP )
	{
		_Color = Buy_Color;
		if ( Open_Price_Level - Stop_Loss_Level < MarketInfo( Symbol(), MODE_STOPLEVEL )*Point )
		{
			Answer = MessageBox(  "Íåïðàâèëüíî óñòàíîâëåíà Stop_Loss_Line (êðàñíàÿ ëèíèÿ)!\n" + 
					 		 			 "\n" +
					 		 			 "Äëÿ BuyLimit è BuyStop - îðäåðîâ îíà äîëæíà áûòü ÍÈÆÅ ëèíèè Open_Price_Line.	\n" + 
					 		 			 "Ìèíèìàëüíûé îòñòóï (" + Symbol() + ") - " + DoubleToStr( MarketInfo( Symbol(), MODE_STOPLEVEL ), 0 ) + " ïóíêòîâ.\n" + 
					 		 			 "\n\n" +
					 		 			 "×òîáû íà÷àòü óñòàíîâêó ñ íà÷àëà, íàæìèòå \"Ïîâòîð\".\n" +
					 		 			 "×òîá îòêàçàòüñÿ îò óñòàíîâêè, íàæìèòå \"Îòìåíà\".", "Óñòàíîâêà îòëîæåííîãî îðäåðà", 0x00000005 | 0x00000030 | 0x00040000 );
			if ( Answer == 4 ) { ObjectsRedraw(); start(); }
			deinit();
			return(-1);
		}
		if ( Take_Profit_Level - Open_Price_Level < MarketInfo( Symbol(), MODE_STOPLEVEL )*Point && Take_Profit_Level > 0 )
		{
			Answer = MessageBox(  "Íåïðàâèëüíî óñòàíîâëåíà Take_Profit_Line (çåë¸íàÿ ëèíèÿ)!\n" + 
					 		 			 "\n" +
					 		 			 "Äëÿ BuyLimit è BuyStop - îðäåðîâ îíà äîëæíà áûòü ÂÛØÅ ëèíèè Open_Price_Line.	\n" + 
					 		 			 "Ìèíèìàëüíûé îòñòóï (" + Symbol() + ") - " + DoubleToStr( MarketInfo( Symbol(), MODE_STOPLEVEL ), 0 ) + " ïóíêòîâ.\n" + 
					 		 			 "\n\n" +
					 		 			 "×òîáû íà÷àòü óñòàíîâêó ñ íà÷àëà, íàæìèòå \"Ïîâòîð\".\n" +
					 		 			 "×òîá îòêàçàòüñÿ îò óñòàíîâêè, íàæìèòå \"Îòìåíà\".", "Óñòàíîâêà îòëîæåííîãî îðäåðà", 0x00000005 | 0x00000030 | 0x00040000 );
			if ( Answer == 4 ) { ObjectsRedraw(); start(); }
			deinit();
			return(-1);
		}
		if ( _OrderType == OP_BUYSTOP )
		{
			if ( Open_Price_Level - Bid < MarketInfo( Symbol(), MODE_STOPLEVEL )*Point )
			{
				Answer = MessageBox( "Íåïðàâèëüíî óñòàíîâëåíà Open_Price_Line (áåëàÿ ëèíèÿ)!\n" + 
					 		 			 	"\n" +
					 		 			 	"Äëÿ BuyStop - îðäåðà îíà äîëæíà áûòü ÂÛØÅ òåêóùåé öåíû.	\n" + 
					 		 			 	"Ìèíèìàëüíûé îòñòóï (" + Symbol() + ") - " + DoubleToStr( MarketInfo( Symbol(), MODE_STOPLEVEL ), 0 ) + " ïóíêòîâ.\n" + 
					 		 			 	"\n\n" +
					 		 			 	"×òîáû íà÷àòü óñòàíîâêó ñ íà÷àëà, íàæìèòå \"Ïîâòîð\".\n" +
					 		 			 	"×òîá îòêàçàòüñÿ îò óñòàíîâêè, íàæìèòå \"Îòìåíà\".", "Óñòàíîâêà îòëîæåííîãî îðäåðà", 0x00000005 | 0x00000030 | 0x00040000 );
				if ( Answer == 4 ) { ObjectsRedraw(); start(); }
				deinit();
				return(-1);
			}
		}
		else
		{
			if ( Bid - Open_Price_Level < MarketInfo( Symbol(), MODE_STOPLEVEL )*Point )
			{
				Answer = MessageBox( "Íåïðàâèëüíî óñòàíîâëåíà Open_Price_Line (áåëàÿ ëèíèÿ)!\n" + 
					 		 			 	"\n" +
					 		 			 	"Äëÿ BuyLimit - îðäåðà îíà äîëæíà áûòü ÍÈÆÅ òåêóùåé öåíû.	\n" + 
					 		 			 	"Ìèíèìàëüíûé îòñòóï (" + Symbol() + ") - " + DoubleToStr( MarketInfo( Symbol(), MODE_STOPLEVEL ), 0 ) + " ïóíêòîâ.\n" + 
					 		 			 	"\n\n" +
					 		 			 	"×òîáû íà÷àòü óñòàíîâêó ñ íà÷àëà, íàæìèòå \"Ïîâòîð\".\n" +
					 		 			 	"×òîá îòêàçàòüñÿ îò óñòàíîâêè, íàæìèòå \"Îòìåíà\".", "Óñòàíîâêà îòëîæåííîãî îðäåðà", 0x00000005 | 0x00000030 | 0x00040000 );
				if ( Answer == 4 ) { ObjectsRedraw(); start(); }
				deinit();
				return(-1);
			}
		}
	}
	if ( _OrderType == OP_SELLLIMIT || _OrderType == OP_SELLSTOP )
	{
		_Color = Sell_Color;
		if ( Stop_Loss_Level - Open_Price_Level < MarketInfo( Symbol(), MODE_STOPLEVEL )*Point )
		{
			Answer = MessageBox(  "Íåïðàâèëüíî óñòàíîâëåíà Stop_Loss_Line (êðàñíàÿ ëèíèÿ)!\n" + 
					 		 			 "\n" +
					 		 			 "Äëÿ SellLimit è SellStop - îðäåðîâ îíà äîëæíà áûòü ÂÛØÅ ëèíèè Open_Price_Line.	\n" + 
					 		 			 "Ìèíèìàëüíûé îòñòóï (" + Symbol() + ") - " + DoubleToStr( MarketInfo( Symbol(), MODE_STOPLEVEL ), 0 ) + " ïóíêòîâ.\n" + 
					 		 			 "\n\n" +
					 		 			 "×òîáû íà÷àòü óñòàíîâêó ñ íà÷àëà, íàæìèòå \"Ïîâòîð\".\n" +
					 		 			 "×òîá îòêàçàòüñÿ îò óñòàíîâêè, íàæìèòå \"Îòìåíà\".", "Óñòàíîâêà îòëîæåííîãî îðäåðà", 0x00000005 | 0x00000030 | 0x00040000 );
			if ( Answer == 4 ) { ObjectsRedraw(); start(); }
			deinit();
			return(-1);
		}
		if ( Open_Price_Level - Take_Profit_Level < MarketInfo( Symbol(), MODE_STOPLEVEL )*Point && Take_Profit_Level > 0 )
		{
			Answer = MessageBox(  "Íåïðàâèëüíî óñòàíîâëåíà Take_Profit_Line (çåë¸íàÿ ëèíèÿ)!\n" + 
					 		 			 "\n" +
					 		 			 "Äëÿ SellLimit è SellStop - îðäåðîâ îíà äîëæíà áûòü ÍÈÆÅ ëèíèè Open_Price_Line.	\n" + 
					 		 			 "Ìèíèìàëüíûé îòñòóï (" + Symbol() + ") - " + DoubleToStr( MarketInfo( Symbol(), MODE_STOPLEVEL ), 0 ) + " ïóíêòîâ.\n" + 
					 		 			 "\n\n" +
					 		 			 "×òîáû íà÷àòü óñòàíîâêó ñ íà÷àëà, íàæìèòå \"Ïîâòîð\".\n" +
					 		 			 "×òîá îòêàçàòüñÿ îò óñòàíîâêè, íàæìèòå \"Îòìåíà\".", "Óñòàíîâêà îòëîæåííîãî îðäåðà", 0x00000005 | 0x00000030 | 0x00040000 );
			if ( Answer == 4 ) { ObjectsRedraw(); start(); }
			deinit();
			return(-1);
		}
		if ( _OrderType == OP_SELLLIMIT )
		{
			if ( Open_Price_Level - Ask < MarketInfo( Symbol(), MODE_STOPLEVEL )*Point )
			{
				Answer = MessageBox( "Íåïðàâèëüíî óñòàíîâëåíà Open_Price_Line (áåëàÿ ëèíèÿ)!\n" + 
					 		 			 	"\n" +
					 		 			 	"Äëÿ SellLimit - îðäåðà îíà äîëæíà áûòü ÍÈÆÅ òåêóùåé öåíû.	\n" + 
					 		 			 	"Ìèíèìàëüíûé îòñòóï (" + Symbol() + ") - " + DoubleToStr( MarketInfo( Symbol(), MODE_STOPLEVEL ), 0 ) + " ïóíêòîâ.\n" + 
					 		 			 	"\n\n" +
					 		 			 	"×òîáû íà÷àòü óñòàíîâêó ñ íà÷àëà, íàæìèòå \"Ïîâòîð\".\n" +
					 		 			 	"×òîá îòêàçàòüñÿ îò óñòàíîâêè, íàæìèòå \"Îòìåíà\".", "Óñòàíîâêà îòëîæåííîãî îðäåðà", 0x00000005 | 0x00000030 | 0x00040000 );
				if ( Answer == 4 ) { ObjectsRedraw(); start(); }
				deinit();
				return(-1);
			}
		}
		else
		{
			if ( Ask - Open_Price_Level < MarketInfo( Symbol(), MODE_STOPLEVEL )*Point )
			{
				Answer = MessageBox( "Íåïðàâèëüíî óñòàíîâëåíà Open_Price_Line (áåëàÿ ëèíèÿ)!\n" + 
					 		 			 	"\n" +
					 		 			 	"Äëÿ SellStop - îðäåðà îíà äîëæíà áûòü ÂÛØÅ òåêóùåé öåíû.	\n" + 
					 		 			 	"Ìèíèìàëüíûé îòñòóï (" + Symbol() + ") - " + DoubleToStr( MarketInfo( Symbol(), MODE_STOPLEVEL ), 0 ) + " ïóíêòîâ.\n" + 
					 		 			 	"\n\n" +
					 		 			 	"×òîáû íà÷àòü óñòàíîâêó ñ íà÷àëà, íàæìèòå \"Ïîâòîð\".\n" +
					 		 			 	"×òîá îòêàçàòüñÿ îò óñòàíîâêè, íàæìèòå \"Îòìåíà\".", "Óñòàíîâêà îòëîæåííîãî îðäåðà", 0x00000005 | 0x00000030 | 0x00040000 );
				if ( Answer == 4 ) { ObjectsRedraw(); start(); }
				deinit();
				return(-1);
			}
		}
	}

	if ( Expiration_Time <= CurTime() && Expiration_Time > 0 )
	{
			Answer = MessageBox(  "Íåïðàâèëüíî óñòàíîâëåíà Expiration_Line (æ¸ëòàÿ ëèíèÿ)!\n" + 
					 		 			 "\n" +
					 		 			 "Ñðîê èñòå÷åíèÿ îðäåðà íå ìîæåò áûòü â ïðîøåäøåì âðåìåíè!		\n" + 
					 		 			 "\n\n" +
					 		 			 "×òîáû íà÷àòü óñòàíîâêó ñ íà÷àëà, íàæìèòå \"Ïîâòîð\".\n" +
					 		 			 "×òîá îòêàçàòüñÿ îò óñòàíîâêè, íàæìèòå \"Îòìåíà\".", "Óñòàíîâêà îòëîæåííîãî îðäåðà", 0x00000005 | 0x00000030 | 0x00040000 );
			if ( Answer == 4 ) { ObjectsRedraw(); start(); }
			deinit();
			return(-1);
	}
	
// âûâîäèì èíôó î çàïðîñå è ïûòàåìñÿ óñòàíîâèòü îðäåð
	Print( "Symbol=",Symbol(), ",_OrderType=",_OrderType, ",Lots=",Lots, ",Open_Price_Level=",Open_Price_Level, ",Slippage=", Slippage, ",Stop_Loss_Level=", Stop_Loss_Level, ",Take_Profit_Level=", Take_Profit_Level, ",_Comment=", _Comment, ",MagicNumber=", MagicNumber, ",Expiration_Time=", Expiration_Time, ",_Color=", _Color );
	int ordersend = OrderSend( Symbol(), _OrderType, Lots, Open_Price_Level, Slippage, Stop_Loss_Level, Take_Profit_Level, _Comment, MagicNumber, Expiration_Time, _Color );
	if ( ordersend > 0 )
	{
// åñëè âñ¸ îê, âûâîäèì ëîã è âûõîäèì
		OrderPrint();
		Print( "Îðäåð ¹", ordersend, " óñòàíîâëåí óñïåøíî!");
		return(0);
	}
// åñëè îøèáêà - âûâîäèì ñîîáùåíèå è âûõîäèì
	int error = GetLastError();
	Print("Îøèáêà ïðè óñòàíîâêå! GetLastError = ", error, ", ErrorDescription =  \"", ErrorDescription( error ), "\"" );
	MessageBox( "Îøèáêà ïðè óñòàíîâêå! GetLastError = " + error + ", ErrorDescription = \"" + ErrorDescription( error ) + "\"", 
             	 	"Îøèáêà óñòàíîâêè îðäåðà", 0x00000000 | 0x00000010 | 0x00040000 ); 
return(-1);
}

int deinit()
{
// óäàëåíèå âñåõ îáúåêòîâ, ñîçäàííûõ ñêðèïòîì
	ObjectDelete( "Open_Price_Line" );
	ObjectDelete( "Stop_Loss_Line" );
	ObjectDelete( "Take_Profit_Line" );
	ObjectDelete( "Expiration_Line" );

	for ( double z = 0.1; z <= 1; z += 0.1 )
	{ ObjectDelete( DoubleToStr( z, 1 )); }
	for ( z = 1; z <= 10; z ++ )
	{ ObjectDelete( DoubleToStr( z, 1 )); }
	ObjectDelete( "Lots" );
	ObjectDelete( "Lots_value" );
	ObjectDelete( ">" );
return(0);
}



