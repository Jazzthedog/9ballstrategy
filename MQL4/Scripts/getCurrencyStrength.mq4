extern int EXT_METRIC = 30; // bars for metric
extern int EXT_METRIC_MIN = 1; // minimum metric value needed for each individual currency

// this function returns the active currencies "strength" value
// it displays the strength value on the active chart's upper left portion of the screen (using Comment function)

double getTrend() {

  // get the active chart's symbol
  string sym = Symbol();

  // get the active chart's
  int per = Period();

	// list all obtainable currency pairs within the array (change array size if need be)
	string ccyList[28] = { "AUDCAD","AUDCHF","AUDJPY","AUDNZD","AUDUSD",
							"CADCHF","CADJPY","CHFJPY","EURAUD","EURCAD",
							"EURCHF","EURGBP","EURJPY","EURNZD","EURUSD",
							"GBPAUD","GBPCAD","GBPCHF","GBPJPY","GBPNZD",
							"GBPUSD","NZDCAD","NZDCHF","NZDJPY","NZDUSD",
							"USDCAD","USDCHF","USDJPY" };

	string quoteCcy, baseCcy, ccy;
	double baseMetric, quoteMetric, metric;

	// now get the active symbol's quote currency...
	string quoteSym = StringSubstr( sym, 0, 3 );
	
	// ... and get the active symbol's base currency.
	string baseSym = StringSubstr( sym, 3, 3 );

	// loop through each element of the currency list array and obtain scores for each individual currency
	for ( int c = 0; c < ArraySize( ccyList ); c += 1 ) {
	
	  // get currency symbol from ccyList array
		ccy = ccyList[c]; 
		
		// see if active symbol contains any individual currency in the selected currency from ccyList
		if ( StringFind( ccy, quoteSym ) > -1 || StringFind( ccy, baseSym ) > -1 ) {
		
		  // get quote currency from current ccyList currency...
			quoteCcy = StringSubstr( ccy, 0, 3 ); 
			
			// ... and get base currency from currenct ccyList currency
			baseCcy = StringSubstr( ccy, 3, 3 ); 
			
			// DEFINE YOUR METRIC HERE (use ccy NOT sym):
			metric = ( iClose( ccy, per, 0 ) - iClose( ccy, per, 1 ) / iATR( ccy, per, EXT_METRIC, 0 ));
			
			if ( quoteCcy == quoteSym ) quoteMetric += metric;
			if ( quoteCcy == baseSym ) baseMetric += metric;
			
			// needs to be subtract for the base currency as any moves down work *for* that currency
			if ( baseCcy == baseSym ) baseMetric += -metric;
			if ( baseCcy == quoteSym ) quoteMetric += -metric;
		}
	}

  // output to active chart - top left part of screen
  // should see something like "EUR 1.03 - CHF 2.14 = -1.11"
  // the total displaying the calculated metric according to how the individual currency fares with other currency pairs
	Comment( quoteSym + " " + DoubleToStr( quoteMetric, 2 ) + " - " + baseSym + " " + DoubleToStr( baseMetric, 2 ) + " = " + DoubleToStr( quoteMetric - baseMetric, 2 ) );

  // return the combined individual currency metric, but test to make sure each individual currency
  // has met the minimum value (could be maximum value if need be, or you can test other constraints on
  // the individual nature of each currency before pushing the combined total out).
	if ( MathAbs( quoteMetric ) > EXT_METRIC_MIN && MathAbs( baseMetric ) > EXT_METRIC_MIN ) return ( quoteMetric - baseMetric );

	return ( 0 );

}