//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+

#ifndef GLOBAL_ARRAYS_INCLUDED
#define GLOBAL_ARRAYS_INCLUDED
int MaxBars = 30;
int LookBack = 5000;
//--
int actualCopied;
//---  Symbol , Timeframe
string currentSymbol;
ENUM_TIMEFRAMES currentTimeframe;
//--- Main indicator arrays
double FirstCycleAfter_X[];       // Declaration only
double FirstCycleAfter_DADturns[];
double MT_ReloadPattern[];
double ST_ReloadPattern[];
double MT_Rubberband[];
double ST_Rubberband[];
double Momentum_Divergence_Partial[];  // Only for Maxbars  -> changed to LookBack
double Momentum_Divergence_Full[];     // Only for Maxbars  -> changed to LookBack
double LT_Conservative[];
double MT_Trend_Cont[];      // Only for Maxbars  -> changed to LookBack
double MT_Trend_Reversal[];  // Only for Maxbars  -> changed to LookBack
double MT_MOM_Wave3[];
double MT_MOM_Wave2[];
double X_Marks_the_spot[];
double ImpulseWithoutRetrace[];
double LT_Trend_Reversal[];      // Only for Maxbars  -> changed to LookBack
double LT_Trend_Cont[];          // Only for Maxbars  -> changed to LookBack
double ST_Trend_Reversal[];
double ST_Trend_Cont[];
//-------------

double D_K_MOM[];
double SETUP[];
bool SetupFOUNDfor_Curr_Timeseries =false;
bool MT_momentum_FOUNDfor_Curr_Timeseries = false;
//-- Indicator arrays
double ATR[];
double ATR14[];
double MT_MA365[];
double ST_MA50[];
double CandleClose[];
double CandleOpen[];
double CandleHigh[];
double CandleLow[];
datetime CandleTime[];
datetime CandleVolume[];

double EMA8[];
double EMA21[];
double BBands220UPPER[];
double BBands220LOWER[];
double RSI14[];
double ADXMAIN[];
double ADXPLUS[];
double ADXMINUS[];
double ST_MA89[];
double ST_MA200[];
double ST_MA365[];
double LT_MA135[];


//subsequent helper arrays
// MT Momentum Divergence START
double MT_MACDDiv_MainSwingLow_Value[];
double MT_MACDDiv_MainSwingHigh_Value[];
double MT_MOMbreakHIGH[];
double MT_MOMbreakLOW[];
double MT_MOMlowerHIGH[];
double MT_MOMHigherLOW[];
double MT_DaDbreakHIGH[];
double MT_DaDbreakLOW[];
double MT_DaDLowerHigh[];
double MT_DaDHigherLOW[];
double DADTurnDown[];
double DADTurnUP[];
double MT_MOM_Break[];
double MT_MOM_Swing_change[];
double MT_DAD_Swing_change[];
double MT_DAD_Break[];
// MT Momentum Divergence START

double LT_Down_MACD_MOM[];
double LT_UP_MACD_MOM[];
double LT_UP_Stoc_D[];
double LT_Down_Stoc_D[];
double LT_UP_Stoc_K[];
double LT_Down_Stoc_K[];


double MT_SMA_Angle[];
double MT_BBand_UPPER[];
double MT_BBand_LOWER[];
double MT_MA_Trend_Angle[];

double MT_PriceSwingHIGHs[];
double MT_PriceSwingLOWs[];

double MT_Wavecount[];
double MT_FailWave[];




int SetupUP = 0;
int SetupDOWN = 0;



double MT_Down_Stoc[];       ///// EA coding :  MT Stoc extreme levels + divergence
double MT_UP_Stoc[];         ///// EA coding :  MT Stoc extreme levels + divergence
double MT_MA150[];
double MT_MACD_DAD[];
double MT_MACD_MOM[];
double MT_Stoc_K[];
double MT_Stoc_D[];
double ST_MACD_DAD[];
double ST_MACD_MOM[];
double ST_Stoc_K[];
double ST_Stoc_D[];



// -- K_D_MOM
double MT_K_Angle[];
double MT_D_Angle[];
double MT_MOM_Angle[];
double ST_K_Angle[];
double ST_D_Angle[];
double ST_MOM_Angle[];

//-- Triggers
double PriceActionBar[];
double ST_Stoc_Divergence[];
double ST_Stoc_Convergence[];
double ST_Stoc_Divergence_AI[];

//-- Bellcurve



double TD_Nine_EXIT[];
double TD_Countdown_EXIT[];
double Riding21EMA_output[];
double Riding8EMA_output[];
double SMIdivergence[];
double RSI_BB_Stoc_EXIT[];
double ADX_EXIT[];
double MFI_EXIT[];
double BB_RSI_EXIT[];
double CCI_EXIT[];
double SMIclimax_Exit[];

double SMI_Signal_Buffer[];
double Riding8ema[];
double Riding21ema[];
double TD_Resistance[];
double TD_Support[];
double MFI[];
double CCI[];
double TD_Perfection[];
double SMI_Buffer[];
double TD_Nine[];
double TD_Countdown[];
//--- Impulse without retrace
double MT_BBand_UPPER220[];
double MT_BBand_LOWER220[];
double MT_EMA45[];

//---  X marks the spot


double ST_EMA15[];
double MT_BBand_LOWER3520[];
double MT_BBand_UPPER3520[];
double LT_Stoc_K[];
double LT_Stoc_D[];

//---   LT WAVECOUNT
double LT_MA_Trend_Angle[];
double LT_SMA_Angle[];
double LT_MA450[];
double LT_BBand_UPPER[];
double LT_BBand_LOWER[];
double LT_PriceSwingHIGHs[];
double LT_PriceSwingLOWs[];
double LT_Wavecount[];
double LT_FailWave[];
double LT_UP_Stoc[];
double LT_Down_Stoc[];

//---   LT MACD Divergence
double LT_MACD_MOM[];
double LT_MACD_DAD[];
double LT_MACDDiv_MainSwingHigh_Value[];
double LT_MACDDiv_MainSwingLow_Value[];
double LT_MOMHigherLOW[];
double LT_MOMbreakHIGH[];
double LT_MOMlowerHIGH[];
double LT_MOMbreakLOW[];
double LT_DaDHigherLOW[];
double LT_DaDbreakHIGH[];
double LT_DaDLowerHigh[];
double LT_DaDbreakLOW[];
double LT_MOM_Break[];          // EA coding : use for LT Momentum -> return == 1 Break UP : return == 2 Break DOWN
double LT_MOM_Swing_change[];   // EA coding : use for LT Momentum -> return == 1 UP : return == 2 DOWN
double LT_DAD_Break[];          // EA coding : use for LT Momentum -> return == 1 Break UP : return == 2 Break DOWN
double LT_DAD_Swing_change[];   // EA coding : use for LT Momentum -> return == 1 UP : return == 2 DOWN
double LT_Momentum_Divergence_Partial[]; // EA coding : use for LT Momentum : This array includes the stoc extreme + MOM > 0 -> return == 1 UP : return == 2 DOWN
double LT_Momentum_Divergence_Full[];    // EA coding : use for LT Momentum : This array includes the stoc extreme + MOM = 4 -> return == 1 UP : return == 2 DOWN
double LT_DADTurnDown[];
double LT_DADTurnUP[];

//-- Trend / Momentum direction
double MT_Divergence_UP_Counter[];
double MT_Divergence_DOWN_Counter[];
double MT_TrendDirection[];
double LT_TrendDirection[];

//--- Triggers added
double ST_Trigger_StocX[];
double ST_Trigger_Stoc3X[];

//--- TD Indicator
//--- Internal
int DeMarkerI_vPeriod = 13;
int DeMarkerI_Max = 60;
int DeMarkerI_Min = 40;
int DeMarkerII_vPeriod = 8;
int DeMarkerII_Max = 60;
int DeMarkerII_Min = 40;
int ROC_vPeriod = 12;
int ROC_Max = 102.5;
int ROC_Min = 97.5;
int REI_vPeriod = 5;
int REI_Max = 40;
int REI_Min = -40;
int Pressure_vPeriod = 5;
int Pressure_Max = 60;
int Pressure_Min = 40;
double Divergence[], TD_Alignment[], TD_AligmentResult[], TD_Aligment_InTrend_Result[];
double ROC[], REI[], Pressure[], DeMarker[], DeMarkII[];

//---  MA - Support/Resistance

double MA_Resistance[];
double MA_Support[];


// ST Momentum Divergence START
double ST_MACDDiv_MainSwingLow_Value[];
double ST_MACDDiv_MainSwingHigh_Value[];
double ST_MOMbreakHIGH[];
double ST_MOMbreakLOW[];
double ST_MOMlowerHIGH[];
double ST_MOMHigherLOW[];
double ST_DaDbreakHIGH[];
double ST_DaDbreakLOW[];
double ST_DaDLowerHigh[];
double ST_DaDHigherLOW[];
double ST_DADTurnDown[];
double ST_DADTurnUP[];
double ST_MOM_Break[];
double ST_MOM_Swing_change[];
double ST_DAD_Swing_change[];
double ST_DAD_Break[];
//-- Trend / Momentum direction
double ST_Divergence_UP_Counter[];
double ST_Divergence_DOWN_Counter[];
double ST_TrendDirection[];
double ST_Down_Stoc[];       ///// EA coding :  MT Stoc extreme levels + divergence
double ST_UP_Stoc[];         ///// EA coding :  MT Stoc extreme levels + divergence
double ST_Momentum_Divergence_Full[];
double ST_Momentum_Divergence_Partial[];
double ST_MOM_Reload[];
double MT_LT_Stoc_Extreme[];
double TD_Alignment_Bellcurve[];
double TopDOG_Setup_USEDin_BELLcurve[];

double BellcurveUP[];
double  BellcurveDOWN[];

// ST Momentum Divergence START


#endif
//+------------------------------------------------------------------+
