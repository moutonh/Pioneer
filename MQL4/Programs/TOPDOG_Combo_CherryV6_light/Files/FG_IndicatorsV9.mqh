//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#property strict
#include <EA_Debug_LogV2.mqh>
//+------------------------------------------------------------------+
//|  Global values
//+------------------------------------------------------------------+
//double FirstCycleAfter_X[];
#include "FG_Global_VariablesV4.mqh"
//double FirstCycleAfter_DADturns[];
////////////////////double MT_Down_Stoc[];
////////////////////double MT_UP_Stoc[];
////////////////////double MT_MA150[];
////////////////////double MT_MACD_DAD[];
////////////////////double MT_MACD_MOM[];
////////////////////double MT_Stoc_K[];
////////////////////double MT_Stoc_D[];
////////////////////double ST_MACD_DAD[];
////////////////////double ST_MACD_MOM[];
////////////////////double ST_Stoc_K[];
////////////////////double ST_Stoc_D[];

//#define MAX_BARS 2000

double ST_MACD_MainSwingHigh_Value[];
double ST_MACD_MainSwingLow_Value[];

//double ST_ReloadPattern[];


//#define MAX_BARS 2000

double MACD_MainSwingHigh_Value[];
double MACD_MainSwingLow_Value[];
//double MT_MACD_MOM[];
//double MT_ReloadPattern[];



//extern int MaxBars;   // The amount of output data.
//int LookBack = 3000; //Form MaxBars
//+------------------------------------------------------------------+
//| Object Arrow - Quick reference                                   |
//| OBJPROP_ARROWCODE : 5   - Leftprice
//|                     6   - Rightprice
//|                     251 - Stop SignArrowTimeless
//|                     252 - Check Sign
//|                     242 - Down Arrow
//|                     241 - Up Arrow
//+------------------------------------------------------------------+
void ArrowTimeless(string name,datetime time,double price,color kleur,int ArrowCode)
  {
// if(ShowFlag==1)
     {
      ObjectCreate(name,OBJ_ARROW,0,time,price);
      ObjectSet(name,OBJPROP_COLOR,kleur);
      ObjectSet(name,OBJPROP_ARROWCODE,ArrowCode);
     }
  }
//+------------------------------------------------------------------+
//| Object Text - Quick reference
//|
//|  TextTimeless("TextSecondLow",Time[iBarShift(NULL,0,SecondHighTime)],High[iBarShift(NULL,0,SecondHighTime)] +10*Point,White,12,"4" );
//+------------------------------------------------------------------+
//void TextTimeless(string name,datetime time,double price,color kleur,int fontsize,string text,double angle)
//  {
////if (ShowFlag == 1)
//     {
//      ObjectCreate(name,OBJ_TEXT,0,time,price);
//      ObjectSetText(name,text,fontsize,"ArialBold",kleur);
//      ObjectSet(name, OBJPROP_ANGLE,angle);
//     }
//  }
void TextTimeless(string name, datetime time, double price, color kleur, int fontsize, string text, double angle)
  {
   ObjectDelete(name);  // Delete existing first

   if(ObjectCreate(name, OBJ_TEXT, 0, time, price))
     {
      ObjectSetText(name, text, fontsize, "Arial", kleur);
      ObjectSet(name, OBJPROP_ANGLE, angle);
      ObjectSet(name, OBJPROP_BACK, false);
      ChartRedraw();
      //  Print("Text created: ", name);
     }
   else
     {
      Print("Failed to create: ", name, " Error: ", GetLastError());
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Populate_Indicator_Arrays()//string symbol, ENUM_TIMEFRAMES timeframe
  {
//  ArrayResize(MTWavecount,MaxBars + 2);
//ArrayResize(MT_Down_Trend,MaxBars + 2);
//ArrayResize(MT_UP_Trend,MaxBars + 2);
   ArrayResize(MT_Down_Stoc,LookBack + 2);
   ArrayResize(MT_UP_Stoc,LookBack + 2);
   ArrayResize(LT_Down_MACD_MOM,LookBack + 2);
   ArrayResize(LT_UP_MACD_MOM,LookBack + 2);
   ArrayResize(LT_UP_Stoc_D,LookBack + 2);
   ArrayResize(LT_Down_Stoc_D,LookBack + 2);
   ArrayResize(LT_UP_Stoc_K,LookBack + 2);
   ArrayResize(LT_Down_Stoc_K,LookBack + 2);
//ArrayResize(MT_DOWN_MOMentum,MaxBars + 2);
//ArrayResize(MT_UP_MOMentum,MaxBars + 2);
   ArrayResize(MT_MA150,LookBack + 2);
   ArrayResize(MT_MACD_DAD,LookBack + 2);
   ArrayResize(MT_MACD_MOM,LookBack + 2);
   ArrayResize(MT_Stoc_K,LookBack + 2);
   ArrayResize(MT_Stoc_D,LookBack + 2);
   ArrayResize(ST_MACD_DAD,LookBack + 2);
   ArrayResize(ST_MACD_MOM,LookBack + 2);
   ArrayResize(ST_Stoc_K,LookBack + 2);
   ArrayResize(ST_Stoc_D,LookBack + 2);
   ArrayResize(ATR,LookBack + 2);
   ArrayResize(ST_MA365,LookBack + 2);
   ArrayResize(MT_Rubberband,LookBack + 2);
   ArrayResize(ST_Rubberband,LookBack + 2);
   ArrayResize(ATR14,LookBack + 2);
   ArrayResize(ST_MA50,LookBack + 2);
//Momentum change arrays
   ArrayResize(MT_MOMbreakHIGH,LookBack + 2);
   ArrayResize(MT_MOMbreakLOW,LookBack + 2);
   ArrayResize(MT_MOMlowerHIGH,LookBack + 2);
   ArrayResize(MT_MOMHigherLOW,LookBack + 2);
   ArrayResize(MT_DaDbreakHIGH,LookBack + 2);
   ArrayResize(MT_DaDbreakLOW,LookBack + 2);
   ArrayResize(MT_DaDLowerHigh,LookBack + 2);
   ArrayResize(MT_DaDHigherLOW,LookBack + 2);
   ArrayResize(MT_MOM_Break,LookBack + 2);
   ArrayResize(MT_MOM_Swing_change,LookBack + 2);
   ArrayResize(MT_DAD_Swing_change,LookBack + 2);
   ArrayResize(MT_DAD_Break,LookBack + 2);
   ArrayResize(DADTurnDown,LookBack + 2);
   ArrayResize(DADTurnUP,LookBack + 2);
   ArrayResize(MT_MACDDiv_MainSwingLow_Value,LookBack + 2);
   ArrayResize(MT_MACDDiv_MainSwingHigh_Value,LookBack + 2);
   ArrayResize(Momentum_Divergence_Partial,LookBack + 2);
   ArrayResize(Momentum_Divergence_Full,LookBack + 2);
   ArrayResize(LT_Conservative,LookBack + 2);
   ArrayResize(FirstCycleAfter_X,LookBack + 2);
   ArrayResize(FirstCycleAfter_DADturns,LookBack + 2);

   ArrayResize(MACD_MainSwingHigh_Value,LookBack + 2);
   ArrayResize(MACD_MainSwingLow_Value,LookBack + 2);
//ArrayResize(MT_MACD_MOM,LookBack + 2);
   ArrayResize(MT_ReloadPattern,LookBack + 2);

   ArrayResize(ST_MACD_MainSwingHigh_Value,LookBack + 2);
   ArrayResize(ST_MACD_MainSwingLow_Value,LookBack + 2);
//ArrayResize(MT_MACD_MOM,LookBack + 2);
   ArrayResize(ST_ReloadPattern,LookBack + 2);
   ArrayResize(MT_SMA_Angle,LookBack + 2);
   ArrayResize(MT_BBand_UPPER,LookBack + 2);
   ArrayResize(MT_BBand_LOWER,LookBack + 2);
   ArrayResize(MT_MA_Trend_Angle,LookBack + 2);
   ArrayResize(MT_PriceSwingHIGHs,LookBack + 2);
   ArrayResize(MT_PriceSwingLOWs,LookBack + 2);
   ArrayResize(MT_Wavecount,LookBack + 2);
   ArrayResize(MT_FailWave,LookBack + 2);
   ArrayResize(MT_Trend_Cont,LookBack + 2);
   ArrayResize(MT_Trend_Reversal,LookBack + 2);
   ArrayResize(MT_MOM_Wave2,LookBack + 2);
   ArrayResize(MT_MOM_Wave3,LookBack + 2);

   ArrayResize(MT_BBand_UPPER220,LookBack + 2);
   ArrayResize(MT_BBand_LOWER220,LookBack + 2);
   ArrayResize(MT_EMA45,LookBack + 2);
   ArrayResize(ImpulseWithoutRetrace,LookBack + 2);

   ArrayResize(X_Marks_the_spot,LookBack + 2);
   ArrayResize(ST_EMA15,LookBack + 2);
   ArrayResize(LT_Stoc_K,LookBack + 2);
   ArrayResize(LT_Stoc_D,LookBack + 2);
   ArrayResize(MT_BBand_LOWER3520,LookBack + 2);
   ArrayResize(MT_BBand_UPPER3520,LookBack + 2);

//---   LT WAVECOUNT
   ArrayResize(LT_MA_Trend_Angle,LookBack + 2);
   ArrayResize(LT_SMA_Angle,LookBack + 2);
   ArrayResize(LT_MA450,LookBack + 2);
   ArrayResize(LT_BBand_UPPER,LookBack + 2);
   ArrayResize(LT_BBand_LOWER,LookBack + 2);
   ArrayResize(LT_PriceSwingHIGHs,LookBack + 2);
   ArrayResize(LT_PriceSwingLOWs,LookBack + 2);
   ArrayResize(LT_Wavecount,LookBack + 2);
   ArrayResize(LT_FailWave,LookBack + 2);
   ArrayResize(LT_UP_Stoc,LookBack + 2);
   ArrayResize(LT_Down_Stoc,LookBack + 2);
   ArrayResize(LT_Trend_Reversal,LookBack + 2);
   ArrayResize(LT_Trend_Cont,LookBack + 2);

//---   LT MACD Divergence
   ArrayResize(LT_MACD_MOM,LookBack + 2);
   ArrayResize(LT_MACD_DAD,LookBack + 2);
   ArrayResize(LT_MACDDiv_MainSwingHigh_Value,LookBack + 2);
   ArrayResize(LT_MACDDiv_MainSwingLow_Value,LookBack + 2);
   ArrayResize(LT_MOMHigherLOW,LookBack + 2);
   ArrayResize(LT_MOMbreakHIGH,LookBack + 2);
   ArrayResize(LT_MOMlowerHIGH,LookBack + 2);
   ArrayResize(LT_MOMbreakLOW,LookBack + 2);
   ArrayResize(LT_DaDHigherLOW,LookBack + 2);
   ArrayResize(LT_DaDbreakHIGH,LookBack + 2);
   ArrayResize(LT_DaDLowerHigh,LookBack + 2);
   ArrayResize(LT_DaDbreakLOW,LookBack + 2);

   ArrayResize(LT_MOM_Break,LookBack + 2);
   ArrayResize(LT_MOM_Swing_change,LookBack + 2);
   ArrayResize(LT_DAD_Break,LookBack + 2);
   ArrayResize(LT_DAD_Swing_change,LookBack + 2);
   ArrayResize(LT_Momentum_Divergence_Partial,LookBack + 2);
   ArrayResize(LT_Momentum_Divergence_Full,LookBack + 2);
   ArrayResize(LT_DADTurnDown,LookBack + 2);
   ArrayResize(LT_DADTurnUP,LookBack + 2);

   ArrayResize(MT_Divergence_UP_Counter,LookBack + 2);
   ArrayResize(MT_Divergence_DOWN_Counter,LookBack + 2);
   ArrayResize(MT_TrendDirection,LookBack + 2);
   ArrayResize(LT_TrendDirection,LookBack + 2);
   ArrayResize(ST_MA89,LookBack + 2);
   ArrayResize(ST_MA200,LookBack + 2);
   ArrayResize(ST_MA365,LookBack + 2);
   ArrayResize(LT_MA135,LookBack + 2);

   ArrayResize(ST_MACDDiv_MainSwingLow_Value,LookBack + 2);
   ArrayResize(ST_MACDDiv_MainSwingHigh_Value,LookBack + 2);
   ArrayResize(ST_MOMbreakHIGH,LookBack + 2);
   ArrayResize(ST_MOMbreakLOW,LookBack + 2);
   ArrayResize(ST_MOMlowerHIGH,LookBack + 2);
   ArrayResize(ST_MOMHigherLOW,LookBack + 2);
   ArrayResize(ST_DaDbreakHIGH,LookBack + 2);
   ArrayResize(ST_DaDbreakLOW,LookBack + 2);
   ArrayResize(ST_DaDLowerHigh,LookBack + 2);
   ArrayResize(ST_DaDHigherLOW,LookBack + 2);
   ArrayResize(ST_DADTurnDown,LookBack + 2);
   ArrayResize(ST_DADTurnUP,LookBack + 2);
   ArrayResize(ST_MOM_Break,LookBack + 2);
   ArrayResize(ST_MOM_Swing_change,LookBack + 2);
   ArrayResize(ST_DAD_Swing_change,LookBack + 2);
   ArrayResize(ST_DAD_Break,LookBack + 2);
//-- Trend / Momentum direction
   ArrayResize(ST_Divergence_UP_Counter,LookBack + 2);
   ArrayResize(ST_Divergence_DOWN_Counter,LookBack + 2);
   ArrayResize(ST_TrendDirection,LookBack + 2);
   ArrayResize(ST_Down_Stoc,LookBack + 2);
   ArrayResize(ST_UP_Stoc,LookBack + 2);
   ArrayResize(ST_Momentum_Divergence_Partial,LookBack + 2);
   ArrayResize(ST_Momentum_Divergence_Full,LookBack + 2);
   ArrayResize(TopDOG_Setup_USEDin_BELLcurve,LookBack + 2);
   ArrayResize(MA_SUPPORT_RESISTANCE,LookBack + 2);

   ClearAll_Setup_Arrays();
   int shortSearch =0;
   for(int i=LookBack+1; i>=1; i--)
     {
      if(iMACD(currentSymbol,currentTimeframe,45,180,225,PRICE_CLOSE,MODE_MAIN,i)> iMACD(currentSymbol,currentTimeframe,45,180,225,PRICE_CLOSE,MODE_MAIN,i+1))
         LT_UP_MACD_MOM[i] = 1;
      if(iMACD(currentSymbol,currentTimeframe,45,180,225,PRICE_CLOSE,MODE_MAIN,i)< iMACD(currentSymbol,currentTimeframe,45,180,225,PRICE_CLOSE,MODE_MAIN,i+1))
         LT_Down_MACD_MOM[i] = 2;
      if(iStochastic(currentSymbol,currentTimeframe,45,27,18,MODE_SMA,0,MODE_MAIN,i) > iStochastic(currentSymbol,currentTimeframe,45,27,18,MODE_SMA,0,MODE_MAIN,i+1)&& iStochastic(currentSymbol,currentTimeframe,45,27,18,MODE_SMA,0,MODE_MAIN,i) > 20 && iStochastic(currentSymbol,currentTimeframe,45,27,18,MODE_SMA,0,MODE_MAIN,i) < 80)
         LT_UP_Stoc_K[i] = 1;
      if(iStochastic(currentSymbol,currentTimeframe,45,27,18,MODE_SMA,0,MODE_MAIN,i) < iStochastic(currentSymbol,currentTimeframe,45,27,18,MODE_SMA,0,MODE_MAIN,i+1)&& iStochastic(currentSymbol,currentTimeframe,45,27,18,MODE_SMA,0,MODE_MAIN,i) > 20 && iStochastic(currentSymbol,currentTimeframe,45,27,18,MODE_SMA,0,MODE_MAIN,i) < 80)
         LT_Down_Stoc_K[i] = 2;
      if(iStochastic(currentSymbol,currentTimeframe,45,27,18,MODE_SMA,0,MODE_SIGNAL,i) > iStochastic(currentSymbol,currentTimeframe,45,27,18,MODE_SMA,0,MODE_SIGNAL,i+1) && iStochastic(currentSymbol,currentTimeframe,45,27,18,MODE_SMA,0,MODE_SIGNAL,i) > 20 && iStochastic(currentSymbol,currentTimeframe,45,27,18,MODE_SMA,0,MODE_SIGNAL,i) < 80)
         LT_UP_Stoc_D[i] = 1;
      if(iStochastic(currentSymbol,currentTimeframe,45,27,18,MODE_SMA,0,MODE_SIGNAL,i) < iStochastic(currentSymbol,currentTimeframe,45,27,18,MODE_SMA,0,MODE_SIGNAL,i+1)&& iStochastic(currentSymbol,currentTimeframe,45,27,18,MODE_SMA,0,MODE_SIGNAL,i) > 20 && iStochastic(currentSymbol,currentTimeframe,45,27,18,MODE_SMA,0,MODE_SIGNAL,i) < 80)
         LT_Down_Stoc_D[i] = 2;

      MT_SMA_Angle[i] =  iCustom(currentSymbol,currentTimeframe,"SMAAngleV3",150,0,6,3,PRICE_CLOSE,3,i);
      LT_SMA_Angle[i] =  iCustom(currentSymbol,currentTimeframe,"SMAAngleV3",450,0,6,3,PRICE_CLOSE,3,i);
      //ST_SMA_Angle[i] =  iCustom(currentSymbol,currentTimeframe,"SMAAngleV3",50,0,6,3,PRICE_CLOSE,3,i);

      ST_MA200[i]= iMA(currentSymbol,currentTimeframe,200,0,MODE_SMA,PRICE_MEDIAN,i);
      ST_MA365[i]= iMA(currentSymbol,currentTimeframe,365,0,MODE_EMA,PRICE_MEDIAN,i);
      LT_MA135[i]= iMA(currentSymbol,currentTimeframe,135,0,MODE_EMA,PRICE_MEDIAN,i);
      ST_MA89[i] = iMA(currentSymbol,currentTimeframe,89,0,MODE_SMA,PRICE_MEDIAN,i);
      ST_MA50[i] = iMA(currentSymbol,currentTimeframe,50,0,MODE_SMA,PRICE_MEDIAN,i);
      MT_EMA45[i] = iMA(currentSymbol,currentTimeframe,45,0,MODE_EMA,PRICE_MEDIAN,i);
      ST_EMA15[i] = iMA(currentSymbol,currentTimeframe,15,0,MODE_EMA,PRICE_MEDIAN,i);
      MT_MA150[i] = iMA(currentSymbol,currentTimeframe,150,0,MODE_SMA,PRICE_MEDIAN,i);
      LT_MA450[i] = iMA(currentSymbol,currentTimeframe,450,0,MODE_SMA,PRICE_MEDIAN,i);
      ST_MA365[i] = iMA(currentSymbol,currentTimeframe,365,0,MODE_SMA,PRICE_MEDIAN,i);
      MT_MACD_DAD[i] =iMACD(currentSymbol,currentTimeframe,15,60,75,PRICE_CLOSE,MODE_SIGNAL,i);
      MT_MACD_MOM[i] =iMACD(currentSymbol,currentTimeframe,15,60,75,PRICE_CLOSE,MODE_MAIN,i);
      LT_MACD_DAD[i] =iMACD(currentSymbol,currentTimeframe,135,405,75,PRICE_CLOSE,MODE_SIGNAL,i);
      LT_MACD_MOM[i] =iMACD(currentSymbol,currentTimeframe,135,405,75,PRICE_CLOSE,MODE_MAIN,i);

      LT_Stoc_K[i] = iStochastic(currentSymbol,currentTimeframe,45,27,18,MODE_SMA,0,MODE_MAIN,i);
      LT_Stoc_D[i] = iStochastic(currentSymbol,currentTimeframe,45,27,18,MODE_SMA,0,MODE_SIGNAL,i);

      MT_Stoc_K[i] = iStochastic(currentSymbol,currentTimeframe,15,9,6,MODE_SMA,0,MODE_MAIN,i);
      MT_Stoc_D[i] = iStochastic(currentSymbol,currentTimeframe,15,9,6,MODE_SMA,0,MODE_SIGNAL,i);

      ST_MACD_DAD[i] =iMACD(currentSymbol,currentTimeframe,5,20,25,PRICE_CLOSE,MODE_SIGNAL,i);
      ST_Stoc_K[i] = iStochastic(currentSymbol,currentTimeframe,5,3,2,MODE_SMA,0,MODE_MAIN,i);
      ST_MACD_MOM[i] =iMACD(currentSymbol,currentTimeframe,5,20,25,PRICE_CLOSE,MODE_MAIN,i);
      ST_Stoc_D[i] = iStochastic(currentSymbol,currentTimeframe,5,3,2,MODE_SMA,0,MODE_SIGNAL,i);

      ATR[i] = iATR(currentSymbol,currentTimeframe,LookBack,i);
      ATR14[i] = iATR(currentSymbol,currentTimeframe,14,i);
      MT_BBand_UPPER[i] = iBands(currentSymbol,currentTimeframe,60,2,0,PRICE_CLOSE,MODE_UPPER,i);
      MT_BBand_LOWER[i] = iBands(currentSymbol,currentTimeframe,60,2,0,PRICE_CLOSE,MODE_LOWER,i);
      MT_BBand_UPPER220[i] = iBands(currentSymbol,currentTimeframe,20,2,0,PRICE_CLOSE,MODE_UPPER,i);
      MT_BBand_LOWER220[i] = iBands(currentSymbol,currentTimeframe,20,2,0,PRICE_CLOSE,MODE_LOWER,i);
      MT_BBand_LOWER3520[i] = iBands(currentSymbol,currentTimeframe,20,3.5,0,PRICE_CLOSE,MODE_LOWER,i);
      MT_BBand_UPPER3520[i] = iBands(currentSymbol,currentTimeframe,20,3.5,0,PRICE_CLOSE,MODE_UPPER,i);
      LT_BBand_UPPER[i] = iBands(currentSymbol,currentTimeframe,180,2,0,PRICE_CLOSE,MODE_UPPER,i);
      LT_BBand_LOWER[i] = iBands(currentSymbol,currentTimeframe,180,2,0,PRICE_CLOSE,MODE_LOWER,i);
      Populate_TrendDirection(i);
     }
//--- Contains an internal: for(int i=LookBack-2; i>=1; i--) .....

   Populate_second_Layer_Arrays(); // - Polpulate array's of non standard indicator for whole chart before and needed for following calculations ( This calculations needs the standard indicator data as populated in the above arrays.)
   MT_Trend();   // Populate MT_MA_Trend_Angle[] useful for the whole chart
   MT_FindPrice_Swing_Lows();
   MT_FindPrice_Swing_High();
   MT_GetWaveCount();
   MT_Populate_TrendCont_TrendReversal();

   LT_Populate_second_Layer_Arrays(); // - Polpulate array's of non standard indicator for whole chart before and needed for following calculations ( This calculations needs the standard indicator data as populated in the above arrays.)
   LT_Trend();   // Populate MT_MA_Trend_Angle[] useful for the whole chart
   LT_FindPrice_Swing_Lows();
   LT_FindPrice_Swing_High();
   LT_GetWaveCount();
   LT_Populate_TrendCont_TrendReversal();

   ST_Populate_second_Layer_Arrays(); // - Polpulate array's of non standard indicator for whole chart before and needed for following calculations ( This calculations needs the standard indicator data as populated in the above arrays.)
//ST_Trend();   // Populate MT_MA_Trend_Angle[] useful for the whole chart
//ST_FindPrice_Swing_Lows();
//ST_FindPrice_Swing_High();
//ST_GetWaveCount();

   PriceImpulseAnalysis();
   XMarksTheSpot();

//--- Contains an internal:   for(int i=MaxBars; i>=1; i--)
   FollowOnCalculation(); // - Only on MAXBARS - Calculate form latest bar (eg.30) to most recent bar(1) 30->1

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Populate_second_Layer_Arrays()
  {
   for(int i=LookBack-2; i>=1; i--)
     {
      if(ValidStocExtreme(i) ==1 || StocdivergenceMT(i) == 1)
        {
         MT_UP_Stoc[i] = 1;
         //   ArrowTimeless(StringConcatenate("WaveCount SwingHighCounter", i), Time[i], Low[i] - 250 * Point, clrGreen, 174);
        }
      else
        {
         if(ValidStocExtreme(i) ==2 || StocdivergenceMT(i) == 2)
           {
            MT_Down_Stoc[i] = 2;
            //    ArrowTimeless(StringConcatenate("WaveCount SwingHighCounter", i), Time[i], Low[i] - 250 * Point, clrRed, 174);
           }
        }

      //---   SMA_ANgle
      //MT_SMA_Angle(i);
      FirstCycleAfter_X(i);
      FirstCycleAfter_DADturn(i);
      MT_Reload(i);
      ST_Reload(i);
      MT_RubberBand(i);
      ST_RubberBand(i);
      //-- MOM DAD Divergence START
      MT_MOM_DAD_Divergence();
      MT_Divergence_UP_Counter[i] = 0;
      MT_Divergence_DOWN_Counter[i] = 0;


      if(MT_MOMbreakHIGH[i] == 1)
        {
         MT_MOM_Break[i] = 1;
         MT_Divergence_UP_Counter[i] = MT_Divergence_UP_Counter[i] +1;
        }
      if(MT_MOMbreakLOW[i] == 1)
        {
         MT_MOM_Break[i] = 2;
         MT_Divergence_DOWN_Counter[i] = MT_Divergence_DOWN_Counter[i] +1;
        }
      if(MT_MOMHigherLOW[i] == 1)
        {
         MT_MOM_Swing_change[i] = 1;
         MT_Divergence_UP_Counter[i] = MT_Divergence_UP_Counter[i] +1;
        }
      if(MT_MOMlowerHIGH[i] == 1)
        {
         MT_MOM_Swing_change[i] = 2;
         MT_Divergence_DOWN_Counter[i] = MT_Divergence_DOWN_Counter[i] +1;
        }
      if(MT_DaDbreakHIGH[i] == 1)
        {
         MT_DAD_Break[i] = 1;
         MT_Divergence_UP_Counter[i] = MT_Divergence_UP_Counter[i] +1;
        }
      if(MT_DaDbreakLOW[i] == 1)
        {
         MT_DAD_Break[i] = 2;
         MT_Divergence_DOWN_Counter[i] = MT_Divergence_DOWN_Counter[i] +1;
        }
      if(MT_DaDLowerHigh[i] == 1)
        {
         MT_DAD_Swing_change[i] = 2;
         MT_Divergence_DOWN_Counter[i] = MT_Divergence_DOWN_Counter[i] +1;
        }
      if(MT_DaDHigherLOW[i] == 1)
        {
         MT_DAD_Swing_change[i] = 1;
         MT_Divergence_UP_Counter[i] = MT_Divergence_UP_Counter[i] +1;
        }



      //Calculatet ttthe Trigger moment on thhe stoc swing extreme....
      if(MT_Divergence_UP_Counter[i] >0 && MT_UP_Stoc[i] ==1)
        {
         Momentum_Divergence_Partial[i] = 1;
        }
      if(MT_Divergence_UP_Counter[i] == 4  && MT_UP_Stoc[i] ==1)
        {
         Momentum_Divergence_Full[i] = 1;
        }
      if(MT_Divergence_DOWN_Counter[i] >0  && MT_Down_Stoc[i] ==2)
        {
         Momentum_Divergence_Partial[i] = 2;
        }
      if(MT_Divergence_DOWN_Counter[i] == 4  && MT_Down_Stoc[i] ==2)
        {
         Momentum_Divergence_Full[i] = 2;
        }
      //-- MOM DAD Divergence END

      //---
      //---  LT Confirmation : START
      //---
      int SetupUP = 0;
      int SetupDOWN = 0;

      if(MT_MA_Trend_Angle[i] == 1 && MT_Wavecount[i] <5 && MT_UP_Stoc[i] ==1)
         SetupUP = SetupUP+1;
      if(MT_MA_Trend_Angle[i] == 2 && MT_Wavecount[i] >6 && MT_UP_Stoc[i] ==1)
         SetupUP = SetupUP+1;
      //      CHECK_ARRAY_INDEX(FirstCycleAfter_X, i);
      if(ST_Rubberband[i] ==1)
         SetupUP = SetupUP+1;
      if(MT_ReloadPattern[i] ==1 && MT_UP_Stoc[i] ==1)
         SetupUP = SetupUP+1;
      if(FirstCycleAfter_X[i] ==1)
         SetupUP = SetupUP+1;
      if(FirstCycleAfter_DADturns[i] ==1)
         SetupUP = SetupUP+1;
      if(ST_ReloadPattern[i] ==1)
         SetupUP = SetupUP+1;
      if(MT_Rubberband[i] ==1)
         SetupUP = SetupUP+1;
      if(MT_MOM_Wave3[i]  ==1 &&  MT_UP_Stoc[i] ==1)
         SetupUP = SetupUP+1;
      if(MT_MOM_Wave2[i]  ==1 && MT_Stoc_K[i] < 50)
         SetupUP = SetupUP+1;
      if(X_Marks_the_spot[i] ==1)
         SetupUP = SetupUP+1;
      if(ImpulseWithoutRetrace[i] ==1)
         SetupUP = SetupUP+1;
      if(MT_Divergence_UP_Counter[i] >0 && MT_UP_Stoc[i] ==1)
         SetupUP = SetupUP+1;
      if(MT_Divergence_UP_Counter[i] == 4 && MT_UP_Stoc[i] ==1)
         SetupUP = SetupUP+1;

      //---   DOWN

      if(MT_MA_Trend_Angle[i] == 2 && MT_Wavecount[i] <5  && MT_Down_Stoc[i] ==2)
         SetupDOWN = SetupDOWN+1;
      if(MT_MA_Trend_Angle[i] == 1 && MT_Wavecount[i] >6  && MT_Down_Stoc[i] ==2)
         SetupDOWN = SetupDOWN+1;

      if(MT_Divergence_DOWN_Counter[i] >0 && MT_Down_Stoc[i] ==2)
         SetupDOWN = SetupDOWN+1;
      if(MT_Divergence_DOWN_Counter[i] == 4 && MT_Down_Stoc[i] ==2)
         SetupDOWN = SetupDOWN+1;

      if(ST_ReloadPattern[i] ==2)
         SetupDOWN = SetupDOWN+1;
      if(MT_ReloadPattern[i] ==2  && MT_Down_Stoc[i] ==2)
         SetupDOWN = SetupDOWN+1;

      if(FirstCycleAfter_X[i] ==2)
         SetupDOWN = SetupDOWN+1;
      if(FirstCycleAfter_DADturns[i] ==2)
         SetupDOWN = SetupDOWN+1;

      if(MT_MOM_Wave3[i]  ==2  &&  MT_Down_Stoc[i] ==2)
         SetupDOWN = SetupDOWN+1;
      if(MT_MOM_Wave2[i]  ==2 && MT_Stoc_K[i] > 50)
         SetupDOWN = SetupDOWN+1;

      if(X_Marks_the_spot[i] ==2)
         SetupDOWN = SetupDOWN+1;
      if(ImpulseWithoutRetrace[i] ==2)
         SetupDOWN = SetupDOWN+1;

      if(MT_Rubberband[i] ==2)
         SetupDOWN = SetupDOWN+1;
      if(ST_Rubberband[i] ==2)
         SetupDOWN = SetupDOWN+1;


      //--- LT for conservative SETUPs
      if((LT_UP_MACD_MOM[i] ==1 || LT_UP_Stoc_D[i] == 1|| LT_UP_Stoc_K[i] == 1) &&

         SetupUP >0







         //Momentum_Divergence_Full[i] == 1 ||
         //Momentum_Divergence_Partial[i] == 1 ||
         //ST_Rubberband[i] == 1 ||
         //MT_Rubberband[i] == 1 ||
         //ST_ReloadPattern[i] ==1 ||
         //MT_ReloadPattern[i] ==1 ||
         //FirstCycleAfter_DADturns[i] == 1 ||
         //FirstCycleAfter_X[i] ==1 ||
         //MT_Trend_Cont[i] == 1 ||
         //MT_Trend_Reversal[i] == 1 ||
         //MT_MOM_Wave3[i] == 1 ||
         //MT_MOM_Wave2[i] == 1 ||
         //X_Marks_the_spot[i] == 1 ||
         //ImpulseWithoutRetrace[i] == 1)
        )
        {
         LT_Conservative[i] =1;
        }

      if((LT_Down_MACD_MOM[i] ==2 || LT_Down_Stoc_D[i] == 2|| LT_Down_Stoc_K[i] == 2)
         && SetupDOWN >0
         //(Momentum_Divergence_Full[i] == 2 ||
         //Momentum_Divergence_Partial[i] == 2 ||
         //    ST_Rubberband[i] == 2 ||
         //    MT_Rubberband[i] == 2 ||
         //    ST_ReloadPattern[i] ==2 ||
         //    MT_ReloadPattern[i] ==2 ||
         //    FirstCycleAfter_DADturns[i] == 2 ||
         //    FirstCycleAfter_X[i] ==2 ||
         //    MT_Trend_Cont[i] == 2 ||
         //    MT_Trend_Reversal[i] == 2||
         //    MT_MOM_Wave3[i] == 2 ||
         //    MT_MOM_Wave2[i] == 2 ||
         //    X_Marks_the_spot[i] == 2 ||
         //    ImpulseWithoutRetrace[i] == 2)
        )
        {
         if(LT_Conservative[i] ==1)
           {
            LT_Conservative[i] =0;
           }
         else
           {
            LT_Conservative[i] =2;
           }
        }




     }


   return(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void FollowOnCalculation()
  {
   for(int i=MaxBars; i>=1 && i<actualCopied; i--)
      //  for(int i=LookBack; i>=1 && i<actualCopied; i--)
     {
      //Print(" i = ",i);
      //FirstCycleAfter_X(i);
      //FirstCycleAfter_DADturn(i);
      //MT_Reload(i);
      //ST_Reload(i);
      //MT_RubberBand(i);
      //ST_RubberBand(i);

      //      //-- MOM DAD Divergence START
      //      MT_MOM_DAD_Divergence();
      //      MT_Divergence_UP_Counter[i] = 0;
      //      MT_Divergence_DOWN_Counter[i] = 0;
      //
      //
      //      if(MT_MOMbreakHIGH[i] == 1)
      //        {
      //         MT_MOM_Break[i] = 1;
      //         MT_Divergence_UP_Counter[i] = MT_Divergence_UP_Counter[i] +1;
      //        }
      //      if(MT_MOMbreakLOW[i] == 1)
      //        {
      //         MT_MOM_Break[i] = 2;
      //         MT_Divergence_DOWN_Counter[i] = MT_Divergence_DOWN_Counter[i] +1;
      //        }
      //      if(MT_MOMHigherLOW[i] == 1)
      //        {
      //         MT_MOM_Swing_change[i] = 1;
      //         MT_Divergence_UP_Counter[i] = MT_Divergence_UP_Counter[i] +1;
      //        }
      //      if(MT_MOMlowerHIGH[i] == 1)
      //        {
      //         MT_MOM_Swing_change[i] = 2;
      //         MT_Divergence_DOWN_Counter[i] = MT_Divergence_DOWN_Counter[i] +1;
      //        }
      //      if(MT_DaDbreakHIGH[i] == 1)
      //        {
      //         MT_DAD_Break[i] = 1;
      //         MT_Divergence_UP_Counter[i] = MT_Divergence_UP_Counter[i] +1;
      //        }
      //      if(MT_DaDbreakLOW[i] == 1)
      //        {
      //         MT_DAD_Break[i] = 2;
      //         MT_Divergence_DOWN_Counter[i] = MT_Divergence_DOWN_Counter[i] +1;
      //        }
      //      if(MT_DaDLowerHigh[i] == 1)
      //        {
      //         MT_DAD_Swing_change[i] = 2;
      //         MT_Divergence_DOWN_Counter[i] = MT_Divergence_DOWN_Counter[i] +1;
      //        }
      //      if(MT_DaDHigherLOW[i] == 1)
      //        {
      //         MT_DAD_Swing_change[i] = 1;
      //         MT_Divergence_UP_Counter[i] = MT_Divergence_UP_Counter[i] +1;
      //        }
      //
      //
      //
      //      //Calculatet ttthe Trigger moment on thhe stoc swing extreme....
      //      if(MT_Divergence_UP_Counter[i] >0 && MT_UP_Stoc[i] ==1)
      //        {
      //         Momentum_Divergence_Partial[i] = 1;
      //        }
      //      if(MT_Divergence_UP_Counter[i] == 4  && MT_UP_Stoc[i] ==1)
      //        {
      //         Momentum_Divergence_Full[i] = 1;
      //        }
      //      if(MT_Divergence_DOWN_Counter[i] >0  && MT_Down_Stoc[i] ==2)
      //        {
      //         Momentum_Divergence_Partial[i] = 2;
      //        }
      //      if(MT_Divergence_DOWN_Counter[i] == 4  && MT_Down_Stoc[i] ==2)
      //        {
      //         Momentum_Divergence_Full[i] = 2;
      //        }
      //      //-- MOM DAD Divergence END

      //      //--- LT for conservative SETUPs
      //      if((LT_UP_MACD_MOM[i] ==1 || LT_UP_Stoc_D[i] == 1|| LT_UP_Stoc_K[i] == 1) && (Momentum_Divergence_Full[i] == 1 || Momentum_Divergence_Partial[i] == 1 ||
      //            ST_Rubberband[i] == 1 || MT_Rubberband[i] == 1 || ST_ReloadPattern[i] ==1 || MT_ReloadPattern[i] ==1 || FirstCycleAfter_DADturns[i] == 1 || FirstCycleAfter_X[i] ==1 || MT_Trend_Cont[i] == 1 || MT_Trend_Reversal[i] == 1 ||
      //            MT_MOM_Wave3[i] == 1 || MT_MOM_Wave2[i] == 1 || X_Marks_the_spot[i] == 1 || ImpulseWithoutRetrace[i] == 1))
      //        {
      //         LT_Conservative[i] =1;
      //        }
      //
      //      if((LT_Down_MACD_MOM[i] ==2 || LT_Down_Stoc_D[i] == 2|| LT_Down_Stoc_K[i] == 2)
      //         && (Momentum_Divergence_Full[i] == 2 || Momentum_Divergence_Partial[i] == 2 ||
      //             ST_Rubberband[i] == 2 || MT_Rubberband[i] == 2 || ST_ReloadPattern[i] ==2 || MT_ReloadPattern[i] ==2 || FirstCycleAfter_DADturns[i] == 2 || FirstCycleAfter_X[i] ==2 || MT_Trend_Cont[i] == 2 || MT_Trend_Reversal[i] == 2||
      //             MT_MOM_Wave3[i] == 2 || MT_MOM_Wave2[i] == 2 || X_Marks_the_spot[i] == 2 || ImpulseWithoutRetrace[i] == 2))
      //        {
      //         if(LT_Conservative[i] ==1)
      //           {
      //            LT_Conservative[i] =0;
      //           }
      //         else
      //           {
      //            LT_Conservative[i] =2;
      //           }
      //        }
      //
      //
      //      MT_Populate_TrendCont_TrendReversal(i);
      //      LT_Populate_TrendCont_TrendReversal(i);
     }
   LT_MACD_Divergence();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//---
//---                DRAWINGS
//---
//---
//---
//---
//+------------------------------------------------------------------+
void DrawHeatMap_of_Setups()
  {
   ClearHeatmapAll();
   int maxBars = MathMin(MaxBars, Bars); // Start with just 20 bars for testing
   if(ArraySize(FirstCycleAfter_X) > 0)
      DrawHeatmapBand_Enhanced("Enhanced_X", FirstCycleAfter_X, 0, maxBars);
   if(ArraySize(FirstCycleAfter_DADturns) > 0)
      DrawHeatmapBand_Enhanced("FirstCycleAfter_DADturns", FirstCycleAfter_DADturns, 1, maxBars);

   if(ArraySize(ST_ReloadPattern) > 0)
      DrawHeatmapBand_Enhanced("ST_ReloadPattern", ST_ReloadPattern, 2, maxBars);
   if(ArraySize(MT_ReloadPattern) > 0)
      DrawHeatmapBand_Enhanced("MT_ReloadPattern", MT_ReloadPattern, 3, maxBars);

   if(ArraySize(MT_Rubberband) > 0)
      DrawHeatmapBand_Enhanced("MT_RubberBand", MT_Rubberband, 4, maxBars);
   if(ArraySize(ST_Rubberband) > 0)
      DrawHeatmapBand_Enhanced("ST_RubberBand", ST_Rubberband, 5, maxBars);

   if(ArraySize(Momentum_Divergence_Partial) > 0)
      DrawHeatmapBand_Enhanced("Momentum_Divergence_Partial",Momentum_Divergence_Partial, 6, maxBars);
   if(ArraySize(Momentum_Divergence_Full) > 0)
      DrawHeatmapBand_Enhanced("Momentum_Divergence_Full", Momentum_Divergence_Full, 7, maxBars);

   if(ArraySize(LT_Conservative)> 0)
      DrawHeatmapBand_Enhanced("LT_Conservative", LT_Conservative, 8, maxBars);

   if(ArraySize(MT_Trend_Cont)> 0)
      DrawHeatmapBand_Enhanced("MT_Trend_Cont", MT_Trend_Cont, 9, maxBars);
   if(ArraySize(MT_Trend_Reversal)> 0)
      DrawHeatmapBand_Enhanced("MT_Trend_Reversal",MT_Trend_Reversal,10, maxBars);
   if(ArraySize(MT_MOM_Wave3)> 0)
      DrawHeatmapBand_Enhanced("MT_MOM_Wave3",MT_MOM_Wave3,11, maxBars);
   if(ArraySize(MT_MOM_Wave2)> 0)
      DrawHeatmapBand_Enhanced("MT_MOM_Wave2",MT_MOM_Wave2,12, maxBars);
   if(ArraySize(ImpulseWithoutRetrace)> 0)
      DrawHeatmapBand_Enhanced("ImpulseWithoutRetrace",ImpulseWithoutRetrace,13, maxBars);
   if(ArraySize(X_Marks_the_spot)> 0)
      DrawHeatmapBand_Enhanced("X_Marks_the_spot",X_Marks_the_spot,14, maxBars);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawCycleArrows(double &array[])
  {
//int totalBars = Bars;
//if (totalBars < LookBack)
//   Loopback = totalBars - 1;
   int arrSize = ArraySize(array);

   for(int i = arrSize-1; i >= 1; i--)
     {
      int val = array[i];

      if(val == 1 || val == 2)
        {
         //  Print(" Detect X value = ", val);
         string name = StringConcatenate("WaveCount TestArrows", i);
         datetime time = CandleTime[i];
         double price = iLow(currentSymbol,currentTimeframe,i) - 150 * Point;
         color clr = (val == 1) ? clrGreen : clrRed;
         int arrowCode = 167;  // Wingdings arrow up/down or whatever symbol you use
         ArrowTimeless(name, time, price, clr, arrowCode);
         //  Print("val = ",val);
        }
     }
  }
//+------------------------------------------------------------------+
//---
//---
//---
//---                SETUPs
//---
//---
//---
//---
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                          MT_RubberBand                                        |
//+------------------------------------------------------------------+
int MT_RubberBand(int i)
  {
   if(MT_MA150[i] > MT_MA150[i+1] && CandleClose[i]  < MT_MA150[i] && CandleOpen[i] < MT_MA150[i] && CandleClose[i]+(ATR14[i]*0.75) < MT_MA150[i] && MT_UP_Stoc[i] == 1)
     {
      // buy
      MT_Rubberband[i] =1;
     }
   else
     {
      if(MT_MA150[i] < MT_MA150[i+1] && CandleClose[i] > MT_MA150[i] && CandleOpen[i] < MT_MA150[i]&& CandleClose[i]-(ATR14[i]*0.75) > MT_MA150[i] && MT_UP_Stoc[i] == 2)
        {
         //sell
         MT_Rubberband[i] =2;
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|                       ST_RubberBand                                           |
//+------------------------------------------------------------------+
int ST_RubberBand(int i)
  {
//iClose(currentSymbol,currentTimeframe,i)
   if(ST_MA50[i] > ST_MA50[i+1] && CandleClose[i] < ST_MA50[i] && CandleOpen[i] < ST_MA50[i] && CandleClose[i]+(ATR14[i]*0.75) < ST_MA50[i])
     {
      // buy
      ST_Rubberband[i] =1;
     }
   else
     {
      if(ST_MA50[i] < ST_MA50[i+1] && CandleClose[i] > ST_MA50[i] && CandleOpen[i] < ST_MA50[i]&& CandleClose[i]-(ATR14[i]*0.75) > ST_MA50[i])
        {
         //sell
         ST_Rubberband[i] =2;
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|         MT_Reload Pattern
//+------------------------------------------------------------------+
int MT_Reload(int i)
  {


//if (i == Bars - 1)  // Only calculate once per new bar
//{
//Print(" Calc Over ext. i = ",i);
   CalculateOverExtended();
//}
   return (int)MT_ReloadPattern[i];  // 1 = down, 2 = up, 0 = none
  }
//+------------------------------------------------------------------+
//|          ST_Reload Pattern
//+------------------------------------------------------------------+
int ST_Reload(int i)
  {
//   ArrayResize(ST_MACD_MainSwingHigh_Value,LookBack + 2);
//   ArrayResize(ST_MACD_MainSwingLow_Value,LookBack + 2);
////ArrayResize(MT_MACD_MOM,LookBack + 2);
//   ArrayResize(ST_ReloadPattern,LookBack + 2);

//if (i == Bars - 1)  // Only calculate once per new bar
//{
//Print(" Calc Over ext. i = ",i);
   ST_CalculateOverExtended();
//}
   return (int)ST_ReloadPattern[i];  // 1 = down, 2 = up, 0 = none
  }
//+------------------------------------------------------------------+
//|          FirstCycleAfter_DADturn                                                        |
//+------------------------------------------------------------------+
int FirstCycleAfter_DADturn(int i)
  {
   int CurrentCyleStart = 0;
   int SwingLowCounter = 0;
   int SwingHighCounter  =0;
   int SwingLowCounter2 = 0;
   int UPSwingHighCounter = 0;
   int UPSwingHighCounter2 = 0;
   int UPSwingLowCounter = 0;
   int UPCurrentCyleStart = 0;


   if(MT_Stoc_K[i] > 55 && MT_MACD_DAD[i] < MT_MACD_DAD[i+1])    ///
     {
      // check if this will be a valid X
      for(int x=i; x<LookBack ; x++)
        {

         if(CurrentCyleStart == 1 &&   MT_MACD_DAD[x] < MT_MACD_DAD[x+1] && MT_MACD_DAD[x+2] < MT_MACD_DAD[x+1])
           {
            FirstCycleAfter_DADturns[i] = 2;
            // ArrowTimeless(StringConcatenate("WaveCount SwingLowCounter", x), Time[x], Low[x] - 200 * Point, clrBlack, 251);
            break;
           }

         if(CurrentCyleStart >1)
           {
            FirstCycleAfter_DADturns[i] = 0;
            break;
           }

         if(MT_Stoc_K[x] > 55 && MT_Stoc_K[x+1] < 55)
           {
            // this is the start of the current cycle high

            CurrentCyleStart = CurrentCyleStart + 1;
            //   ArrowTimeless(StringConcatenate("WaveCount CurrentCyleStart", x), Time[x], Low[x] - 150 * Point, clrPink, 174);
           }
        }
     }
//---
//--- Buy
//---
   UPCurrentCyleStart = 0;
   if(MT_Stoc_K[i] < 45 && MT_MACD_DAD[i] > MT_MACD_DAD[i+1])    ///
     {
      // check if this will be a valid X
      for(int x=i; x<LookBack ; x++)
        {

         if(UPCurrentCyleStart == 1 &&   MT_MACD_DAD[x] > MT_MACD_DAD[x+1] && MT_MACD_DAD[x+2] > MT_MACD_DAD[x+1])
           {
            FirstCycleAfter_DADturns[i] = 1;
            //  ArrowTimeless(StringConcatenate("WaveCount SwingLowCounter", x), Time[x], Low[x] - 200 * Point, clrBlack, 251);
            break;
           }

         if(UPCurrentCyleStart >1)
           {
            FirstCycleAfter_DADturns[i] = 0;
            break;
           }

         if(MT_Stoc_K[x] < 45 && MT_Stoc_K[x+1] > 45)
           {
            // this is the start of the current cycle high

            UPCurrentCyleStart = UPCurrentCyleStart + 1;
            //    ArrowTimeless(StringConcatenate("WaveCount CurrentCyleStart", x), Time[x], Low[x] - 150 * Point, clrPink, 174);
           }
        }
     }
   return(0);
  }

//+------------------------------------------------------------------+
//|                    FirstCycleAfter_X
//+------------------------------------------------------------------+
int FirstCycleAfter_X(int i)
  {
   int CurrentCyleStart = 0;
   int SwingLowCounter = 0;
   int SwingHighCounter  =0;
   int SwingLowCounter2 = 0;
   int UPSwingHighCounter = 0;
   int UPSwingHighCounter2 = 0;
   int UPSwingLowCounter = 0;
   int UPCurrentCyleStart = 0;
   if(MT_Stoc_K[i] > 45 &&  iClose(currentSymbol,currentTimeframe,i) < MT_MA150[i] && MT_MACD_DAD[i] < MT_MACD_DAD[i+1])    ///
     {
      // check if this will be a valid X
      for(int x=i; x<LookBack && x<actualCopied; x++)
        {
         if(CurrentCyleStart == 1 && MT_UP_Stoc[x] ==1 && iClose(currentSymbol,currentTimeframe,x) < MT_MA150[x])
           {
            if(iClose(currentSymbol,currentTimeframe,x) < MT_MA150[x] && iOpen(currentSymbol,currentTimeframe,x) < MT_MA150[x])
              {
               SwingLowCounter = SwingLowCounter + 1;
              }
            //        ArrowTimeless(StringConcatenate("WaveCount SwingLowCounter", x), Time[x], Low[x] - 200 * Point, clrBlack, 251);
           }

         if(CurrentCyleStart >1 && MT_UP_Stoc[x] ==1 && iClose(currentSymbol,currentTimeframe,x) < MT_MA150[x])
           {
            if(iClose(currentSymbol,currentTimeframe,x) < MT_MA150[x] && iOpen(currentSymbol,currentTimeframe,x) < MT_MA150[x])
              {
               SwingLowCounter2 = SwingLowCounter2 + 1;
              }
            //       ArrowTimeless(StringConcatenate("WaveCount SwingLowCounter4", x), Time[x], High[x] + 200 * Point, clrBlack, 251);
           }


         if(CurrentCyleStart > 1 && SwingLowCounter2 >3)
           {
            //       ArrowTimeless(StringConcatenate("WaveCount break >2 ", x), Time[x], High[x] + 300 * Point, clrBlue, 174);
            break;
           }


         if(SwingLowCounter > 3 && MT_Down_Stoc[x] ==2)
           {
            if(iClose(currentSymbol,currentTimeframe,x) > MT_MA150[x] && iOpen(currentSymbol,currentTimeframe,x) > MT_MA150[x])
              {
               SwingHighCounter = SwingHighCounter + 1;
              }

            //       ArrowTimeless(StringConcatenate("WaveCount SwingHighCounter", x), Time[x], Low[x] - 250 * Point, clrGreenYellow, 174);

           }
         if(SwingLowCounter > 3 && MT_Down_Stoc[x] ==2 &&  MT_Down_Stoc[x+1] !=2)
           {

            if(SwingHighCounter > 2)
              {
               FirstCycleAfter_X[i] = 2;
               //    ArrowTimeless(StringConcatenate("WaveCount Trigger", i), Time[i], Low[i] - 300 * Point, clrLimeGreen, 252);
              }
            else
              {
               CHECK_ARRAY_INDEX(FirstCycleAfter_X, i);
               FirstCycleAfter_X[i] = 0;
              }
            //        ArrowTimeless(StringConcatenate("WaveCount break", x), Time[x], Low[x] - 300 * Point, clrBlue, 174);
            break;
           }
         if(MT_Stoc_K[x] > 45 && MT_Stoc_K[x+1] < 45 && iClose(currentSymbol,currentTimeframe,x) < MT_MA150[x])
           {
            // this is the start of the current cycle high
            //        ArrowTimeless(StringConcatenate("WaveCount CurrentCyleStart", x), Time[x], Low[x] - 150 * Point, clrPink, 174);
            CurrentCyleStart = CurrentCyleStart + 1;
           }
        }
     }
//---
//--- Buy
//---
   UPSwingHighCounter = 0;
   UPSwingHighCounter2 = 0;
   UPSwingLowCounter = 0;
   UPCurrentCyleStart = 0;

   if(MT_Stoc_K[i] < 55 &&  iClose(currentSymbol,currentTimeframe,i)  > MT_MA150[i] && MT_MACD_DAD[i] > MT_MACD_DAD[i+1])    ///
     {
      // check if this will be a valid X
      for(int x=i; x<LookBack ; x++)
        {

         if(UPCurrentCyleStart == 1 && MT_Down_Stoc[x] ==2 && iClose(currentSymbol,currentTimeframe,x) > MT_MA150[x])
           {
            if(iClose(currentSymbol,currentTimeframe,x) > MT_MA150[x] && iOpen(currentSymbol,currentTimeframe,x) > MT_MA150[x])
              {
               UPSwingHighCounter = UPSwingHighCounter + 1;
               //     ArrowTimeless(StringConcatenate("WaveCount SwingLowCounter", x), Time[x], Low[x] - 200 * Point, clrBlack, 251);
              }

           }

         if(UPCurrentCyleStart >1 && MT_Down_Stoc[x] ==2 && iClose(currentSymbol,currentTimeframe,x) > MT_MA150[x])
           {
            if(iClose(currentSymbol,currentTimeframe,x) > MT_MA150[x] && iOpen(currentSymbol,currentTimeframe,x) > MT_MA150[x])
              {
               UPSwingHighCounter2 = UPSwingHighCounter2 + 1;
              }
            //            ArrowTimeless(StringConcatenate("WaveCount SwingLowCounter4", x), Time[x], High[x] + 6000 * Point, clrPink, 110);
           }


         if(UPCurrentCyleStart > 1 && UPSwingHighCounter2 >3)
           {
            // ArrowTimeless(StringConcatenate("WaveCount break >2 ", x), Time[x], High[x] + 300 * Point, clrBlue, 174);
            break;
           }

         if(UPSwingHighCounter > 3 && MT_UP_Stoc[x] ==1)
           {
            //    ArrowTimeless(StringConcatenate("WaveCount SwingHighCounter", x), Time[x], Low[x] - 250 * Point, clrGreenYellow, 174);
            if(iClose(currentSymbol,currentTimeframe,x) < MT_MA150[x] && iOpen(currentSymbol,currentTimeframe,x) < MT_MA150[x])
              {
               UPSwingLowCounter = UPSwingLowCounter + 1;
               //       ArrowTimeless(StringConcatenate("WaveCount SwingHighCounter", x), Time[x], Low[x] - 250 * Point, clrGreenYellow, 174);
              }

           }
         if(UPSwingHighCounter > 3 && MT_UP_Stoc[x] ==1 &&  MT_UP_Stoc[x+1] !=1)
           {
            if(UPSwingLowCounter > 2)
              {
               FirstCycleAfter_X[i] = 1;
               //              ArrowTimeless(StringConcatenate("WaveCount Trigger", i), Time[i], Low[i] - 300 * Point, clrLimeGreen, 252);
              }
            else
              {
               FirstCycleAfter_X[i] = 0;
              }
            //         ArrowTimeless(StringConcatenate("WaveCount break", x), Time[x], Low[x] - 300 * Point, clrBlue, 174);
            break;
           }
         if(MT_Stoc_K[x] < 55 && MT_Stoc_K[x+1] > 55 && iClose(currentSymbol,currentTimeframe,x) > MT_MA150[x])
           {
            // this is the start of the current cycle low
            //           ArrowTimeless(StringConcatenate("WaveCount CurrentCyleStart", x), Time[x], Low[x] - 150 * Point, clrPink, 174);
            UPCurrentCyleStart = UPCurrentCyleStart + 1;
           }
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|           MT_MOM_DAD_Divergence
//+------------------------------------------------------------------+
void MT_MOM_DAD_Divergence()
  {
   double stoch_level55=50;
   double stoch_level45=50;
   bool inSwingHigh = false;
   int swingStartBar = 0;
   int swingEndBar = 0;
   int LastSwingLowBar = -1;
   int LastSwingHighBar55 = -1;
   int LastSwingHighBar45 = -1;
   int LastSwingHighBar = -1;
   swingStartBar = 0;
   swingEndBar = 0;
   int offset = 50;


   for(int i = LookBack-3; i > 0; i--)
     {
      //---
      //--- MOM
      //---

      // Check for swing high start/end (stochastic crosses above 55 threshold)
      //  if(StochSignalBuffer[i] < stoch_level55 && StochSignalBuffer[i+1] >= stoch_level55)
      //MT_Stoc_K
      if(MT_Stoc_K[i] < stoch_level55 && MT_Stoc_K[i+1] >= stoch_level55)
        {
         //   CreateSwingLabel("|", Time[i], MT_MT_MACD_MOM[i] - offset*2, clrBlack);
         swingStartBar = i;
         for(int j = i+1; j < LookBack - 50; j++)
           {
            //    if(StochSignalBuffer[j] < stoch_level55 && StochSignalBuffer[j+1] >= stoch_level55)
            if(MT_Stoc_K[j] < stoch_level55 && MT_Stoc_K[j+1] >= stoch_level55)
              {
               //        CreateSwingLabel("^", Time[j], MT_MT_MACD_MOM[j] - offset*2, clrRed);
               swingEndBar = j;
               break;
              }
           }
         // Find the highest swing value in the range
         if(LastSwingLowBar > -1)
            swingEndBar =  MathMin(swingEndBar,LastSwingLowBar);
         //  Print(" LastSwingLowBar = ",LastSwingLowBar," swingEndBar = ",swingEndBar);
         int maxBar = MT_MACDDiv_FindMaxSwingHIGHInRange(swingStartBar, swingEndBar);
         LastSwingHighBar = maxBar;
         if(maxBar > 0)
           {
            MT_MACDDiv_StoreSwingHighValue(maxBar, MT_MACD_MOM[maxBar]);
           }
        }



      // Check for swing low start/end (stochastic crosses above threshold)
      //   if(StochSignalBuffer[i] > stoch_level45 && StochSignalBuffer[i+1] <= stoch_level45)
      if(MT_Stoc_K[i] > stoch_level45 && MT_Stoc_K[i+1] <= stoch_level45)
        {
         swingStartBar = i;
         for(int j = i+1; j < LookBack - 50; j++)
           {
            // if(StochSignalBuffer[j] > stoch_level45 && StochSignalBuffer[j+1] <= stoch_level45)
            if(MT_Stoc_K[j] > stoch_level45 && MT_Stoc_K[j+1] <= stoch_level45)
              {
               swingEndBar = j;
               break;
              }
           }
         // Find the highest swing value in the range
         //      Print(" LastSwingHighBar = ",LastSwingHighBar," swingEndBar = ",swingEndBar);
         if(LastSwingHighBar > -1)
            swingEndBar = MathMin(swingEndBar,LastSwingHighBar);
         //       int t = MathMin(swingEndBar,LastSwingHighBar);

         int maxBar = MT_MACDDiv_FindMaxSwingLOWInRange(swingStartBar, swingEndBar);
         LastSwingLowBar = maxBar;
         // When you set the LastSwingLowBar value
         if(maxBar > 0)
           {
            MT_MACDDiv_StoreSwingLowValue(maxBar, MT_MACD_MOM[maxBar]);
           }
        }

      //---
      //--- DAD
      //---
      double offset = 50;
      //     Print("i = ",i," MT_MACD_DAD[i+1] =  ",MT_MACD_DAD[i+1]);
      if(MT_MACD_DAD[i+2] < MT_MACD_DAD[i+1] && MT_MACD_DAD[i+1] > MT_MACD_DAD[i])
        {
         DADTurnDown[i+1] = i+1;
         //if(displayDADswinglevels == true)
         //   CreateSwingLabel(i+1, Time[i+1], MT_MACD_DAD[i+1]+offset, SwingHighColor);
        }
      if(MT_MACD_DAD[i+2] > MT_MACD_DAD[i+1] && MT_MACD_DAD[i+1] < MT_MACD_DAD[i])
        {
         DADTurnUP[i+1] = i+1;
         //if(displayDADswinglevels == true)
         //   CreateSwingLabel(i+1, Time[i+1], MT_MACD_DAD[i+1]-offset, SwingLowColor);
        }
     }
   MT_MACDDiv_FilterSwingLowsBetweenHighs();
   MT_MACDDiv_FilterSwingHighsBetweenLows();
   MT_MOMUPPattern();
   MT_MOMDownPattern();
   MT_DADUPPattern();
   MT_DADDOWNPattern();
  }
//+------------------------------------------------------------------+
//---
//---
//---      Supporting transactions for the above
//---
//---
//---
//---
//---
//|                                                                  |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|      StocdivergenceMT                                            |
//+------------------------------------------------------------------+
int StocdivergenceMT(int i)
  {
   double SwingValue = 0;
   double PriceFirstValue,PriceSecondValue;
   int Swing,SwingCnt;
   int ret = 0;
   double StocSwingValue = 0;
   double StocFirstValue,StocSecondValue;
   int StocSwing,StocSwingCnt;


// -STOC
// - BUY
   if(MT_Stoc_K[i]<50 && MT_Stoc_K[i]>20)
     {
      StocFirstValue = MT_Stoc_K[i];
      PriceFirstValue = iClose(currentSymbol,currentTimeframe,i);//Close[i];
      StocSwing = i;
      StocSwingCnt = StocSwingCnt +1;
      for(int k = i; k< LookBack; k++) //     for(int k = i; k<i+100; k++)
        {
         if(MT_Stoc_K[k+1]>50)
           {
            //    ArrowTimeless(StringConcatenate("RubberBand Low",k),Time[k ],Low[k ],clrBlack,108);
            break;
           }
         // Print("MT_Stoc_K[k] = ",MT_Stoc_K[k]);
         if(MT_Stoc_K[k]  > MT_Stoc_K[k+1] && MT_Stoc_K[k+2] > MT_Stoc_K[k+1]&& MT_Stoc_K[k+1]<20)
           {
            //Print(" &&&&&&&&&&& Stock below 20");
            //determine if swing low is below 20  - find StocSwing position
            StocSecondValue = MT_Stoc_K[k+1];//iStochastic(NULL,0,15,9,6,MODE_SMA,0,MODE_MAIN,k+1);
            PriceSecondValue =   MathMin(iClose(currentSymbol,currentTimeframe,k+1),MathMin(iClose(currentSymbol,currentTimeframe,k+2),iClose(currentSymbol,currentTimeframe,k+3)));  // MathMin(Close[k+1],MathMin(Close[k+2],Close[k+3]));
            StocSwing = k+1;
            StocSwingCnt = StocSwingCnt +1;
            //   ArrowTimeless(StringConcatenate("RubberBand Low2",k+1),Time[k+1],PriceSecondValue,clrGreen,108);
            break;
           }
        }
      if(StocSwingCnt == 2)
        {
         for(int x = i; x<StocSwing-1; x++)
           {
            if(iLow(currentSymbol,currentTimeframe,x)  < PriceSecondValue && StocSecondValue < MT_Stoc_K[x]) //Low[x]
              {
               ret=1;
               //  ArrowTimeless(StringConcatenate("RubberBand Low2",x ),Time[x ],PriceSecondValue,clrGreen,108);
              }
           }
        }

     }
//-- SELL

   if(MT_Stoc_K[i]>50 && MT_Stoc_K[i]<80)
     {

      StocFirstValue = MT_Stoc_K[i] ;
      StocSwing = i+1;
      StocSwingCnt = StocSwingCnt +1;
      PriceFirstValue = iClose(currentSymbol,currentTimeframe,i) ;//Close[i];
      for(int k = i; k<LookBack; k++)
        {
         if(MT_Stoc_K[k+1]<50)
           {
            StocSwingCnt = 0;
            break;
           }
         if(MT_Stoc_K[k] < MT_Stoc_K[k+1] && MT_Stoc_K[k+2] < MT_Stoc_K[k+1] && MT_Stoc_K[k+1]>80)
           {
            StocSecondValue =  MT_Stoc_K[k+1];
            PriceSecondValue = MathMax(iClose(currentSymbol,currentTimeframe,k+1),MathMax(iClose(currentSymbol,currentTimeframe,k+2),iClose(currentSymbol,currentTimeframe,k+3)));      //MathMax(Close[k+1],MathMax(Close[k+2],Close[k+3]));
            StocSwing = k+1;
            StocSwingCnt = StocSwingCnt +1;
            //   ArrowTimeless(StringConcatenate("RubberBand Low",i),Time[i ],High[i ]+300*Point,clrRed,108);
            break;
           }
        }
      if(StocSwingCnt == 2)
        {
         for(int x = i; x<StocSwing-1; x++)
           {
            if(iHigh(currentSymbol,currentTimeframe,x)  > PriceSecondValue && StocSecondValue > MT_Stoc_K[x]) //High[x]
              {
               ret=2;
               //    ArrowTimeless(StringConcatenate("RubberBand Low2",x ),Time[x ],PriceSecondValue,clrPink,108);
              }
           }
         //if(StocSwingCnt == 2)
         //  {
         //   if(PriceFirstValue > PriceSecondValue && StocFirstValue < StocSecondValue)
         //     {
         //      //  ArrowTimeless(StringConcatenate("RubberBand Low",i),Time[i ],High[i ]+300*Point,clrRed,108);
         //      ret = 2;
         //     }
        }

     }

   return(ret);
  }

//+------------------------------------------------------------------+
//|     Stoc       - Check MT and ST Stochastics for swing highs.
//+------------------------------------------------------------------+
int ValidStocExtreme(int i)
  {
   int ret = 0;
   if(MT_Stoc_K[i] > 55 && (MT_Stoc_K[i] > 78 || MT_Stoc_K[i+1] > 78 || MT_Stoc_K[i+2] > 78|| MT_Stoc_K[i+3] > 78))
     {
      ret=2;
      //  ArrowTimeless(StringConcatenate("RubberBand StocExtremeHigh",i),Time[i ],High[i],clrPink,108);
     }

   if(MT_Stoc_K[i] < 45 && (MT_Stoc_K[i] < 22 || MT_Stoc_K[i+1] < 22|| MT_Stoc_K[i+3] < 22|| MT_Stoc_K[i+3] < 22))
     {
      ret=1;
      //  ArrowTimeless(StringConcatenate("RubberBand StocExtremeLow",i),Time[i ],Low[i],clrGreen,108);
     }

   return(ret);
  }


//+------------------------------------------------------------------+
//| Store swing high and low safely                                  |
//+------------------------------------------------------------------+
void StoreSwingLowValue(int barIndex, double value)
  {
   if(barIndex >= 0 && barIndex < Bars)
      MACD_MainSwingLow_Value[barIndex] = value;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void StoreSwingHighValue(int barIndex, double value)
  {
   if(barIndex >= 0 && barIndex < Bars)

      MACD_MainSwingHigh_Value[barIndex] = value;

  }

//+------------------------------------------------------------------+
//| Filter logic                                                     |
//+------------------------------------------------------------------+
void FilterSwingLowsBetweenHighs(int Verskil)
  {
   int highPoints[], highCount = 0;
   for(int i = Verskil - 1; i >= 0; i--)
     {
      if(MACD_MainSwingHigh_Value[i] != EMPTY_VALUE && MACD_MainSwingHigh_Value[i] != 0)
        {
         ArrayResize(highPoints, highCount + 1);
         highPoints[highCount++] = i;
        }
     }
   for(int pair = 0; pair < highCount - 1; pair++)
     {
      int startBar = highPoints[pair];
      int endBar   = highPoints[pair + 1];
      if(startBar < endBar)
        {
         int tmp = startBar;
         startBar = endBar;
         endBar = tmp;
        }
      int lowPoints[], lowCount = 0;
      double lowestValue = 999999;
      int lowestIndex = -1;

      for(int i = startBar - 1; i > endBar; i--)
        {
         if(MACD_MainSwingLow_Value[i] != EMPTY_VALUE && MACD_MainSwingLow_Value[i] != 0)
           {
            ArrayResize(lowPoints, lowCount + 1);
            lowPoints[lowCount++] = i;
            if(MACD_MainSwingLow_Value[i] < lowestValue)
              {
               lowestValue = MACD_MainSwingLow_Value[i];
               lowestIndex = i;
              }
           }
        }
      if(lowCount > 1)
        {
         for(int j = 0; j < lowCount; j++)
           {
            if(lowPoints[j] != lowestIndex)
               MACD_MainSwingLow_Value[lowPoints[j]] = 0;
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void FilterSwingHighsBetweenLows(int Verskil)
  {
   int lowPoints[], lowCount = 0;
   for(int i = Verskil - 1; i >= 0; i--)
     {
      if(MACD_MainSwingLow_Value[i] != EMPTY_VALUE && MACD_MainSwingLow_Value[i] != 0)
        {
         ArrayResize(lowPoints, lowCount + 1);
         lowPoints[lowCount++] = i;
        }
     }

   for(int pair = 0; pair < lowCount - 1; pair++)
     {
      int startBar = lowPoints[pair];
      int endBar   = lowPoints[pair + 1];
      if(startBar < endBar)
        {
         int tmp = startBar;
         startBar = endBar;
         endBar = tmp;
        }

      int highPoints[], highCount = 0;
      double highestValue = -999999;
      int highestIndex = -1;

      for(int i = startBar - 1; i > endBar; i--)
        {
         if(MACD_MainSwingHigh_Value[i] != EMPTY_VALUE && MACD_MainSwingHigh_Value[i] != 0)
           {
            ArrayResize(highPoints, highCount + 1);
            highPoints[highCount++] = i;
            if(MACD_MainSwingHigh_Value[i] > highestValue)
              {
               highestValue = MACD_MainSwingHigh_Value[i];
               highestIndex = i;
              }
           }
        }

      if(highCount > 1)
        {
         for(int j = 0; j < highCount; j++)
           {
            if(highPoints[j] != highestIndex)
               MACD_MainSwingHigh_Value[highPoints[j]] = 0;
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|   Scan for Down pattern
//+------------------------------------------------------------------+
//int DownPattern_Old(int Verskil)
//  {
//   double SH1,SH2,SH3, SL1,SL2,SL3;
//
//   double SLFirst = -30000;
//   double SHFirst = -30000;
//
//   int DowntrendSwingCnt = 0;
//   double offset = 50;
//   int LastSwingShift = 0;
//
//   int SH1shift,SH2shift,SH3shift,SL1shift,SL2shift,SL3shift;
//   for(int i = Verskil-1; i >= 0; i--)
//     {
//      if(MACD_MainSwingHigh_Value[i] < 30000 && MACD_MainSwingHigh_Value[i] != 0)
//        {
//         //   Print(" i = ",i, " SH1 = ",SH1);
//         SH3 = SH2;
//         SH3shift = SH2shift;
//         SH2 = SH1;
//         SH2shift = SH1shift;
//         SH1 = MACD_MainSwingHigh_Value[i];
//         SHFirst = SH1;
//         SH1shift = i;
//        }
//      if(MACD_MainSwingLow_Value[i]  < 30000 && MACD_MainSwingLow_Value[i] != 0)
//        {
//         SL3 = SL2;
//         SL3shift = SL2shift;
//         SL2 = SL1;
//
//         SL2shift = SL1shift;
//         SL1 = MACD_MainSwingLow_Value[i];
//         SLFirst = SL1;
//         SL1shift = i;
//        }
//
//
//      if(DowntrendSwingCnt > 0 && LastSwingShift > 0 && SH2 > SH1 && SL2 > SLFirst && SLFirst != -30000)
//        {
//         if(DowntrendSwingCnt % 2 == 0)
//           {
//            DowntrendSwingCnt = DowntrendSwingCnt + 1;
//           }
//        }
//      if(SL3< SL2 && SL1 < SL2 && SL1shift < SH1shift && SL1 != -30000 && SH1 > SH2)
//        {
//         LastSwingShift = SH1shift;
//         DowntrendSwingCnt = 1;
//
//        }
//
//      if(SH3 < SH2 && SH2 > SHFirst && SH1shift < SL1shift && SHFirst != -30000)
//        {
//         LastSwingShift = SH1shift;
//         //if(DowntrendSwingCnt != 1)
//         //  {
//         DowntrendSwingCnt = 0;
//         DowntrendSwingCnt = DowntrendSwingCnt + 1;
//         DowntrendSwingCnt = DowntrendSwingCnt + 1;
//
//        }
//      if((SHFirst > SH2 && SHFirst != -30000)  || (SLFirst > SL2 && SLFirst != -30000))
//        {
//         DowntrendSwingCnt = 0;
//         LastSwingShift = 0;
//        }
//      if(DowntrendSwingCnt > 0)
//        {
//         Print(" DowntrendSwingCnt = ",DowntrendSwingCnt);
//        }
//
//      if(((DowntrendSwingCnt >=5 && MT_UP_Stoc[i] == 1))) //&& MT_MACD_MOM[i] < SH1) || (DowntrendSwingCnt >3 && MT_MACD_MOM[i] < SL1)) )   //    && MT_MA150[i] > MT_MA150[i+3] && && MT_UP_Stoc[i] == 1
//        {
//         // TextTimeless(StringConcatenate("WaveCount",i),Time[i],High[i],clrBlack,10,  MathRound(MT_MACD_MOM[i])+" :      "+ MathRound(SL1),90.0);//+ 10000*Point
//         //  Print(" MT_MACD_MOM[i] < SL1 : MT_MACD_MOM[i]  = ",MT_MACD_MOM[i]," SL1 = ",SL1," DowntrendSwingCnt = ",DowntrendSwingCnt );
//         MT_ReloadPattern[i]=1;
//         Print(" MT_ReloadPattern[i]= ",MT_ReloadPattern[i]);
//        }
//      //---MomWave3
//      if(((DowntrendSwingCnt == 3 && MT_MACD_MOM[i] < SH1) || (DowntrendSwingCnt > 1 && MT_MACD_MOM[i] < SL1 && DowntrendSwingCnt < 4))  && MT_UP_Stoc[i] == 1)//(DowntrendSwingCnt >= 3 && MAINMABuffer[i] > SH1) || (DowntrendSwingCnt > 1 && MAINMABuffer[i] > SL1))
//        {
//         MT_MOM_Wave3[i] = 1;
//        }
//      //---
//      //--- MomWave2
//      if((DowntrendSwingCnt == 1 || DowntrendSwingCnt == 2)  && SL1 < MT_MACD_MOM[i] && SH1 > MT_MACD_MOM[i]  && MT_Stoc_K[i]>50)
//        {
//         MT_MOM_Wave2[i] = 2;
//        }
//      //---
//      SHFirst = -30000;
//      SLFirst = -30000;
//     }
//   return(0);
//  }
////  Print(" i = ",i, " MACD_MainSwingHigh_Value[i] = ",MACD_MainSwingHigh_Value[i]," SHFirst = ",SHFirst," SH2 = ",SH2," SH3 = ",SH3);
//
////      if(DowntrendSwingCnt > 0  && LastSwingShift > 0 && SH2 > SHFirst && SL2 > SL1 && SHFirst != -30000) // )//&& SL1 < SL2)//
////        {
////         if(DowntrendSwingCnt % 2 == 0)
////           {
////           }
////         else
////           {
////            DowntrendSwingCnt = DowntrendSwingCnt + 1;
////           }
////        }
////      if(DowntrendSwingCnt > 0  && LastSwingShift > 0 && SH2 > SH1 && SL2 > SLFirst  && SLFirst != -30000) // )//&& SL1 < SL2)//
////        {
////         if(DowntrendSwingCnt % 2 == 0)
////           {
////            DowntrendSwingCnt = DowntrendSwingCnt + 1;
////
////           }
////         else
////           {
////
////           }
////        }
////      if(SH3 < SH2 && SH2 > SHFirst && SH1shift < SL1shift && SHFirst != -30000) // )//&& SL1 < SL2)//
////        {
////         DowntrendSwingCnt = 0;
////         LastSwingShift = SH1shift;
////         // Print(" Print swings");
////         // CreateSwingLabel("Top", Time[SH2shift], SH2 + offset*4, clrBlack);
////         DowntrendSwingCnt = DowntrendSwingCnt + 1;
////         DowntrendSwingCnt = DowntrendSwingCnt + 1;
////        }
//+------------------------------------------------------------------+
//| Scan for Down pattern                                            |
//+------------------------------------------------------------------+
int DownPattern(int Verskil)
  {
   double SH1, SH2, SH3, SL1, SL2, SL3;
   double SLFirst = -30000;
   double SHFirst = -30000;
   int DowntrendSwingCnt = 0;
   double offset = 0.0001; // Reduced offset for better visibility
   int LastSwingShift = 0;
   int SH1shift, SH2shift, SH3shift, SL1shift, SL2shift, SL3shift;

   for(int i = Verskil-1; i >= 0; i--)
     {
      if(MACD_MainSwingHigh_Value[i] < 30000 && MACD_MainSwingHigh_Value[i] != 0)
        {
         SH3 = SH2;
         SH3shift = SH2shift;
         SH2 = SH1;
         SH2shift = SH1shift;
         SH1 = MACD_MainSwingHigh_Value[i];
         SHFirst = SH1;
         SH1shift = i;
        }

      if(MACD_MainSwingLow_Value[i] < 30000 && MACD_MainSwingLow_Value[i] != 0)
        {
         SL3 = SL2;
         SL3shift = SL2shift;
         SL2 = SL1;
         SL2shift = SL1shift;
         SL1 = MACD_MainSwingLow_Value[i];
         SLFirst = SL1;
         SL1shift = i;
        }

      if(DowntrendSwingCnt > 0 && LastSwingShift > 0 && SH2 > SHFirst && SL2 > SL1 && SHFirst != -30000)//
        {
         if(DowntrendSwingCnt % 2 != 0)
           {
            DowntrendSwingCnt = DowntrendSwingCnt + 1;
            //    CreateSwingLabel(IntegerToString(DowntrendSwingCnt), Time[SH1shift], SHFirst + offset, SwingLowColor);
           }
        }

      if(DowntrendSwingCnt > 0 && LastSwingShift > 0 && SH2 > SH1 && SL2 > SLFirst && SLFirst != -30000)
        {
         if(DowntrendSwingCnt % 2 == 0)
           {
            DowntrendSwingCnt = DowntrendSwingCnt + 1;
            //  CreateSwingLabel(IntegerToString(DowntrendSwingCnt), Time[SL1shift], SLFirst - offset, SwingLowColor);
           }
        }
      if(SL3< SL2 && SL1 < SL2 && SL1shift < SH1shift && SL1 != -30000 && SH1 > SH2)
        {
         LastSwingShift = SH1shift;
         DowntrendSwingCnt = 1;
         // CreateSwingLabel(IntegerToString(DowntrendSwingCnt)+" brk", Time[SL1shift], SL1 + offset, clrBlue);//SwingHighColor);
        }

      if(SH3 < SH2 && SH2 > SHFirst && SH1shift < SL1shift && SHFirst != -30000)
        {
         LastSwingShift = SH1shift;
         //if(DowntrendSwingCnt != 1)
         //  {
         DowntrendSwingCnt = 0;
         DowntrendSwingCnt = DowntrendSwingCnt + 1;
         //  CreateSwingLabel(IntegerToString(DowntrendSwingCnt), Time[SL1shift], SL1 - offset, SwingLowColor);
         //}
         DowntrendSwingCnt = DowntrendSwingCnt + 1;
         // CreateSwingLabel(IntegerToString(DowntrendSwingCnt), Time[SH1shift], SHFirst + offset, SwingLowColor);
        }


      if((SHFirst > SH2 && SHFirst != -30000) || (SLFirst > SL2 && SLFirst != -30000))
        {
         DowntrendSwingCnt = 0;
         LastSwingShift = 0;
        }

      if(((DowntrendSwingCnt >= 5 && MT_MACD_MOM[i] < SH1) || (DowntrendSwingCnt > 3 && MT_MACD_MOM[i] < SL1)) && MT_UP_Stoc[i] == 1)
        {
         //      CreateSwingLabel("*", Time[i], MAINMABuffer[i], SwingHighColor);
         MT_ReloadPattern[i]=1;
        }

      //---MomWave3
      if(((DowntrendSwingCnt == 3 && MT_MACD_MOM[i] < SH1) || (DowntrendSwingCnt > 1 && MT_MACD_MOM[i] < SL1 && DowntrendSwingCnt < 4)) &&  MT_UP_Stoc[i] ==1) //(DowntrendSwingCnt >= 3 && MAINMABuffer[i] > SH1) || (DowntrendSwingCnt > 1 && MAINMABuffer[i] > SL1))
        {
         //  CreateSwingLabel("+", Time[i], MAINMABuffer[i], clrGreen);
         MT_MOM_Wave3[i] = 1;
        }
      //---
      //--- MomWave2
      if((DowntrendSwingCnt == 1 || DowntrendSwingCnt == 2)  && SL1 < MT_MACD_MOM[i] && SH1 > MT_MACD_MOM[i] && MT_Stoc_K[i] > 50)
        {
         //  CreateSwingLabel("+", Time[i], MAINMABuffer[i], clrRed);
         MT_MOM_Wave2[i] = 2;
        }
      //---

      SHFirst = -30000;
      SLFirst = -30000;
     }
   return(0);
  }

//+------------------------------------------------------------------+
//|   Scan for Down pattern
//+------------------------------------------------------------------+
int UPPattern(int Verskil)
  {
   double SH1,SH2,SH3, SL1,SL2,SL3;

   double SLFirst = -30000;
   double SHFirst = -30000;

   int UPtrendSwingCnt = 0;
   double offset = 50;
   int LastSwingShift = 0;

   int SH1shift,SH2shift,SH3shift,SL1shift,SL2shift,SL3shift;
   for(int i = Verskil-1; i >= 0; i--)
     {
      if(MACD_MainSwingHigh_Value[i] < 30000)
        {
         //   Print(" i = ",i, " SH1 = ",SH1);
         SH3 = SH2;
         SH3shift = SH2shift;
         SH2 = SH1;
         SH2shift = SH1shift;
         SH1 = MACD_MainSwingHigh_Value[i];
         SHFirst = SH1;
         SH1shift = i;
        }
      if(MACD_MainSwingLow_Value[i]  < 30000)
        {
         SL3 = SL2;
         SL3shift = SL2shift;
         SL2 = SL1;

         SL2shift = SL1shift;
         SL1 = MACD_MainSwingLow_Value[i];
         SLFirst = SL1;
         SL1shift = i;
        }

      //  Print(" i = ",i, " MACD_MainSwingHigh_Value[i] = ",MACD_MainSwingHigh_Value[i]," SHFirst = ",SHFirst," SH2 = ",SH2," SH3 = ",SH3);

      //if(UPtrendSwingCnt > 0  && LastSwingShift > 0 && SL2 < SLFirst && SH2 < SH1 && SLFirst != -30000) // )//&& SL1 < SL2)//
      //  {
      //   //    Print(" SH2 < SH1 ");
      //   if(UPtrendSwingCnt % 2 == 0)
      //     {
      //     }
      //   else
      //     {
      //      UPtrendSwingCnt = UPtrendSwingCnt + 1;
      //     }
      //  }
      //if(UPtrendSwingCnt > 0  && LastSwingShift > 0 && SL2 < SL1 && SH2 < SHFirst  && SHFirst != -30000) // )//&& SL1 < SL2)//
      //  {
      //   if(UPtrendSwingCnt % 2 == 0)
      //     {
      //      UPtrendSwingCnt = UPtrendSwingCnt + 1;
      //     }
      //   else
      //     {
      //     }
      //  }
      //if(SL3 > SL2 && SL2 < SLFirst && SL1shift < SH1shift && SLFirst != -30000) // )//&& SL1 < SL2)//
      //  {
      //   UPtrendSwingCnt = 0;
      //   LastSwingShift = SL1shift;
      //   // Print(" Print swings");
      //   //  CreateSwingLabel("Bot", Time[SL2shift], SL2 - offset*2, clrBlack);
      //   UPtrendSwingCnt = UPtrendSwingCnt + 1;
      //   UPtrendSwingCnt = UPtrendSwingCnt + 1;
      //  }
      if(UPtrendSwingCnt > 0 && LastSwingShift > 0 && SL2 < SLFirst && SH2 < SH1 && SLFirst != -30000)
        {
         if(UPtrendSwingCnt % 2 != 0)
           {
            UPtrendSwingCnt = UPtrendSwingCnt + 1;
           }
        }

      if(UPtrendSwingCnt > 0 && LastSwingShift > 0 && SL2 < SL1 && SH2 < SHFirst && SHFirst != -30000)
        {
         if(UPtrendSwingCnt % 2 == 0)
           {
            UPtrendSwingCnt = UPtrendSwingCnt + 1;
           }
        }


      if(SH3> SH2 && SH1 > SH2 && SH1shift < SL1shift && SH1 != -30000 && SL1 < SL2)
        {
         LastSwingShift = SL1shift;
         UPtrendSwingCnt = 1;

        }
      if(SL3 > SL2 && SL2 < SLFirst && SL1shift < SH1shift && SLFirst != -30000)
        {

         LastSwingShift = SL1shift;

         UPtrendSwingCnt = 0;
         UPtrendSwingCnt = UPtrendSwingCnt + 1;

         UPtrendSwingCnt = UPtrendSwingCnt + 1;

        }
      if((SLFirst < SL2 && SLFirst != -30000)  || (SHFirst < SH2 && SHFirst != -30000))
        {
         UPtrendSwingCnt = 0;
         LastSwingShift = 0;
        }

      if(((UPtrendSwingCnt >=5) && MT_Down_Stoc[i] == 2)) //&& MT_MACD_MOM[i] > SL1) || (UPtrendSwingCnt >3 && MT_MACD_MOM[i] > SH1)) ) // && MT_MA150[i] < MT_MA150[i+3] &&&& MT_UP_Stoc[i] == 2
        {
         // TextTimeless(StringConcatenate("WaveCount",i),Time[i],High[i],clrBlack,10,  MathRound(MT_MACD_MOM[i])+" :      "+ MathRound(SL1),90.0);//+ 10000*Point
         //  Print(" MT_MACD_MOM[i] < SL1 : MT_MACD_MOM[i]  = ",MT_MACD_MOM[i]," SL1 = ",SL1," DowntrendSwingCnt = ",DowntrendSwingCnt );
         MT_ReloadPattern[i]=2;
        }
      //---MomWave3

      if(((UPtrendSwingCnt == 3 && MT_MACD_MOM[i] > SL1) || (UPtrendSwingCnt ==2  && MT_MACD_MOM[i] > GetHighestMACDBetweenStochCrossover(i) && UPtrendSwingCnt < 4 && SL1shift < SH1shift))&& MT_Down_Stoc[i] ==2) //
        {
         MT_MOM_Wave3[i] = 2;
        }
      //---
      //--- MomWave2

      if((UPtrendSwingCnt == 1 || UPtrendSwingCnt == 2)  && SH1 > MT_MACD_MOM[i] && SL1 < MT_MACD_MOM[i]  && MT_Stoc_K[i] < 50)
        {
         MT_MOM_Wave2[i] = 1;
        }
      //---
      SHFirst = -30000;
      SLFirst = -30000;
     }
   return(0);
  }
//+------------------------------------------------------------------+
//| Function to find highest MAINMABuffer value between stochastic  |
//| crossovers above and below 50 in the previous high cycle        |
//+------------------------------------------------------------------+
double GetHighestMACDBetweenStochCrossover(int startIndex, int maxBarsBack = 500)
  {
   double highestValue = EMPTY_VALUE;
   int crossAbove50 = -1;
   int crossBelow50 = -1;

// Find the most recent stochastic cross below 50 (return point)
   for(int i = startIndex; i < startIndex + maxBarsBack && i < LookBack - 1; i++)
     {
      if(MT_Stoc_K[i] < 50.0 && MT_Stoc_K[i + 1] >= 50.0)
        {
         crossBelow50 = i;
         break;
        }
     }

// If we found a cross below 50, now find the previous cross above 50
   if(crossBelow50 != -1)
     {
      for(int i = crossBelow50 + 1; i < startIndex + maxBarsBack && i < LookBack - 1; i++)
        {
         if(MT_Stoc_K[i] >= 50.0 && MT_Stoc_K[i + 1] < 50.0)
           {
            crossAbove50 = i;
            break;
           }
        }
     }

// If we found both crossover points, find the highest MACD value between them
   if(crossAbove50 != -1 && crossBelow50 != -1)
     {
      highestValue = MT_MACD_MOM[crossAbove50]; // Initialize with first value

      for(int i = crossAbove50; i >= crossBelow50; i--)
        {
         if(MT_MACD_MOM[i] != 0 && MT_MACD_MOM[i] != EMPTY_VALUE && MT_MACD_MOM[i] > highestValue)
           {
            highestValue = MT_MACD_MOM[i];
           }
        }

      // Debug print
      //Print("Stoch Cross Above 50 at bar: ", crossAbove50,
      //      " Cross Below 50 at bar: ", crossBelow50,
      //      " Highest MACD: ", DoubleToString(highestValue, 5));
     }

   return highestValue;
  }
//+------------------------------------------------------------------+
//| Find max swing high in a range                                   |
//+------------------------------------------------------------------+
int FindMaxSwingLOWInRange(int startBar, int endBar)
  {
   double maxValue = 3000000;
   int maxBar = -1;
// Print(" startBar = ",startBar," endBar = ",endBar);

   for(int i = startBar; i <= endBar; i++)
     {
      // Print(" i = ",i," MT_MACD_DAD[i] = ",MT_MACD_MOM[i]," maxValue = ",maxValue);
      if(MT_MACD_MOM[i] < MT_MACD_MOM[i+1] && MT_MACD_MOM[i] < MT_MACD_MOM[i-1] && MT_MACD_MOM[i] < maxValue)
        {
         //    Print("Max value found: i= ",i);
         maxValue = MT_MACD_MOM[i];
         maxBar = i;
        }
     }
   return maxBar;
  }
//+------------------------------------------------------------------+
//| Find max swing high in a range                                   |
//+------------------------------------------------------------------+
int FindMaxSwingHIGHInRange(int startBar, int endBar)
  {
   double maxValue = -3000000;
   int maxBar = -1;
// Print(" startBar = ",startBar," endBar = ",endBar);

   for(int i = startBar; i <= endBar; i++)
     {
      //   Print(" i = ",i," MT_MACD_DAD[i] = ",MT_MACD_MOM[i]," maxValue = ",maxValue);
      if(MT_MACD_MOM[i] > MT_MACD_MOM[i+1] && MT_MACD_MOM[i] > MT_MACD_MOM[i-1] && MT_MACD_MOM[i] > maxValue)
        {
         //     Print("Max value found: i= ",i);
         maxValue = MT_MACD_MOM[i];
         maxBar = i;
        }
     }
   return maxBar;
  }
//+------------------------------------------------------------------+
//| Main calculation trigger (run on every new bar)                  |
//+------------------------------------------------------------------+
void CalculateOverExtended()
  {
   ArrayInitialize(MACD_MainSwingHigh_Value, EMPTY_VALUE);
   ArrayInitialize(MACD_MainSwingLow_Value, EMPTY_VALUE);
   ArrayInitialize(MT_ReloadPattern, 0);

// Detect stochastic-based swing points
   bool inSwingHigh = false;
   int swingStartBar = 0;
   int swingEndBar = 0;
   int LastSwingLowBar = -1;
   int LastSwingHighBar55 = -1;
   int LastSwingHighBar45 = -1;
   int LastSwingHighBar = -1;
   swingStartBar = 0;
   swingEndBar = 0;
   double stoch_level55=50;
   double stoch_level45=50;
   for(int i = LookBack-2; i > 0; i--)
     {
      // Check for swing high start/end (stochastic crosses above 55 threshold)
      if(MT_Stoc_D[i] < stoch_level55 && MT_Stoc_D[i+1] >= stoch_level55)
        {
         swingStartBar = i;
         for(int j = i+1; j < LookBack; j++)
           {
            if(MT_Stoc_D[j] < stoch_level55 && MT_Stoc_D[j+1] >= stoch_level55)
              {
               swingEndBar = j;
               break;
              }
           }
         // Find the highest swing value in the range
         if(LastSwingLowBar > -1)
            swingEndBar =  MathMin(swingEndBar,LastSwingLowBar);
         //  Print(" LastSwingLowBar = ",LastSwingLowBar," swingEndBar = ",swingEndBar);
         int maxBar = FindMaxSwingHIGHInRange(swingStartBar, swingEndBar);
         LastSwingHighBar = maxBar;
         if(maxBar > 0)
           {
            //     ArrowTimeless(StringConcatenate("WaveCount SH", maxBar), Time[maxBar], High[maxBar] + 500 * Point, clrRed, 167);
            StoreSwingHighValue(maxBar, MT_MACD_MOM[maxBar]);
           }
        }
      if(MT_Stoc_D[i] < stoch_level45 && MT_Stoc_D[i+1] >= stoch_level45)
        {
         swingStartBar = i;
         for(int j = i+1; j < LookBack; j++)
           {
            if(MT_Stoc_D[j] < stoch_level45 && MT_Stoc_D[j+1] >= stoch_level45)
              {
               swingEndBar = j;
               break;
              }
           }
         // Find the highest swing value in the range
         if(LastSwingLowBar > -1)
            swingEndBar =  MathMin(swingEndBar,LastSwingLowBar);
         //  Print(" LastSwingLowBar = ",LastSwingLowBar," swingEndBar = ",swingEndBar);
         int maxBar = FindMaxSwingHIGHInRange(swingStartBar, swingEndBar);
         LastSwingHighBar = maxBar;
         if(maxBar > 0)
           {
            //        ArrowTimeless(StringConcatenate("WaveCount SH", maxBar), Time[maxBar], High[maxBar] + 500 * Point, clrRed, 167);
            StoreSwingHighValue(maxBar, MT_MACD_MOM[maxBar]);
           }
        }
      // Check for swing low start/end (stochastic crosses above threshold)
      if(MT_Stoc_D[i] > stoch_level45 && MT_Stoc_D[i+1] <= stoch_level45)
        {
         swingStartBar = i;
         for(int j = i+1; j < LookBack ; j++)
           {
            if(MT_Stoc_D[j] > stoch_level45 && MT_Stoc_D[j+1] <= stoch_level45)
              {
               swingEndBar = j;
               break;
              }
           }
         // Find the highest swing value in the range
         //      Print(" LastSwingHighBar = ",LastSwingHighBar," swingEndBar = ",swingEndBar);
         if(LastSwingHighBar > -1)
            swingEndBar = MathMin(swingEndBar,LastSwingHighBar);
         int maxBar = FindMaxSwingLOWInRange(swingStartBar, swingEndBar);
         LastSwingLowBar = maxBar;
         // When you set the LastSwingLowBar value
         if(maxBar > 0)
           {
            //      ArrowTimeless(StringConcatenate("WaveCount SL1", maxBar), Time[maxBar], Low[maxBar] - 500 * Point, clrBlueViolet, 167);
            StoreSwingLowValue(maxBar, MT_MACD_MOM[maxBar]);
           }
        }
      // Check for swing low start/end (stochastic crosses above threshold)
      if(MT_Stoc_D[i] > stoch_level55 && MT_Stoc_D[i+1] <= stoch_level55)
        {
         //     Print(" MT_Stoc_D[i] > stoch_level55 ");
         swingStartBar = i;
         for(int j = i+1; j < LookBack; j++)
           {
            if(MT_Stoc_D[j] > stoch_level55 && MT_Stoc_D[j+1] <= stoch_level55)
              {
               inSwingHigh = false;
               swingEndBar = j;
               break;
              }
           }
         //      Find the highest swing value in the range
         if(LastSwingHighBar > -1)
            swingEndBar = MathMin(swingEndBar,LastSwingHighBar);
         int t = MathMin(swingEndBar,LastSwingHighBar);
         int maxBar = FindMaxSwingLOWInRange(swingStartBar, swingEndBar);
         LastSwingLowBar = maxBar;
         if(maxBar > 0)
           {
            StoreSwingLowValue(maxBar, MT_MACD_MOM[maxBar]);
            //   ArrowTimeless(StringConcatenate("WaveCount SL1", maxBar), Time[maxBar], Low[maxBar] - 500 * Point, clrBlueViolet, 167);
           }
        }
     }
   FilterSwingLowsBetweenHighs(LookBack);
   FilterSwingHighsBetweenLows(LookBack);
   UPPattern(LookBack);
   DownPattern(LookBack);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//---
//---
//---
//---
//---          Reload pattern  ST
//---
//---
//---
//---
//|                                                                  |
//+------------------------------------------------------------------+




//+------------------------------------------------------------------+
//| Store swing high and low safely                                  |
//+------------------------------------------------------------------+
void ST_StoreSwingLowValue(int barIndex, double value)
  {
   if(barIndex >= 0 && barIndex < Bars)
      ST_MACD_MainSwingLow_Value[barIndex] = value;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ST_StoreSwingHighValue(int barIndex, double value)
  {
   if(barIndex >= 0 && barIndex < Bars)
      ST_MACD_MainSwingHigh_Value[barIndex] = value;
  }

//+------------------------------------------------------------------+
//| Filter logic                                                     |
//+------------------------------------------------------------------+
void ST_FilterSwingLowsBetweenHighs(int Verskil)
  {
   int highPoints[], highCount = 0;
   for(int i = Verskil - 1; i >= 0; i--)
     {

      if(ST_MACD_MainSwingHigh_Value[i] != EMPTY_VALUE && ST_MACD_MainSwingHigh_Value[i] != 0)
        {


         ArrayResize(highPoints, highCount + 1);
         highPoints[highCount++] = i;
        }
     }

   for(int pair = 0; pair < highCount - 1; pair++)
     {
      int startBar = highPoints[pair];
      int endBar   = highPoints[pair + 1];
      if(startBar < endBar)
        {
         int tmp = startBar;
         startBar = endBar;
         endBar = tmp;
        }

      int lowPoints[], lowCount = 0;
      double lowestValue = 999999;
      int lowestIndex = -1;

      for(int i = startBar - 1; i > endBar; i--)
        {
         if(ST_MACD_MainSwingLow_Value[i] != EMPTY_VALUE && ST_MACD_MainSwingLow_Value[i] != 0)
           {

            ArrayResize(lowPoints, lowCount + 1);
            lowPoints[lowCount++] = i;
            if(ST_MACD_MainSwingLow_Value[i] < lowestValue)
              {
               lowestValue = ST_MACD_MainSwingLow_Value[i];
               lowestIndex = i;
              }
           }
        }

      if(lowCount > 1)
        {
         for(int j = 0; j < lowCount; j++)
           {
            if(lowPoints[j] != lowestIndex)
               ST_MACD_MainSwingLow_Value[lowPoints[j]] = 0;
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ST_FilterSwingHighsBetweenLows(int Verskil)
  {
   int lowPoints[], lowCount = 0;
   for(int i = Verskil - 1; i >= 0; i--)
     {
      if(ST_MACD_MainSwingLow_Value[i] != EMPTY_VALUE && ST_MACD_MainSwingLow_Value[i] != 0)
        {
         ArrayResize(lowPoints, lowCount + 1);
         lowPoints[lowCount++] = i;
        }
     }

   for(int pair = 0; pair < lowCount - 1; pair++)
     {
      int startBar = lowPoints[pair];
      int endBar   = lowPoints[pair + 1];
      if(startBar < endBar)
        {
         int tmp = startBar;
         startBar = endBar;
         endBar = tmp;
        }

      int highPoints[], highCount = 0;
      double highestValue = -999999;
      int highestIndex = -1;

      for(int i = startBar - 1; i > endBar; i--)
        {
         if(ST_MACD_MainSwingHigh_Value[i] != EMPTY_VALUE && ST_MACD_MainSwingHigh_Value[i] != 0)
           {
            ArrayResize(highPoints, highCount + 1);
            highPoints[highCount++] = i;
            if(ST_MACD_MainSwingHigh_Value[i] > highestValue)
              {
               highestValue = ST_MACD_MainSwingHigh_Value[i];
               highestIndex = i;
              }
           }
        }

      if(highCount > 1)
        {
         for(int j = 0; j < highCount; j++)
           {
            if(highPoints[j] != highestIndex)
               ST_MACD_MainSwingHigh_Value[highPoints[j]] = 0;
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|   Scan for Down pattern
//+------------------------------------------------------------------+
int ST_DownPattern(int Verskil)
  {
   double SH1,SH2,SH3, SL1,SL2,SL3;

   double SLFirst = -30000;
   double SHFirst = -30000;

   int DowntrendSwingCnt = 0;
   double offset = 50;
   int LastSwingShift = 0;

   int SH1shift,SH2shift,SH3shift,SL1shift,SL2shift,SL3shift;
   for(int i = Verskil-1; i >= 0; i--)
     {
      if(ST_MACD_MainSwingHigh_Value[i] < 30000)
        {
         //   Print(" i = ",i, " SH1 = ",SH1);
         SH3 = SH2;
         SH3shift = SH2shift;
         SH2 = SH1;
         SH2shift = SH1shift;
         SH1 = ST_MACD_MainSwingHigh_Value[i];
         SHFirst = SH1;
         SH1shift = i;
        }
      if(ST_MACD_MainSwingLow_Value[i]  < 30000)
        {
         SL3 = SL2;
         SL3shift = SL2shift;
         SL2 = SL1;

         SL2shift = SL1shift;
         SL1 = ST_MACD_MainSwingLow_Value[i];
         SLFirst = SL1;
         SL1shift = i;
        }

      //  Print(" i = ",i, " MACD_MainSwingHigh_Value[i] = ",MACD_MainSwingHigh_Value[i]," SHFirst = ",SHFirst," SH2 = ",SH2," SH3 = ",SH3);

      if(DowntrendSwingCnt > 0  && LastSwingShift > 0 && SH2 > SHFirst && SL2 > SL1 && SHFirst != -30000) // )//&& SL1 < SL2)//
        {
         if(DowntrendSwingCnt % 2 == 0)
           {
           }
         else
           {
            DowntrendSwingCnt = DowntrendSwingCnt + 1;
           }
        }
      if(DowntrendSwingCnt > 0  && LastSwingShift > 0 && SH2 > SH1 && SL2 > SLFirst  && SLFirst != -30000) // )//&& SL1 < SL2)//
        {
         if(DowntrendSwingCnt % 2 == 0)
           {
            DowntrendSwingCnt = DowntrendSwingCnt + 1;

           }
         else
           {

           }
        }
      if(SH3 < SH2 && SH2 > SHFirst && SH1shift < SL1shift && SHFirst != -30000) // )//&& SL1 < SL2)//
        {
         DowntrendSwingCnt = 0;
         LastSwingShift = SH1shift;
         // Print(" Print swings");
         // CreateSwingLabel("Top", Time[SH2shift], SH2 + offset*4, clrBlack);
         DowntrendSwingCnt = DowntrendSwingCnt + 1;
         DowntrendSwingCnt = DowntrendSwingCnt + 1;
        }

      if((SHFirst > SH2 && SHFirst != -30000)  || (SLFirst > SL2 && SLFirst != -30000))
        {
         DowntrendSwingCnt = 0;
         LastSwingShift = 0;
        }

      if(((DowntrendSwingCnt >=5 && ST_MACD_MOM[i] < SH1) || (DowntrendSwingCnt >3 && ST_MACD_MOM[i] < SL1))&& MT_UP_Stoc[i] == 1) // && ST_MA50[i] > ST_MA50[i+1] && MT_UP_Stoc[i] == 1
        {
         // TextTimeless(StringConcatenate("WaveCount",i),Time[i],High[i],clrBlack,10,  MathRound(MT_MACD_MOM[i])+" :      "+ MathRound(SL1),90.0);//+ 10000*Point
         //  Print(" MT_MACD_MOM[i] < SL1 : MT_MACD_MOM[i]  = ",MT_MACD_MOM[i]," SL1 = ",SL1," DowntrendSwingCnt = ",DowntrendSwingCnt );

         ST_ReloadPattern[i]=1;
        }
      SHFirst = -30000;
      SLFirst = -30000;
     }
   return(0);
  }

//+------------------------------------------------------------------+
//|   Scan for Down pattern
//+------------------------------------------------------------------+
int ST_UPPattern(int Verskil)
  {
   double SH1,SH2,SH3, SL1,SL2,SL3;

   double SLFirst = -30000;
   double SHFirst = -30000;

   int UPtrendSwingCnt = 0;
   double offset = 50;
   int LastSwingShift = 0;

   int SH1shift,SH2shift,SH3shift,SL1shift,SL2shift,SL3shift;
   for(int i = Verskil-1; i >= 0; i--)
     {
      if(ST_MACD_MainSwingHigh_Value[i] < 30000)
        {
         //   Print(" i = ",i, " SH1 = ",SH1);
         SH3 = SH2;
         SH3shift = SH2shift;
         SH2 = SH1;
         SH2shift = SH1shift;
         SH1 = ST_MACD_MainSwingHigh_Value[i];
         SHFirst = SH1;
         SH1shift = i;
        }
      if(ST_MACD_MainSwingLow_Value[i]  < 30000)
        {
         SL3 = SL2;
         SL3shift = SL2shift;
         SL2 = SL1;

         SL2shift = SL1shift;
         SL1 = ST_MACD_MainSwingLow_Value[i];
         SLFirst = SL1;
         SL1shift = i;
        }

      //  Print(" i = ",i, " MACD_MainSwingHigh_Value[i] = ",MACD_MainSwingHigh_Value[i]," SHFirst = ",SHFirst," SH2 = ",SH2," SH3 = ",SH3);

      if(UPtrendSwingCnt > 0  && LastSwingShift > 0 && SL2 < SLFirst && SH2 < SH1 && SLFirst != -30000) // )//&& SL1 < SL2)//
        {
         //    Print(" SH2 < SH1 ");
         if(UPtrendSwingCnt % 2 == 0)
           {
           }
         else
           {
            UPtrendSwingCnt = UPtrendSwingCnt + 1;
           }
        }
      if(UPtrendSwingCnt > 0  && LastSwingShift > 0 && SL2 < SL1 && SH2 < SHFirst  && SHFirst != -30000) // )//&& SL1 < SL2)//
        {
         if(UPtrendSwingCnt % 2 == 0)
           {
            UPtrendSwingCnt = UPtrendSwingCnt + 1;
           }
         else
           {
           }
        }
      if(SL3 > SL2 && SL2 < SLFirst && SL1shift < SH1shift && SLFirst != -30000) // )//&& SL1 < SL2)//
        {
         UPtrendSwingCnt = 0;
         LastSwingShift = SL1shift;
         // Print(" Print swings");
         //  CreateSwingLabel("Bot", Time[SL2shift], SL2 - offset*2, clrBlack);
         UPtrendSwingCnt = UPtrendSwingCnt + 1;
         UPtrendSwingCnt = UPtrendSwingCnt + 1;
        }
      if((SLFirst < SL2 && SLFirst != -30000)  || (SHFirst < SH2 && SHFirst != -30000))
        {
         UPtrendSwingCnt = 0;
         LastSwingShift = 0;
        }
      if(((UPtrendSwingCnt >=5 && ST_MACD_MOM[i] > SL1) || (UPtrendSwingCnt >3 && ST_MACD_MOM[i] > SH1)) && MT_Down_Stoc[i] == 2) // && ST_MA50[i] < ST_MA50[i+1] && MT_UP_Stoc[i] == 2
        {
         // TextTimeless(StringConcatenate("WaveCount",i),Time[i],High[i],clrBlack,10,  MathRound(MT_MACD_MOM[i])+" :      "+ MathRound(SL1),90.0);//+ 10000*Point
         //  Print(" MT_MACD_MOM[i] < SL1 : MT_MACD_MOM[i]  = ",MT_MACD_MOM[i]," SL1 = ",SL1," DowntrendSwingCnt = ",DowntrendSwingCnt );
         ST_ReloadPattern[i]=2;
        }
      SHFirst = -30000;
      SLFirst = -30000;
     }
   return(0);
  }
//+------------------------------------------------------------------+
//| Find max swing high in a range                                   |
//+------------------------------------------------------------------+
int ST_FindMaxSwingLOWInRange(int startBar, int endBar)
  {
   double maxValue = 3000000;
   int maxBar = -1;
// Print(" startBar = ",startBar," endBar = ",endBar);

   for(int i = startBar; i <= endBar; i++)
     {
      // Print(" i = ",i," MT_MACD_DAD[i] = ",MT_MACD_MOM[i]," maxValue = ",maxValue);
      if(ST_MACD_MOM[i] < ST_MACD_MOM[i+1] && ST_MACD_MOM[i] < ST_MACD_MOM[i-1] && ST_MACD_MOM[i] < maxValue)
        {
         //    Print("Max value found: i= ",i);
         maxValue = ST_MACD_MOM[i];
         maxBar = i;
        }
     }
   return maxBar;
  }
//+------------------------------------------------------------------+
//| Find max swing high in a range                                   |
//+------------------------------------------------------------------+
int ST_FindMaxSwingHIGHInRange(int startBar, int endBar)
  {
   double maxValue = -3000000;
   int maxBar = -1;
// Print(" startBar = ",startBar," endBar = ",endBar);

   for(int i = startBar; i <= endBar; i++)
     {
      //   Print(" i = ",i," MT_MACD_DAD[i] = ",MT_MACD_MOM[i]," maxValue = ",maxValue);
      if(ST_MACD_MOM[i] > ST_MACD_MOM[i+1] && ST_MACD_MOM[i] > ST_MACD_MOM[i-1] && ST_MACD_MOM[i] > maxValue)
        {
         //     Print("Max value found: i= ",i);
         maxValue = ST_MACD_MOM[i];
         maxBar = i;
        }
     }
   return maxBar;
  }
//+------------------------------------------------------------------+
//| Main calculation trigger (run on every new bar)                  |
//+------------------------------------------------------------------+
void ST_CalculateOverExtended()
  {
   ArrayInitialize(ST_MACD_MainSwingHigh_Value, EMPTY_VALUE);
   ArrayInitialize(ST_MACD_MainSwingLow_Value, EMPTY_VALUE);
   ArrayInitialize(ST_ReloadPattern, 0);

// Detect stochastic-based swing points
   bool inSwingHigh = false;
   int swingStartBar = 0;
   int swingEndBar = 0;
   int LastSwingLowBar = -1;
   int LastSwingHighBar55 = -1;
   int LastSwingHighBar45 = -1;
   int LastSwingHighBar = -1;
   swingStartBar = 0;
   swingEndBar = 0;
   double stoch_level55=55;
   double stoch_level45=45;
   for(int i = LookBack-2; i > 0; i--)
     {
      // Check for swing high start/end (stochastic crosses above 55 threshold)
      if(ST_Stoc_D[i] < stoch_level55 && ST_Stoc_D[i+1] >= stoch_level55)
        {
         swingStartBar = i;
         for(int j = i+1; j < LookBack; j++)
           {
            if(ST_Stoc_D[j] < stoch_level55 && ST_Stoc_D[j+1] >= stoch_level55)
              {
               swingEndBar = j;
               break;
              }
           }
         // Find the highest swing value in the range
         if(LastSwingLowBar > -1)
            swingEndBar =  MathMin(swingEndBar,LastSwingLowBar);
         //  Print(" LastSwingLowBar = ",LastSwingLowBar," swingEndBar = ",swingEndBar);
         int maxBar = ST_FindMaxSwingHIGHInRange(swingStartBar, swingEndBar);
         LastSwingHighBar = maxBar;
         if(maxBar > 0)
           {
            ST_StoreSwingHighValue(maxBar, ST_MACD_MOM[maxBar]);
           }
        }
      if(ST_Stoc_D[i] < stoch_level45 && ST_Stoc_D[i+1] >= stoch_level45)
        {
         swingStartBar = i;
         for(int j = i+1; j < LookBack; j++)
           {
            if(ST_Stoc_D[j] < stoch_level45 && ST_Stoc_D[j+1] >= stoch_level45)
              {
               swingEndBar = j;
               break;
              }
           }
         // Find the highest swing value in the range
         if(LastSwingLowBar > -1)
            swingEndBar =  MathMin(swingEndBar,LastSwingLowBar);
         //  Print(" LastSwingLowBar = ",LastSwingLowBar," swingEndBar = ",swingEndBar);
         int maxBar = ST_FindMaxSwingHIGHInRange(swingStartBar, swingEndBar);
         LastSwingHighBar = maxBar;
         if(maxBar > 0)
           {
            ST_StoreSwingHighValue(maxBar, ST_MACD_MOM[maxBar]);
           }
        }
      // Check for swing low start/end (stochastic crosses above threshold)
      if(ST_Stoc_D[i] > stoch_level45 && ST_Stoc_D[i+1] <= stoch_level45)
        {
         swingStartBar = i;
         for(int j = i+1; j < LookBack ; j++)
           {
            if(ST_Stoc_D[j] > stoch_level45 && ST_Stoc_D[j+1] <= stoch_level45)
              {
               swingEndBar = j;
               break;
              }
           }
         // Find the highest swing value in the range
         //      Print(" LastSwingHighBar = ",LastSwingHighBar," swingEndBar = ",swingEndBar);
         if(LastSwingHighBar > -1)
            swingEndBar = MathMin(swingEndBar,LastSwingHighBar);
         int maxBar = ST_FindMaxSwingLOWInRange(swingStartBar, swingEndBar);
         LastSwingLowBar = maxBar;
         // When you set the LastSwingLowBar value
         if(maxBar > 0)
           {
            ST_StoreSwingLowValue(maxBar, ST_MACD_MOM[maxBar]);
           }
        }
      // Check for swing low start/end (stochastic crosses above threshold)
      if(ST_Stoc_D[i] > stoch_level55 && ST_Stoc_D[i+1] <= stoch_level55)
        {
         //     Print(" MT_Stoc_D[i] > stoch_level55 ");
         swingStartBar = i;
         for(int j = i+1; j < LookBack; j++)
           {
            if(ST_Stoc_D[j] > stoch_level55 && ST_Stoc_D[j+1] <= stoch_level55)
              {
               inSwingHigh = false;
               swingEndBar = j;
               break;
              }
           }
         //      Find the highest swing value in the range
         if(LastSwingHighBar > -1)
            swingEndBar = MathMin(swingEndBar,LastSwingHighBar);
         int t = MathMin(swingEndBar,LastSwingHighBar);
         int maxBar = ST_FindMaxSwingLOWInRange(swingStartBar, swingEndBar);
         LastSwingLowBar = maxBar;
         if(maxBar > 0)
           {
            ST_StoreSwingLowValue(maxBar, ST_MACD_MOM[maxBar]);
           }
        }
     }
   ST_FilterSwingLowsBetweenHighs(LookBack);
   ST_FilterSwingHighsBetweenLows(LookBack);
   ST_UPPattern(LookBack);
   ST_DownPattern(LookBack);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ClearHeatmapAll()
  {
   int    obj_total=ObjectsTotal();
   string name;
   for(int i=0; i<obj_total; i++)

     {
      name=ObjectName(i);
      if(name!="")
        {
         if(StringFind(name,"Heat",0)!=-1)

           {
            ObjectDelete(name);
            int err=GetLastError();
            i=i-1;
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawHeatmapBand_Enhanced(string baseName, double &array[], int verticalIndex, int maxBars)
  {

   int chartId = 0;
//Print("=== DrawHeatmapBand_Enhanced START ===");
//Print("BaseName: ", baseName, " VerticalIndex: ", verticalIndex);

   if(ArraySize(array) == 0)
      return;

   double bandTop, bandBottom;
   for(int i = maxBars; i >0 && i < actualCopied; i--)
     {
      //// Get 150SMA values for current and previous bars to determine direction
      double sma365_current = ST_MA365[i];
      double sma365_previous = ST_MA365[i+1];
      double sma150_current = MT_MA150[i];
      // Get ATR value
      //double atr_value = iATR(NULL, 0, 100, 1);
      double atr_value = ATR[i];
      // Adjust for multiple vertical bands (if needed)
      double bandSpacing = atr_value * 0.3;  // Space between multiple bands
      // Check if SMA values are valid
      //if(sma365_current == 0 || sma365_previous == 0 || atr_value == 0)
      //  {
      //   Print("ERROR: Invalid SMA150 or ATR values - SMA Current: ", sma365_current,
      //         " SMA Previous: ", sma365_previous, " ATR: ", atr_value);
      //   return;
      //  }

      // Determine SMA direction
      bool sma_moving_up = (sma150_current > sma365_previous);


      // Position the band based on SMA direction


      //if(sma_moving_up)
      //  {
      //   // SMA moving UP: band top is ATR below the 150SMA
      //   bandTop = sma150_current - bandSpacing;
      //   bandBottom = bandTop - bandSpacing;  // Band height = ATR
      //   bandTop -= (verticalIndex * bandSpacing);
      //   bandBottom -= (verticalIndex * bandSpacing);
      //  }
      //else
      //  {
      //   // SMA moving DOWN: band top is ATR above the 150SMA
      //   bandTop = sma150_current + atr_value*0.5;
      //   bandBottom = bandTop - bandSpacing;  // Band height = ATR
      //   bandTop += (verticalIndex * bandSpacing);
      //   bandBottom += (verticalIndex * bandSpacing);
      //  }


      bandTop = sma150_current - bandSpacing;
      bandBottom = bandTop - bandSpacing;  // Band height = ATR
      bandTop -= (verticalIndex * bandSpacing);
      bandBottom -= (verticalIndex * bandSpacing);


      int objectsCreated = 0;
      int trendlinesCreated = 0;
      //
      //   for(int i = 0; i < maxBars && i < ArraySize(array); i++)
      //   {
      if(array[i] == 0 || array[i] == EMPTY_VALUE)
         continue;

      string objName = StringFormat("%s_%d", baseName+"Heat", i);
      string trendlineName = StringFormat("%s_TL_%d", baseName+"Heat", i); // Trendline name

      if(ObjectFind(chartId, objName) != -1)
         ObjectDelete(chartId, objName);

      if(ObjectFind(chartId, trendlineName) != -1)
         ObjectDelete(chartId, trendlineName);

      datetime time1 = Time[i+1];
      datetime time2 = (i > 0) ? Time[i] : (Time[i] + PeriodSeconds());

      if(time1 <= 0 || time2 <= 0 || time1 >= time2)
         continue;

      // Enhanced color with NO transparency
      color fillColor = (array[i] == 1) ? clrPaleGreen : clrPink;  // BRIGHT colors, no transparency
      color borderColor = (array[i] == 1) ? clrForestGreen : clrRed;  // BRIGHT colors, no transparency

      // Create rectangle
      if(ObjectCreate(chartId, objName, OBJ_RECTANGLE, 0, time1, bandBottom, time2, bandTop))
        {
         objectsCreated++;

         // MAXIMUM VISIBILITY SETTINGS
         ObjectSetInteger(chartId, objName, OBJPROP_COLOR, fillColor);
         ObjectSetInteger(chartId, objName, OBJPROP_WIDTH, 1);             // THICK border
         ObjectSetInteger(chartId, objName, OBJPROP_BGCOLOR, fillColor);   // BRIGHT fill
         ObjectSetInteger(chartId, objName, OBJPROP_FILL, true);
         ObjectSetInteger(chartId, objName, OBJPROP_BACK, true);          // background
         ObjectSetInteger(chartId, objName, OBJPROP_SELECTABLE, true);     // MAKE SELECTABLE for testing
         ObjectSetInteger(chartId, objName, OBJPROP_SELECTED, false);
         ObjectSetInteger(chartId, objName, OBJPROP_HIDDEN, false);        // NOT HIDDEN
         ObjectSetInteger(chartId, objName, OBJPROP_WIDTH, 1);             // THICK border
         ObjectSetInteger(chartId, objName, OBJPROP_STYLE, STYLE_SOLID);   // SOLID line
         //   ObjectSetInteger(chartId, objName, OBJPROP_COLOR, borderColor);

         //if(objectsCreated <= 5)
         //  {
         //   Print("ENHANCED Object[", i, "] created at price: ", bandBottom, "-", bandTop);
         //   Print("  Time range: ", TimeToString(time1), " to ", TimeToString(time2));
         //  }
        }

      // Create trendline below the band (same width as rectangle)
      double trendlinePrice = bandBottom;// - (atr_value * 0.05); // Small offset below band

      if(ObjectCreate(chartId, trendlineName, OBJ_TREND, 0, time1, trendlinePrice, time2, trendlinePrice))
        {
         trendlinesCreated++;

         // Trendline settings
         ObjectSetInteger(chartId, trendlineName, OBJPROP_COLOR, borderColor);      // Use borderColor
         ObjectSetInteger(chartId, trendlineName, OBJPROP_WIDTH, 1);                // Thick line
         ObjectSetInteger(chartId, trendlineName, OBJPROP_STYLE, STYLE_SOLID);      // Solid line
         ObjectSetInteger(chartId, trendlineName, OBJPROP_BACK, true);              // Background
         ObjectSetInteger(chartId, trendlineName, OBJPROP_SELECTABLE, false);      // Not selectable
         ObjectSetInteger(chartId, trendlineName, OBJPROP_HIDDEN, false);          // Not hidden
         ObjectSetInteger(chartId, trendlineName, OBJPROP_RAY_LEFT, false);        // No ray extension left
         ObjectSetInteger(chartId, trendlineName, OBJPROP_RAY_RIGHT, false);       // No ray extension right

         //if(trendlinesCreated <= 5)
         //  {
         //   Print("Trendline[", i, "] created at price: ", trendlinePrice);
         //   Print("  Time range: ", TimeToString(time1), " to ", TimeToString(time2));
         //  }
        }
      // Add this code after the bottom trendline creation block:

      // Create trendline above the band (same width as rectangle)
      string topTrendlineName = StringFormat("%s_TL_TOP_%d", baseName+"Heat", i); // Top trendline name

      if(ObjectFind(chartId, topTrendlineName) != -1)
         ObjectDelete(chartId, topTrendlineName);

      double topTrendlinePrice = bandTop; //+ (atr_value * 0.05); // Small offset above band

      if(ObjectCreate(chartId, topTrendlineName, OBJ_TREND, 0, time1, topTrendlinePrice, time2, topTrendlinePrice))
        {
         trendlinesCreated++;

         // Top trendline settings
         ObjectSetInteger(chartId, topTrendlineName, OBJPROP_COLOR, borderColor);      // Use borderColor
         ObjectSetInteger(chartId, topTrendlineName, OBJPROP_WIDTH, 1);                // Thick line
         ObjectSetInteger(chartId, topTrendlineName, OBJPROP_STYLE, STYLE_SOLID);      // Solid line
         ObjectSetInteger(chartId, topTrendlineName, OBJPROP_BACK, true);              // Background
         ObjectSetInteger(chartId, topTrendlineName, OBJPROP_SELECTABLE, false);      // Not selectable
         ObjectSetInteger(chartId, topTrendlineName, OBJPROP_HIDDEN, false);          // Not hidden
         ObjectSetInteger(chartId, topTrendlineName, OBJPROP_RAY_LEFT, false);        // No ray extension left
         ObjectSetInteger(chartId, topTrendlineName, OBJPROP_RAY_RIGHT, false);       // No ray extension right
         //
         //         if(trendlinesCreated <= 10) // Increased limit since we now have 2 trendlines per rectangle
         //           {
         //            Print("Top Trendline[", i, "] created at price: ", topTrendlinePrice);
         //            Print("  Time range: ", TimeToString(time1), " to ", TimeToString(time2));
         //           }
        }
     }


  }

//+------------------------------------------------------------------+
//|   Scan for Down pattern
//+------------------------------------------------------------------+
int MT_MOMDownPattern()
  {
   double SH1,SH2,SH3, SL1,SL2,SL3;

   double SLFirst = -30000;
   double SHFirst = -30000;

   int DowntrendSwingCnt = 0;
   double offset = 50;
   int LastSwingShift = 0;
   int MoM_Break_Low = 0;
   int MoM_Lower_High =0;
   double MOM_Max_High_Swing = 0;
   double MOM_Max_High_Swing_2 = 0;
   int SH1shift,SH2shift,SH3shift,SL1shift,SL2shift,SL3shift;

   for(int i = LookBack-1; i >= 0; i--)
     {
      if(MT_MACDDiv_MainSwingHigh_Value[i] < 30000 && MT_MACDDiv_MainSwingHigh_Value[i] != 0)
        {
         //   Print(" i = ",i, " SH1 = ",SH1);
         SH3 = SH2;
         SH3shift = SH2shift;
         SH2 = SH1;
         SH2shift = SH1shift;
         SH1 = MT_MACDDiv_MainSwingHigh_Value[i];
         SHFirst = SH1;
         SH1shift = i;
         // Print("MT_MACDDiv_MainSwingHigh_Value[i]");
         //    ArrowTimeless(StringConcatenate("WaveCount SH", i), Time[i], High[i] + 500 * Point, clrRed, 174);
         //      TextTimeless(StringConcatenate("WaveCount SHtext",i),Time[i],High[i],clrBlack,10,  SH1,90.0);//+ 10000*Point
        }
      if(MT_MACDDiv_MainSwingLow_Value[i]  < 30000 && MT_MACDDiv_MainSwingLow_Value[i]  != 0)
        {
         SL3 = SL2;
         SL3shift = SL2shift;
         SL2 = SL1;

         SL2shift = SL1shift;
         SL1 = MT_MACDDiv_MainSwingLow_Value[i];
         SLFirst = SL1;
         SL1shift = i;
         //  ArrowTimeless(StringConcatenate("WaveCount SL", i), Time[i], Low[i] - 500 * Point, clrGreen, 174);
        }

      //MOM - LOWER HIGH detected
      if(SH3 < SH2 && SH2 > SH1  && SH1 != -30000&& SH2 != -30000&& SH3 != -30000 &&
         SH2 > 0)
        {
         // Pattern for the lower swing high on MOM
         MoM_Lower_High = 1;
         MOM_Max_High_Swing_2 = MathMax(SH1,MathMax(SH2,SH3));
         //  if(displayIndicators_MOM == true)
         //     CreateSwingLabel("^", Time[SH1shift], SH1 + offset*3, clrBlack);
        }

      if(MoM_Lower_High == 1 && (MT_MACD_DAD[i] < 0 || (MT_MACD_MOM[i] > MOM_Max_High_Swing_2 && MOM_Max_High_Swing_2 >0)))
        {
         //Reset the downward signal
         MoM_Lower_High = 0;
         MOM_Max_High_Swing_2 = 0;
         // CreateSwingLabel("|", Time[i], 0, clrBlack);
        }

      if(MoM_Lower_High == 1)
        {
         // if(displayIndicators_MOM == true)
         //    CreateSwingLabel("'", Time[i], 50, clrRed);
         MT_MOMlowerHIGH[i]=1;
        }

      // MOM - SWING LOW break lower

      if(MT_MACD_MOM[i] < SL1) //DowntrendSwingCnt >=5 &&
        {
         // Break of the previous swing low on MOM
         MoM_Break_Low = 1;
         MOM_Max_High_Swing = MathMax(SH1,MathMax(SH2,SH3));
        }
      if(MoM_Break_Low == 1 && (MT_MACD_DAD[i] < 0 || (MT_MACD_MOM[i] > MOM_Max_High_Swing && MOM_Max_High_Swing >0)))
        {
         //Reset the downward signal
         MoM_Break_Low = 0;
         DowntrendSwingCnt = 0;
         MOM_Max_High_Swing = 0;
         // if(displayIndicators_MOM == true)
         //    CreateSwingLabel("|", Time[i], 200, clrBlack);
        }

      if(MoM_Break_Low == 1)
        {
         // if(displayIndicators_MOM == true)
         //    CreateSwingLabel("*", Time[i], 100, clrBlack);
         MT_MOMbreakLOW[i]=1;
        }
      if(MT_MACD_MOM[i] > SH1)
        {
         MT_MOMbreakLOW[i]=0;
         MT_MOMlowerHIGH[i]=0;
        }
      SHFirst = -30000;
      SLFirst = -30000;
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|   Scan for Down pattern
//+------------------------------------------------------------------+
int MT_MOMUPPattern()
  {
   double SH1,SH2,SH3, SL1,SL2,SL3;

   double SLFirst = -30000;
   double SHFirst = -30000;

   int UPtrendSwingCnt = 0;
   double offset = 50;
   int LastSwingShift = 0;
   int MoM_Break_HIGH = 0;
   int MoM_Higher_LOW = 0;
   double MOM_Min_Low_Swing_2 = 0;
   double MOM_Min_Low_Swing = 0;
//Print(" Start UPPattern : Verskil = ",Verskil);
   int SH1shift,SH2shift,SH3shift,SL1shift,SL2shift,SL3shift;
   for(int i = LookBack-10; i > 0; i--)
     {
      //  Print(" i = ",i);
      if(MT_MACDDiv_MainSwingHigh_Value[i] < 30000 && MT_MACDDiv_MainSwingHigh_Value[i] !=0)
        {
         //if(displayIndicators_MOM == true)
         //  Print(" i = ",i, " SH1 = ",SH1);
         SH3 = SH2;
         SH3shift = SH2shift;
         SH2 = SH1;
         SH2shift = SH1shift;
         SH1 = MT_MACDDiv_MainSwingHigh_Value[i];
         SHFirst = SH1;
         SH1shift = i;
         //ArrowTimeless(StringConcatenate("WaveCount SH", i), Time[i], High[i] + 500 * Point, clrRed, 174);

        }
      if(MT_MACDDiv_MainSwingLow_Value[i]  < 30000 && MT_MACDDiv_MainSwingLow_Value[i] !=0)
        {
         //   Print(" i = ",i, " SL1 = ",SL1);
         SL3 = SL2;
         SL3shift = SL2shift;
         SL2 = SL1;

         SL2shift = SL1shift;
         SL1 = MT_MACDDiv_MainSwingLow_Value[i];
         SLFirst = SL1;
         SL1shift = i;
         //ArrowTimeless(StringConcatenate("WaveCount SL", i), Time[i], Low[i] - 500 * Point, clrGreen, 174);
        }

      //MOM - HIGHER LOW detected
      if(SL3 > SL2 && SL2 < SL1  && SL1 != -30000&& SL2 != -30000&& SL3 != -30000 &&
         SL2 < 0)
        {
         // Pattern for the lower swing high on MOM
         MoM_Higher_LOW = 1;
         MOM_Min_Low_Swing_2 = MathMin(SL1,MathMin(SL2,SL3));
         //if(displayIndicators_MOM == true)
         //   CreateSwingLabel("^", Time[SL1shift], SL1 - offset*3, clrBlack);
        }

      if(MoM_Higher_LOW == 1 && (MT_MACD_DAD[i] > 0 || (MT_MACD_MOM[i] < MOM_Min_Low_Swing_2 && MOM_Min_Low_Swing_2 <0)))
        {
         //Reset the downward signal
         MoM_Higher_LOW = 0;
         MOM_Min_Low_Swing_2 = 0;
         // CreateSwingLabel("|", Time[i], 0, clrBlack);
        }

      if(MoM_Higher_LOW == 1)
        {
         //if(displayIndicators_MOM == true)
         //       CreateSwingLabel("'", Time[i], -50, clrGreen);
         MT_MOMHigherLOW[i]=1;
        }

      // MOM - SWING HIGH break UP

      if(MT_MACD_MOM[i] > SH1 && SH1 > -3000)
        {
         // Break of the previous swing high on MOM
         MoM_Break_HIGH = 1;
         MOM_Min_Low_Swing = MathMin(SL1,MathMin(SL2,SL3));
         //             TextTimeless(StringConcatenate("WaveCount SHtext",i),Time[i],High[i],clrBlack,10,   "SL1 = "+MathRound(SL1)+"SL2 = "+MathRound(SL2)+"SL3 = "+MathRound(SL3),90.0);//+ 10000*Point

         //  CreateSwingLabel("@", Time[i], -100, clrGreen);
        }
      if(MoM_Break_HIGH == 1 && (MT_MACD_DAD[i] > 0 || (MT_MACD_MOM[i] < MOM_Min_Low_Swing && MOM_Min_Low_Swing < 0)))
        {
         //Reset the downward signal
         MoM_Break_HIGH = 0;
         MOM_Min_Low_Swing = 0;
         //if(displayIndicators_MOM == true)
         //      CreateSwingLabel("|", Time[i], 0, clrBlack);
        }

      if(MoM_Break_HIGH == 1)
        {
         //if(displayIndicators_MOM == true)
         //     CreateSwingLabel("*", Time[i], -100, clrBlack);
         MT_MOMbreakHIGH[i]=1;
        }
      if(MT_MACD_MOM[i] < SL1)
        {
         MT_MOMbreakHIGH[i]=0;
         MT_MOMHigherLOW[i]=0;
        }
      SHFirst = -30000;
      SLFirst = -30000;
     }
   return(0);
  }
////+------------------------------------------------------------------+
////|   Scan for UP pattern
////+------------------------------------------------------------------+
int MT_DADUPPattern()
  {
   double SH1,SH2,SH3, SL1,SL2,SL3;

   double SLFirst = -30000;
   double SHFirst = -30000;

   int UPtrendSwingCnt = 0;
   double offset = 50;
   int LastSwingShift = 0;
   int DaD_Break_HIGH = 0;
   int DaD_Higher_LOW = 0;
   double DaD_Min_Low_Swing_2 = 0;
   double DaD_Min_Low_Swing = 0;
//Print(" Start UPPattern : Verskil = ",Verskil);
   int SH1shift,SH2shift,SH3shift,SL1shift,SL2shift,SL3shift;
   for(int i = LookBack-1 ; i >= 0; i--)
     {
      //  Print(" i = ",i);
      if(DADTurnDown[i] < 30000 && DADTurnDown[i] !=0)
        {

         SH3 = SH2;
         SH3shift = SH2shift;
         SH2 = SH1;
         SH2shift = SH1shift;
         SH1 = MT_MACD_DAD[i];
         SHFirst = SH1;
         SH1shift = i;
         //   Print(" i = ",i, " SH1 = ",SH1);
        }
      if(DADTurnUP[i]  < 30000 && DADTurnUP[i] !=0)
        {
         SL3 = SL2;
         SL3shift = SL2shift;
         SL2 = SL1;
         SL2shift = SL1shift;
         SL1 = MT_MACD_DAD[i];
         SLFirst = SL1;
         SL1shift = i;
         //     Print(" i = ",i, " SL1 = ",SL1);
        }

      //---
      //---DAD - HIGHER LOW detected
      //---

      if(SL1 > SL2 &&
         SL1 != -30000&& SL2 != -30000&& SH1 != -30000 &&
         SH1 < 0 && SL2 < 0 && SL1 < 0 &&
         SH1shift > SL1shift)
        {
         // Pattern for the lower swing high on MOM
         //   Print("i = ",i,"  SL1 > SL2 ");
         DaD_Higher_LOW = 1;

         //if(displayIndicators_DAD == true)
         //   CreateSwingLabel("^", Time[SL1shift], SL1 - offset*3, clrBlack);
         //   CreateSwingLabel(IntegerToString(SH1), Time[SL1shift], SL1 - offset*3, clrBlack);
        }

      if(DaD_Higher_LOW == 1 && (MT_MACD_DAD[i] > 0 || SL1 > MT_MACD_DAD[i]))
        {
         //Reset the downward signal
         DaD_Higher_LOW = 0;
         DaD_Min_Low_Swing_2 = 0;
         //if(displayIndicators_DAD == true)
         //   CreateSwingLabel("|", Time[i], 0, clrBlack);
        }

      if(DaD_Higher_LOW == 1)
        {
         //if(displayIndicators_DAD == true)
         //   CreateSwingLabel("'", Time[i], -50, clrGreen);
         MT_DaDHigherLOW[i]=1;
        }


      //---
      //---// DAD - SWING HIGH break UP
      //---

      if(MT_MACD_DAD[i] > SH1 && SH1 > -3000 && SH1 < 0)
        {
         // Break of the previous swing low on MOM
         DaD_Break_HIGH = 1;
         //  CreateSwingLabel("@", Time[i], -100, clrGreen);
        }

      if(DaD_Break_HIGH == 1 && (MT_MACD_DAD[i] > 0 || SL1 > MT_MACD_DAD[i]))
        {
         //Reset the downward signal
         DaD_Break_HIGH = 0;
         DaD_Min_Low_Swing = 0;
         //if(displayIndicators_DAD == true)
         //   CreateSwingLabel("|", Time[i], 0, clrBlack);
        }

      if(DaD_Break_HIGH == 1)
        {
         //if(displayIndicators_DAD == true)
         //   CreateSwingLabel("*", Time[i], -100, clrBlack);
         MT_DaDbreakHIGH[i]=1;
        }
      SHFirst = -30000;
      SLFirst = -30000;
     }
   return(0);
  }
////+------------------------------------------------------------------+
////|   Scan for UP pattern
////+------------------------------------------------------------------+
int MT_DADDOWNPattern()
  {
   double SH1,SH2,SH3, SL1,SL2,SL3;

   double SLFirst = -30000;
   double SHFirst = -30000;

   int UPtrendSwingCnt = 0;
   double offset = 50;
   int LastSwingShift = 0;
   int DaD_Break_LOW = 0;
   int DaD_Lower_HIGH = 0;

//Print(" Start UPPattern : Verskil = ",Verskil);
   int SH1shift,SH2shift,SH3shift,SL1shift,SL2shift,SL3shift;
   for(int i = LookBack-1 ; i >= 0; i--)
     {
      //  Print(" i = ",i);
      if(DADTurnDown[i] < 30000 && DADTurnDown[i] !=0)
        {

         SH3 = SH2;
         SH3shift = SH2shift;
         SH2 = SH1;
         SH2shift = SH1shift;
         SH1 = MT_MACD_DAD[i];
         SHFirst = SH1;
         SH1shift = i;
         //   Print(" i = ",i, " SH1 = ",SH1);
        }
      if(DADTurnUP[i]  < 30000 && DADTurnUP[i] !=0)
        {
         SL3 = SL2;
         SL3shift = SL2shift;
         SL2 = SL1;
         SL2shift = SL1shift;
         SL1 = MT_MACD_DAD[i];
         SLFirst = SL1;
         SL1shift = i;
         //     Print(" i = ",i, " SL1 = ",SL1);
        }

      //---
      //---DAD - HIGHER LOW detected
      //---

      if(SH1 < SH2 &&
         SH1 != -30000&& SH2 != -30000&& SL1 != -30000 &&
         SH1 > 0 && SH2 > 0 && SL1 > 0 &&
         SL1shift > SH1shift)
        {
         // Pattern for the lower swing high on MOM
         //   Print("i = ",i,"  SL1 > SL2 ");
         DaD_Lower_HIGH = 1;

         //if(displayIndicators_DAD == true)
         //   CreateSwingLabel("^", Time[SH1shift], SH1 + offset*3, clrBlack);
        }

      if(DaD_Lower_HIGH == 1 && (MT_MACD_DAD[i] < 0 || SH1 < MT_MACD_DAD[i]))
        {
         //Reset the downward signal
         DaD_Lower_HIGH = 0;
         //if(displayIndicators_DAD == true)
         //   CreateSwingLabel("|", Time[i], 100, clrBlack);
        }

      if(DaD_Lower_HIGH == 1)
        {
         //if(displayIndicators_DAD == true)
         //   CreateSwingLabel("'", Time[i], 200, clrGreen);
         MT_DaDLowerHigh[i]=1;
        }


      //---
      //---// DAD - SWING HIGH break UP
      //---

      if(MT_MACD_DAD[i] < SL1 && SL1 > -3000 && SL1 > 0)
        {
         // Break of the previous swing low on MOM
         DaD_Break_LOW = 1;
         //  CreateSwingLabel("@", Time[i], -100, clrGreen);
        }

      if(DaD_Break_LOW == 1 && (MT_MACD_DAD[i] < 0 || SH1 < MT_MACD_DAD[i]))
        {
         //Reset the downward signal
         DaD_Break_LOW = 0;
         //if(displayIndicators_DAD == true)
         //   CreateSwingLabel("|", Time[i], 200, clrBlack);
        }

      if(DaD_Break_LOW == 1)
        {
         //if(displayIndicators_DAD == true)
         //   CreateSwingLabel("*", Time[i],  100, clrBlack);
         MT_DaDbreakLOW[i]=1;
        }

      SHFirst = -30000;
      SLFirst = -30000;
     }
   return(0);
  }
////+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Store swing low value safely in buffer                           |
//+------------------------------------------------------------------+
void MT_MACDDiv_StoreSwingLowValue(int barIndex, double value)
  {
   MT_MACDDiv_MainSwingLow_Value[barIndex] = value;
  }
//+------------------------------------------------------------------+
//| Store swing high value safely in buffer                          |
//+------------------------------------------------------------------+
void MT_MACDDiv_StoreSwingHighValue(int barIndex, double value)
  {
   MT_MACDDiv_MainSwingHigh_Value[barIndex] = value;
  }
//+------------------------------------------------------------------+
//| Find max swing high in a range                                   |
//+------------------------------------------------------------------+
int MT_MACDDiv_FindMaxSwingLOWInRange(int startBar, int endBar)
  {
   double maxValue = 3000000;
   int maxBar = -1;
// Print(" startBar = ",startBar," endBar = ",endBar);
   double MostrightPoint;
   for(int i = startBar; i <= endBar; i++)
     {

      if(i-2 >0)
         MostrightPoint = MT_MACD_MOM[i-2];
      else
         MostrightPoint = MT_MACD_MOM[i-1];


      if(MT_MACD_MOM[i] < MT_MACD_MOM[i+2] && MT_MACD_MOM[i] < MostrightPoint && MT_MACD_MOM[i] < maxValue)
        {
         //    Print("Max value found: i= ",i);
         maxValue = MT_MACD_MOM[i];
         maxBar = i;
        }
     }
   return maxBar;
  }
//+------------------------------------------------------------------+
//| Find max swing high in a range                                   |
//+------------------------------------------------------------------+
int MT_MACDDiv_FindMaxSwingHIGHInRange(int startBar, int endBar)
  {
   double maxValue = -3000000;
   int maxBar = -1;
// Print(" startBar = ",startBar," endBar = ",endBar);
   for(int i = startBar; i <= endBar && i-2 >0 && i-2 <LookBack; i++)
     {

      //   Print(" i = ",i," MT_MACD_DAD[i] = ",MT_MACD_MOM[i]," maxValue = ",maxValue);
      if(MT_MACD_MOM[i] > MT_MACD_MOM[i+2] && MT_MACD_MOM[i] > MT_MACD_MOM[i-2] && MT_MACD_MOM[i] > maxValue && i-2 < LookBack) //
        {
         //     Print("Max value found: i= ",i);
         maxValue = MT_MACD_MOM[i];
         maxBar = i;
        }
     }
   return maxBar;
  }
//+------------------------------------------------------------------+
//| Filter swing low values between consecutive swing highs          |
//+------------------------------------------------------------------+
void MT_MACDDiv_FilterSwingLowsBetweenHighs()
  {
   int highPoints[]; // Array to store indices of swing high points
   int highCount = 0; // Count of valid swing high points

// First pass: Find all valid swing high points
   for(int i = LookBack-1; i >= 0; i--)
     {
      if(MT_MACDDiv_MainSwingHigh_Value[i] != EMPTY_VALUE && MT_MACDDiv_MainSwingHigh_Value[i] != 0)
        {
         // Resize array to accommodate new point
         ArrayResize(highPoints, highCount + 1);
         highPoints[highCount] = i;
         highCount++;
        }
     }

// Process each pair of consecutive swing highs
   for(int pair = 0; pair < highCount - 1; pair++)
     {
      int startBar = highPoints[pair];
      int endBar = highPoints[pair + 1];

      // Ensure proper order (smaller index = older bar)
      if(startBar < endBar)
        {
         int temp = startBar;
         startBar = endBar;
         endBar = temp;
        }

      // Find all swing low points between these highs
      int lowPoints[]; // Array to store indices of swing low points
      int lowCount = 0; // Count of swing low points
      double lowestValue = 999999; // Initialize to a high value
      int lowestIndex = -1;

      for(int i = startBar - 1; i > endBar; i--)
        {
         if(MT_MACDDiv_MainSwingLow_Value[i] != EMPTY_VALUE && MT_MACDDiv_MainSwingLow_Value[i] != 0)
           {
            // Add to array of low points
            ArrayResize(lowPoints, lowCount + 1);
            lowPoints[lowCount] = i;
            lowCount++;

            // Check if this is the lowest value
            if(MT_MACDDiv_MainSwingLow_Value[i] < lowestValue)
              {
               lowestValue = MT_MACDDiv_MainSwingLow_Value[i];
               lowestIndex = i;
              }
           }
        }

      // If we found more than one low point
      if(lowCount > 1)
        {
         // Keep only the lowest value, set others to 0
         for(int j = 0; j < lowCount; j++)
           {
            int lowIndex = lowPoints[j];
            if(lowIndex != lowestIndex)
              {
               // Remove this swing low point
               MT_MACDDiv_MainSwingLow_Value[lowIndex] = 0;
               //     Print(" Values That was set to 0 SwingLow = ",lowIndex);
               // Also remove any text labels associated with this point
               //string objName = indicatorName + "_L_" + TimeToStr(Time[lowIndex]);
               //if(ObjectFind(objName) >= 0)
               //   ObjectDelete(objName);
              }
           }

         //  Print("Filtered swing lows between bars ", startBar, " and ", endBar, ": kept lowest at bar ", lowestIndex);
        }
     }
  }
//+------------------------------------------------------------------+
//| Filter swing high values between consecutive swing lows          |
//+------------------------------------------------------------------+
void MT_MACDDiv_FilterSwingHighsBetweenLows()
  {
   int lowPoints[]; // Array to store indices of swing low points
   int lowCount = 0; // Count of valid swing low points

// First pass: Find all valid swing low points
   for(int i = LookBack-1; i >= 0; i--)
     {
      if(MT_MACDDiv_MainSwingLow_Value[i] != EMPTY_VALUE && MT_MACDDiv_MainSwingLow_Value[i] != 0)
        {
         // Resize array to accommodate new point
         ArrayResize(lowPoints, lowCount + 1);
         lowPoints[lowCount] = i;
         lowCount++;
        }
     }

// Process each pair of consecutive swing lows
   for(int pair = 0; pair < lowCount - 1; pair++)
     {
      int startBar = lowPoints[pair];
      int endBar = lowPoints[pair + 1];

      // Ensure proper order (smaller index = older bar)
      if(startBar < endBar)
        {
         int temp = startBar;
         startBar = endBar;
         endBar = temp;
        }

      // Find all swing high points between these lows
      int highPoints[]; // Array to store indices of swing high points
      int highCount = 0; // Count of swing high points
      double highestValue = -999999; // Initialize to a low value
      int highestIndex = -1;

      for(int i = startBar - 1; i > endBar; i--)
        {
         if(MT_MACDDiv_MainSwingHigh_Value[i] != EMPTY_VALUE && MT_MACDDiv_MainSwingHigh_Value[i] != 0)
           {
            // Add to array of high points
            ArrayResize(highPoints, highCount + 1);
            highPoints[highCount] = i;
            highCount++;

            // Check if this is the highest value
            if(MT_MACDDiv_MainSwingHigh_Value[i] > highestValue)
              {
               highestValue = MT_MACDDiv_MainSwingHigh_Value[i];
               highestIndex = i;
              }
           }
        }

      // If we found more than one high point
      if(highCount > 1)
        {
         // Keep only the highest value, set others to 0
         for(int j = 0; j < highCount; j++)
           {
            int highIndex = highPoints[j];
            if(highIndex != highestIndex)
              {
               // Remove this swing high point
               MT_MACDDiv_MainSwingHigh_Value[highIndex] = 0;
               //     Print(" Set values to 0 at SwingHigh point = ",highIndex);

               // Also remove any text labels associated with this point
               //string objName = indicatorName + "_H_" + TimeToStr(Time[highIndex]);
               //if(ObjectFind(objName) >= 0)
               //   ObjectDelete(objName);
              }
           }

         //  Print("Filtered swing highs between bars ", startBar, " and ", endBar, ": kept highest at bar ", highestIndex);
        }
     }
  }
//+------------------------------------------------------------------+




//TextTimeless(StringConcatenate("WaveCount",i),Time[i],High[i],clrBlack,10,  MathRound(MT_MACD_MOM[i])+" :      "+ MathRound(SL1),90.0);//+ 10000*Point
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
// Define this helper function once in your indicator file
void ClearArray(double &arr[])
  {
   int size = ArraySize(arr);
   for(int i = 0; i < size; i++)
      arr[i] = 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ClearAll_Setup_Arrays()
  {
// Call this after ArrayResize() for each array:
   ClearArray(MT_Down_Stoc);
   ClearArray(MT_UP_Stoc);
   ClearArray(LT_Down_MACD_MOM);
   ClearArray(LT_UP_MACD_MOM);
   ClearArray(LT_UP_Stoc_D);
   ClearArray(LT_Down_Stoc_D);
   ClearArray(LT_UP_Stoc_K);
   ClearArray(LT_Down_Stoc_K);
   ClearArray(MT_MA150);
   ClearArray(MT_MACD_DAD);
   ClearArray(MT_MACD_MOM);
   ClearArray(MT_Stoc_K);
   ClearArray(MT_Stoc_D);
   ClearArray(ST_MACD_DAD);
   ClearArray(ST_MACD_MOM);
   ClearArray(ST_Stoc_K);
   ClearArray(ST_Stoc_D);
   ClearArray(ATR);
   ClearArray(ST_MA365);
   ClearArray(MT_Rubberband);
   ClearArray(ST_Rubberband);
   ClearArray(ATR14);
   ClearArray(ST_MA50);
   ClearArray(MT_MOMbreakHIGH);
   ClearArray(MT_MOMbreakLOW);
   ClearArray(MT_MOMlowerHIGH);
   ClearArray(MT_MOMHigherLOW);
   ClearArray(MT_DaDbreakHIGH);
   ClearArray(MT_DaDbreakLOW);
   ClearArray(MT_DaDLowerHigh);
   ClearArray(MT_DaDHigherLOW);
   ClearArray(MT_MOM_Break);
   ClearArray(MT_MOM_Swing_change);
   ClearArray(MT_DAD_Swing_change);
   ClearArray(MT_DAD_Break);
   ClearArray(DADTurnDown);
   ClearArray(DADTurnUP);
   ClearArray(MT_MACDDiv_MainSwingLow_Value);
   ClearArray(MT_MACDDiv_MainSwingHigh_Value);
   ClearArray(Momentum_Divergence_Partial);
   ClearArray(Momentum_Divergence_Full);
   ClearArray(LT_Conservative);
   ClearArray(FirstCycleAfter_X);
   ClearArray(FirstCycleAfter_DADturns);
   ClearArray(MACD_MainSwingHigh_Value);
   ClearArray(MACD_MainSwingLow_Value);
   ClearArray(MT_ReloadPattern);
   ClearArray(ST_MACD_MainSwingHigh_Value);
   ClearArray(ST_MACD_MainSwingLow_Value);
   ClearArray(ST_ReloadPattern);
   ClearArray(MT_Trend_Cont);
   ClearArray(MT_Trend_Reversal);
   ClearArray(MT_SMA_Angle);
   ClearArray(MT_BBand_UPPER);
   ClearArray(MT_BBand_LOWER);
   ClearArray(MT_MA_Trend_Angle);
   ClearArray(MT_PriceSwingHIGHs);
   ClearArray(MT_PriceSwingLOWs);
   ClearArray(MT_Wavecount);
   ClearArray(MT_FailWave);
   ClearArray(MT_Trend_Cont);
   ClearArray(MT_MOM_Wave3);
   ClearArray(MT_MOM_Wave2);
   ClearArray(X_Marks_the_spot);
   ClearArray(ST_EMA15);
   ClearArray(MT_EMA45);
   ClearArray(ImpulseWithoutRetrace);
   ClearArray(MT_BBand_LOWER3520);
   ClearArray(MT_BBand_UPPER3520);
   ClearArray(LT_Stoc_K);
   ClearArray(LT_Stoc_D);
   ClearArray(LT_MA_Trend_Angle);
   ClearArray(LT_SMA_Angle);
   ClearArray(LT_MA450);
   ClearArray(LT_BBand_UPPER);
   ClearArray(LT_BBand_LOWER);
   ClearArray(LT_PriceSwingHIGHs);
   ClearArray(LT_PriceSwingLOWs);
   ClearArray(LT_Wavecount);
   ClearArray(LT_FailWave);
   ClearArray(LT_UP_Stoc);
   ClearArray(LT_Down_Stoc);
   ClearArray(LT_Trend_Reversal);
   ClearArray(LT_Trend_Cont);
//---   LT MACD Divergence
   ClearArray(LT_MACD_MOM);
   ClearArray(LT_MACD_DAD);
   ClearArray(LT_MACDDiv_MainSwingHigh_Value);
   ClearArray(LT_MACDDiv_MainSwingLow_Value);
   ClearArray(LT_MOMHigherLOW);
   ClearArray(LT_MOMbreakHIGH);
   ClearArray(LT_MOMlowerHIGH);
   ClearArray(LT_MOMbreakLOW);
   ClearArray(LT_DaDHigherLOW);
   ClearArray(LT_DaDbreakHIGH);
   ClearArray(LT_DaDLowerHigh);
   ClearArray(LT_DaDbreakLOW);
   ClearArray(LT_MOM_Break);
   ClearArray(LT_MOM_Swing_change);
   ClearArray(LT_DAD_Break);
   ClearArray(LT_DAD_Swing_change);
   ClearArray(LT_Momentum_Divergence_Partial);
   ClearArray(LT_Momentum_Divergence_Full);
   ClearArray(ST_MA89);
   ClearArray(ST_MA200);
   ClearArray(ST_MA365);
   ClearArray(LT_MA135);

   ClearArray(ST_MACDDiv_MainSwingLow_Value);
   ClearArray(ST_MACDDiv_MainSwingHigh_Value);
   ClearArray(ST_MOMbreakHIGH);
   ClearArray(ST_MOMbreakLOW);
   ClearArray(ST_MOMlowerHIGH);
   ClearArray(ST_MOMHigherLOW);
   ClearArray(ST_DaDbreakHIGH);
   ClearArray(ST_DaDbreakLOW);
   ClearArray(ST_DaDLowerHigh);
   ClearArray(ST_DaDHigherLOW);
   ClearArray(ST_DADTurnDown);
   ClearArray(ST_DADTurnUP);
   ClearArray(ST_MOM_Break);
   ClearArray(ST_MOM_Swing_change);
   ClearArray(ST_DAD_Swing_change);
   ClearArray(ST_DAD_Break);
//-- Trend / Momentum direction
   ClearArray(ST_Divergence_UP_Counter);
   ClearArray(ST_Divergence_DOWN_Counter);
   ClearArray(ST_TrendDirection);
   ClearArray(ST_Down_Stoc);
   ClearArray(ST_UP_Stoc);
   ClearArray(ST_Momentum_Divergence_Partial);
   ClearArray(ST_Momentum_Divergence_Full);
   ClearArray(TopDOG_Setup_USEDin_BELLcurve);
   ClearArray(MA_SUPPORT_RESISTANCE);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Trend indicator
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int MT_Trend()
  {

   for(int i=LookBack; i>=1; i--)
     {
      if(Angle150SMA(i) == 1   && DetectValid_TopDog_Trend_BB150SMA(i) == 1) //Angle150SMA(i) == 1   &&
        {
         MT_MA_Trend_Angle[i] = 1;
        }
      if(Angle150SMA(i) == 2     &&  DetectValid_TopDog_Trend_BB150SMA(i) == 2)//Angle150SMA(i) == 2    &&
        {
         MT_MA_Trend_Angle[i] = 2;
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|        DetectValid_TopDog_Trend_BB150SMA
//+------------------------------------------------------------------+
int DetectValid_TopDog_Trend_BB150SMA(int i)
  {
   int ret = 0;

   for(int k=i ; k<=LookBack-4; k++)
     {
      if(MT_MA150[k]<MT_MA150[k+3])
        {
         break;
        }
      if(iClose(currentSymbol,currentTimeframe,k) > MT_BBand_UPPER[k])//iBands(NULL,0,60,2,0,PRICE_CLOSE,MODE_UPPER,k)) iClose
        {
         ret =1;
         break;
        }
     }
   for(int k=i ; k<=LookBack-4; k++)
     {
      if(MT_MA150[k]>MT_MA150[k+3])
        {
         break;
        }
      if(iClose(currentSymbol,currentTimeframe,k) < MT_BBand_LOWER[k]) //iBands(NULL,0,60,2,0,PRICE_CLOSE,MODE_LOWER,k))
        {
         ret =2;
         break;
        }
     }
   return(ret);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Angle150SMA(int i)
  {
   int ret =0;
//  if(iCustom(NULL,0,"SMAAngleV3",150,0,6,3,PRICE_CLOSE,3,i) < -0.02)  //&& iCustom(NULL,0,"SMAAngleV3",150,0,6,3,PRICE_CLOSE,3,i)<0)
// Print(" MT_SMA_Angle[i] = ",MT_SMA_Angle[i]);
   if(MT_SMA_Angle[i] < -0.02)
     {
      //  Print(" < - 0.02 MT_SMA_Angle[i] = ",MT_SMA_Angle[i]);
      ret = 2;
     }
   else
     {
      if(PreviousTrendtriggerDown(i) == 2)
        {
         ret = 2;
        }
     }
//  if(iCustom(NULL,0,"SMAAngleV3",150,0,6,3,PRICE_CLOSE,3,i) > 0.02)// && PreviousTrendtriggerUP(i) == 1) //&& iCustom(NULL,0,"SMAAngleV3",150,0,6,3,PRICE_CLOSE,3,i)>0)
   if(MT_SMA_Angle[i] > 0.02)
     {
      //     Print(" >  0.02 MT_SMA_Angle[i] = ",MT_SMA_Angle[i]);
      ret = 1;
     }
   else
     {
      if(PreviousTrendtriggerUP(i) == 1)
        {
         ret = 1;
        }
     }
   return(ret);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int PreviousTrendtriggerDown(int i)
  {
   int ret = 0;
   for(int k=i; k<LookBack; k++)
     {
      //    if(iCustom(NULL,0,"SMAAngleV3",150,0,6,3,PRICE_CLOSE,3,k) < -0.02)
      if(MT_SMA_Angle[k] < -0.02)
        {
         ret = 2;
         break;
        }
      else
        {
         //       if(iCustom(NULL,0,"SMAAngleV3",150,0,6,3,PRICE_CLOSE,3,k) >= 0)
         if(MT_SMA_Angle[k] >=0)
           {
            return(0);
           }
        }
     }
   return(ret);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int PreviousTrendtriggerUP(int i)
  {
   int ret = 0;
   for(int k=i; k<LookBack; k++)
     {
      if(MT_SMA_Angle[k] > 0.02)
         //  if(iCustom(NULL,0,"SMAAngleV3",150,0,6,3,PRICE_CLOSE,3,k) > 0.02)
        {
         ret = 1;
         break;
        }
      else
        {
         if(MT_SMA_Angle[k] <=0)
            //     if(iCustom(NULL,0,"SMAAngleV3",150,0,6,3,PRICE_CLOSE,3,k) <= 0)
           {
            return(0);
           }
        }
     }
   return(ret);
  }
////+------------------------------------------------------------------+
////|                                                                  |
////+------------------------------------------------------------------+
//void MT_SMA_Angle_old(int i)
//  {
//   double fEndMA, fStartMA;
//   double fAngle, mFactor, dFactor;
//   int MA_Sensitivity=6;
//   int MA_FlatSensitivity = 3;
//   int EndSMAShift = 0;
//   if(i+ MA_Sensitivity < LookBack)
//     {
//      fEndMA= MT_MA150[i+EndSMAShift];
//      fStartMA= MT_MA150[i+MA_Sensitivity];
//
//      // Calculate slope
//      double deltaY = fEndMA - fStartMA;
//      double deltaX = MA_Sensitivity-EndSMAShift;
//
//      // Calculate angle in radians, then convert to degrees
//      double angleRad = MathArctan(deltaY / deltaX);
//      double ATRr;
//      ATRr = ATR[i];
//      if(ATRr ==0)
//        {
//         //ATRr=CandleHigh[i]-CandleLow[i];//
//         ATRr=iHigh(currentSymbol,currentTimeframe,i)-iLow(currentSymbol,currentTimeframe,i);
//          MathMax(ATRr,0.00001);
//        }
//      if(ATRr > 0)
//      {
//      fAngle = (deltaY/ATRr)/deltaX;
//
//      if(MT_MA150[i+MA_FlatSensitivity] >  MT_MA150[i] && fAngle > 0)
//        {
//         fAngle ==0;
//        }
//      if(MT_MA150[i+MA_FlatSensitivity] <  MT_MA150[i] && fAngle < 0)
//        {
//         fAngle ==0;
//        }
//      MT_SMA_Angle[i]=fAngle;
//     }
//     }
//  }


//+------------------------------------------------------------------+
//| Calculate SMA Angles Function                                    |
//| Parameters:                                                      |
//|   limit - number of bars to calculate from current bar          |
//| Uses global arrays: MT_MA150[], MT_SMA_Angle[]                  |
//+------------------------------------------------------------------+
//void CalculateSMAAngles( )
//{
//int SMAPeriod = 150;
//double AngleTreshold = 0;
//int MA_Sensitivity = 6;
//int MA_FlatSensitivity = 3;
//int EndSMAShift = 0;
//
//   int limit = LookBack;
//   double fEndMA, fStartMA;
//   double fAngle;
//   double ATR;
//
//   // Validate parameters
//   if(EndSMAShift >= MA_Sensitivity)
//   {
//      Print("Error: EndSMAShift >= MA_Sensitivity, adjusting values");
//      MA_Sensitivity = 6;
//      EndSMAShift = 0;
//   }
//
//   // Ensure we don't go beyond array bounds
//   int maxIndex = ArraySize(MT_MA150) - 1;
//   if(limit > maxIndex)
//   {
//      Print("Warning: limit adjusted from ", limit, " to ", maxIndex);
//      limit = maxIndex;
//   }
//
//   // Main calculation loop
//   for(int i = 1; i < limit; i++)
//   {
//      // Check array bounds before accessing
//      if(i + MA_Sensitivity >= ArraySize(MT_MA150))
//      {
//         Print("Warning: Stopping calculation at index ", i, " due to array bounds");
//         break;
//      }
//
//      // Use pre-calculated MA values from global array
//      fEndMA = MT_MA150[i + EndSMAShift];
//      fStartMA = MT_MA150[i + MA_Sensitivity];
//
//      // Get ATR for normalization
//      ATR = iATR(NULL, 0, 1000, i);
//
//      // Calculate slope
//      double deltaY = fEndMA - fStartMA;
//      double deltaX = MA_Sensitivity - EndSMAShift;
//
//      // Ensure ATR is not zero to avoid division by zero
//// With this safer version:
//if(i < Bars)
//{
//    ATR = High[i] - Low[i];
//}
//else
//{
//    ATR = 0.00001; // or use a default value
//    Print("Warning: Index ", i, " exceeds Bars (", Bars, ")");
//}
//
//      // Calculate normalized angle
//// With this safer version:
//if(deltaX != 0 && ATR != 0)
//{
//    fAngle = (deltaY / ATR) / deltaX;
//}
//else
//{
//    fAngle = 0; // or some default value
//    if(deltaX == 0)
//        Print("Warning: deltaX is zero (MA_Sensitivity=", MA_Sensitivity, ", EndSMAShift=", EndSMAShift, ")");
//    if(ATR == 0)
//        Print("Warning: ATR is zero at index ", i);
//}
//
//      // Apply flat sensitivity logic
//      if(i + MA_FlatSensitivity < ArraySize(MT_MA150))
//      {
//         if(MT_MA150[i + MA_FlatSensitivity] > MT_MA150[i] && fAngle > 0)
//         {
//            fAngle = 0;
//         }
//         if(MT_MA150[i + MA_FlatSensitivity] < MT_MA150[i] && fAngle < 0)
//         {
//            fAngle = 0;
//         }
//      }
//
//      // Populate the angle array
//      MT_SMA_Angle[i] = fAngle;
//      Print(" MT_SMA_Angle[i] = ",MT_SMA_Angle[i] );
//   }
//}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MT_FindPrice_Swing_High()
  {
   int swingShift = -1;
   double swingHighPrice = -1;


// 1. Cache stochastic values
//  int lookback = MathMin(Bars - 1, MAX_LOOKBACK);
//ArrayResize(MT_Stoc_K, lookback + 2);
//  ArrayResize(MT_PriceSwingHIGHs, lookback + 2);

//for(int i = startShift; i <= lookback + 1; i++)
//  {
//   MT_Stoc_K[i] = iStochastic(NULL, 0, STOCH_K_PERIOD_MT, STOCH_D_PERIOD_MT, STOCH_SLOWING_MT, MODE_SMA, 0, MODE_MAIN, i);
//  }
// 2. Loop from most recent bar to older bars
//  for(i = startShift; i < lookback; i++)
   for(int i = LookBack; i >= 1; i--)
     {
      // Detect cross below 55
      if(MT_Stoc_K[i] < 55 && MT_Stoc_K[i + 1] >= 55)
        {
         int crossBelowShift = i;

         // Search forward for prior cross above 45
         for(int j = i-1 ; j <= LookBack; j++)
           {
            if(MT_Stoc_K[j] > 45 && MT_Stoc_K[j + 1] <= 45)
              {
               // Identify highest price between j and i
               double highest = -1;
               int highShift = -1;

               for(int k = i; k <= j; k++)
                 {
                  if(iHigh(currentSymbol,currentTimeframe,k)  > highest)
                    {
                     highest = iHigh(currentSymbol,currentTimeframe,k);
                     highShift = k;
                    }
                 }
               if(highest >0)
                 {
                  MT_PriceSwingHIGHs[i] = iHigh(currentSymbol,currentTimeframe,highShift);
                  //         ArrowTimeless(StringConcatenate("WaveCount SH",i),Time[i],High[i ]+200*Point,clrGreen,108);
                  //Print("highShift = ",highShift," MT_PriceSwingHIGHs[swingShift] = ", MT_PriceSwingHIGHs[highShift]);
                 }
               for(int x = highShift+1; x <= LookBack; x++)
                 {
                  // Clean up the situations where the 55 is crossed down but then the 45 is not cross to confirm begin of next wave, thus if not closed it is still part of initial wave.
                  if(MT_PriceSwingHIGHs[x] >0)
                    {
                     MT_PriceSwingHIGHs[x] = 0;
                    }
                  if(MT_Stoc_K[x]<45)
                    {
                     break;
                    }
                 }
               // return;
               break;
              }
           }
         // If no prior cross found, exit early
         //break;
        }
     }
// diplay array
//for(int i = 1; i <= LookBack; i++)
//  {
//   if(MT_PriceSwingHIGHs[i] >0 && MT_PriceSwingHIGHs[i] < 300000)
//     {
//     ArrowTimeless(StringConcatenate("WaveCount_SH",i),Time[i],High[i ]+200*Point,clrRed,108);
//      TextTimeless(StringConcatenate("WaveCount SHtext",i),Time[i],High[i],clrBlack,10, MT_PriceSwingHIGHs[i],90.0);
//    //  Print("i = ",i," MT_PriceSwingHIGHs[i] = ", MT_PriceSwingHIGHs[i]);
//     }
//  }
  }
//+------------------------------------------------------------------+
//| Custom Function: Fast Swing Low on Stochastic Reversal           |
//+------------------------------------------------------------------+
void MT_FindPrice_Swing_Lows()
  {
   int swingShift = -1;
   double swingLowPrice = -1;

// 1. Cache stochastic values
//   int lookback = MathMin(Bars - 1, MAX_LOOKBACK);
//   ArrayResize(MT_Stoc_K, lookback + 2);
//  ArrayResize(MT_PriceSwingLOWs, lookback + 2); // <-- for storing swing lows
//
//   for(int i = startShift; i <= lookback + 1; i++)
//     {
//      MT_Stoc_K[i] = iStochastic(NULL, 0, STOCH_K_PERIOD_MT, STOCH_D_PERIOD_MT, STOCH_SLOWING_MT, MODE_SMA, 0, MODE_MAIN, i);
//     }

// 2. Loop from most recent bar to older bars
   for(int i = LookBack; i>=1; i--)
     {
      // Detect cross up through 45
      if(MT_Stoc_K[i] > 45 && MT_Stoc_K[i + 1] <= 45)
        {
         int crossAboveShift = i;
         //    ArrowTimeless(StringConcatenate("WaveCount >45", i), Time[i], Low[i] - 300 * Point, clrRed, 108);
         // Look backward for cross down through 55
         //    for(int j = i - 1; j >= startShift; j--)
         for(int j = i-1 ; j <= LookBack; j++)
           {
            if(MT_Stoc_K[j] < 55 && MT_Stoc_K[j + 1] >= 55)
              {
               // Identify lowest price between j and i
               double lowest = 999999;
               int lowShift = -1;
               //   ArrowTimeless(StringConcatenate("WaveCount <55", j), Time[j], Low[j] - 300 * Point, clrOrange, 108);
               for(int k = i; k <= j; k++)
                 {
                  if(iLow(currentSymbol,currentTimeframe,k)   < lowest)
                    {
                     lowest = iLow(currentSymbol,currentTimeframe,k);
                     lowShift = k;
                    }
                 }

               if(lowest != 999999)
                 {
                  MT_PriceSwingLOWs[i] = iLow(currentSymbol,currentTimeframe,lowShift);
                  //          ArrowTimeless(StringConcatenate("WaveCount SL", i), Time[lowShift], Low[lowShift] - 350 * Point, clrBlack, 108);
                  // Print("lowShift = ", lowShift, " MT_PriceSwingLOWs[swingShift] = ", MT_PriceSwingLOWs[lowShift]);
                 }

               // Clear overlapping invalid entries forward
               for(int x = lowShift + 1; x <= LookBack; x++)
                 {
                  if(MT_PriceSwingLOWs[x] > 0)
                     MT_PriceSwingLOWs[x] = 0;
                  if(MT_Stoc_K[x] > 55)
                     break;
                 }

               break; // Exit inner loop
              }
           }
        }
     }

//// Display array
//for(int i = 1; i <= LookBack; i++)
//  {
//   if(MT_PriceSwingLOWs[i] > 0 && MT_PriceSwingLOWs[i] <3000000)
//     {
//      //  ArrowTimeless(StringConcatenate("WaveCount_SL", i), Time[i], Low[i] - 200 * Point, clrBlue, 108);
//      //  TextTimeless(StringConcatenate("WaveCount _SL",i),Time[i],High[i]+ 100*Point,clrBlack,12,MT_PriceSwingLOWs[i],90.0);
//      // Print("i = ", i, " MT_PriceSwingLOWs[i] = ", MT_PriceSwingLOWs[i]);
//     }
//  }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MT_GetWaveCount()
  {
   double SH,Previous_SH;
   double SL = 3000000;
   double Previous_SL = 3000000;
   int SHshift,SLshift;
   int ConvirmedWavecount;
   int PrevCycleEnd =0;
   int UPtrend = 0;
   int DOWNtrend = 0;
   int FailedWaveConfirmed = 0;
//  ArrayResize(Wavecount, Lookback + 2);
//  ArrayResize(FailWave, Lookback + 2);
   for(int i = LookBack; i >= 1; i--)
     {
      if(MT_MA_Trend_Angle[i] != 1 && MT_MA_Trend_Angle[i] != 2)
        {
         // reset all
         MT_Wavecount[i] = 0;
         MT_FailWave[i] = 0;
         UPtrend = 0;
         DOWNtrend = 0;
         PrevCycleEnd = 0;
        }
      else
        {
         // Print(" Trendangle[i] = ",Trendangle[i]);
         //  ArrowTimeless(StringConcatenate("WaveCount Start", i), Time[i], High[i] + 200 * Point, clrGreen, 108);
         if(MT_MA_Trend_Angle[i] == 1 && MT_MA_Trend_Angle[i+1] != 1)
           {
            // UP trend started
            UPtrend = 1;
            SH = 0;
            SLshift = 0;
            Previous_SH = 0;
            ConvirmedWavecount = 0;
            PrevCycleEnd = i;
            //     ArrowTimeless(StringConcatenate("WaveCount Start7&&", Time[i]), Time[i], High[i] + 200 * Point, clrGreen, 108);
           }
         if(UPtrend == 1)
           {
            MT_Wavecount[i] = MT_Wavecount[i+1];
            MT_FailWave[i] = MT_FailWave[i+1];

            //if((PriceSwingHIGHs[i] != EMPTY_VALUE && PriceSwingHIGHs[i] >0))
            //  {
            //   //make the Swing high value visible on all other itterations
            //   // PriceSwingHIGHs[i] - this value only available on bars when Stoc cross below 55
            //   if(PriceSwingHIGHs[i] > SH )
            //   {
            //    SH = PriceSwingHIGHs[i];
            //   }
            //  }

            if(MT_PriceSwingHIGHs[i]  >0 && MT_Wavecount[i] ==0)
              {
               // Fist scenario different than other increment only by 1 and not 2.
               ConvirmedWavecount =1;
               MT_Wavecount[i] = 1;
               //  PrintWavesUP(PrevCycleEnd,i);
               SH = MT_PriceSwingHIGHs[i];
               //ArrowTimeless(StringConcatenate("WaveCount Nr1", i), Time[i], High[i] + 300 * Point, clrBlueViolet, 108);
               //TextTimeless(StringConcatenate("WaveCount SHtext23",i),Time[i],High[i],clrBlack,10, SH,90.0);

              }
            //if( MT_Wavecount[i]>0 && SH != EMPTY_VALUE )//iHigh(currentSymbol,currentTimeframe,i)>SH &&&& iHigh(currentSymbol,currentTimeframe,i) < 300000
            //{
            //  ArrowTimeless(StringConcatenate("WaveCount high>SH", i), Time[i], High[i] + 50 * Point, clrYellowGreen, 108);
            //  TextTimeless(StringConcatenate("WaveCount SHtext",i),Time[i],High[i],clrBlack,10,iHigh(currentSymbol,currentTimeframe,i)+"    :   "+SH,90.0);
            //}



            if(iHigh(currentSymbol,currentTimeframe,i)>SH && ConvirmedWavecount == MT_Wavecount[i] && MT_Wavecount[i]>0)
              {
               MT_FailWave[i] = 1;
               if(FailedWaveConfirmed == 0)
                 {
                  MT_Wavecount[i] = MT_Wavecount[i]+2;
                 }
               //ArrowTimeless(StringConcatenate("WaveCount high>SH", i), Time[i], High[i] + 100 * Point, clrYellowGreen, 108);
              }
            if(iOpen(currentSymbol,currentTimeframe,i) > SH && iClose(currentSymbol,currentTimeframe,i) > SH && MT_Wavecount[i] >1)
              {
               MT_FailWave[i] = 0;
               //ArrowTimeless(StringConcatenate("WaveCount cl>SH op>SH", i), Time[i], High[i] + 200 * Point, clrPink, 167);
              }

            if((MT_PriceSwingHIGHs[i] >0) && MT_PriceSwingHIGHs[i] > Previous_SH &&  MT_Wavecount[i] >0)
              {
               //ArrowTimeless(StringConcatenate("WaveCount CrossBlow55", i), Time[i], High[i] + 200 * Point,clrBlue, 108);
               ConvirmedWavecount = MT_Wavecount[i];
               if(MT_FailWave[i] == 1)
                 {
                  // confirmed failed wave do not increment on next cycle
                  FailedWaveConfirmed = 1;
                 }
               else
                 {
                  FailedWaveConfirmed = 0;
                  SH = MT_PriceSwingHIGHs[i];
                 }
               MT_FailWave[i] = 0;
               // PrintWavesUP(PrevCycleEnd,i);
               Previous_SH = SH;
               PrevCycleEnd = i;
              }

           }

         if(MT_MA_Trend_Angle[i] == 2 && MT_MA_Trend_Angle[i+1] != 2)
           {
            // UP trend started
            DOWNtrend = 1;
            SL = 3000000;
            //  SLshift = 0;
            Previous_SL = 3000000;
            ConvirmedWavecount = 0;
            PrevCycleEnd = 0;
            FailedWaveConfirmed = 0;
            //       ArrowTimeless(StringConcatenate("WaveCount Start", i), Time[i], High[i] + 200 * Point, clrRed, 108);
            PrevCycleEnd = i;
           }

         if(DOWNtrend == 1)
           {
            MT_Wavecount[i] = MT_Wavecount[i+1];
            MT_FailWave[i] = MT_FailWave[i+1];

            //if((PriceSwingLOWs[i] != EMPTY_VALUE && PriceSwingLOWs[i] >0))
            //  {
            //   //make the Swing lows value visible on all other itterations
            //   // PriceSwingHIGHs[i] - this value only available on bars when Stoc cross below 55
            //   if(PriceSwingLOWs[i] < SL && PriceSwingLOWs[i] != EMPTY_VALUE)
            //     {
            //      SL = PriceSwingLOWs[i];
            //     }
            //  }

            if((MT_PriceSwingLOWs[i]   >0) && MT_Wavecount[i] ==0)
              {
               // Fist scenario different than other increment only by 1 and not 2.
               ConvirmedWavecount =1;
               MT_Wavecount[i] = 1;
               SL = MT_PriceSwingLOWs[i];
               //         ArrowTimeless(StringConcatenate("WaveCount Nr1", i), Time[i], Low[i] - 300 * Point, clrBlueViolet, 108);
               // TextTimeless(StringConcatenate("WaveCount Nr1Text",i),Time[i],High[i]+ 100*Point,clrBlack,12, SL,0);

               //  PrintWavesDOWN(PrevCycleEnd,i);
              }

            if(iLow(currentSymbol,currentTimeframe,i)<SL && ConvirmedWavecount == MT_Wavecount[i] && MT_Wavecount[i]>0)
              {
               MT_FailWave[i] = 1;
               if(FailedWaveConfirmed == 0)
                 {
                  MT_Wavecount[i] = MT_Wavecount[i]+2;
                 }
               //     ArrowTimeless(StringConcatenate("WaveCount low<SL", i), Time[i], Low[i] - 100 * Point, clrYellowGreen, 108);
               //     TextTimeless(StringConcatenate("WaveCount low<SLText",i),Time[i],High[i]+ 100*Point,clrBlack,12, SL,0);
              }
            if(iOpen(currentSymbol,currentTimeframe,i) < SL && iClose(currentSymbol,currentTimeframe,i) < SL && MT_Wavecount[i] >1)
              {
               MT_FailWave[i] = 0;
               //      ArrowTimeless(StringConcatenate("WaveCount cl<SL op<SL", i), Time[i], Low[i] - 200 * Point, clrPink, 167);
              }

            if((MT_PriceSwingLOWs[i] >0) && MT_PriceSwingLOWs[i] < Previous_SL && MT_Wavecount[i]>0)
              {
               //      ArrowTimeless(StringConcatenate("WaveCount CrossAbove45", i), Time[i], Low[i] - 200 * Point,clrBlue, 108);
               ConvirmedWavecount = MT_Wavecount[i];

               if(MT_FailWave[i] == 1)
                 {
                  // confirmed failed wave do not increment on next cycle
                  FailedWaveConfirmed = 1;
                 }
               else
                 {
                  FailedWaveConfirmed = 0;
                  SL = MT_PriceSwingLOWs[i];
                 }
               MT_FailWave[i] = 0;
               // PrintWavesDOWN(PrevCycleEnd,i);
               Previous_SL = SL;
               PrevCycleEnd = i;
              }
           }
        }
      // Print(" i = ",i," Wave count = ",MT_Wavecount[i]);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int PrintWavesUP(int PrevCycleEnd,int i)
  {
   double HH = 0;
   double LL = 3000000;
   int HHshift = 0;
   int LLshift = 0;
//  double ATR = iATR(NULL,0,14,i);
   for(int x = PrevCycleEnd; x >= i; x--)
     {
      if(iHigh(currentSymbol,currentTimeframe,x)>HH)
        {
         HH = iHigh(currentSymbol,currentTimeframe,x);
         HHshift = x;
        }
      if(iLow(currentSymbol,currentTimeframe,x) < LL)
        {
         LL = iLow(currentSymbol,currentTimeframe,x);
         LLshift = x;
        }
     }
//  TextTimeless(StringConcatenate("WaveCount SwHigh",HHshift),Time[HHshift],High[HHshift]+ 100*Point,clrBlack,12, Wavecount[HHshift],0);
//  TextTimeless(StringConcatenate("WaveCount SwLow",Time[LLshift]),Time[LLshift],Low[LLshift]- 200*Point,clrBlack,12, Wavecount[LLshift]-1,0);
   if(MT_FailWave[HHshift] == 1)
     {
      if(MT_Wavecount[HHshift] ==0)
        {
         TextTimeless(StringConcatenate("WaveCount SwHigh",Time[HHshift]),Time[HHshift],High[HHshift],clrBlack,12, "1F",0);
        }
      else
        {
         TextTimeless(StringConcatenate("WaveCount SwHigh",Time[HHshift]),Time[HHshift],High[HHshift],clrBlack,12, MT_Wavecount[HHshift]+"F",0);
        }
      if(MT_Wavecount[HHshift] -1 > 0)
         TextTimeless(StringConcatenate("WaveCount SwLow",Time[LLshift]),Time[LLshift],Low[LLshift]+ATR[i]*0.4,clrBlack,12, MT_Wavecount[HHshift] -1,0);
     }
   else
     {
      if(MT_Wavecount[HHshift] ==0)
        {
         TextTimeless(StringConcatenate("WaveCount SwHigh",Time[HHshift]),Time[HHshift],High[HHshift],clrBlack,12, 1,0);
        }
      else
        {
         TextTimeless(StringConcatenate("WaveCount SwHigh",Time[HHshift]),Time[HHshift],High[HHshift],clrBlack,12, MT_Wavecount[HHshift],0);
        }
      if(MT_Wavecount[HHshift] -1 > 0)
         TextTimeless(StringConcatenate("WaveCount SwLow",Time[LLshift]),Time[LLshift],Low[LLshift]+ ATR[i]*0.4,clrBlack,12, MT_Wavecount[HHshift] -1,0);
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int PrintWavesDOWN(int PrevCycleEnd,int i)
  {
   double HH = 0;
   double LL = 3000000;
   int HHshift = 0;
   int LLshift = 0;
// double ATR = iATR(NULL,0,14,i);
   for(int x = PrevCycleEnd; x >= i; x--)
     {
      if(iHigh(currentSymbol,currentTimeframe,x)>HH)
        {
         HH = iHigh(currentSymbol,currentTimeframe,x);
         HHshift = x;
        }
      if(iLow(currentSymbol,currentTimeframe,x) < LL)
        {
         LL = iLow(currentSymbol,currentTimeframe,x);
         LLshift = x;
        }
     }
   if(MT_FailWave[LLshift] == 1)
     {
      if(MT_Wavecount[LLshift] ==0)
        {
         TextTimeless(StringConcatenate("WaveCount SwLow",Time[LLshift]),Time[LLshift],Low[LLshift],clrBlack,12, "1F",0);
        }
      else
        {
         TextTimeless(StringConcatenate("WaveCount SwLow",Time[LLshift]),Time[LLshift],Low[LLshift],clrBlack,12, MT_Wavecount[LLshift]+"F",0);
        }
      if(MT_Wavecount[LLshift] -1 > 0)
         TextTimeless(StringConcatenate("WaveCount SwHigh",Time[HHshift]),Time[HHshift],High[HHshift]+ATR[i]*0.4,clrBlack,12, MT_Wavecount[LLshift] -1,0);
     }
   else
     {
      if(MT_Wavecount[LLshift] ==0)
        {
         TextTimeless(StringConcatenate("WaveCount SwLow",Time[LLshift]),Time[LLshift],Low[LLshift],clrBlack,12, 1,0);
        }
      else
        {
         TextTimeless(StringConcatenate("WaveCount SwLow",Time[LLshift]),Time[LLshift],Low[LLshift],clrBlack,12, MT_Wavecount[LLshift],0);
        }
      if(MT_Wavecount[LLshift] -1 > 0)
         TextTimeless(StringConcatenate("WaveCount SwHigh",Time[HHshift]),Time[HHshift],High[HHshift]+ ATR[i]*0.4,clrBlack,12, MT_Wavecount[LLshift] -1,0);
     }
//  TextTimeless(StringConcatenate("WaveCount SwLow",Time[LLshift]),Time[LLshift],Low[LLshift]- 200*Point,clrBlack,12, Wavecount[LLshift]-1,0);
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int MT_Populate_TrendCont_TrendReversal()
  {
   for(int i = LookBack; i >= 1 ; i--)
     {
      //Print(" i = ",i ," MT_MA_Trend_Angle[i] = ",MT_MA_Trend_Angle[i] );
      if(MT_MA_Trend_Angle[i] == 2  && MT_Wavecount[i] >6 && MT_UP_Stoc[i] ==1)
        {
         MT_Trend_Reversal[i] = 1;
         // Print(" MT_Trend_Reversal[i] = ",MT_Trend_Reversal[i]);
        }
      if(MT_MA_Trend_Angle[i] == 1  && MT_Wavecount[i] >6  && MT_Down_Stoc[i] ==2) //
        {
         MT_Trend_Reversal[i] = 2;
         //  Print(" MT_Trend_Reversal[i] = ",MT_Trend_Reversal[i]);
        }
      if(MT_MA_Trend_Angle[i] == 1  && MT_Wavecount[i] <5 && MT_UP_Stoc[i] ==1)
        {
         MT_Trend_Cont[i] = 1;
         // Print("  MT_Trend_Cont[i] = ", MT_Trend_Cont[i]);
        }
      if(MT_MA_Trend_Angle[i] == 2   && MT_Wavecount[i] <5  && MT_Down_Stoc[i] ==2)
        {
         MT_Trend_Cont[i] = 2;
         //  Print("  MT_Trend_Cont[i] = ", MT_Trend_Cont[i]);
        }
      //   if(MT_Trend_Cont[i] >0)
      //   {
      ////   Print(" i = ", i , " MT_Trend_Cont[i] = ",MT_Trend_Cont[i]);
      // }
     }
   return(0);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Main Price Impulse Analysis Function                            |
//+------------------------------------------------------------------+
void PriceImpulseAnalysis()
  {
   int limit = LookBack; //MathMin(rates_total - 1, LookbackBars);

//// Resize arrays
//   ArrayResize(ST_Stoc_K, limit + 1);
//   ArrayResize(MT_Stoc_K, limit + 1);
//   ArrayResize(MT_EMA45, limit + 1);
//   ArrayResize(MT_MA150, limit + 1);
//   ArrayResize(BB_Upper, limit + 1);
//   ArrayResize(BB_Lower, limit + 1);
//   ArrayResize(ImpulseWithoutRetrace, limit + 1);
//
//// Initialize ImpulseWithoutRetrace array
//   ArrayInitialize(ImpulseWithoutRetrace, 0);

// Pre-populate arrays
//for(int i = 0; i <= limit; i++)
//{
// ST_Stoc_K[i] = iStochastic(NULL, 0, 5, 3, 2, MODE_SMA, 0, MODE_MAIN, i);
// MT_Stoc_K[i] = iStochastic(NULL, 0, 15, 9, 6, MODE_SMA, 0, MODE_MAIN, i);
// MT_EMA45[i] = iMA(NULL, 0, 45, 0, MODE_EMA, PRICE_MEDIAN, i);
// MT_MA150[i] = iMA(NULL, 0, 150, 0, MODE_SMA, PRICE_MEDIAN, i);
// BB_Upper[i] = iBands(NULL, 0, 20, 2, 0, PRICE_CLOSE, MODE_UPPER, i);
// BB_Lower[i] = iBands(NULL, 0, 20, 2, 0, PRICE_CLOSE, MODE_LOWER, i);
//}

// Clear previous objects if showing only recent setup
//if(Setups == 1)
//  {
//   ObjectsDeleteAll(0, "PIR_");
//   ObjectsDeleteAll(0, "PIR_BEAR_");
//  }

// BULLISH LOGIC - Find L2 points and analyze setups
   for(int i = LookBack; i >= 1 && i < actualCopied; i--)  // Start from 200 to have enough history
     {
      // Check for L2 conditions (BULLISH)
      CHECK_ARRAY_INDEX(CandleClose, i);
      //    Print(" CandleClose i = ",i );
      if(CandleClose[i] > MT_EMA45[i] &&
         MT_EMA45[i] > MT_EMA45[i+1] &&
         MT_EMA45[i] > MT_MA150[i+1] &&
         MT_MA150[i] > MT_MA150[i+1] &&
         MT_Stoc_K[i] < 55)
        {

         // Found potential L2 point
         int L2_bar = i;

         // Find L1 - last close below MT_EMA45 before crossing above
         int L1_bar = -1;
         double L1_price = 0;
         int TagTheUpperBand =0;
         for(int j = i + 1; j <= limit - 10; j++)
           {
            if(CandleClose[j] > MT_BBand_UPPER220[j])
              {
               // wait for first setup to finish
               TagTheUpperBand = 1;
              }

            if(CandleClose[j] < MT_EMA45[j] && TagTheUpperBand == 1)
              {
               // Found last close below EMA45, now find nearest swing low
               for(int k = j; k <= limit - 5; k++)
                 {
                  double fractal = iFractals(NULL, 0, MODE_LOWER, k);
                  if(fractal > 0)
                    {
                     L1_bar = k;
                     L1_price = fractal;
                     //               ArrowTimeless(StringConcatenate("Impulse - L1",Time[k]),Time[k],High[k],clrOrange,108);

                     break;
                    }
                 }
               break;
              }
           }

         if(L1_bar == -1)
           {
            //   continue; // No L1 found
           }
         else
           {

            // Check Rule 1 - Price crosses MT_EMA45 only once and no 3 consecutive closes below
            bool rule1_valid = CheckRule1_Bullish(L1_bar, L2_bar);
            if(!rule1_valid)
              {

               //continue;
              }
            else
              {

               // Find H1 and H2
               double H1_price = 0;
               int H1_bar = -1;
               double H2_price = 0;
               int H2_bar = -1;
               //        TextTimeless(StringConcatenate("Impulse - L2_H1 check",i),Time[i],Close[i]+ 100*Point,clrBlack,7, "  "+L2_bar+"  "+L1_bar,90.0);

               // Find H1 - highest close outside upper Bollinger band
               for(int j = L1_bar; j >= L2_bar; j--)
                 {
                  if(CandleClose[j] > MT_BBand_UPPER220[j] && CandleHigh[j] > H1_price)
                    {

                     H1_price = CandleHigh[j];
                     H1_bar = j;
                     //            ArrowTimeless(StringConcatenate("Impulse - H1",Time[j]),Time[j],High[j],clrPink,108);

                     //    Print("i = ",i," H1_price = ",H1_price," H1_bar = ",H1_bar );

                    }
                 }

               // Check Rule 2 - Must have H1

               if(H1_bar == -1)
                 {
                  //Print(" No H1_bar i = ",i," H1_bar = ",H1_bar," H1_price = ",H1_price," H1_bar = ",H1_bar );
                  //   continue;
                 }
               else
                 {

                  //Print("i = ",i," H1_price = ",H1_price," H1_bar = ",H1_bar," L2_bar = ",L2_bar );

                  // Find H2 - highest point between L1 and L2
                  for(int j = H1_bar; j >= L2_bar; j--)
                    {
                     if(CandleHigh[j] > H2_price)
                       {
                        H2_price = CandleHigh[j];
                        H2_bar = j;

                       }
                    }
                  //         ArrowTimeless(StringConcatenate("Impulse - H2",Time[H2_bar]),Time[H2_bar],High[H2_bar],clrRed,108);
                  // Calculate F1 - 38.2% Fibonacci level
                  double F1_price = H2_price - ((H2_price - L1_price) * 0.382);
                  //         ArrowTimeless(StringConcatenate("Impulse - F1",Time[H2_bar]),Time[H2_bar],F1_price,clrBlue,232);
                  // Check Rule 3 - L2 must be above F1 and no close below F1 between H2 and L2
                  bool rule3_valid = CheckRule3_Bullish(H2_bar, L2_bar, F1_price);
                  if(!rule3_valid)
                    {
                     //  continue;
                    }
                  else
                    {
                     //              ArrowTimeless(StringConcatenate("Impulse - F1check",Time[H2_bar]),Time[H2_bar],F1_price-100*Point,clrGreen,252);
                     // Count cycles between L2 and H1
                     //   FindSwingHighH3(L1_bar,L2_bar);
                     int cycle_count = CountCycles(L2_bar, FindSwingHighH3(L1_bar,L2_bar));
                     //   TextTimeless(StringConcatenate("Impulse - CycleCounts",i),Time[H2_bar],Close[H2_bar]+ 100*Point,clrBlack,7, cycle_count+"  "+L2_bar+"  "+H1_bar,90.0);
                     //  Print("BULLISH i = ",i,"Count = ",cycle_count," L2_bar = ",L2_bar," H1_bar = ",H1_bar);
                     // All rules passed - draw the setup and set signal
                     //             ArrowTimeless(StringConcatenate("Impulse - L2",Time[i]),Time[i],High[i],clrGreen,108);
                     ////                     DrawSetup_Bullish(L1_bar, L1_price, H1_bar, H1_price, H2_bar, H2_price,
                     ////                               L2_bar, F1_price, cycle_count, Time[L2_bar]);
                     ////
                     // Set bullish signal
                     if(cycle_count >= 3)
                       {
                        ImpulseWithoutRetrace[i] = 1;
                       }
                     //if(Setups == 1)
                     //   break; // Only show most recent
                     //if(i < 100)
                     //  {
                     //   Print("i= ",i);
                     //  }
                    }
                 }
              }
           }
        }
     }

// BEARISH LOGIC - Find H2 points and analyze setups
   for(int i = LookBack; i >= 1 && i < actualCopied; i--)  // Start from 200 to have enough history
     {
      // Check for H2 conditions (BEARISH) - inverse of bullish L2 conditions
      if(CandleClose[i] < MT_EMA45[i] &&
         MT_EMA45[i] < MT_EMA45[i+1] &&
         MT_EMA45[i] < MT_MA150[i+1] &&
         MT_MA150[i] < MT_MA150[i+1] &&
         MT_Stoc_K[i] > 45)
        {

         // Found potential H2 point (bearish equivalent of L2)
         int H2_bar_bear = i;

         // Find H1 - last close above MT_EMA45 before crossing below
         int H1_bar_bear = -1;
         double H1_price_bear = 0;
         int TagTheLowerBand = 0;
         for(int j = i + 1; j <= limit - 10; j++)
           {
            if(CandleClose[j] < MT_BBand_LOWER220[j])
              {
               // wait for first setup to finish
               TagTheLowerBand = 1;
              }

            if(CandleClose[j] > MT_EMA45[j] && TagTheLowerBand == 1)
              {
               // Found last close above EMA45, now find nearest swing high
               for(int k = j; k <= limit - 5; k++)
                 {
                  double fractal = iFractals(NULL, 0, MODE_UPPER, k);
                  if(fractal > 0)
                    {
                     H1_bar_bear = k;
                     H1_price_bear = fractal;
                     //            ArrowTimeless(StringConcatenate("Impulse - Bear_H1",Time[k]),Time[k],Low[k],clrOrange,242);

                     break;
                    }
                 }
               break;
              }
           }

         if(H1_bar_bear == -1)
           {
            //   continue; // No H1 found
           }
         else
           {

            // Check Rule 1 - Price crosses MT_EMA45 only once and no 3 consecutive closes above
            bool rule1_valid_bear = CheckRule1_Bearish(H1_bar_bear, H2_bar_bear);
            if(!rule1_valid_bear)
              {

               //continue;
              }
            else
              {

               // Find L1 and L2 (bearish equivalents)
               double L1_price_bear = 99999;
               int L1_bar_bear = -1;
               double L2_price_bear = 99999;
               int L2_bar_bear = -1;
               //  TextTimeless(StringConcatenate("Impulse - Bear_H2_L1 check",i),Time[i],Close[i]- 100*Point,clrBlack,7, "  "+H2_bar_bear+"  "+H1_bar_bear,90.0);

               // Find L1 - lowest close outside lower Bollinger band
               for(int j = H1_bar_bear; j >= H2_bar_bear; j--)
                 {
                  if(CandleClose[j] < MT_BBand_LOWER220[j] && CandleLow[j] < L1_price_bear)
                    {

                     L1_price_bear = CandleLow[j];
                     L1_bar_bear = j;
                     //      ArrowTimeless(StringConcatenate("Impulse - Bear_L1",Time[j]),Time[j],Low[j],clrPink,242);

                    }
                 }

               // Check Rule 2 - Must have L1

               if(L1_bar_bear == -1)
                 {
                  //Print(" No L1_bar_bear i = ",i," L1_bar_bear = ",L1_bar_bear," L1_price_bear = ",L1_price_bear );
                  //   continue;
                 }
               else
                 {

                  // Find L2 - lowest point between H1 and H2
                  for(int j = L1_bar_bear; j >= H2_bar_bear; j--)
                    {
                     if(CandleLow[j] < L2_price_bear)
                       {
                        L2_price_bear = CandleLow[j];
                        L2_bar_bear = j;

                       }
                    }
                  //   ArrowTimeless(StringConcatenate("Impulse - Bear_L2",Time[L2_bar_bear]),Time[L2_bar_bear],Low[L2_bar_bear],clrRed,242);
                  // Calculate F1 - 38.2% Fibonacci level (bearish)
                  double F1_price_bear = L2_price_bear + ((H1_price_bear - L2_price_bear) * 0.382);
                  //   ArrowTimeless(StringConcatenate("Impulse - Bear_F1",Time[L2_bar_bear]),Time[L2_bar_bear],F1_price_bear,clrBlue,232);
                  // Check Rule 3 - H2 must be below F1 and no close above F1 between L2 and H2
                  bool rule3_valid_bear = CheckRule3_Bearish(L2_bar_bear, H2_bar_bear, F1_price_bear);
                  if(!rule3_valid_bear)
                    {
                     //  continue;
                    }
                  else
                    {
                     //          ArrowTimeless(StringConcatenate("Impulse - Bear_F1check",Time[L2_bar_bear]),Time[L2_bar_bear],F1_price_bear+100*Point,clrGreen,252);
                     // Count cycles between H2 and L1
                     int cycle_count_bear = CountCycles(H2_bar_bear, FindSwingLowL3(H1_bar_bear, H2_bar_bear));
                     //  TextTimeless(StringConcatenate("Impulse - Bear_CycleCounts",i),Time[L2_bar_bear],Close[L2_bar_bear]- 100*Point,clrBlack,7, cycle_count_bear+"  "+H2_bar_bear+"  "+L1_bar_bear,90.0);
                     //   Print("BEARISH i = ",i,"Count = ",cycle_count_bear," H2_bar = ",H2_bar_bear," L1_bar = ",L1_bar_bear);
                     // All rules passed - draw the setup and set signal
                     //  ArrowTimeless(StringConcatenate("Impulse - Bear_H2_final",Time[i]),Time[i],Low[i],clrGreen,242);
                     //////DrawSetup_Bearish(H1_bar_bear, H1_price_bear, L1_bar_bear, L1_price_bear, L2_bar_bear, L2_price_bear,
                     //////          H2_bar_bear, F1_price_bear, cycle_count_bear, Time[H2_bar_bear]);

                     // Set bearish signal
                     if(cycle_count_bear >= 3)
                       {
                        ImpulseWithoutRetrace[i] = 2;
                       }

                    }
                 }
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Find the shift (bar index) of the last swing high (H3) between  |
//| L2 and L1 using fractals. H3 must be above Close[L2]             |
//+------------------------------------------------------------------+
int FindSwingHighH3(int L1, int L2)
  {
   int H3shift = 0;
   double HighestValue = 0;

// Loop from L2 back to L1
   for(int k = L2; k <= L1; k++)
     {
      double fractalHigh = iFractals(NULL, 0, MODE_UPPER, k);

      if(fractalHigh != 0.0 && CandleHigh[k] > CandleClose[L2])
        {
         H3shift = k;
        }
     }

   if(H3shift > 0)
     {
      //ArrowTimeless(StringConcatenate("Impulse - H3",Time[H3shift]),Time[H3shift],Low[H3shift]-300*Point,clrPink,234);
      return(H3shift);
     }
   return -1; // No valid H3 found
  }

//+------------------------------------------------------------------+
//| Find the shift (bar index) of the last swing low (L3) between   |
//| H2 and H1 using fractals. L3 must be below Close[H2]            |
//+------------------------------------------------------------------+
int FindSwingLowL3(int H1, int H2)
  {
   int L3shift = 0;
   double LowestValue = 99999;

// Loop from H2 back to H1
   for(int k = H2; k <= H1; k++)
     {
      double fractalLow = iFractals(NULL, 0, MODE_LOWER, k);

      if(fractalLow != 0.0 && CandleLow[k] < CandleClose[H2])
        {
         L3shift = k;
        }
     }

   if(L3shift > 0)
     {
      //ArrowTimeless(StringConcatenate("Impulse - Bear_L3",Time[L3shift]),Time[L3shift],High[L3shift]+300*Point,clrPink,233);
      return(L3shift);
     }
   return -1; // No valid L3 found
  }
//+------------------------------------------------------------------+
//| Check Rule 1 - Price crosses EMA45 only once, no 3 consecutive closes below (BULLISH) |
//+------------------------------------------------------------------+
bool CheckRule1_Bullish(int L1_bar, int L2_bar)
  {
   int crosses = 0;
   int consecutive_below = 0;
   bool was_above = false;

   for(int i = L1_bar; i >= L2_bar; i--)
     {
      if(CandleClose[i] > MT_EMA45[i])
        {
         if(!was_above)
            crosses++;
         was_above = true;
         consecutive_below = 0;
        }
      else
        {
         if(was_above)
            consecutive_below++;
         if(consecutive_below >= 3)
            return false;
        }
     }

   return crosses <= 1;
  }

//+------------------------------------------------------------------+
//| Check Rule 1 - Price crosses EMA45 only once, no 3 consecutive closes above (BEARISH) |
//+------------------------------------------------------------------+
bool CheckRule1_Bearish(int H1_bar, int H2_bar)
  {
   int crosses = 0;
   int consecutive_above = 0;
   bool was_below = false;

   for(int i = H1_bar; i >= H2_bar; i--)
     {
      if(CandleClose[i] < MT_EMA45[i])
        {
         if(!was_below)
            crosses++;
         was_below = true;
         consecutive_above = 0;
        }
      else
        {
         if(was_below)
            consecutive_above++;
         if(consecutive_above >= 3)
            return false;
        }
     }

   return crosses <= 1;
  }

//+------------------------------------------------------------------+
//| Check Rule 3 - L2 above F1 and no close below F1 between H2 and L2 (BULLISH) |
//+------------------------------------------------------------------+
bool CheckRule3_Bullish(int H2_bar, int L2_bar, double F1_price)
  {
   if(CandleClose[L2_bar] <= F1_price)
      return false;

   for(int i = H2_bar; i >= L2_bar; i--)
     {
      if(CandleClose[i] < F1_price)
         return false;
     }

   return true;
  }

//+------------------------------------------------------------------+
//| Check Rule 3 - H2 below F1 and no close above F1 between L2 and H2 (BEARISH) |
//+------------------------------------------------------------------+
bool CheckRule3_Bearish(int L2_bar, int H2_bar, double F1_price)
  {
   if(CandleClose[H2_bar] >= F1_price)
      return false;

   for(int i = L2_bar; i >= H2_bar; i--)
     {
      if(CandleClose[i] > F1_price)
         return false;
     }

   return true;
  }

//+------------------------------------------------------------------+
//| Count half cycles between L2 and H1                             |
//+------------------------------------------------------------------+
int CountCycles(int start_bar, int end_bar)
  {
   int cycles = 0;
   bool in_top_cycle = false;
   bool in_bottom_cycle = false;

// Check initial state at start
   if(ST_Stoc_K[start_bar] > 55)
      in_top_cycle = true;
   else
      if(ST_Stoc_K[start_bar] < 45)
         in_bottom_cycle = true;

   for(int i = start_bar; i <= end_bar; i++)
     {
      double stoc = ST_Stoc_K[i];

      if(!in_top_cycle && !in_bottom_cycle)
        {
         if(stoc > 55)
           {
            in_top_cycle = true;
            cycles++;
            //   ArrowTimeless(StringConcatenate("Impulse - Cycle",Time[i]),Time[i],Low[i]-300*Point,clrPink,167);
           }
         else
            if(stoc < 45)
              {
               in_bottom_cycle = true;
               cycles++;
               //      ArrowTimeless(StringConcatenate("Impulse - Cycle",Time[i]),Time[i],Low[i]-300*Point,clrPink,167);
              }
        }
      else
         if(in_top_cycle)
           {
            if(stoc < 55)
              {
               in_top_cycle = false;
               if(stoc < 45)
                 {
                  in_bottom_cycle = true;
                  cycles++;
                  //     ArrowTimeless(StringConcatenate("Impulse - Cycle",Time[i]),Time[i],Low[i]-300*Point,clrPink,167);
                 }
              }
           }
         else
            if(in_bottom_cycle)
              {
               if(stoc > 45)
                 {
                  in_bottom_cycle = false;
                  if(stoc > 55)
                    {
                     in_top_cycle = true;
                     cycles++;
                     //      ArrowTimeless(StringConcatenate("Impulse - Cycle",Time[i]),Time[i],Low[i]-300*Point,clrPink,167);
                    }
                 }
              }
     }
   return cycles;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int XMarksTheSpot()
  {
   for(int i=LookBack; i>=1; i--)
     {
      int CurrentCyleStart = 0;
      int SwingLowCounter = 0;
      int SwingHighCounter  =0;
      int SwingLowCounter2 = 0;
      int UPSwingHighCounter = 0;
      int UPSwingHighCounter2 = 0;
      int UPSwingLowCounter = 0;
      int UPCurrentCyleStart = 0;
      int ATRDistance =0;

      bool CloseBelow45EMA = false;
      bool ValidSwingHigh = false;
      bool ValidSwingLowBelow150SMA = false;
      bool ValidSetup = false;
      double Historical_distance =0;
      double distance =0;


      distance = MathAbs(MT_MA150[i] - MT_EMA45[i]);
      if(ATR14[i] > distance)
        {
         //    ArrowTimeless(StringConcatenate("WaveCount Xmark", i), CandleTime[i], CandleHigh[i], clrRed, 159);
         ATRDistance = 1;
        }
      //Print(" i = ",i);
      //---
      //--- BEARISH SCENARIO (Original Code)
      //---
      if(ATRDistance == 1 && CandleClose[i] < MT_EMA45[i])
        {
         ValidSwingHigh = false;
         ValidSwingLowBelow150SMA = false;
         ValidSetup = false;

         int CountStocOverSold = 0;
         for(int x=i; x<LookBack && x < actualCopied; x++)
           {
            Historical_distance = MathAbs(MT_MA150[x] - MT_EMA45[x]);
            if(Historical_distance < ATR14[x])
              {
               //          ArrowTimeless(StringConcatenate("WaveCount CloseBelow45EMA", x), CandleTime[x], CandleHigh[x] + 100 * Point, clrGreenYellow, 251);
               //       Print(" Historical_distance < ATR[x] CandleTime[x] = ",CandleTime[x]);
              }

            if(MT_EMA45[x] > MT_MA150[x]  && ST_EMA15[x] > MT_EMA45[x] && ValidSwingLowBelow150SMA == false)
              {
               //   ArrowTimeless(StringConcatenate("WaveCount Setup False", x), CandleTime[x], CandleHigh[x] + 200 * Point, clrRed, 251);
               ValidSetup = false;
               break;
              }
            if((CandleHigh[x] > ST_EMA15[x] || MT_Stoc_K[x] > 55) && Historical_distance < ATR14[x])//CandleHigh[x] > ST_EMA15[x] ||
              {
               //  ArrowTimeless(StringConcatenate("WaveCount ValidSwingHigh", x), CandleTime[x], CandleHigh[x] + 300 * Point, clrPurple, 251);
               ValidSwingHigh = true;
              }

            if(ValidSwingHigh == true && MT_UP_Stoc[x] == 1 && CandleClose[x] < MT_MA150[x])
              {
               //   ArrowTimeless(StringConcatenate("WaveCount ValidSwingLowBelow150SMA", x), CandleTime[x], CandleHigh[x] + 250 * Point, clrGreen, 251);
               ValidSwingLowBelow150SMA = true;
              }
            if(ValidSwingLowBelow150SMA == true && MT_UP_Stoc[x] == 1 && MT_UP_Stoc[x+1] == 0)
              {
               //                       ArrowTimeless(StringConcatenate("WaveCount CountStocOverSold", x), CandleTime[x], CandleHigh[x] + 150 * Point, clrOrange, 251);
               CountStocOverSold = CountStocOverSold +1;
              }

            if(CountStocOverSold ==1 && CandleClose[x] > MT_MA150[x] && MT_Stoc_K[x] > 55 && iClose(currentSymbol,currentTimeframe,x)> MT_MA150[x])
              {
               //  ArrowTimeless(StringConcatenate("WaveCount ValidSetup = true", x), CandleTime[x], CandleHigh[x] + 150 * Point, clrPink, 251);
               //    ArrowTimeless(StringConcatenate("WaveCount i candle", i), CandleTime[i], CandleHigh[i] + 150 * Point, clrRed, 168);
               ValidSetup = true;
               break;
              }
           }
         if(ValidSetup == true)
           {
            //  ArrowTimeless(StringConcatenate("WaveCount ValidSetupBearish", i), CandleTime[i], CandleHigh[i] + 300 * Point, clrBlue, 252);
            //  Print("Valid Setup");
            if(CheckRangingMarket(i) == 1)
              {
               //     ArrowTimeless(StringConcatenate("WaveCount Ranging", i), CandleTime[i], CandleHigh[i] + 250 * Point, clrRed, 168);
              }
            if(CheckEMABelowSMAWithATRDistance(i,LookBack) == 1)
              {
               //   ArrowTimeless(StringConcatenate("WaveCount CheckBelow", i), CandleTime[i], CandleHigh[i] +  150 * Point, clrGreen, 252);
              }
            if(CheckEMAClosetoLargerEMA(i) ==1)
              {
               //  ArrowTimeless(StringConcatenate("WaveCount ARTsmall", i), CandleTime[i], CandleHigh[i] +  350 * Point, clrGreen, 252);
              }

            if(CheckRangingMarket(i) == 0  && (CheckEMABelowSMAWithATRDistance(i,LookBack) == 1  || CheckEMAClosetoLargerEMA(i) ==1) && CheckStochasticWhileATRCondition(i) ==1)
              {
               //   ArrowTimeless(StringConcatenate("WaveCount BearishSignal", i), CandleTime[i], CandleHigh[i] +  150 * Point, clrRed, 234);
               X_Marks_the_spot[i] = 2;  // Bearish
               // Print(" i = ",i," X_Marks_the_spot[i] = ",X_Marks_the_spot[i], " (BEARISH)");
              }
           }
        }

      //---
      //--- BULLISH SCENARIO (New Code - Inverted Logic)
      //---
      if(ATRDistance == 1 && CandleClose[i] > MT_EMA45[i])
        {
         bool ValidSwingLow = false;
         bool ValidSwingHighAbove150SMA = false;
         bool ValidBullishSetup = false;

         int CountStocOverBought = 0;
         for(int x=i; x<LookBack && x < actualCopied; x++)
           {
            Historical_distance = MathAbs(MT_MA150[x] - MT_EMA45[x]);
            if(Historical_distance < ATR14[x])
              {
               //     ArrowTimeless(StringConcatenate("WaveCount CloseAbove45EMA", x), Time[x], Low[x] - 100 * Point, clrCyan, 251);
              }

            // Break if trend changes against bullish setup
            if(MT_EMA45[x] < MT_MA150[x]  && ST_EMA15[x] < MT_EMA45[x] && ValidSwingHighAbove150SMA == false)
              {
               ValidBullishSetup = false;
               break;
              }

            // Look for swing low (inverted from swing high)
            if((CandleLow[x] < ST_EMA15[x] || MT_Stoc_K[x] < 45) && Historical_distance < ATR14[x])
              {
               ValidSwingLow = true;
              }

            // Look for swing high above 150 SMA (inverted from swing low below 150 SMA)
            if(ValidSwingLow == true &&  MT_Down_Stoc[x] == 2 && CandleClose[x] > MT_MA150[x])
              {
               ValidSwingHighAbove150SMA = true;
              }

            // Count oversold to overbought transitions (inverted)
            if(ValidSwingHighAbove150SMA == true && MT_Down_Stoc[x] ==2  &&  MT_Down_Stoc[x+1] == 0)
              {
               CountStocOverBought = CountStocOverBought + 1;
              }

            // Final validation for bullish setup (inverted conditions)
            if(CountStocOverBought == 1 && CandleClose[x] < MT_MA150[x] && MT_Stoc_K[x] < 45)
              {
               ValidBullishSetup = true;
               break;
              }
           }

         if(ValidBullishSetup == true)
           {
            // ArrowTimeless(StringConcatenate("WaveCount ValidSetupBullish", i), Time[i], Low[i] - 300 * Point, clrLime, 252);

            if(CheckRangingMarketBullish(i) == 1)
              {
               //   ArrowTimeless(StringConcatenate("WaveCount RangingBull", i), Time[i], Low[i] - 250 * Point, clrOrange, 168);
              }
            if(CheckEMAAboveSMAWithATRDistance(i,LookBack) == 1)  // You'll need to create this function
              {
               //   ArrowTimeless(StringConcatenate("WaveCount CheckAbove", i), Time[i], Low[i] - 150 * Point, clrLime, 252);
              }
            if(CheckEMAClosetoSmallerEMA(i) == 1)  // You'll need to create this function
              {
               //  ArrowTimeless(StringConcatenate("WaveCount ARTsmallBull", i), Time[i], Low[i] - 350 * Point, clrLime, 252);
              }

            if(CheckRangingMarketBullish(i) == 0 && (CheckEMAAboveSMAWithATRDistance(i,LookBack) == 1 || CheckEMAClosetoSmallerEMA(i) == 1) && CheckStochasticWhileATRConditionBullish(i) == 1)
              {
               //  ArrowTimeless(StringConcatenate("WaveCount BullishSignal", i), Time[i], Low[i] - 150 * Point, clrLime, 233);
               X_Marks_the_spot[i] = 1;  // Bullish
               //Print(" i = ",i," X_Marks_the_spot[i] = ",X_Marks_the_spot[i], " (BULLISH)");
              }
           }
        }
     }
   return(0);  // Added return statement
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CheckRangingMarket(int i)
  {
   int ret = 0;
   int ATRDistance = 0;
   int Above55_And_ATR = 0;
   int Cycles_And_ATR = 0;
   int Above55 = 0;
   int Below45 = 0;
   int Below45_And_ATR = 0;
   double distance = 0;
   int Cycles = 0;

// State tracking variables
   bool inAbove55State = false;
   bool inBelow45State = false;
   bool above55CycleProcessed = false;
   bool below45CycleProcessed = false;

// ATR streak tracking
   int consecutiveBarsWithoutATR = 0;

   for(int k = i; k < i + 1000 && k < LookBack; k++)//&& k < LookBack
     {
      // Reset ATRDistance for each bar and recalculate
      ATRDistance = 0;
      distance = MathAbs(MT_MA150[k] - MT_EMA45[k]);
      if(ATR14[k] > distance)
        {
         ATRDistance = 1;
         consecutiveBarsWithoutATR = 0; // Reset counter when ATR condition is met
        }
      else
        {
         consecutiveBarsWithoutATR++; // Increment counter when ATR condition is not met
        }

      // Break if 30 consecutive bars without ATRDistance = 1
      if(consecutiveBarsWithoutATR >= 30)
        {
         break;
        }
      if(CandleClose[k]<MT_BBand_LOWER3520[k])
        {
         break;
        }
      if(LT_Stoc_K[i+1] >  LT_Stoc_K[i] && LT_Stoc_D[i+1] > LT_Stoc_D[i] && (MT_Stoc_K[i+1] >  MT_Stoc_K[i] || MT_Stoc_D[i+1] > MT_Stoc_D[i]) &&
         MT_MA150[i] > MT_EMA45[i] &&
         MT_MA150[i+1] > MT_MA150[i] &&
         MT_EMA45[i+1] > MT_EMA45[i])
        {
         break;
        }

      // Check for below 45 state
      if(MT_Stoc_K[k] < 45)
        {
         // If we weren't already in below45 state, this is a new cycle
         if(!inBelow45State)
           {
            inBelow45State = true;
            inAbove55State = false;
            above55CycleProcessed = false; // Reset for next cycle

            // Count this as a new half-cycle (including current position)
            Cycles++;
            Below45 = 1;
            Above55 = 0; // Reset above55 flag
            below45CycleProcessed = false; // Reset processing flag for this cycle
           }

         // Check ATR condition for this half-cycle (only once per cycle)
         if(ATRDistance == 1 && !below45CycleProcessed)
           {
            Below45_And_ATR = 1;
            Cycles_And_ATR++;
            below45CycleProcessed = true; // Mark this cycle as processed
            //  ArrowTimeless(StringConcatenate("WaveCount CountStocOverSold", k), Time[k], High[k] + 50 * Point, clrRoyalBlue, 167);
           }
        }
      // Check for above 55 state
      else
         if(MT_Stoc_K[k] > 55)
           {
            // If we weren't already in above55 state, this is a new cycle
            if(!inAbove55State)
              {
               inAbove55State = true;
               inBelow45State = false;
               below45CycleProcessed = false; // Reset for next cycle

               // Count this as a new half-cycle (including current position)
               Cycles++;
               Above55 = 1;
               Below45 = 0; // Reset below45 flag
               above55CycleProcessed = false; // Reset processing flag for this cycle
              }

            // Check ATR condition for this half-cycle (only once per cycle)
            if(ATRDistance == 1 && !above55CycleProcessed)
              {
               Above55_And_ATR = 1;
               Cycles_And_ATR++;
               above55CycleProcessed = true; // Mark this cycle as processed
               //     ArrowTimeless(StringConcatenate("WaveCount CountStocOverBought", k), Time[k], High[k] + 50 * Point, clrGreen, 167);
              }
           }
      // Check if we found 3 half-cycles with ATR condition met
      if(Cycles_And_ATR == 3)
        {
         ret = 1;
         //  ArrowTimeless(StringConcatenate("WaveCount Ranging", k), Time[k], High[k] + 150 * Point, clrPurple, 168);
         break;
        }

      // Stop after 3 half-cycles regardless of ATR condition
      if(Cycles == 4)
         break;
     }

   return(ret);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CheckEMAClosetoLargerEMA(int i)
  {
   if(MT_EMA45[i] >= MT_MA150[i])
     {
      // Calculate distance between MA150 and EMA45
      double distance = MathAbs(MT_MA150[i] - MT_EMA45[i]);

      // Check ATRDistance condition
      int ATRDistance = 0;
      if(ATR14[i]*0.25 > distance && MT_EMA45[i] < MT_EMA45[i+1] && MT_EMA45[i+1] < MT_EMA45[i+2])
        {
         return 1;
        }
      else
        {
         return 0;
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
//| Simplified version focusing only on the core logic              |
//+------------------------------------------------------------------+
int CheckStochasticWhileATRCondition(int k)
  {
   for(int i = k; i < i+100 && i+100 < LookBack; i++)
     {
      // Skip invalid data
      if(ATR14[i] == EMPTY_VALUE || MT_MA150[i] == EMPTY_VALUE || MT_EMA45[i] == EMPTY_VALUE || ATR14[i] == 0 || MT_MA150[i] == 0 || MT_EMA45[i] == 0)
         continue;

      double distance = MathAbs(MT_MA150[i] - MT_EMA45[i]);

      // Continue while ATR >= distance
      if(ATR14[i] >= distance)
        {
         // Check if all stochastics are below 20
         if(LT_Stoc_K[i] < 20.0 && LT_Stoc_D[i] < 20.0 &&
            MT_Stoc_K[i] < 20.0 && MT_Stoc_D[i] < 20.0)
           {
            return 0; // Failed condition
           }
        }
      else
        {
         break; // ATR condition no longer met
        }
     }

   return 1; // Passed
  }
//+------------------------------------------------------------------+
//| Check EMA below SMA with ATR distance condition                  |
//| Returns 1 if:                                                    |
//| 1) Current EMA45 is below SMA150                                 |
//| 2) All previous periods until EMA crossed above SMA had ATRDistance = 1 |
//+------------------------------------------------------------------+
int CheckEMABelowSMAWithATRDistance(int x,int arraySize)
  {
//Check condition 1: Current EMA45 is below SMA150
   if(MT_EMA45[x] >= MT_MA150[x])
     {
      return 0; // EMA is not below SMA currently
     }

// Find the cross point where EMA45 crossed above SMA150
   int crossPoint = -1;

// Start from index 1 (previous bar) and look backwards
   for(int i = x; i < x+50 && i <LookBack; i++)
     {
      // Calculate distance between MA150 and EMA45
      double distance = MathAbs(MT_MA150[i] - MT_EMA45[i]);


      // Check if we have valid data
      if(MT_EMA45[i] == EMPTY_VALUE || MT_MA150[i] == EMPTY_VALUE || MT_EMA45[i] == 0 || MT_MA150[i] == 0)
         continue;

      // Check if EMA crossed above SMA at this point
      // Current bar: EMA below SMA, Previous bar: EMA above SMA
      if(i == 1)
        {
         // For the first check, compare current vs previous
         if(MT_EMA45[i] > MT_MA150[i])
           {
            crossPoint = i;
            break;
           }
        }
      else
        {
         // For subsequent bars, look for the crossing pattern
         if(MT_EMA45[i] < MT_MA150[i] && MT_EMA45[i+1] > MT_MA150[i+1])
            //  if(distance < ATR[i]  || MT_EMA45[i] < MT_MA150[i] && MT_EMA45[i+1] > MT_MA150[i+1])
           {
            crossPoint = i;
            break;
           }
        }
     }
// If no cross point found, check all available data
   if(crossPoint == -1)
     {
      return 0;
      crossPoint = arraySize - 1;

     }
// Check condition 2: All periods from current (index 0) up to cross point
// must have ATRDistance = 1
   for(int k = x; k <= crossPoint; k++)
     {
      // Skip if we don't have valid data
      if(MT_EMA45[k] == EMPTY_VALUE || MT_MA150[k] == EMPTY_VALUE || MT_EMA45[k] == 0 || MT_MA150[k] == 0)
         continue;
     }

// Both conditions are met
   return 1;
  }
//+------------------------------------------------------------------+
//| Check EMA above SMA with ATR distance condition (Bullish)       |
//| Returns 1 if:                                                    |
//| 1) Current EMA45 is above SMA150                                 |
//| 2) All previous periods until EMA crossed below SMA had ATRDistance = 1 |
//+------------------------------------------------------------------+
int CheckEMAAboveSMAWithATRDistance(int x, int arraySize)
  {
// Check condition 1: Current EMA45 is above SMA150
   if(MT_EMA45[x] <= MT_MA150[x])
     {
      return 0; // EMA is not above SMA currently
     }

// Find the cross point where EMA45 crossed below SMA150
   int crossPoint = -1;

// Start from index 1 (previous bar) and look backwards
   for(int i = x; i < x + 50 && i < LookBack; i++)
     {
      // Calculate distance between MA150 and EMA45
      double distance = MathAbs(MT_MA150[i] - MT_EMA45[i]);

      // Check if we have valid data
      if(MT_EMA45[i] == EMPTY_VALUE || MT_MA150[i] == EMPTY_VALUE || MT_EMA45[i] == 0 || MT_MA150[i] == 0)
         continue;

      // Check if EMA crossed below SMA at this point
      // Current bar: EMA above SMA, Previous bar: EMA below SMA
      if(i == 1)
        {
         // For the first check, compare current vs previous
         if(MT_EMA45[i] < MT_MA150[i])
           {
            crossPoint = i;
            break;
           }
        }
      else
        {
         // For subsequent bars, look for the crossing pattern (inverted from bearish)
         if(MT_EMA45[i] > MT_MA150[i] && MT_EMA45[i+1] < MT_MA150[i+1])
           {
            //        ArrowTimeless(StringConcatenate("WaveCount CrossPointBull", i), Time[i], Low[i] - 200 * Point, clrYellow, 116);
            crossPoint = i;
            break;
           }
        }
     }

// If no cross point found, check all available data
   if(crossPoint == -1)
     {
      return 0;
      crossPoint = arraySize - 1;
     }

// Check condition 2: All periods from current (index 0) up to cross point
// must have ATRDistance = 1
   for(int k = x; k <= crossPoint; k++)
     {
      // Skip if we don't have valid data
      if(MT_EMA45[k] == EMPTY_VALUE || MT_MA150[k] == EMPTY_VALUE || MT_EMA45[k] == 0 || MT_MA150[k] == 0)
         continue;


     }

// Both conditions are met
   return 1;
  }

//+------------------------------------------------------------------+
//| Check EMA close to smaller EMA (Bullish version)                |
//| Returns 1 if EMA45 is close to MA150 with bullish conditions    |
//+------------------------------------------------------------------+
int CheckEMAClosetoSmallerEMA(int i)
  {
   if(MT_EMA45[i] <= MT_MA150[i])
     {
      // Calculate distance between EMA45 and MA150
      double distance = MathAbs(MT_MA150[i] - MT_EMA45[i]);

      // Check ATRDistance condition (inverted logic - EMA rising)
      int ATRDistance = 0;
      if(ATR14[i] * 0.25 > distance && MT_EMA45[i] > MT_EMA45[i+1] && MT_EMA45[i+1] > MT_EMA45[i+2])
        {
         return 1;
        }
      else
        {
         return 0;
        }
     }
   return 0;
  }

//+------------------------------------------------------------------+
//| Check Stochastic while ATR condition (Bullish version)          |
//| Returns 0 if all stochastics are above 80 while ATR >= distance |
//| Returns 1 if condition passes (inverted from bearish)           |
//+------------------------------------------------------------------+
int CheckStochasticWhileATRConditionBullish(int k)
  {
   for(int i = k; i < k + 100 && i + 100 < LookBack; i++)
     {
      // Skip invalid data
      if(ATR14[i] == EMPTY_VALUE || MT_MA150[i] == EMPTY_VALUE || MT_EMA45[i] == EMPTY_VALUE || ATR14[i] == 0 || MT_MA150[i] == 0 || MT_EMA45[i] == 0)
         continue;

      double distance = MathAbs(MT_MA150[i] - MT_EMA45[i]);

      // Continue while ATR >= distance
      if(ATR14[i] >= distance)
        {
         // Check if all stochastics are above 80 (inverted from < 20)
         if(LT_Stoc_K[i] > 80.0 && LT_Stoc_D[i] > 80.0 &&
            MT_Stoc_K[i] > 80.0 && MT_Stoc_D[i] > 80.0)
           {
            return 0; // Failed condition (too overbought)
           }
        }
      else
        {
         break; // ATR condition no longer met
        }
     }

   return 1; // Passed
  }

//+------------------------------------------------------------------+
//| Enhanced Ranging Market Check for Bullish Scenarios             |
//| Same logic as original but with additional bullish markers      |
//+------------------------------------------------------------------+
int CheckRangingMarketBullish(int i)
  {
   int ret = 0;
   int ATRDistance = 0;
   int Above55_And_ATR = 0;
   int Cycles_And_ATR = 0;
   int Above55 = 0;
   int Below45 = 0;
   int Below45_And_ATR = 0;
   double distance = 0;
   int Cycles = 0;

// State tracking variables
   bool inAbove55State = false;
   bool inBelow45State = false;
   bool above55CycleProcessed = false;
   bool below45CycleProcessed = false;

// ATR streak tracking
   int consecutiveBarsWithoutATR = 0;

   for(int k = i; k < LookBack; k++)
     {
      // Reset ATRDistance for each bar and recalculate
      ATRDistance = 0;
      distance = MathAbs(MT_MA150[k] - MT_EMA45[k]);
      if(ATR14[k] > distance)
        {
         ATRDistance = 1;
         consecutiveBarsWithoutATR = 0; // Reset counter when ATR condition is met
        }
      else
        {
         consecutiveBarsWithoutATR++; // Increment counter when ATR condition is not met
        }

      // Break if 30 consecutive bars without ATRDistance = 1
      if(consecutiveBarsWithoutATR >= 30)
        {
         break;
        }

      // Break if price goes above upper Bollinger Band (bullish breakout)
      if(CandleClose[k] > MT_BBand_UPPER3520[k])
        {
         break;
        }

      // Break on strong bearish momentum (inverted from bullish break condition)
      if(LT_Stoc_K[i+1] < LT_Stoc_K[i] && LT_Stoc_D[i+1] < LT_Stoc_D[i] &&
         (MT_Stoc_K[i+1] < MT_Stoc_K[i] || MT_Stoc_D[i+1] < MT_Stoc_D[i]) &&
         MT_MA150[i] < MT_EMA45[i] &&
         MT_MA150[i+1] < MT_MA150[i] &&
         MT_EMA45[i+1] < MT_EMA45[i])
        {
         break;
        }

      // Check for below 45 state
      if(MT_Stoc_K[k] < 45)
        {
         // If we weren't already in below45 state, this is a new cycle
         if(!inBelow45State)
           {
            inBelow45State = true;
            inAbove55State = false;
            above55CycleProcessed = false; // Reset for next cycle

            // Count this as a new half-cycle (including current position)
            Cycles++;
            Below45 = 1;
            Above55 = 0; // Reset above55 flag
            below45CycleProcessed = false; // Reset processing flag for this cycle
           }

         // Check ATR condition for this half-cycle (only once per cycle)
         if(ATRDistance == 1 && !below45CycleProcessed)
           {
            Below45_And_ATR = 1;
            Cycles_And_ATR++;
            below45CycleProcessed = true; // Mark this cycle as processed
            //       ArrowTimeless(StringConcatenate("WaveCount CountStocOverSoldBull", k), Time[k], Low[k] - 50 * Point, clrAqua, 167);
           }
        }

      // Check for above 55 state
      else
         if(MT_Stoc_K[k] > 55)
           {
            // If we weren't already in above55 state, this is a new cycle
            if(!inAbove55State)
              {
               inAbove55State = true;
               inBelow45State = false;
               below45CycleProcessed = false; // Reset for next cycle

               // Count this as a new half-cycle (including current position)
               Cycles++;
               Above55 = 1;
               Below45 = 0; // Reset below45 flag
               above55CycleProcessed = false; // Reset processing flag for this cycle
              }

            // Check ATR condition for this half-cycle (only once per cycle)
            if(ATRDistance == 1 && !above55CycleProcessed)
              {
               Above55_And_ATR = 1;
               Cycles_And_ATR++;
               above55CycleProcessed = true; // Mark this cycle as processed
               //      ArrowTimeless(StringConcatenate("WaveCount CountStocOverBoughtBull", k), Time[k], Low[k] - 50 * Point, clrLime, 167);
              }
           }

      // Check if we found 3 half-cycles with ATR condition met
      if(Cycles_And_ATR == 3)
        {
         ret = 1;
         //    ArrowTimeless(StringConcatenate("WaveCount RangingBull", k), Time[k], Low[k] - 150 * Point, clrOrange, 168);
         break;
        }

      // Stop after 3 half-cycles regardless of ATR condition
      if(Cycles == 4)
         break;
     }

   return(ret);
  }
//+------------------------------------------------------------------+
//---
//---
//---                   LT_WAVECOUNT
//---
//---
//---
//---
//---
//+------------------------------------------------------------------+
int LT_Trend()
  {

   for(int i=LookBack; i>=1; i--)
     {
      if(Angle450SMA(i) == 1   && DetectValid_TopDog_Trend_BB450SMA(i) == 1) //Angle150SMA(i) == 1   &&
        {
         LT_MA_Trend_Angle[i] = 1;
         //       ArrowTimeless(StringConcatenate("LT_UP",Time[i]),Time[i],High[i]+20*Point,clrGreen,167);
        }
      if(Angle450SMA(i) == 2    &&  DetectValid_TopDog_Trend_BB450SMA(i) == 2)//Angle150SMA(i) == 2    &&
        {
         LT_MA_Trend_Angle[i] = 2;
         //       ArrowTimeless(StringConcatenate("LT_DOWN",Time[i]),Time[i],High[i]+20*Point,clrRed,167);
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int LT_Populate_second_Layer_Arrays()
  {
   for(int i=LookBack-2; i>=1; i--)
     {
      if(LT_ValidStocExtreme(i) ==1 || StocdivergenceLT(i) == 1)
        {
         LT_UP_Stoc[i] = 1;
         //      Print(" LT_UPStoc i = ", i);
         //ArrowTimeless(StringConcatenate("LT_UP",Time[i]),Time[i],High[i]+20*Point,clrGreenYellow,167);
        }
      else
        {
         if(LT_ValidStocExtreme(i) ==2 || StocdivergenceLT(i) == 2)
           {
            LT_Down_Stoc[i] = 2;
            //                Print(" LT_DownStoc i = ", i);
            // ArrowTimeless(StringConcatenate("LT_DOWN",Time[i]),Time[i],High[i]+20*Point,clrRed,167);
           }
        }
      //---   SMA_ANgle
      //    LT_SMA_Angle(i);
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|     Stoc       - Check LT and ST Stochastics for swing highs.
//+------------------------------------------------------------------+
int LT_ValidStocExtreme(int i)
  {
   int ret = 0;
   if(LT_Stoc_K[i] > 55 && (LT_Stoc_K[i] > 78 || LT_Stoc_K[i+1] > 78 || LT_Stoc_K[i+2] > 78|| LT_Stoc_K[i+3] > 78))
     {
      ret=2;
      //  ArrowTimeless(StringConcatenate("RubberBand StocExtremeHigh",i),Time[i ],High[i],clrPink,108);
     }

   if(LT_Stoc_K[i] < 45 && (LT_Stoc_K[i] < 22 || LT_Stoc_K[i+1] < 22|| LT_Stoc_K[i+3] < 22|| LT_Stoc_K[i+3] < 22))
     {
      ret=1;
      //  ArrowTimeless(StringConcatenate("RubberBand StocExtremeLow",i),Time[i ],Low[i],clrGreen,108);
     }

   return(ret);
  }
//+------------------------------------------------------------------+
//|      StocdivergenceLT                                            |
//+------------------------------------------------------------------+
int StocdivergenceLT(int i)
  {
   double SwingValue = 0;
   double PriceFirstValue,PriceSecondValue;
   int Swing,SwingCnt;
   int ret = 0;
   double StocSwingValue = 0;
   double StocFirstValue,StocSecondValue;
   int StocSwing,StocSwingCnt;


// -STOC
// - BUY
   if(LT_Stoc_K[i]<50 && LT_Stoc_K[i]>20)
     {
      StocFirstValue = LT_Stoc_K[i];
      PriceFirstValue = iClose(currentSymbol,currentTimeframe,i);//Close[i];
      StocSwing = i;
      StocSwingCnt = StocSwingCnt +1;
      for(int k = i; k< LookBack; k++) //     for(int k = i; k<i+100; k++)
        {
         if(LT_Stoc_K[k+1]>50)
           {
            //    ArrowTimeless(StringConcatenate("RubberBand Low",k),Time[k ],Low[k ],clrBlack,108);
            break;
           }
         // Print("LT_Stoc_K[k] = ",LT_Stoc_K[k]);
         if(LT_Stoc_K[k]  > LT_Stoc_K[k+1] && LT_Stoc_K[k+2] > LT_Stoc_K[k+1]&& LT_Stoc_K[k+1]<20)
           {
            //Print(" &&&&&&&&&&& Stock below 20");
            //determine if swing low is below 20  - find StocSwing position
            StocSecondValue = LT_Stoc_K[k+1];//iStochastic(NULL,0,15,9,6,MODE_SMA,0,MODE_MAIN,k+1);
            PriceSecondValue =   MathMin(iClose(currentSymbol,currentTimeframe,k+1),MathMin(iClose(currentSymbol,currentTimeframe,k+2),iClose(currentSymbol,currentTimeframe,k+3)));  // MathMin(Close[k+1],MathMin(Close[k+2],Close[k+3]));
            StocSwing = k+1;
            StocSwingCnt = StocSwingCnt +1;
            //   ArrowTimeless(StringConcatenate("RubberBand Low2",k+1),Time[k+1],PriceSecondValue,clrGreen,108);
            break;
           }
        }
      if(StocSwingCnt == 2)
        {
         for(int x = i; x<StocSwing-1; x++)
           {
            if(iLow(currentSymbol,currentTimeframe,x)  < PriceSecondValue && StocSecondValue < LT_Stoc_K[x]) //Low[x]
              {
               ret=1;
               //  ArrowTimeless(StringConcatenate("RubberBand Low2",x ),Time[x ],PriceSecondValue,clrGreen,108);
              }
           }
        }

     }
//-- SELL

   if(LT_Stoc_K[i]>50 && LT_Stoc_K[i]<80)
     {

      StocFirstValue = LT_Stoc_K[i] ;
      StocSwing = i+1;
      StocSwingCnt = StocSwingCnt +1;
      PriceFirstValue = iClose(currentSymbol,currentTimeframe,i) ;//Close[i];
      for(int k = i; k<LookBack; k++)
        {
         if(LT_Stoc_K[k+1]<50)
           {
            StocSwingCnt = 0;
            break;
           }
         if(LT_Stoc_K[k] < LT_Stoc_K[k+1] && LT_Stoc_K[k+2] < LT_Stoc_K[k+1] && LT_Stoc_K[k+1]>80)
           {
            StocSecondValue =  LT_Stoc_K[k+1];
            PriceSecondValue = MathMax(iClose(currentSymbol,currentTimeframe,k+1),MathMax(iClose(currentSymbol,currentTimeframe,k+2),iClose(currentSymbol,currentTimeframe,k+3)));      //MathMax(Close[k+1],MathMax(Close[k+2],Close[k+3]));
            StocSwing = k+1;
            StocSwingCnt = StocSwingCnt +1;
            //   ArrowTimeless(StringConcatenate("RubberBand Low",i),Time[i ],High[i ]+300*Point,clrRed,108);
            break;
           }
        }
      if(StocSwingCnt == 2)
        {
         for(int x = i; x<StocSwing-1; x++)
           {
            if(iHigh(currentSymbol,currentTimeframe,x)  > PriceSecondValue && StocSecondValue > LT_Stoc_K[x]) //High[x]
              {
               ret=2;
               //    ArrowTimeless(StringConcatenate("RubberBand Low2",x ),Time[x ],PriceSecondValue,clrPink,108);
              }
           }
         //if(StocSwingCnt == 2)
         //  {
         //   if(PriceFirstValue > PriceSecondValue && StocFirstValue < StocSecondValue)
         //     {
         //      //  ArrowTimeless(StringConcatenate("RubberBand Low",i),Time[i ],High[i ]+300*Point,clrRed,108);
         //      ret = 2;
         //     }
        }

     }

   return(ret);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ST_Populate_second_Layer_Arrays()
  {
   for(int i=LookBack-2; i>=1; i--)
     {
      if(ST_ValidStocExtreme(i) ==1) //|| ST_Stocdivergence(i) == 1)
        {
         ST_UP_Stoc[i] = 1;
         //      Print(" ST_UPStoc i = ", i);
         //ArrowTimeless(StringConcatenate("ST_UP",Time[i]),Time[i],High[i]+20*Point,clrGreenYellow,167);
        }
      else
        {
         if(ST_ValidStocExtreme(i) ==2)// || ST_Stocdivergence(i) == 2)
           {
            ST_Down_Stoc[i] = 2;
            //                Print(" ST_DownStoc i = ", i);
            // ArrowTimeless(StringConcatenate("ST_DOWN",Time[i]),Time[i],High[i]+20*Point,clrRed,167);
           }
        }

     }
   return(0);
  }
//+------------------------------------------------------------------+
//|     Stoc       - Check LT and ST Stochastics for swing highs.
//+------------------------------------------------------------------+
int ST_ValidStocExtreme(int i)
  {
   int ret = 0;
   if(ST_Stoc_K[i] > 55 && (ST_Stoc_K[i] > 78 || ST_Stoc_K[i+1] > 78 || ST_Stoc_K[i+2] > 78|| ST_Stoc_K[i+3] > 78))
     {
      ret=2;
      //  ArrowTimeless(StringConcatenate("RubberBand StocExtremeHigh",i),Time[i ],High[i],clrPink,108);
     }

   if(ST_Stoc_K[i] < 45 && (ST_Stoc_K[i] < 22 || ST_Stoc_K[i+1] < 22|| ST_Stoc_K[i+3] < 22|| ST_Stoc_K[i+3] < 22))
     {
      ret=1;
      //  ArrowTimeless(StringConcatenate("RubberBand StocExtremeLow",i),Time[i ],Low[i],clrGreen,108);
     }

   return(ret);
  }
//+------------------------------------------------------------------+
//|      StocdivergenceLT                                            |
//+------------------------------------------------------------------+
int ST_Stocdivergence(int i)
  {
   double SwingValue = 0;
   double PriceFirstValue,PriceSecondValue;
   int Swing,SwingCnt;
   int ret = 0;
   double StocSwingValue = 0;
   double StocFirstValue,StocSecondValue;
   int StocSwing,StocSwingCnt;


// -STOC
// - BUY
   if(ST_Stoc_K[i]<50 && ST_Stoc_K[i]>20)
     {
      StocFirstValue = ST_Stoc_K[i];
      PriceFirstValue = iClose(currentSymbol,currentTimeframe,i);//Close[i];
      StocSwing = i;
      StocSwingCnt = StocSwingCnt +1;
      for(int k = i; k< LookBack; k++) //     for(int k = i; k<i+100; k++)
        {
         if(ST_Stoc_K[k+1]>50)
           {
            //    ArrowTimeless(StringConcatenate("RubberBand Low",k),Time[k ],Low[k ],clrBlack,108);
            break;
           }
         // Print("ST_Stoc_K[k] = ",ST_Stoc_K[k]);
         if(ST_Stoc_K[k]  > ST_Stoc_K[k+1] && ST_Stoc_K[k+2] > ST_Stoc_K[k+1]&& ST_Stoc_K[k+1]<20)
           {
            //Print(" &&&&&&&&&&& Stock below 20");
            //determine if swing low is below 20  - find StocSwing position
            StocSecondValue = ST_Stoc_K[k+1];//iStochastic(NULL,0,15,9,6,MODE_SMA,0,MODE_MAIN,k+1);
            PriceSecondValue =   MathMin(iClose(currentSymbol,currentTimeframe,k+1),MathMin(iClose(currentSymbol,currentTimeframe,k+2),iClose(currentSymbol,currentTimeframe,k+3)));  // MathMin(Close[k+1],MathMin(Close[k+2],Close[k+3]));
            StocSwing = k+1;
            StocSwingCnt = StocSwingCnt +1;
            //   ArrowTimeless(StringConcatenate("RubberBand Low2",k+1),Time[k+1],PriceSecondValue,clrGreen,108);
            break;
           }
        }
      if(StocSwingCnt == 2)
        {
         for(int x = i; x<StocSwing-1; x++)
           {
            if(iLow(currentSymbol,currentTimeframe,x)  < PriceSecondValue && StocSecondValue < ST_Stoc_K[x]) //Low[x]
              {
               ret=1;
               //  ArrowTimeless(StringConcatenate("RubberBand Low2",x ),Time[x ],PriceSecondValue,clrGreen,108);
              }
           }
        }

     }
//-- SELL

   if(ST_Stoc_K[i]>50 && ST_Stoc_K[i]<80)
     {

      StocFirstValue = ST_Stoc_K[i] ;
      StocSwing = i+1;
      StocSwingCnt = StocSwingCnt +1;
      PriceFirstValue = iClose(currentSymbol,currentTimeframe,i) ;//Close[i];
      for(int k = i; k<LookBack; k++)
        {
         if(ST_Stoc_K[k+1]<50)
           {
            StocSwingCnt = 0;
            break;
           }
         if(ST_Stoc_K[k] < ST_Stoc_K[k+1] && ST_Stoc_K[k+2] < ST_Stoc_K[k+1] && ST_Stoc_K[k+1]>80)
           {
            StocSecondValue =  ST_Stoc_K[k+1];
            PriceSecondValue = MathMax(iClose(currentSymbol,currentTimeframe,k+1),MathMax(iClose(currentSymbol,currentTimeframe,k+2),iClose(currentSymbol,currentTimeframe,k+3)));      //MathMax(Close[k+1],MathMax(Close[k+2],Close[k+3]));
            StocSwing = k+1;
            StocSwingCnt = StocSwingCnt +1;
            //   ArrowTimeless(StringConcatenate("RubberBand Low",i),Time[i ],High[i ]+300*Point,clrRed,108);
            break;
           }
        }
      if(StocSwingCnt == 2)
        {
         for(int x = i; x<StocSwing-1; x++)
           {
            if(iHigh(currentSymbol,currentTimeframe,x)  > PriceSecondValue && StocSecondValue > ST_Stoc_K[x]) //High[x]
              {
               ret=2;
               //    ArrowTimeless(StringConcatenate("RubberBand Low2",x ),Time[x ],PriceSecondValue,clrPink,108);
              }
           }
         //if(StocSwingCnt == 2)
         //  {
         //   if(PriceFirstValue > PriceSecondValue && StocFirstValue < StocSecondValue)
         //     {
         //      //  ArrowTimeless(StringConcatenate("RubberBand Low",i),Time[i ],High[i ]+300*Point,clrRed,108);
         //      ret = 2;
         //     }
        }

     }

   return(ret);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Angle450SMA(int i)
  {
   int ret =0;
   if(LT_SMA_Angle[i] < -0.02)
     {

      ret = 2;
     }
   else
     {
      if(LT_PreviousTrendtriggerDown(i) == 2)
        {
         ret = 2;
        }
     }
   if(LT_SMA_Angle[i] > 0.02)
     {

      ret = 1;
     }
   else
     {
      if(LT_PreviousTrendtriggerUP(i) == 1)
        {
         ret = 1;
        }
     }
   return(ret);
  }
//+------------------------------------------------------------------+
//|        DetectValid_TopDog_Trend_BB150SMA
//+------------------------------------------------------------------+
int DetectValid_TopDog_Trend_BB450SMA(int i)
  {
   int ret = 0;

   for(int k=i ; k<=LookBack-4; k++)
     {
      if(LT_MA450[k]<LT_MA450[k+3])
        {
         break;
        }
      if(iClose(currentSymbol,currentTimeframe,k) > LT_BBand_UPPER[k])//iBands(NULL,0,60,2,0,PRICE_CLOSE,MODE_UPPER,k)) iClose
        {
         ret =1;
         break;
        }
     }
   for(int k=i ; k<=LookBack-4; k++)
     {
      if(LT_MA450[k]>LT_MA450[k+3])
        {
         break;
        }
      if(iClose(currentSymbol,currentTimeframe,k) < LT_BBand_LOWER[k]) //iBands(NULL,0,60,2,0,PRICE_CLOSE,MODE_LOWER,k))
        {
         ret =2;
         break;
        }
     }
   return(ret);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int LT_PreviousTrendtriggerDown(int i)
  {
   int ret = 0;
   for(int k=i; k<LookBack; k++)
     {
      //    if(iCustom(NULL,0,"SMAAngleV3",150,0,6,3,PRICE_CLOSE,3,k) < -0.02)
      if(LT_SMA_Angle[k] < -0.02)
        {
         ret = 2;
         break;
        }
      else
        {
         //       if(iCustom(NULL,0,"SMAAngleV3",150,0,6,3,PRICE_CLOSE,3,k) >= 0)
         if(LT_SMA_Angle[k] >=0)
           {
            return(0);
           }
        }
     }
   return(ret);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int LT_PreviousTrendtriggerUP(int i)
  {
   int ret = 0;
   for(int k=i; k<LookBack; k++)
     {
      if(LT_SMA_Angle[k] > 0.02)
        {
         ret = 1;
         break;
        }
      else
        {
         if(LT_SMA_Angle[k] <=0)
           {
            return(0);
           }
        }
     }
   return(ret);
  }
//+------------------------------------------------------------------+
//| Custom Function: Fast Swing High on Stochastic Reversal          |
//+------------------------------------------------------------------+
void LT_FindPrice_Swing_High()
  {
   int swingShift = -1;
   double swingHighPrice = -1;


// 1. Cache stochastic values
//  int lookback = MathMin(Bars - 1, MAX_LOOKBACK);
//ArrayResize(LT_Stoc_K, lookback + 2);
//  ArrayResize(LT_PriceSwingHIGHs, lookback + 2);


// 2. Loop from most recent bar to older bars
//  for(i = startShift; i < lookback; i++)
   for(int i = LookBack; i >= 1; i--)
     {
      // Detect cross below 55
      if(LT_Stoc_K[i] < 55 && LT_Stoc_K[i + 1] >= 55)
        {
         int crossBelowShift = i;

         // Search forward for prior cross above 45
         for(int j = i-1 ; j <= LookBack; j++)
           {
            if(LT_Stoc_K[j] > 45 && LT_Stoc_K[j + 1] <= 45)
              {
               // Identify highest price between j and i
               double highest = -1;
               int highShift = -1;

               for(int k = i; k <= j; k++)
                 {
                  if(iHigh(currentSymbol,currentTimeframe,k)  > highest)
                    {
                     highest = iHigh(currentSymbol,currentTimeframe,k);
                     highShift = k;
                    }
                 }
               if(highest >0)
                 {
                  LT_PriceSwingHIGHs[i] = iHigh(currentSymbol,currentTimeframe,highShift);
                  //         ArrowTimeless(StringConcatenate("WaveCount SH",i),Time[i],High[i ]+200*Point,clrGreen,108);
                  //Print("highShift = ",highShift," LT_PriceSwingHIGHs[swingShift] = ", LT_PriceSwingHIGHs[highShift]);
                 }
               for(int x = highShift+1; x <= LookBack; x++)
                 {
                  // Clean up the situations where the 55 is crossed down but then the 45 is not cross to confirm begin of next wave, thus if not closed it is still part of initial wave.
                  if(LT_PriceSwingHIGHs[x] >0)
                    {
                     LT_PriceSwingHIGHs[x] = 0;
                    }
                  if(LT_Stoc_K[x]<45)
                    {
                     break;
                    }
                 }
               // return;
               break;
              }
           }
         // If no prior cross found, exit early
         //break;
        }
     }
// diplay array
//for(int i = 1; i <= LookBack; i++)
//  {
//   if(LT_PriceSwingHIGHs[i] >0 && LT_PriceSwingHIGHs[i] < 300000)
//     {
//     ArrowTimeless(StringConcatenate("WaveCount_SH",i),Time[i],High[i ]+200*Point,clrRed,108);
//      TextTimeless(StringConcatenate("WaveCount SHtext",i),Time[i],High[i],clrBlack,10, LT_PriceSwingHIGHs[i],90.0);
//    //  Print("i = ",i," LT_PriceSwingHIGHs[i] = ", LT_PriceSwingHIGHs[i]);
//     }
//  }
  }
//+------------------------------------------------------------------+
//| Custom Function: Fast Swing Low on Stochastic Reversal           |
//+------------------------------------------------------------------+
void LT_FindPrice_Swing_Lows()
  {
   int swingShift = -1;
   double swingLowPrice = -1;

// 1. Cache stochastic values
//   int lookback = MathMin(Bars - 1, MAX_LOOKBACK);
//   ArrayResize(LT_Stoc_K, lookback + 2);
//  ArrayResize(LT_PriceSwingLOWs, lookback + 2); // <-- for storing swing lows
//


// 2. Loop from most recent bar to older bars
   for(int i = LookBack; i>=1; i--)
     {
      // Detect cross up through 45
      if(LT_Stoc_K[i] > 45 && LT_Stoc_K[i + 1] <= 45)
        {
         int crossAboveShift = i;
         //    ArrowTimeless(StringConcatenate("WaveCount >45", i), Time[i], Low[i] - 300 * Point, clrRed, 108);
         // Look backward for cross down through 55
         //    for(int j = i - 1; j >= startShift; j--)
         for(int j = i-1 ; j <= LookBack; j++)
           {
            if(LT_Stoc_K[j] < 55 && LT_Stoc_K[j + 1] >= 55)
              {
               // Identify lowest price between j and i
               double lowest = 999999;
               int lowShift = -1;
               //   ArrowTimeless(StringConcatenate("WaveCount <55", j), Time[j], Low[j] - 300 * Point, clrOrange, 108);
               for(int k = i; k <= j; k++)
                 {
                  if(iLow(currentSymbol,currentTimeframe,k)   < lowest)
                    {
                     lowest = iLow(currentSymbol,currentTimeframe,k);
                     lowShift = k;
                    }
                 }

               if(lowest != 999999)
                 {
                  LT_PriceSwingLOWs[i] = iLow(currentSymbol,currentTimeframe,lowShift);
                  //          ArrowTimeless(StringConcatenate("WaveCount SL", i), Time[lowShift], Low[lowShift] - 350 * Point, clrBlack, 108);
                 }

               // Clear overlapping invalid entries forward
               for(int x = lowShift + 1; x <= LookBack; x++)
                 {
                  if(LT_PriceSwingLOWs[x] > 0)
                     LT_PriceSwingLOWs[x] = 0;
                  if(LT_Stoc_K[x] > 55)
                     break;
                 }

               break; // Exit inner loop
              }
           }
        }
     }

//// Display array
//for(int i = 1; i <= LookBack; i++)
//  {
//   if(LT_PriceSwingLOWs[i] > 0 && LT_PriceSwingLOWs[i] <3000000)
//     {
//      //  ArrowTimeless(StringConcatenate("WaveCount_SL", i), Time[i], Low[i] - 200 * Point, clrBlue, 108);
//      //  TextTimeless(StringConcatenate("WaveCount _SL",i),Time[i],High[i]+ 100*Point,clrBlack,12,LT_PriceSwingLOWs[i],90.0);
//      // Print("i = ", i, " LT_PriceSwingLOWs[i] = ", LT_PriceSwingLOWs[i]);
//     }
//  }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LT_GetWaveCount()
  {
   double SH,Previous_SH;
   double SL = 3000000;
   double Previous_SL = 3000000;
   int SHshift,SLshift;
   int ConvirmedWavecount;
   int PrevCycleEnd =0;
   int UPtrend = 0;
   int DOWNtrend = 0;
   int FailedWaveConfirmed = 0;
//  ArrayResize(Wavecount, Lookback + 2);
//  ArrayResize(FailWave, Lookback + 2);
   for(int i = LookBack; i >= 1; i--)
     {
      if(LT_MA_Trend_Angle[i] != 1 && LT_MA_Trend_Angle[i] != 2)
        {
         // reset all
         LT_Wavecount[i] = 0;
         LT_FailWave[i] = 0;
         UPtrend = 0;
         DOWNtrend = 0;
         PrevCycleEnd = 0;
        }
      else
        {
         // Print(" Trendangle[i] = ",Trendangle[i]);
         //  ArrowTimeless(StringConcatenate("WaveCount Start", i), Time[i], High[i] + 200 * Point, clrGreen, 108);
         if(LT_MA_Trend_Angle[i] == 1 && LT_MA_Trend_Angle[i+1] != 1)
           {
            // UP trend started
            UPtrend = 1;
            SH = 0;
            SLshift = 0;
            Previous_SH = 0;
            ConvirmedWavecount = 0;
            PrevCycleEnd = i;
            //     ArrowTimeless(StringConcatenate("WaveCount Start7&&", Time[i]), Time[i], High[i] + 200 * Point, clrGreen, 108);
           }
         if(UPtrend == 1)
           {
            LT_Wavecount[i] = LT_Wavecount[i+1];
            LT_FailWave[i] = LT_FailWave[i+1];

            //if((PriceSwingHIGHs[i] != EMPTY_VALUE && PriceSwingHIGHs[i] >0))
            //  {
            //   //make the Swing high value visible on all other itterations
            //   // PriceSwingHIGHs[i] - this value only available on bars when Stoc cross below 55
            //   if(PriceSwingHIGHs[i] > SH )
            //   {
            //    SH = PriceSwingHIGHs[i];
            //   }
            //  }

            if(LT_PriceSwingHIGHs[i]  >0 && LT_Wavecount[i] ==0)
              {
               // Fist scenario different than other increment only by 1 and not 2.
               ConvirmedWavecount =1;
               LT_Wavecount[i] = 1;
               //  PrintWavesUP(PrevCycleEnd,i);
               SH = LT_PriceSwingHIGHs[i];
               //ArrowTimeless(StringConcatenate("WaveCount Nr1", i), Time[i], High[i] + 300 * Point, clrBlueViolet, 108);
               //TextTimeless(StringConcatenate("WaveCount SHtext23",i),Time[i],High[i],clrBlack,10, SH,90.0);

              }
            //if( LT_Wavecount[i]>0 && SH != EMPTY_VALUE )//iHigh(currentSymbol,currentTimeframe,i)>SH &&&& iHigh(currentSymbol,currentTimeframe,i) < 300000
            //{
            //  ArrowTimeless(StringConcatenate("WaveCount high>SH", i), Time[i], High[i] + 50 * Point, clrYellowGreen, 108);
            //  TextTimeless(StringConcatenate("WaveCount SHtext",i),Time[i],High[i],clrBlack,10,iHigh(currentSymbol,currentTimeframe,i)+"    :   "+SH,90.0);
            //}



            if(iHigh(currentSymbol,currentTimeframe,i)>SH && ConvirmedWavecount == LT_Wavecount[i] && LT_Wavecount[i]>0)
              {
               LT_FailWave[i] = 1;
               if(FailedWaveConfirmed == 0)
                 {
                  LT_Wavecount[i] = LT_Wavecount[i]+2;
                 }
               //ArrowTimeless(StringConcatenate("WaveCount high>SH", i), Time[i], High[i] + 100 * Point, clrYellowGreen, 108);
              }
            if(iOpen(currentSymbol,currentTimeframe,i) > SH && iClose(currentSymbol,currentTimeframe,i) > SH && LT_Wavecount[i] >1)
              {
               LT_FailWave[i] = 0;
               //ArrowTimeless(StringConcatenate("WaveCount cl>SH op>SH", i), Time[i], High[i] + 200 * Point, clrPink, 167);
              }

            if((LT_PriceSwingHIGHs[i] >0) && LT_PriceSwingHIGHs[i] > Previous_SH &&  LT_Wavecount[i] >0)
              {
               //ArrowTimeless(StringConcatenate("WaveCount CrossBlow55", i), Time[i], High[i] + 200 * Point,clrBlue, 108);
               ConvirmedWavecount = LT_Wavecount[i];
               if(LT_FailWave[i] == 1)
                 {
                  // confirmed failed wave do not increment on next cycle
                  FailedWaveConfirmed = 1;
                 }
               else
                 {
                  FailedWaveConfirmed = 0;
                  SH = LT_PriceSwingHIGHs[i];
                 }
               LT_FailWave[i] = 0;
               // PrintWavesUP(PrevCycleEnd,i);
               Previous_SH = SH;
               PrevCycleEnd = i;
              }

           }

         if(LT_MA_Trend_Angle[i] == 2 && LT_MA_Trend_Angle[i+1] != 2)
           {
            // UP trend started
            DOWNtrend = 1;
            SL = 3000000;
            //  SLshift = 0;
            Previous_SL = 3000000;
            ConvirmedWavecount = 0;
            PrevCycleEnd = 0;
            FailedWaveConfirmed = 0;
            //       ArrowTimeless(StringConcatenate("WaveCount Start", i), Time[i], High[i] + 200 * Point, clrRed, 108);
            PrevCycleEnd = i;
           }

         if(DOWNtrend == 1)
           {
            LT_Wavecount[i] = LT_Wavecount[i+1];
            LT_FailWave[i] = LT_FailWave[i+1];

            //if((PriceSwingLOWs[i] != EMPTY_VALUE && PriceSwingLOWs[i] >0))
            //  {
            //   //make the Swing lows value visible on all other itterations
            //   // PriceSwingHIGHs[i] - this value only available on bars when Stoc cross below 55
            //   if(PriceSwingLOWs[i] < SL && PriceSwingLOWs[i] != EMPTY_VALUE)
            //     {
            //      SL = PriceSwingLOWs[i];
            //     }
            //  }

            if((LT_PriceSwingLOWs[i]   >0) && LT_Wavecount[i] ==0)
              {
               // Fist scenario different than other increment only by 1 and not 2.
               ConvirmedWavecount =1;
               LT_Wavecount[i] = 1;
               SL = LT_PriceSwingLOWs[i];
               //         ArrowTimeless(StringConcatenate("WaveCount Nr1", i), Time[i], Low[i] - 300 * Point, clrBlueViolet, 108);
               // TextTimeless(StringConcatenate("WaveCount Nr1Text",i),Time[i],High[i]+ 100*Point,clrBlack,12, SL,0);

               //  PrintWavesDOWN(PrevCycleEnd,i);
              }

            if(iLow(currentSymbol,currentTimeframe,i)<SL && ConvirmedWavecount == LT_Wavecount[i] && LT_Wavecount[i]>0)
              {
               LT_FailWave[i] = 1;
               if(FailedWaveConfirmed == 0)
                 {
                  LT_Wavecount[i] = LT_Wavecount[i]+2;
                 }
               //     ArrowTimeless(StringConcatenate("WaveCount low<SL", i), Time[i], Low[i] - 100 * Point, clrYellowGreen, 108);
               //     TextTimeless(StringConcatenate("WaveCount low<SLText",i),Time[i],High[i]+ 100*Point,clrBlack,12, SL,0);
              }
            if(iOpen(currentSymbol,currentTimeframe,i) < SL && iClose(currentSymbol,currentTimeframe,i) < SL && LT_Wavecount[i] >1)
              {
               LT_FailWave[i] = 0;
               //      ArrowTimeless(StringConcatenate("WaveCount cl<SL op<SL", i), Time[i], Low[i] - 200 * Point, clrPink, 167);
              }

            if((LT_PriceSwingLOWs[i] >0) && LT_PriceSwingLOWs[i] < Previous_SL && LT_Wavecount[i]>0)
              {
               //      ArrowTimeless(StringConcatenate("WaveCount CrossAbove45", i), Time[i], Low[i] - 200 * Point,clrBlue, 108);
               ConvirmedWavecount = LT_Wavecount[i];

               if(LT_FailWave[i] == 1)
                 {
                  // confirmed failed wave do not increment on next cycle
                  FailedWaveConfirmed = 1;
                 }
               else
                 {
                  FailedWaveConfirmed = 0;
                  SL = LT_PriceSwingLOWs[i];
                 }
               LT_FailWave[i] = 0;
               // PrintWavesDOWN(PrevCycleEnd,i);
               Previous_SL = SL;
               PrevCycleEnd = i;
              }
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int LT_Populate_TrendCont_TrendReversal()
  {
   for(int i = LookBack; i >= 1 ; i--)
     {
      if(LT_MA_Trend_Angle[i] == 2 && LT_Wavecount[i] >6 && LT_UP_Stoc[i] ==1)
        {
         LT_Trend_Reversal[i] = 1;
         //     Print(" MT_Trend_Reversal[i] = ",MT_Trend_Reversal[i]);
        }
      if(LT_MA_Trend_Angle[i] == 1 && LT_Wavecount[i] >6  && LT_Down_Stoc[i] ==2) //
        {
         LT_Trend_Reversal[i] = 2;

         //    Print(" MT_Trend_Reversal[i] = ",MT_Trend_Reversal[i]);
        }
      if(LT_MA_Trend_Angle[i] == 1 && LT_Wavecount[i] <5 && LT_UP_Stoc[i] ==1)
        {
         LT_Trend_Cont[i] = 1;
         //     Print(" i = ",i," UP LT_Trend_Cont[i] = ", LT_Trend_Cont[i]);
         //ArrowTimeless(StringConcatenate("LT_UP",Time[i]),Time[i],High[i]+20*Point,clrGreen,167);
        }
      if(LT_MA_Trend_Angle[i] == 2 && LT_Wavecount[i] <5  && LT_Down_Stoc[i] ==2)
        {
         LT_Trend_Cont[i] = 2;
         //ArrowTimeless(StringConcatenate("LT_Down",Time[i]),Time[i],High[i]+20*Point,clrRed,167);

        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|           LT_MOM_DAD_Divergence
//+------------------------------------------------------------------+
void LT_MOM_DAD_Divergence()
  {
   double stoch_level55=50;
   double stoch_level45=50;
   bool inSwingHigh = false;
   int swingStartBar = 0;
   int swingEndBar = 0;
   int LastSwingLowBar = -1;
   int LastSwingHighBar55 = -1;
   int LastSwingHighBar45 = -1;
   int LastSwingHighBar = -1;
   swingStartBar = 0;
   swingEndBar = 0;
   int offset = 50;


   for(int i = LookBack-3; i > 0; i--)
     {
      //---
      //--- MOM
      //---

      // Check for swing high start/end (stochastic crosses above 55 threshold)

      if(LT_Stoc_K[i] < stoch_level55 && LT_Stoc_K[i+1] >= stoch_level55)
        {
         //   CreateSwingLabel("|", Time[i],  LT_MACD_MOM[i] - offset*2, clrBlack);
         swingStartBar = i;
         for(int j = i+1; j < LookBack - 50; j++)
           {
            //    if(StochSignalBuffer[j] < stoch_level55 && StochSignalBuffer[j+1] >= stoch_level55)
            if(LT_Stoc_K[j] < stoch_level55 && LT_Stoc_K[j+1] >= stoch_level55)
              {
               //        CreateSwingLabel("^", Time[j], LT_LT_MACD_MOM[j] - offset*2, clrRed);
               swingEndBar = j;
               break;
              }
           }
         // Find the highest swing value in the range
         if(LastSwingLowBar > -1)
            swingEndBar =  MathMin(swingEndBar,LastSwingLowBar);
         //  Print(" LastSwingLowBar = ",LastSwingLowBar," swingEndBar = ",swingEndBar);
         int maxBar = LT_MACDDiv_FindMaxSwingHIGHInRange(swingStartBar, swingEndBar);
         LastSwingHighBar = maxBar;
         if(maxBar > 0)
           {
            LT_MACDDiv_StoreSwingHighValue(maxBar, LT_MACD_MOM[maxBar]);
           }
        }



      // Check for swing low start/end (stochastic crosses above threshold)
      //   if(StochSignalBuffer[i] > stoch_level45 && StochSignalBuffer[i+1] <= stoch_level45)
      if(LT_Stoc_K[i] > stoch_level45 && LT_Stoc_K[i+1] <= stoch_level45)
        {
         swingStartBar = i;
         for(int j = i+1; j < LookBack - 50; j++)
           {
            // if(StochSignalBuffer[j] > stoch_level45 && StochSignalBuffer[j+1] <= stoch_level45)
            if(LT_Stoc_K[j] > stoch_level45 && LT_Stoc_K[j+1] <= stoch_level45)
              {
               swingEndBar = j;
               break;
              }
           }
         // Find the highest swing value in the range
         //      Print(" LastSwingHighBar = ",LastSwingHighBar," swingEndBar = ",swingEndBar);
         if(LastSwingHighBar > -1)
            swingEndBar = MathMin(swingEndBar,LastSwingHighBar);
         //       int t = MathMin(swingEndBar,LastSwingHighBar);

         int maxBar = LT_MACDDiv_FindMaxSwingLOWInRange(swingStartBar, swingEndBar);
         LastSwingLowBar = maxBar;
         // When you set the LastSwingLowBar value
         if(maxBar > 0)
           {
            LT_MACDDiv_StoreSwingLowValue(maxBar, LT_MACD_MOM[maxBar]);
           }
        }

      //---
      //--- DAD
      //---
      double offset = 50;
      //     Print("i = ",i," LT_MACD_DAD[i+1] =  ",LT_MACD_DAD[i+1]);
      if(LT_MACD_DAD[i+2] < LT_MACD_DAD[i+1] && LT_MACD_DAD[i+1] > LT_MACD_DAD[i])
        {
         LT_DADTurnDown[i+1] = i+1;
         //if(displayDADswinglevels == true)
         //   CreateSwingLabel(i+1, Time[i+1], LT_MACD_DAD[i+1]+offset, SwingHighColor);
        }
      if(LT_MACD_DAD[i+2] > LT_MACD_DAD[i+1] && LT_MACD_DAD[i+1] < LT_MACD_DAD[i])
        {
         LT_DADTurnUP[i+1] = i+1;
         //if(displayDADswinglevels == true)
         //   CreateSwingLabel(i+1, Time[i+1], LT_MACD_DAD[i+1]-offset, SwingLowColor);
        }
     }
   LT_MACDDiv_FilterSwingLowsBetweenHighs();
   LT_MACDDiv_FilterSwingHighsBetweenLows();
   LT_MOMUPPattern();
   LT_MOMDownPattern();
   LT_DADUPPattern();
   LT_DADDOWNPattern();
  }
//+------------------------------------------------------------------+
//---
//---
//---      Supporting transactions for the above
//---
//---
//---
//---
//---
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Filter swing low values between consecutive swing highs          |
//+------------------------------------------------------------------+
void LT_MACDDiv_FilterSwingLowsBetweenHighs()
  {
   int highPoints[]; // Array to store indices of swing high points
   int highCount = 0; // Count of valid swing high points

// First pass: Find all valid swing high points
   for(int i = LookBack-1; i >= 0; i--)
     {
      if(LT_MACDDiv_MainSwingHigh_Value[i] != EMPTY_VALUE && LT_MACDDiv_MainSwingHigh_Value[i] != 0)
        {
         // Resize array to accommodate new point
         ArrayResize(highPoints, highCount + 1);
         highPoints[highCount] = i;
         highCount++;
        }
     }

// Process each pair of consecutive swing highs
   for(int pair = 0; pair < highCount - 1; pair++)
     {
      int startBar = highPoints[pair];
      int endBar = highPoints[pair + 1];

      // Ensure proper order (smaller index = older bar)
      if(startBar < endBar)
        {
         int temp = startBar;
         startBar = endBar;
         endBar = temp;
        }

      // Find all swing low points between these highs
      int lowPoints[]; // Array to store indices of swing low points
      int lowCount = 0; // Count of swing low points
      double lowestValue = 999999; // Initialize to a high value
      int lowestIndex = -1;

      for(int i = startBar - 1; i > endBar; i--)
        {
         if(LT_MACDDiv_MainSwingLow_Value[i] != EMPTY_VALUE && LT_MACDDiv_MainSwingLow_Value[i] != 0)
           {
            // Add to array of low points
            ArrayResize(lowPoints, lowCount + 1);
            lowPoints[lowCount] = i;
            lowCount++;

            // Check if this is the lowest value
            if(LT_MACDDiv_MainSwingLow_Value[i] < lowestValue)
              {
               lowestValue = LT_MACDDiv_MainSwingLow_Value[i];
               lowestIndex = i;
              }
           }
        }

      // If we found more than one low point
      if(lowCount > 1)
        {
         // Keep only the lowest value, set others to 0
         for(int j = 0; j < lowCount; j++)
           {
            int lowIndex = lowPoints[j];
            if(lowIndex != lowestIndex)
              {
               // Remove this swing low point
               LT_MACDDiv_MainSwingLow_Value[lowIndex] = 0;
               //     Print(" Values That was set to 0 SwingLow = ",lowIndex);
               // Also remove any text labels associated with this point
               //string objName = indicatorName + "_L_" + TimeToStr(Time[lowIndex]);
               //if(ObjectFind(objName) >= 0)
               //   ObjectDelete(objName);
              }
           }

         //  Print("Filtered swing lows between bars ", startBar, " and ", endBar, ": kept lowest at bar ", lowestIndex);
        }
     }
  }
//+------------------------------------------------------------------+
//| Filter swing high values between consecutive swing lows          |
//+------------------------------------------------------------------+
void LT_MACDDiv_FilterSwingHighsBetweenLows()
  {
   int lowPoints[]; // Array to store indices of swing low points
   int lowCount = 0; // Count of valid swing low points

// First pass: Find all valid swing low points
   for(int i = LookBack-1; i >= 0; i--)
     {
      if(LT_MACDDiv_MainSwingLow_Value[i] != EMPTY_VALUE && LT_MACDDiv_MainSwingLow_Value[i] != 0)
        {
         // Resize array to accommodate new point
         ArrayResize(lowPoints, lowCount + 1);
         lowPoints[lowCount] = i;
         lowCount++;
        }
     }

// Process each pair of consecutive swing lows
   for(int pair = 0; pair < lowCount - 1; pair++)
     {
      int startBar = lowPoints[pair];
      int endBar = lowPoints[pair + 1];

      // Ensure proper order (smaller index = older bar)
      if(startBar < endBar)
        {
         int temp = startBar;
         startBar = endBar;
         endBar = temp;
        }

      // Find all swing high points between these lows
      int highPoints[]; // Array to store indices of swing high points
      int highCount = 0; // Count of swing high points
      double highestValue = -999999; // Initialize to a low value
      int highestIndex = -1;

      for(int i = startBar - 1; i > endBar; i--)
        {
         if(LT_MACDDiv_MainSwingHigh_Value[i] != EMPTY_VALUE && LT_MACDDiv_MainSwingHigh_Value[i] != 0)
           {
            // Add to array of high points
            ArrayResize(highPoints, highCount + 1);
            highPoints[highCount] = i;
            highCount++;

            // Check if this is the highest value
            if(LT_MACDDiv_MainSwingHigh_Value[i] > highestValue)
              {
               highestValue = LT_MACDDiv_MainSwingHigh_Value[i];
               highestIndex = i;
              }
           }
        }

      // If we found more than one high point
      if(highCount > 1)
        {
         // Keep only the highest value, set others to 0
         for(int j = 0; j < highCount; j++)
           {
            int highIndex = highPoints[j];
            if(highIndex != highestIndex)
              {
               // Remove this swing high point
               LT_MACDDiv_MainSwingHigh_Value[highIndex] = 0;
               //     Print(" Set values to 0 at SwingHigh point = ",highIndex);

               // Also remove any text labels associated with this point
               //string objName = indicatorName + "_H_" + TimeToStr(Time[highIndex]);
               //if(ObjectFind(objName) >= 0)
               //   ObjectDelete(objName);
              }
           }

         //  Print("Filtered swing highs between bars ", startBar, " and ", endBar, ": kept highest at bar ", highestIndex);
        }
     }
  }
//+------------------------------------------------------------------+
//|   Scan for Down pattern
//+------------------------------------------------------------------+
int LT_MOMUPPattern()
  {
   double SH1,SH2,SH3, SL1,SL2,SL3;

   double SLFirst = -30000;
   double SHFirst = -30000;

   int UPtrendSwingCnt = 0;
   double offset = 50;
   int LastSwingShift = 0;
   int MoM_Break_HIGH = 0;
   int MoM_Higher_LOW = 0;
   double MOM_Min_Low_Swing_2 = 0;
   double MOM_Min_Low_Swing = 0;
//Print(" Start UPPattern : Verskil = ",Verskil);
   int SH1shift,SH2shift,SH3shift,SL1shift,SL2shift,SL3shift;
   for(int i = LookBack-10; i > 0; i--)
     {
      //  Print(" i = ",i);
      if(LT_MACDDiv_MainSwingHigh_Value[i] < 30000 && LT_MACDDiv_MainSwingHigh_Value[i] !=0)
        {
         //if(displayIndicators_MOM == true)
         //  Print(" i = ",i, " SH1 = ",SH1);
         SH3 = SH2;
         SH3shift = SH2shift;
         SH2 = SH1;
         SH2shift = SH1shift;
         SH1 = LT_MACDDiv_MainSwingHigh_Value[i];
         SHFirst = SH1;
         SH1shift = i;
         //     ArrowTimeless(StringConcatenate("WaveCount SH", i), Time[i], High[i] + 500 * Point, clrRed, 174);
        }
      if(LT_MACDDiv_MainSwingLow_Value[i]  < 30000 && LT_MACDDiv_MainSwingLow_Value[i] !=0)
        {
         //   Print(" i = ",i, " SL1 = ",SL1);
         SL3 = SL2;
         SL3shift = SL2shift;
         SL2 = SL1;

         SL2shift = SL1shift;
         SL1 = LT_MACDDiv_MainSwingLow_Value[i];
         SLFirst = SL1;
         SL1shift = i;
         //    ArrowTimeless(StringConcatenate("WaveCount SL", i), Time[i], Low[i] - 500 * Point, clrGreen, 174);
        }

      //MOM - HIGHER LOW detected
      if(SL3 > SL2 && SL2 < SL1  && SL1 != -30000&& SL2 != -30000&& SL3 != -30000 &&
         SL2 < 0)
        {
         // Pattern for the lower swing high on MOM
         MoM_Higher_LOW = 1;
         MOM_Min_Low_Swing_2 = MathMin(SL1,MathMin(SL2,SL3));
         //if(displayIndicators_MOM == true)
         //   CreateSwingLabel("^", Time[SL1shift], SL1 - offset*3, clrBlack);
        }

      if(MoM_Higher_LOW == 1 && (LT_MACD_DAD[i] > 0 || (LT_MACD_MOM[i] < MOM_Min_Low_Swing_2 && MOM_Min_Low_Swing_2 <0)))
        {
         //Reset the downward signal
         MoM_Higher_LOW = 0;
         MOM_Min_Low_Swing_2 = 0;
         // CreateSwingLabel("|", Time[i], 0, clrBlack);
        }

      if(MoM_Higher_LOW == 1)
        {
         //if(displayIndicators_MOM == true)
         //       CreateSwingLabel("'", Time[i], -50, clrGreen);
         LT_MOMHigherLOW[i]=1;
         //           ArrowTimeless(StringConcatenate("WaveCount Higher_LOW", i), Time[i], High[i] + 100 * Point, clrGreen, 174);
        }

      // MOM - SWING HIGH break UP

      if(LT_MACD_MOM[i] > SH1 && SH1 > -3000)
        {
         // Break of the previous swing high on MOM
         MoM_Break_HIGH = 1;
         MOM_Min_Low_Swing = MathMin(SL1,MathMin(SL2,SL3));
         //             TextTimeless(StringConcatenate("WaveCount SHtext",i),Time[i],High[i],clrBlack,10,   "SL1 = "+MathRound(SL1)+"SL2 = "+MathRound(SL2)+"SL3 = "+MathRound(SL3),90.0);//+ 10000*Point

         //  CreateSwingLabel("@", Time[i], -100, clrGreen);
        }
      if(MoM_Break_HIGH == 1 && (LT_MACD_DAD[i] > 0 || (LT_MACD_MOM[i] < MOM_Min_Low_Swing && MOM_Min_Low_Swing < 0)))
        {
         //Reset the downward signal
         MoM_Break_HIGH = 0;
         MOM_Min_Low_Swing = 0;
         //if(displayIndicators_MOM == true)
         //      CreateSwingLabel("|", Time[i], 0, clrBlack);
        }

      if(MoM_Break_HIGH == 1)
        {
         //if(displayIndicators_MOM == true)
         //     CreateSwingLabel("*", Time[i], -100, clrBlack);
         LT_MOMbreakHIGH[i]=1;
         //ArrowTimeless(StringConcatenate("WaveCount breakHIGH", i), Time[i], High[i] + 100 * Point, clrGreen, 174);
        }
      if(LT_MACD_MOM[i] < SL1)
        {
         LT_MOMbreakHIGH[i]=0;
         LT_MOMHigherLOW[i]=0;
        }

      SHFirst = -30000;
      SLFirst = -30000;
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|   Scan for Down pattern
//+------------------------------------------------------------------+
int LT_MOMDownPattern()
  {
   double SH1,SH2,SH3, SL1,SL2,SL3;

   double SLFirst = -30000;
   double SHFirst = -30000;

   int DowntrendSwingCnt = 0;
   double offset = 50;
   int LastSwingShift = 0;
   int MoM_Break_Low = 0;
   int MoM_Lower_High =0;
   double MOM_Max_High_Swing = 0;
   double MOM_Max_High_Swing_2 = 0;
   int SH1shift,SH2shift,SH3shift,SL1shift,SL2shift,SL3shift;

   for(int i = LookBack-1; i >= 0; i--)
     {
      if(LT_MACDDiv_MainSwingHigh_Value[i] < 30000 && LT_MACDDiv_MainSwingHigh_Value[i] != 0)
        {
         //   Print(" i = ",i, " SH1 = ",SH1);
         SH3 = SH2;
         SH3shift = SH2shift;
         SH2 = SH1;
         SH2shift = SH1shift;
         SH1 = LT_MACDDiv_MainSwingHigh_Value[i];
         SHFirst = SH1;
         SH1shift = i;
         // Print("LT_MACDDiv_MainSwingHigh_Value[i]");
         //    ArrowTimeless(StringConcatenate("WaveCount SH", i), Time[i], High[i] + 500 * Point, clrRed, 174);
         //      TextTimeless(StringConcatenate("WaveCount SHtext",i),Time[i],High[i],clrBlack,10,  SH1,90.0);//+ 10000*Point
        }
      if(LT_MACDDiv_MainSwingLow_Value[i]  < 30000 && LT_MACDDiv_MainSwingLow_Value[i]  != 0)
        {
         SL3 = SL2;
         SL3shift = SL2shift;
         SL2 = SL1;

         SL2shift = SL1shift;
         SL1 = LT_MACDDiv_MainSwingLow_Value[i];
         SLFirst = SL1;
         SL1shift = i;
         //  ArrowTimeless(StringConcatenate("WaveCount SL", i), Time[i], Low[i] - 500 * Point, clrGreen, 174);
        }

      //MOM - LOWER HIGH detected
      if(SH3 < SH2 && SH2 > SH1  && SH1 != -30000&& SH2 != -30000&& SH3 != -30000 &&
         SH2 > 0)
        {
         // Pattern for the lower swing high on MOM
         MoM_Lower_High = 1;
         MOM_Max_High_Swing_2 = MathMax(SH1,MathMax(SH2,SH3));
         //  if(displayIndicators_MOM == true)
         //     CreateSwingLabel("^", Time[SH1shift], SH1 + offset*3, clrBlack);
        }

      if(MoM_Lower_High == 1 && (LT_MACD_DAD[i] < 0 || (LT_MACD_MOM[i] > MOM_Max_High_Swing_2 && MOM_Max_High_Swing_2 >0)))
        {
         //Reset the downward signal
         MoM_Lower_High = 0;
         MOM_Max_High_Swing_2 = 0;
         // CreateSwingLabel("|", Time[i], 0, clrBlack);
        }

      if(MoM_Lower_High == 1)
        {
         // if(displayIndicators_MOM == true)
         //    CreateSwingLabel("'", Time[i], 50, clrRed);
         LT_MOMlowerHIGH[i]=1;
        }

      // MOM - SWING LOW break lower

      if(LT_MACD_MOM[i] < SL1) //DowntrendSwingCnt >=5 &&
        {
         // Break of the previous swing low on MOM
         MoM_Break_Low = 1;
         MOM_Max_High_Swing = MathMax(SH1,MathMax(SH2,SH3));
        }
      if(MoM_Break_Low == 1 && (LT_MACD_DAD[i] < 0 || (LT_MACD_MOM[i] > MOM_Max_High_Swing && MOM_Max_High_Swing >0)))
        {
         //Reset the downward signal
         MoM_Break_Low = 0;
         DowntrendSwingCnt = 0;
         MOM_Max_High_Swing = 0;
         // if(displayIndicators_MOM == true)
         //    CreateSwingLabel("|", Time[i], 200, clrBlack);
        }

      if(MoM_Break_Low == 1)
        {
         // if(displayIndicators_MOM == true)
         //    CreateSwingLabel("*", Time[i], 100, clrBlack);
         LT_MOMbreakLOW[i]=1;
        }
      if(LT_MACD_MOM[i] > SH1)
        {
         LT_MOMbreakLOW[i]=0;
         LT_MOMlowerHIGH[i]=0;
        }

      SHFirst = -30000;
      SLFirst = -30000;
     }
   return(0);
  }
////+------------------------------------------------------------------+
////|   Scan for UP pattern
////+------------------------------------------------------------------+
int LT_DADUPPattern()
  {
   double SH1,SH2,SH3, SL1,SL2,SL3;

   double SLFirst = -30000;
   double SHFirst = -30000;

   int UPtrendSwingCnt = 0;
   double offset = 50;
   int LastSwingShift = 0;
   int DaD_Break_HIGH = 0;
   int DaD_Higher_LOW = 0;
   double DaD_Min_Low_Swing_2 = 0;
   double DaD_Min_Low_Swing = 0;
//Print(" Start UPPattern : Verskil = ",Verskil);
   int SH1shift,SH2shift,SH3shift,SL1shift,SL2shift,SL3shift;
   for(int i = LookBack-1 ; i >= 0; i--)
     {
      //  Print(" i = ",i);
      if(LT_DADTurnDown[i] < 30000 && LT_DADTurnDown[i] !=0)
        {

         SH3 = SH2;
         SH3shift = SH2shift;
         SH2 = SH1;
         SH2shift = SH1shift;
         SH1 = LT_MACD_DAD[i];
         SHFirst = SH1;
         SH1shift = i;
         //   Print(" i = ",i, " SH1 = ",SH1);
         //   ArrowTimeless(StringConcatenate("WaveCount LT SH", i), Time[i], High[i] + 200 * Point, clrRed, 174);
        }
      if(LT_DADTurnUP[i]  < 30000 && LT_DADTurnUP[i] !=0)
        {
         SL3 = SL2;
         SL3shift = SL2shift;
         SL2 = SL1;
         SL2shift = SL1shift;
         SL1 = LT_MACD_DAD[i];
         SLFirst = SL1;
         SL1shift = i;
         //     Print(" i = ",i, " SL1 = ",SL1);
         //    ArrowTimeless(StringConcatenate("WaveCount LT SL", i), Time[i], Low[i] - 200 * Point, clrGreen, 174);
        }

      //---
      //---DAD - HIGHER LOW detected
      //---

      if(SL1 > SL2 &&
         SL1 != -30000&& SL2 != -30000&& SH1 != -30000 &&
         SH1 < 0 && SL2 < 0 && SL1 < 0 &&
         SH1shift > SL1shift)
        {
         // Pattern for the lower swing high on MOM
         //   Print("i = ",i,"  SL1 > SL2 ");
         DaD_Higher_LOW = 1;

         //if(displayIndicators_DAD == true)
         //   CreateSwingLabel("^", Time[SL1shift], SL1 - offset*3, clrBlack);
         //   CreateSwingLabel(IntegerToString(SH1), Time[SL1shift], SL1 - offset*3, clrBlack);
        }

      if(DaD_Higher_LOW == 1 && (LT_MACD_DAD[i] > 0 || SL1 > LT_MACD_DAD[i]))
        {
         //Reset the downward signal
         DaD_Higher_LOW = 0;
         DaD_Min_Low_Swing_2 = 0;
         //if(displayIndicators_DAD == true)
         //   CreateSwingLabel("|", Time[i], 0, clrBlack);
        }

      if(DaD_Higher_LOW == 1)
        {
         //if(displayIndicators_DAD == true)
         //   CreateSwingLabel("'", Time[i], -50, clrGreen);
         LT_DaDHigherLOW[i]=1;

        }


      //---
      //---// DAD - SWING HIGH break UP
      //---

      if(LT_MACD_DAD[i] > SH1 && SH1 > -3000 && SH1 < 0)
        {
         // Break of the previous swing low on MOM
         DaD_Break_HIGH = 1;
         //  CreateSwingLabel("@", Time[i], -100, clrGreen);
        }

      if(DaD_Break_HIGH == 1 && (LT_MACD_DAD[i] > 0 || SL1 > LT_MACD_DAD[i]))
        {
         //Reset the downward signal
         DaD_Break_HIGH = 0;
         DaD_Min_Low_Swing = 0;
         //if(displayIndicators_DAD == true)
         //   CreateSwingLabel("|", Time[i], 0, clrBlack);
        }

      if(DaD_Break_HIGH == 1)
        {
         //if(displayIndicators_DAD == true)
         //   CreateSwingLabel("*", Time[i], -100, clrBlack);
         LT_DaDbreakHIGH[i]=1;
         //     ArrowTimeless(StringConcatenate("WaveCount breakHIGH", i), Time[i], High[i] + 100 * Point, clrGreen, 174);
        }
      SHFirst = -30000;
      SLFirst = -30000;
     }
   return(0);
  }
////+------------------------------------------------------------------+
////|   Scan for UP pattern
////+------------------------------------------------------------------+
int LT_DADDOWNPattern()
  {
   double SH1,SH2,SH3, SL1,SL2,SL3;

   double SLFirst = -30000;
   double SHFirst = -30000;

   int UPtrendSwingCnt = 0;
   double offset = 50;
   int LastSwingShift = 0;
   int DaD_Break_LOW = 0;
   int DaD_Lower_HIGH = 0;

//Print(" Start UPPattern : Verskil = ",Verskil);
   int SH1shift,SH2shift,SH3shift,SL1shift,SL2shift,SL3shift;
   for(int i = LookBack-1 ; i >= 0; i--)
     {
      //  Print(" i = ",i);
      if(LT_DADTurnDown[i] < 30000 && LT_DADTurnDown[i] !=0)
        {

         SH3 = SH2;
         SH3shift = SH2shift;
         SH2 = SH1;
         SH2shift = SH1shift;
         SH1 = LT_MACD_DAD[i];
         SHFirst = SH1;
         SH1shift = i;
         //   Print(" i = ",i, " SH1 = ",SH1);
        }
      if(LT_DADTurnUP[i]  < 30000 && LT_DADTurnUP[i] !=0)
        {
         SL3 = SL2;
         SL3shift = SL2shift;
         SL2 = SL1;
         SL2shift = SL1shift;
         SL1 = LT_MACD_DAD[i];
         SLFirst = SL1;
         SL1shift = i;
         //     Print(" i = ",i, " SL1 = ",SL1);
        }

      //---
      //---DAD - HIGHER LOW detected
      //---

      if(SH1 < SH2 &&
         SH1 != -30000&& SH2 != -30000&& SL1 != -30000 &&
         SH1 > 0 && SH2 > 0 && SL1 > 0 &&
         SL1shift > SH1shift)
        {
         // Pattern for the lower swing high on MOM
         //   Print("i = ",i,"  SL1 > SL2 ");
         DaD_Lower_HIGH = 1;

         //if(displayIndicators_DAD == true)
         //   CreateSwingLabel("^", Time[SH1shift], SH1 + offset*3, clrBlack);
        }

      if(DaD_Lower_HIGH == 1 && (LT_MACD_DAD[i] < 0 || SH1 < LT_MACD_DAD[i]))
        {
         //Reset the downward signal
         DaD_Lower_HIGH = 0;
         //if(displayIndicators_DAD == true)
         //   CreateSwingLabel("|", Time[i], 100, clrBlack);
        }

      if(DaD_Lower_HIGH == 1)
        {
         //if(displayIndicators_DAD == true)
         //   CreateSwingLabel("'", Time[i], 200, clrGreen);
         LT_DaDLowerHigh[i]=1;
        }


      //---
      //---// DAD - SWING HIGH break UP
      //---

      if(LT_MACD_DAD[i] < SL1 && SL1 > -3000 && SL1 > 0)
        {
         // Break of the previous swing low on MOM
         DaD_Break_LOW = 1;
         //  CreateSwingLabel("@", Time[i], -100, clrGreen);
        }

      if(DaD_Break_LOW == 1 && (LT_MACD_DAD[i] < 0 || SH1 < LT_MACD_DAD[i]))
        {
         //Reset the downward signal
         DaD_Break_LOW = 0;
         //if(displayIndicators_DAD == true)
         //   CreateSwingLabel("|", Time[i], 200, clrBlack);
        }

      if(DaD_Break_LOW == 1)
        {
         //if(displayIndicators_DAD == true)
         //   CreateSwingLabel("*", Time[i],  100, clrBlack);
         LT_DaDbreakLOW[i]=1;
        }

      SHFirst = -30000;
      SLFirst = -30000;
     }
   return(0);
  }

//+------------------------------------------------------------------+
//| Store swing low value safely in buffer                           |
//+------------------------------------------------------------------+
void LT_MACDDiv_StoreSwingLowValue(int barIndex, double value)
  {
   LT_MACDDiv_MainSwingLow_Value[barIndex] = value;
//  ArrowTimeless(StringConcatenate("LT_indi_StoreSwingLowValue",Time[barIndex]),Time[barIndex],Low[barIndex]-300*Point,clrGreen,167);
  }
//+------------------------------------------------------------------+
//| Store swing high value safely in buffer                          |
//+------------------------------------------------------------------+
void LT_MACDDiv_StoreSwingHighValue(int barIndex, double value)
  {
   LT_MACDDiv_MainSwingHigh_Value[barIndex] = value;
// ArrowTimeless(StringConcatenate("LT_indi_StoreSwingHighValue",Time[barIndex]),Time[barIndex],Low[barIndex]-300*Point,clrRed,167);
  }
//+------------------------------------------------------------------+
//| Find max swing high in a range                                   |
//+------------------------------------------------------------------+
int LT_MACDDiv_FindMaxSwingLOWInRange(int startBar, int endBar)
  {
   double maxValue = 3000000;
   int maxBar = -1;
// Print(" startBar = ",startBar," endBar = ",endBar);
   double MostrightPoint;
   for(int i = startBar; i <= endBar; i++)
     {

      if(i-2 >0)
         MostrightPoint = LT_MACD_MOM[i-2];
      else
         MostrightPoint = LT_MACD_MOM[i-1];


      if(LT_MACD_MOM[i] < LT_MACD_MOM[i+2] && LT_MACD_MOM[i] < MostrightPoint && LT_MACD_MOM[i] < maxValue)
        {
         //    Print("Max value found: i= ",i);
         //       ArrowTimeless(StringConcatenate("LT_indi_HighValue",Time[i]),Time[i],Low[i]-100*Point,clrGreen,233);
         maxValue = LT_MACD_MOM[i];
         maxBar = i;
        }
     }
   return maxBar;
  }
//+------------------------------------------------------------------+
//| Find max swing high in a range                                   |
//+------------------------------------------------------------------+
int LT_MACDDiv_FindMaxSwingHIGHInRange(int startBar, int endBar)
  {
   double maxValue = -3000000;
   int maxBar = -1;
// Print(" startBar = ",startBar," endBar = ",endBar);
   for(int i = startBar; i <= endBar && i-2 >0 && i-2 <LookBack; i++)
     {

      //   Print(" i = ",i," LT_MACD_DAD[i] = ",LT_MACD_MOM[i]," maxValue = ",maxValue);
      if(LT_MACD_MOM[i] > LT_MACD_MOM[i+2] && LT_MACD_MOM[i] > LT_MACD_MOM[i-2] && LT_MACD_MOM[i] > maxValue && i-2 < LookBack) //
        {
         //    ArrowTimeless(StringConcatenate("LT_indi_LowValue",Time[i]),Time[i],Low[i]-100*Point,clrRed,234);
         //     Print("Max value found: i= ",i);
         maxValue = LT_MACD_MOM[i];
         maxBar = i;
        }
     }
   return maxBar;
  }



//+------------------------------------------------------------------+
void LT_MACD_Divergence()
  {
   LT_MOM_DAD_Divergence();
   for(int i=LookBack; i>=1; i--)
     {

      //-- MOM DAD Divergence START
      int LT_Divergence_UP_Counter = 0;
      int LT_Divergence_DOWN_Counter = 0;
      if(LT_MOMbreakHIGH[i] == 1)
        {
         LT_MOM_Break[i] = 1;
         LT_Divergence_UP_Counter = LT_Divergence_UP_Counter +1;
        }
      if(LT_MOMbreakLOW[i] == 1)
        {
         LT_MOM_Break[i] = 2;
         LT_Divergence_DOWN_Counter = LT_Divergence_DOWN_Counter +1;
        }
      if(LT_MOMHigherLOW[i] == 1)
        {
         LT_MOM_Swing_change[i] = 1;
         LT_Divergence_UP_Counter = LT_Divergence_UP_Counter +1;
        }
      if(LT_MOMlowerHIGH[i] == 1)
        {
         LT_MOM_Swing_change[i] = 2;
         LT_Divergence_DOWN_Counter = LT_Divergence_DOWN_Counter +1;
        }
      if(LT_DaDbreakHIGH[i] == 1)
        {
         LT_DAD_Break[i] = 1;
         LT_Divergence_UP_Counter = LT_Divergence_UP_Counter +1;
        }
      if(LT_DaDbreakLOW[i] == 1)
        {
         LT_DAD_Break[i] = 2;
         LT_Divergence_DOWN_Counter = LT_Divergence_DOWN_Counter +1;
        }
      if(LT_DaDLowerHigh[i] == 1)
        {
         LT_DAD_Swing_change[i] = 2;
         LT_Divergence_DOWN_Counter = LT_Divergence_DOWN_Counter +1;
        }
      if(LT_DaDHigherLOW[i] == 1)
        {
         LT_DAD_Swing_change[i] = 1;
         LT_Divergence_UP_Counter = LT_Divergence_UP_Counter +1;
        }



      if(LT_Divergence_UP_Counter >1 && LT_UP_Stoc[i] ==1)
        {
         LT_Momentum_Divergence_Partial[i] = 1;
         //    Print(" i= ", i,"  LT_Momentum_Divergence_Partial[i] = ",LT_Momentum_Divergence_Partial[i]);
        }
      if(LT_Divergence_UP_Counter == 4  && LT_UP_Stoc[i] ==1)
        {
         LT_Momentum_Divergence_Full[i] = 1;
         //            Print(" i= ", i," LT_Momentum_Divergence_Partial[i] = ",LT_Momentum_Divergence_Partial[i]);
        }
      if(LT_Divergence_DOWN_Counter >0  && LT_Down_Stoc[i] ==2)
        {
         LT_Momentum_Divergence_Partial[i] = 2;
        }
      if(LT_Divergence_DOWN_Counter == 4  && LT_Down_Stoc[i] ==2)
        {
         LT_Momentum_Divergence_Full[i] = 2;
        }
     }
  }
//-- MOM DAD Divergence END
//+------------------------------------------------------------------+
//|  Populate trend direction
//+------------------------------------------------------------------+
int Populate_TrendDirection(int i)
  {
   if(i+1 < LookBack)
     {
      if(MT_MA150[i+1]> MT_MA150[i])
        {
         MT_TrendDirection[i] = 2;
        }
      else
        {
         MT_TrendDirection[i] = 1;
        }
      if(LT_MA450[i+1]> LT_MA450[i])
        {
         LT_TrendDirection[i] = 2;
        }
      else
        {
         LT_TrendDirection[i] = 1;
        }
     }
   return(0);
  }

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Helper function to check if MA value is within range            |
//+------------------------------------------------------------------+
bool IsMAInRange(double maValue, double rangeStart, double rangeEnd)
  {
// Ensure rangeStart is always the lower value
   double lowerBound = MathMin(rangeStart, rangeEnd);
   double upperBound = MathMax(rangeStart, rangeEnd);

   return (maValue >= lowerBound && maValue <= upperBound);
  }
//+------------------------------------------------------------------+
//| CheckMAResistance - Checks for MA resistance/support levels     |
//| Input: direction - 1 for BUY (bullish), 2 for SELL (bearish)   |
//| Returns: 0 if MA resistance/support found, 1 if clear           |
//+------------------------------------------------------------------+
int CheckMAResistance(int AmountOfMASR)
  {
   ArrayResize(MA_Resistance, LookBack + 2);
   ArrayResize(MA_Support, LookBack + 2);
   for(int i=1; i <= LookBack && i<actualCopied; i++)
     {
      // Get current market data
      double currentClose = CandleClose[i];

      // Initialize results
      MA_Resistance[i] = 0;
      MA_Support[i] = 0;

      // Check RESISTANCE (BUY direction - above current price)
      double resistanceRangeStart = currentClose;
      double resistanceRangeEnd = currentClose + (ATR14[i] * 2.0);

      int resistanceMACount = 0;
      if(IsMAInRange(MT_MA150[i], resistanceRangeStart, resistanceRangeEnd))
         resistanceMACount++;
      if(IsMAInRange(ST_MA89[i], resistanceRangeStart, resistanceRangeEnd))
         resistanceMACount++;
      if(IsMAInRange(ST_MA200[i], resistanceRangeStart, resistanceRangeEnd))
         resistanceMACount++;
      if(IsMAInRange(ST_MA365[i], resistanceRangeStart, resistanceRangeEnd))
         resistanceMACount++;
      if(IsMAInRange(LT_MA135[i], resistanceRangeStart, resistanceRangeEnd))
         resistanceMACount++;

      // Set resistance flag if count is acceptable
   //   CHECK_ARRAY_INDEX(ST_Stoc_Divergence, i);
      if(resistanceMACount <= AmountOfMASR  && (TDAlignmentTrigger[i] == 1 ||ST_Stoc_Divergence[i] == 1 ||PriceActionBar[i] == 1))
        {
         MA_Resistance[i] = 1;
         MA_SUPPORT_RESISTANCE[i] = 1;
        }

      // Check SUPPORT (SELL direction - below current price)
      double supportRangeStart = currentClose - (ATR14[i] * 2.0);
      double supportRangeEnd = currentClose;

      int supportMACount = 0;
      if(IsMAInRange(MT_MA150[i], supportRangeStart, supportRangeEnd))
         supportMACount++;
      if(IsMAInRange(ST_MA89[i], supportRangeStart, supportRangeEnd))
         supportMACount++;
      if(IsMAInRange(ST_MA200[i], supportRangeStart, supportRangeEnd))
         supportMACount++;
      if(IsMAInRange(ST_MA365[i], supportRangeStart, supportRangeEnd))
         supportMACount++;
      if(IsMAInRange(LT_MA135[i], supportRangeStart, supportRangeEnd))
         supportMACount++;

      // Set support flag if count is acceptable

      if(supportMACount <= AmountOfMASR  && (TDAlignmentTrigger[i] == 2 ||ST_Stoc_Divergence[i] == 2 ||PriceActionBar[i] == 2))
        {
         MA_Support[i] = 1;
         MA_SUPPORT_RESISTANCE[i] = 2;
        }
     }

   return 1;  // Success
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetTrigger_cnt()
  {
   ClearArray(UP_TRIGGER_COUNT);
   ClearArray(DOWN_TRIGGER_COUNT);
   ArrayResize(UP_TRIGGER_COUNT,LookBack + 2);
   ArrayResize(DOWN_TRIGGER_COUNT,LookBack + 2);
   int UP_Trigger = 0;
   int DOWN_Trigger = 0;

   for(int i=1; i <= LookBack; i++)
     {
      UP_Trigger = 0;
      DOWN_Trigger = 0;

      if(TDAlignmentTrigger[i] == 1)
         UP_Trigger = UP_Trigger + 1;
      if(PriceActionBar[i] == 1)
         UP_Trigger = UP_Trigger + 1;
      if(ST_Stoc_Divergence[i] == 1)
         UP_Trigger = UP_Trigger + 1;

      if(TDAlignmentTrigger[i] == 2)
         DOWN_Trigger = DOWN_Trigger + 1;
      if(PriceActionBar[i] == 2)
         DOWN_Trigger = DOWN_Trigger + 1;
      if(ST_Stoc_Divergence[i] == 2)
         DOWN_Trigger = DOWN_Trigger + 1;

      UP_TRIGGER_COUNT[i] = UP_Trigger;
      DOWN_TRIGGER_COUNT[i] = DOWN_Trigger;
     }

   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetK_D_MOM_cnt()
  {
   ClearArray(UP_K_D_MOM_COUNT);
   ClearArray(DOWN_K_D_MOM_COUNT);
   ArrayResize(UP_K_D_MOM_COUNT,LookBack + 2);
   ArrayResize(DOWN_K_D_MOM_COUNT,LookBack + 2);

   int UP_K_D_MOM = 0;
   int DOWN_K_D_MOM = 0;

   for(int i=1; i <= LookBack; i++)
     {
     DOWN_K_D_MOM = 0;
     UP_K_D_MOM = 0;
      UP_K_D_MOM_COUNT[i] = 0;
      DOWN_K_D_MOM_COUNT[i] = 0;
      if(ST_K_Angle[i] == 1)
         UP_K_D_MOM = UP_K_D_MOM +1;
      if(ST_D_Angle[i] == 1)
         UP_K_D_MOM = UP_K_D_MOM +1;
      if(ST_MOM_Angle[i] == 1)
         UP_K_D_MOM = UP_K_D_MOM +1;
      if(MT_K_Angle[i] == 1)
         UP_K_D_MOM = UP_K_D_MOM +1;
      if(MT_D_Angle[i] == 1)
         UP_K_D_MOM = UP_K_D_MOM +1;
      if(MT_MOM_Angle[i] == 1)
         UP_K_D_MOM = UP_K_D_MOM +1;


      if(ST_K_Angle[i] == 2)
         DOWN_K_D_MOM = DOWN_K_D_MOM+1;
      if(ST_D_Angle[i] == 2)
         DOWN_K_D_MOM = DOWN_K_D_MOM+1;
      if(ST_MOM_Angle[i] == 2)
         DOWN_K_D_MOM = DOWN_K_D_MOM+1;
      if(MT_K_Angle[i] == 2)
         DOWN_K_D_MOM = DOWN_K_D_MOM+1;
      if(MT_D_Angle[i] == 2)
         DOWN_K_D_MOM = DOWN_K_D_MOM+1;
      if(MT_MOM_Angle[i] == 2)
         DOWN_K_D_MOM = DOWN_K_D_MOM+1;

      UP_K_D_MOM_COUNT[i] = UP_K_D_MOM;
      DOWN_K_D_MOM_COUNT[i] = DOWN_K_D_MOM;

     }
   return(0);
  }
//+------------------------------------------------------------------+
//|   Count the SETUPs and populate them in an array
//+------------------------------------------------------------------+
int GetSETUPcnt()
  {
   ClearArray(UP_SETUP_COUNT);
   ClearArray(DOWN_SETUP_COUNT);
   ArrayResize(UP_SETUP_COUNT,LookBack + 2);
   ArrayResize(DOWN_SETUP_COUNT,LookBack + 2);
   int SetupUP = 0;
   int SetupDOWN =0;

   for(int t=1; t <= LookBack; t++)
     {
      UP_SETUP_COUNT[t] = 0;
      DOWN_SETUP_COUNT[t] = 0;
      SetupUP = 0;
      SetupDOWN =0;

      if(MT_Trend_Cont[t] ==1)
         SetupUP = SetupUP+1;
      if(MT_Trend_Reversal[t] ==1)
         SetupUP = SetupUP+1;
      if(FirstCycleAfter_X[t] ==1)
         SetupUP = SetupUP+1;
      if(FirstCycleAfter_DADturns[t] ==1)
         SetupUP = SetupUP+1;
      if(MT_ReloadPattern[t] ==1)
         SetupUP = SetupUP+1;
      if(ST_ReloadPattern[t] ==1)
         SetupUP = SetupUP+1;
      if(MT_Rubberband[t] ==1)
         SetupUP = SetupUP+1;
      if(ST_Rubberband[t] ==1)
         SetupUP = SetupUP+1;
      if(Momentum_Divergence_Partial[t] ==1)
         SetupUP = SetupUP+1;
      if(Momentum_Divergence_Full[t] ==1)
         SetupUP = SetupUP+1;
      //if(LT_Conservative[t] ==1)
      //   SetupUP = SetupUP+1;

      if(MT_MOM_Wave3[t] ==1)
         SetupUP = SetupUP+1;
      if(MT_MOM_Wave2[t] ==1)
         SetupUP = SetupUP+1;
      if(X_Marks_the_spot[t] ==1)
         SetupUP = SetupUP+1;
      if(ImpulseWithoutRetrace[t] ==1)
         SetupUP = SetupUP+1;



      if(MT_Trend_Cont[t] ==2)
         SetupDOWN = SetupDOWN+1;
      if(MT_Trend_Reversal[t] ==2)
         SetupDOWN = SetupDOWN+1;
      if(FirstCycleAfter_X[t] ==2)
         SetupDOWN = SetupDOWN+1;
      if(FirstCycleAfter_DADturns[t] ==2)
         SetupDOWN = SetupDOWN+1;
      if(MT_ReloadPattern[t] ==2)
         SetupDOWN = SetupDOWN+1;
      if(ST_ReloadPattern[t] ==2)
         SetupDOWN = SetupDOWN+1;
      if(MT_Rubberband[t] ==2)
         SetupDOWN = SetupDOWN+1;
      if(ST_Rubberband[t] ==2)
         SetupDOWN = SetupDOWN+1;
      if(Momentum_Divergence_Partial[t] ==2)
         SetupDOWN = SetupDOWN+1;
      if(Momentum_Divergence_Full[t] ==2)
         SetupDOWN = SetupDOWN+1;
      //if(LT_Conservative[t] ==2)
      //   SetupDOWN = SetupDOWN+1;

      if(MT_MOM_Wave3[t] ==2)
         SetupDOWN = SetupDOWN+1;
      if(MT_MOM_Wave2[t] ==2)
         SetupDOWN = SetupDOWN+1;
      if(X_Marks_the_spot[t] ==2)
         SetupDOWN = SetupDOWN+1;
      if(ImpulseWithoutRetrace[t] ==2)
         SetupDOWN = SetupDOWN+1;

      UP_SETUP_COUNT[t] = SetupUP;
      DOWN_SETUP_COUNT[t] = SetupDOWN;
     }
   return(0);
  }
//+------------------------------------------------------------------+
//| Function to determine if a sell trade should be entered          |
//| Returns: 1 = Enter trade, 0 = Do not enter trade                 |
//+------------------------------------------------------------------+
int ShouldEnterSellTrade(int x)
{
   int StocCross_shift = -1;
   int trigger_count = 0;
   int loss_count = 0;
   string debug_info = "";
    int DebugSwitchOn = 0;
    
   // Step 1: Find the first Stochastic crossing above 20 going backward from x
   for(int i = x; i < LookBack - 1; i++)
   {
      if(MT_Stoc_K[i] > 20 && MT_Stoc_K[i + 1] <= 20)
      {
         StocCross_shift = i;
         break;
      }
   }
   
   debug_info = "Bar[" + IntegerToString(x) + "]: StocCross=" + IntegerToString(StocCross_shift);
   
   // If no stochastic cross found, allow trade
   if(StocCross_shift == -1)
   {
      if(DebugSwitchOn == 1)Print(debug_info + " | NoStocCross | Result=ENTER");
      AfterLOSS_filter[x] = 2;     
      return 1;

   }
   
   // NEW: Check if bar x is consecutive to any previous signal - if so, block immediately
   if(MA_SUPPORT_RESISTANCE[x] == 2)
   {
      // Check if bar x+1 also has a signal (consecutive)
      if(MA_SUPPORT_RESISTANCE[x + 1] == 2)
      {
         if(DebugSwitchOn == 1)Print(debug_info + " | ConsecutiveSignal | Result=BLOCK");
         return 0;
      }
   }
   
   // Count sell triggers between StocCross_shift and x (excluding consecutive signals)
   int prev_signal_bar = -1;
   for(int i = StocCross_shift; i >= x; i--)
   {
      if(MA_SUPPORT_RESISTANCE[i] == 2)
      {
         // Skip if this is immediately consecutive to the previous signal
         if(prev_signal_bar == -1 || prev_signal_bar - i > 1)
         {
            trigger_count++;
            prev_signal_bar = i;
         }
      }
   }
   
   debug_info += " | Triggers=" + IntegerToString(trigger_count);
   
   // Step 2: If only 1 trigger and it's at bar x, enter trade
   if(trigger_count == 1 && MA_SUPPORT_RESISTANCE[x] == 2)
   {
      if(DebugSwitchOn == 1)Print(debug_info + " | SingleTriggerAtX | Result=ENTER");
      AfterLOSS_filter[x] = 2; 
      return 1;
   }
   
   // Step 3-6: If 2 or more triggers, check for losses
   if(trigger_count >= 2)
   {
      string trade_results = "";
      int last_signal_bar = -1;
      int last_loss_bar = -1;  // Track the most recent LOSS bar (from actual trades only)
      int last_entered_bar = -1;  // NEW: Track the last bar where trade was actually entered
      
      // Loop through each sell signal from StocCross_shift towards x
      // BUT exclude bar x from outcome evaluation and skip consecutive signals
      prev_signal_bar = -1;
      for(int i = StocCross_shift; i > x; i--)
      {
         if(MA_SUPPORT_RESISTANCE[i] == 2)
         {
            // Skip if this is immediately consecutive to the previous signal
            if(prev_signal_bar != -1 && prev_signal_bar - i == 1)
               continue;
            
            int sellsignal_shift_position = i;
            last_signal_bar = i;
            prev_signal_bar = i;
            
            // NEW: Check if this signal would have been blocked by signal strength
            // If so, skip WIN/LOSS evaluation entirely
            bool signal_would_be_blocked = false;
            if(last_loss_bar != -1)
            {
               double loss_signal = DOWN_SETUP_COUNT[last_loss_bar] + DOWN_K_D_MOM_COUNT[last_loss_bar] + DOWN_TRIGGER_COUNT[last_loss_bar];
               double signal_at_i = DOWN_SETUP_COUNT[i] + DOWN_K_D_MOM_COUNT[i] + DOWN_TRIGGER_COUNT[i];
               
               if(signal_at_i <= loss_signal)
                  signal_would_be_blocked = true;
            }
            
            // If this signal would have been blocked, don't evaluate WIN/LOSS
            if(signal_would_be_blocked)
               continue;
            
            // This trade would have been entered, so evaluate it
            last_entered_bar = i;
            
            // Step 4a: Find swing high for stop loss
            int Swing_High_position = sellsignal_shift_position;
            
            for(int j = sellsignal_shift_position; j <= StocCross_shift; j++)
            {
               if(j < Bars - 1 && High[j + 1] < High[j])
               {
                  Swing_High_position = j;
                  break;
               }
            }
            
            // Calculate stop loss value
            double StopLoss_value = High[Swing_High_position] - Close[sellsignal_shift_position];
            double min_sl = ATR(50,x) * 1.5;
            
            if(StopLoss_value < min_sl)
               StopLoss_value = min_sl;
            
            // Step 4b: Calculate TP value
            double TP_value = Close[sellsignal_shift_position] - StopLoss_value;
            
            // Check if trade was WIN or LOSS
            bool trade_hit_tp = false;
            bool trade_hit_sl = false;
            
            // Loop forward from sellsignal_shift_position to x+1 (exclude x)
            for(int k = sellsignal_shift_position - 1; k > x; k--)
            {
               // Check if stop loss was hit first
               if(High[k] > High[Swing_High_position])
               {
                  trade_hit_sl = true;
                  break;
               }
               
               // Check if take profit was hit
               if(Low[k] < TP_value)
               {
                  trade_hit_tp = true;
                  break;
               }
            }
            
            // Determine if this trade was a LOSS or WIN or OPEN
            string trade_outcome = "";
            if(trade_hit_sl)
            {
               loss_count++;
               last_loss_bar = i;
               trade_outcome = "LOSS(SL)";
            }
            else if(trade_hit_tp)
            {
               trade_outcome = "WIN";
            }
            else
            {
               // Trade hasn't closed yet - still OPEN
               // If this is the most recent signal and current bar x also has a signal, BLOCK
               if(i == last_signal_bar && MA_SUPPORT_RESISTANCE[x] == 2)
               {
                  debug_info += " | Trades=" + trade_results + "[S" + IntegerToString(i) + ":OPEN] | PrevTradeOpen | Result=BLOCK";
                  if(DebugSwitchOn == 1)Print(debug_info);
                  return 0;
               }
               
               loss_count++;
               last_loss_bar = i;
               trade_outcome = "LOSS(NoTP)";
            }
            
            trade_results += "[S" + IntegerToString(i) + ":" + trade_outcome + "] ";
            
            // Step 6: If 2 losses found, do not enter trade
            if(loss_count >= 2)
            {
               debug_info += " | Trades=" + trade_results + "| Losses=" + IntegerToString(loss_count) + " | Result=BLOCK";
               if(DebugSwitchOn == 1)Print(debug_info);
               return 0;
            }
         }
      }
      
      // Add trades info to debug
      debug_info += " | Trades=" + trade_results;
      
      // NEW: Signal strength comparison - only if last ENTERED trade was a LOSS
      if(last_loss_bar != -1)
      {
         // Calculate signal strength at the LOSS bar
         double loss_signal = DOWN_SETUP_COUNT[last_loss_bar] + DOWN_K_D_MOM_COUNT[last_loss_bar] + DOWN_TRIGGER_COUNT[last_loss_bar];
         
         // Calculate signal strength at current bar
         double current_signal = DOWN_SETUP_COUNT[x] + DOWN_K_D_MOM_COUNT[x] + DOWN_TRIGGER_COUNT[x];
         
         // Add signal comparison to debug
         debug_info += "| LossBar=" + IntegerToString(last_loss_bar) + " | LossSig=" + DoubleToString(loss_signal, 1) + " | CurrentSig=" + DoubleToString(current_signal, 1);
         
         // Current signal must be stronger than the loss signal
         if(current_signal <= loss_signal)
         {
            debug_info += " | SignalWeaker | Result=BLOCK";
            if(DebugSwitchOn == 1)Print(debug_info);
            return 0;
         }
         
         debug_info += " | SignalStronger";
      }
      
      debug_info += " | Losses=" + IntegerToString(loss_count) + " | Result=ENTER";
      if(DebugSwitchOn == 1)Print(debug_info);
      AfterLOSS_filter[x] = 2; 
      return 1;
   }
   
   // If less than 2 triggers, allow trade
   if(DebugSwitchOn == 1)Print(debug_info + " | Result=ENTER");
   AfterLOSS_filter[x] = 2; 
   return 1;
}
//+------------------------------------------------------------------+
//| ATR Function (if not already defined)                            |
//+------------------------------------------------------------------+
double ATR(int period,int x)
{
   return iATR(currentSymbol, currentTimeframe, period, x);
}

//+------------------------------------------------------------------+
//| Function to determine if a buy trade should be entered           |
//| Returns: 1 = Enter trade, 0 = Do not enter trade                 |
//+------------------------------------------------------------------+
int ShouldEnterTrade(int x)
{
   
   int StocCross_shift = -1;
   int trigger_count = 0;
   int loss_count = 0;
   string debug_info = "";
   
   
   int DebugSwitchOn = 0;
   
   
   // Step 1: Find the first Stochastic crossing below 80 going backward from x
   for(int i = x; i < LookBack - 1; i++)
   {
      if(MT_Stoc_K[i] < 80 && MT_Stoc_K[i + 1] >= 80)
      {
         StocCross_shift = i;
         break;
      }
   }
   
   debug_info = "Bar[" + IntegerToString(x) + "]: StocCross=" + IntegerToString(StocCross_shift);
   
   // If no stochastic cross found, allow trade
   if(StocCross_shift == -1)
   {
      if(DebugSwitchOn == 1)Print(debug_info + " | NoStocCross | Result=ENTER");
      AfterLOSS_filter[x] = 1; 
      return 1;
   }
   
   // NEW: Check if bar x is consecutive to any previous signal - if so, block immediately
   if(MA_SUPPORT_RESISTANCE[x] == 1)
   {
      // Check if bar x+1 also has a signal (consecutive)
      if(MA_SUPPORT_RESISTANCE[x + 1] == 1)
      {
         if(DebugSwitchOn == 1)Print(debug_info + " | ConsecutiveSignal | Result=BLOCK");
         return 0;
      }
   }
   
   // Count buy triggers between StocCross_shift and x (excluding consecutive signals)
   int prev_signal_bar = -1;
   for(int i = StocCross_shift; i >= x; i--)
   {
      if(MA_SUPPORT_RESISTANCE[i] == 1)
      {
         // Skip if this is immediately consecutive to the previous signal
         if(prev_signal_bar == -1 || prev_signal_bar - i > 1)
         {
            trigger_count++;
            prev_signal_bar = i;
         }
      }
   }
   
   debug_info += " | Triggers=" + IntegerToString(trigger_count);
   
   // Step 2: If only 1 trigger and it's at bar x, enter trade
   if(trigger_count == 1 && MA_SUPPORT_RESISTANCE[x] == 1)
   {
      if(DebugSwitchOn == 1)Print(debug_info + " | SingleTriggerAtX | Result=ENTER");
      AfterLOSS_filter[x] = 1; 
      return 1;
   }
   
   // Step 3-6: If 2 or more triggers, check for losses
   if(trigger_count >= 2)
   {
      string trade_results = "";
      int last_signal_bar = -1;
      int last_loss_bar = -1;  // Track the most recent LOSS bar (from actual trades only)
      int last_entered_bar = -1;  // NEW: Track the last bar where trade was actually entered
      
      // Loop through each buy signal from StocCross_shift towards x
      // BUT exclude bar x from outcome evaluation and skip consecutive signals
      prev_signal_bar = -1;
      for(int i = StocCross_shift; i > x; i--)
      {
         if(MA_SUPPORT_RESISTANCE[i] == 1)
         {
            // Skip if this is immediately consecutive to the previous signal
            if(prev_signal_bar != -1 && prev_signal_bar - i == 1)
               continue;
            
            int buysignal_shift_position = i;
            last_signal_bar = i;
            prev_signal_bar = i;
            
            // NEW: Check if this signal would have been blocked by signal strength
            // If so, skip WIN/LOSS evaluation entirely
            bool signal_would_be_blocked = false;
            if(last_loss_bar != -1)
            {
               double loss_signal = UP_SETUP_COUNT[last_loss_bar] + UP_K_D_MOM_COUNT[last_loss_bar] + UP_TRIGGER_COUNT[last_loss_bar];
               double signal_at_i = UP_SETUP_COUNT[i] + UP_K_D_MOM_COUNT[i] + UP_TRIGGER_COUNT[i];
               
               if(signal_at_i <= loss_signal)
                  signal_would_be_blocked = true;
            }
            
            // If this signal would have been blocked, don't evaluate WIN/LOSS
            if(signal_would_be_blocked)
               continue;
            
            // This trade would have been entered, so evaluate it
            last_entered_bar = i;
            
            // Step 4a: Find swing low for stop loss
            int Swing_Low_position = buysignal_shift_position;
            
            for(int j = buysignal_shift_position; j <= StocCross_shift; j++)
            {
               if(j < Bars - 1 && Low[j + 1] > Low[j])
               {
                  Swing_Low_position = j;
                  break;
               }
            }
            
            // Calculate stop loss value
            double StopLoss_value = Close[buysignal_shift_position] - Low[Swing_Low_position];
            double min_sl = ATR(50,x) * 1.5;
            
            if(StopLoss_value < min_sl)
               StopLoss_value = min_sl;
            
            // Step 4b: Calculate TP value
            double TP_value = Close[buysignal_shift_position] + StopLoss_value;
            
            // Check if trade was WIN or LOSS
            bool trade_hit_tp = false;
            bool trade_hit_sl = false;
            
            // Loop forward from buysignal_shift_position to x+1 (exclude x)
            for(int k = buysignal_shift_position - 1; k > x; k--)
            {
               // Check if stop loss was hit first
               if(Low[k] < Low[Swing_Low_position])
               {
                  trade_hit_sl = true;
                  break;
               }
               
               // Check if take profit was hit
               if(High[k] > TP_value)
               {
                  trade_hit_tp = true;
                  break;
               }
            }
            
            // Determine if this trade was a LOSS or WIN or OPEN
            string trade_outcome = "";
            if(trade_hit_sl)
            {
               loss_count++;
               last_loss_bar = i;
               trade_outcome = "LOSS(SL)";
            }
            else if(trade_hit_tp)
            {
               trade_outcome = "WIN";
            }
            else
            {
               // Trade hasn't closed yet - still OPEN
               // If this is the most recent signal and current bar x also has a signal, BLOCK
               if(i == last_signal_bar && MA_SUPPORT_RESISTANCE[x] == 1)
               {
                  debug_info += " | Trades=" + trade_results + "[B" + IntegerToString(i) + ":OPEN] | PrevTradeOpen | Result=BLOCK";
                  if(DebugSwitchOn == 1)Print(debug_info);
                  return 0;
               }
               
               loss_count++;
               last_loss_bar = i;
               trade_outcome = "LOSS(NoTP)";
            }
            
            trade_results += "[B" + IntegerToString(i) + ":" + trade_outcome + "] ";
            
            // Step 6: If 2 losses found, do not enter trade
            if(loss_count >= 2)
            {
               debug_info += " | Trades=" + trade_results + "| Losses=" + IntegerToString(loss_count) + " | Result=BLOCK";
               if(DebugSwitchOn == 1)Print(debug_info);
               return 0;
            }
         }
      }
      
      // Add trades info to debug
      debug_info += " | Trades=" + trade_results;
      
      // NEW: Signal strength comparison - only if last ENTERED trade was a LOSS
      if(last_loss_bar != -1)
      {
         // Calculate signal strength at the LOSS bar
         double loss_signal = UP_SETUP_COUNT[last_loss_bar] + UP_K_D_MOM_COUNT[last_loss_bar] + UP_TRIGGER_COUNT[last_loss_bar];
         
         // Calculate signal strength at current bar
         double current_signal = UP_SETUP_COUNT[x] + UP_K_D_MOM_COUNT[x] + UP_TRIGGER_COUNT[x];
         
         // Add signal comparison to debug
         debug_info += "| LossBar=" + IntegerToString(last_loss_bar) + " | LossSig=" + DoubleToString(loss_signal, 1) + " | CurrentSig=" + DoubleToString(current_signal, 1);
         
         // Current signal must be stronger than the loss signal
         if(current_signal <= loss_signal)
         {
            debug_info += " | SignalWeaker | Result=BLOCK";
            if(DebugSwitchOn == 1)Print(debug_info);
            return 0;
         }
         
         debug_info += " | SignalStronger";
      }
      
      debug_info += " | Losses=" + IntegerToString(loss_count) + " | Result=ENTER";
      if(DebugSwitchOn == 1)Print(debug_info);
      AfterLOSS_filter[x] = 1; 
      return 1;
   }
   
   // If less than 2 triggers, allow trade
   if(DebugSwitchOn == 1)Print(debug_info + " | Result=ENTER");
   AfterLOSS_filter[x] = 1; 
   return 1;
}
////+------------------------------------------------------------------+
////|                                                                  |
////+------------------------------------------------------------------+
void Populate_KDMOM_TRIGGER_cnt()
  {
 //  Print(" >>>>>>>>>>>>>> Enter Populate_KDMOM_TRIGGER_cnt()");
   GetK_D_MOM_cnt();
   GetTrigger_cnt();
   for(int t=1; t <= LookBack; t++)
     {
      if(MA_SUPPORT_RESISTANCE[t] == 2)
        {
    ShouldEnterSellTrade(t); 
      //   Print(" t = ",t," SETUP[t] = ",SETUP[t]," DOWN_SETUP_COUNT[t] = ",DOWN_SETUP_COUNT[t]," DOWN_K_D_MOM_COUNT[t] = ",DOWN_K_D_MOM_COUNT[t]," DOWN_TRIGGER_COUNT[t] = ",DOWN_TRIGGER_COUNT[t]);
        }
      if(MA_SUPPORT_RESISTANCE[t] == 1)
        {
       ShouldEnterTrade(t);  
      //   Print(" t = ",t," SETUP[t] = ",SETUP[t]," UP_SETUP_COUNT[t] = ",UP_SETUP_COUNT[t]," UP_K_D_MOM_COUNT[t] = ",UP_K_D_MOM_COUNT[t]," UP_TRIGGER_COUNT[t] = ",UP_TRIGGER_COUNT[t]);
        }
     }
 
  }