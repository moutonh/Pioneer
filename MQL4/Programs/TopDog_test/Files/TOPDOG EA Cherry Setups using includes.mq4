//+------------------------------------------------------------------+
//|  TOPDOG_CherryTrig_EA.mq4                                        |
//|                                                                  |
//|  EA version of "TOPDOG - COMBO - CherryTrigv6 using IncludesV9". |
//|  Does NOT call the indicator. It runs the same calculation chain |
//|  directly from the includes and trades the same two conditions   |
//|  the indicator draws on level 15 (ha14u / ha14d):                |
//|                                                                  |
//|    LONG  :  SETUP[i] == 1  &&  MT_UP_Stoc[i]   == 1              |
//|    SHORT :  SETUP[i] == 2  &&  MT_Down_Stoc[i] == 2              |
//|                                                                  |
//|  Evaluated once per new bar on the last closed bar (shift 1),    |
//|  entry is at market on the open of the new bar.                  |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""
#property version   "1.00"
#property strict

//--- Same macro + include order as the indicator (needed by FG_IndicatorsV9.mqh)
#define CHECK_ARRAY_INDEX(array, index) CheckArrayIndex(array, #array, __FUNCTION__, __LINE__, index)
#include <FG_Global_VariablesV7.mqh>
#include <EA_Debug_LogV2.mqh>
#include <FG_IndicatorsV9.mqh>
//--- FG_K_D_MomV4.mqh and FG_TriggersV7.mqh are intentionally NOT included:
//--- they only feed the K/D/MOM + trigger rows of the dashboard, not SETUP or MT_xx_Stoc.

//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
input double EA_Lots              = 0.10;   // Lot size
input int    EA_StopLossPips      = 0;      // Stop loss in pips (0 = none)
input int    EA_TakeProfitPips    = 0;      // Take profit in pips (0 = none)
input int    EA_MagicNumber       = 90210;  // Magic number
input int    EA_SlippagePoints    = 30;     // Max slippage (points)
input int    EA_SignalShift       = 1;      // Bar to read signal from (1 = last closed bar, min 1)
input bool   EA_OnePositionOnly   = true;   // Skip new entries while a trade of this EA is open
input bool   EA_CloseOnOpposite   = false;  // Close open trade when the opposite signal appears
input bool   EA_TradeOnAttach     = false;  // Evaluate immediately on attach (otherwise wait for next new bar)
input string EA_Comment           = "TopDog CherryTrig EA";

//+------------------------------------------------------------------+
//| Candle arrays (copy of PopulateOther() from the indicator)       |
//+------------------------------------------------------------------+
int TD_PopulateOther()
  {
   ArraySetAsSeries(CandleClose, true);
   ArraySetAsSeries(CandleOpen, true);
   ArraySetAsSeries(CandleHigh, true);
   ArraySetAsSeries(CandleLow, true);
   ArraySetAsSeries(CandleTime, true);
   ArraySetAsSeries(CandleVolume, true);

   ArrayResize(CandleClose, LookBack + 150);
   ArrayResize(CandleOpen, LookBack + 150);
   ArrayResize(CandleHigh, LookBack + 150);
   ArrayResize(CandleLow, LookBack + 150);
   ArrayResize(CandleTime, LookBack + 150);
   ArrayResize(CandleVolume, LookBack + 150);

   actualCopied = CopyClose(currentSymbol, currentTimeframe, 0, LookBack + 150, CandleClose);
   CopyOpen(currentSymbol, currentTimeframe, 0, LookBack + 150, CandleOpen);
   CopyHigh(currentSymbol, currentTimeframe, 0, LookBack + 150, CandleHigh);
   CopyLow(currentSymbol, currentTimeframe, 0, LookBack + 150, CandleLow);
   CopyTime(currentSymbol, currentTimeframe, 0, LookBack + 150, CandleTime);
   CopyTickVolume(currentSymbol, currentTimeframe, 0, LookBack + 150, CandleVolume);

   return(0);
  }

//+------------------------------------------------------------------+
//| SETUP array (copy of Populate_SETUParray() from the indicator)   |
//|   SETUP[t] = 1 -> UP setup count   >= Req_SETUPS                 |
//|   SETUP[t] = 2 -> DOWN setup count >= Req_SETUPS                 |
//|   (UP wins if both qualify, same as the indicator)               |
//+------------------------------------------------------------------+
void TD_Populate_SETUParray()
  {
   GetSETUPcnt();   // fills UP_SETUP_COUNT[] / DOWN_SETUP_COUNT[] (from the include)

   ArrayResize(SETUP, LookBack + 2);

   for(int t = 1; t <= LookBack; t++)
     {
      SETUP[t] = 0;

      if(DOWN_SETUP_COUNT[t] >= Req_SETUPS)
         SETUP[t] = 2;
      if(UP_SETUP_COUNT[t] >= Req_SETUPS)
         SETUP[t] = 1;
     }
  }

//+------------------------------------------------------------------+
//| Helpers                                                          |
//+------------------------------------------------------------------+
double TD_PipSize()
  {
   return((Digits == 3 || Digits == 5) ? Point * 10 : Point);
  }

double TD_NormLots(double lots)
  {
   double step = MarketInfo(Symbol(), MODE_LOTSTEP);
   double minL = MarketInfo(Symbol(), MODE_MINLOT);
   double maxL = MarketInfo(Symbol(), MODE_MAXLOT);
   if(step <= 0)
      step = 0.01;

   lots = MathFloor(lots / step + 0.5) * step;
   lots = MathMax(minL, MathMin(maxL, lots));

   int d = 0;
   double s = step;
   while(d < 8 && MathAbs(s - MathRound(s)) > 1e-8)
     {
      s *= 10;
      d++;
     }
   return(NormalizeDouble(lots, d));
  }

void TD_CountPositions(int &buys, int &sells)
  {
   buys = 0;
   sells = 0;
   for(int k = OrdersTotal() - 1; k >= 0; k--)
     {
      if(!OrderSelect(k, SELECT_BY_POS, MODE_TRADES))
         continue;
      if(OrderSymbol() != Symbol() || OrderMagicNumber() != EA_MagicNumber)
         continue;
      if(OrderType() == OP_BUY)
         buys++;
      else
         if(OrderType() == OP_SELL)
            sells++;
     }
  }

void TD_CloseSide(int type)
  {
   for(int k = OrdersTotal() - 1; k >= 0; k--)
     {
      if(!OrderSelect(k, SELECT_BY_POS, MODE_TRADES))
         continue;
      if(OrderSymbol() != Symbol() || OrderMagicNumber() != EA_MagicNumber || OrderType() != type)
         continue;

      RefreshRates();
      double price = (type == OP_BUY) ? Bid : Ask;
      if(!OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(price, Digits), EA_SlippagePoints, clrNONE))
         Print("OrderClose failed, ticket ", OrderTicket(), " error ", GetLastError());
     }
  }

bool TD_OpenTrade(int type)
  {
   double lots = TD_NormLots(EA_Lots);
   double pip  = TD_PipSize();
   double minDist = MarketInfo(Symbol(), MODE_STOPLEVEL) * Point;

   for(int attempt = 0; attempt < 3; attempt++)
     {
      RefreshRates();
      double price = (type == OP_BUY) ? Ask : Bid;
      double sl = 0, tp = 0;

      if(type == OP_BUY)
        {
         if(EA_StopLossPips > 0)
            sl = price - EA_StopLossPips * pip;
         if(EA_TakeProfitPips > 0)
            tp = price + EA_TakeProfitPips * pip;
         if(sl != 0 && price - sl < minDist)
            sl = price - minDist;
         if(tp != 0 && tp - price < minDist)
            tp = price + minDist;
        }
      else
        {
         if(EA_StopLossPips > 0)
            sl = price + EA_StopLossPips * pip;
         if(EA_TakeProfitPips > 0)
            tp = price - EA_TakeProfitPips * pip;
         if(sl != 0 && sl - price < minDist)
            sl = price + minDist;
         if(tp != 0 && price - tp < minDist)
            tp = price - minDist;
        }

      int ticket = OrderSend(Symbol(), type, lots, NormalizeDouble(price, Digits), EA_SlippagePoints,
                             NormalizeDouble(sl, Digits), NormalizeDouble(tp, Digits),
                             EA_Comment, EA_MagicNumber, 0, (type == OP_BUY) ? clrGreen : clrRed);
      if(ticket > 0)
         return(true);

      int err = GetLastError();
      Print("OrderSend failed (", (type == OP_BUY ? "BUY" : "SELL"), ") error ", err, " attempt ", attempt + 1);
      // retry on transient errors only: 4 busy, 135 price changed, 136 off quotes, 138 requote, 146 context busy
      if(err == 4 || err == 135 || err == 136 || err == 138 || err == 146)
         Sleep(500);
      else
         break;
     }
   return(false);
  }

//+------------------------------------------------------------------+
//| Remove chart objects the include may draw (same as DeleteRec())  |
//+------------------------------------------------------------------+
void TD_DeleteObjects()
  {
   for(int i = ObjectsTotal() - 1; i >= 0; i--)
     {
      string name = ObjectName(i);
      if(name == "")
         continue;
      if(StringFind(name, "Rubber", 0) != -1 ||
         StringFind(name, "SwingEndoftrend", 0) != -1 ||
         StringFind(name, "WaveCount", 0) != -1 ||
         StringFind(name, "SuppText-", 0) != -1)
         ObjectDelete(name);
     }
  }

//+------------------------------------------------------------------+
//| Init / Deinit                                                    |
//+------------------------------------------------------------------+
int OnInit()
  {
   currentSymbol    = Symbol();
   currentTimeframe = Period();

   if(EA_Lots <= 0)
     {
      Print("EA_Lots must be > 0");
      return(INIT_PARAMETERS_INCORRECT);
     }

   // The include itself calls the SMAAngleV3 indicator via iCustom - make sure it can load.
   ResetLastError();
   iCustom(Symbol(), Period(), "SMAAngleV3", 150, 0, 6, 3, PRICE_CLOSE, 3, 1);
   int err = GetLastError();
   if(err != 0)
      Print("WARNING: iCustom(SMAAngleV3) returned error ", err,
            " - make sure SMAAngleV3.ex4 is in MQL4/Indicators, otherwise MT_SMA_Angle/LT_SMA_Angle will be wrong.");

   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
   TD_DeleteObjects();
  }

//+------------------------------------------------------------------+
//| Main                                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   static datetime lastBar = 0;
   static bool     warned  = false;

   //--- run once per new bar (the indicator also only recalculates on a new bar)
   datetime t0 = iTime(Symbol(), Period(), 0);
   if(t0 == lastBar)
      return;
   bool firstRun = (lastBar == 0);
   lastBar = t0;
   if(firstRun && !EA_TradeOnAttach)
      return;

   currentSymbol    = Symbol();
   currentTimeframe = Period();

   if(Bars < LookBack + 10)
     {
      if(!warned)
        {
         Print("Not enough history: Bars=", Bars, " LookBack=", LookBack, ". Waiting for more bars.");
         warned = true;
        }
      return;
     }

   int shift = MathMax(1, EA_SignalShift);   // the include arrays are only populated from bar 1
   if(shift > LookBack)
      return;

   //--- same calculation chain the indicator runs before it draws level 15 (ha14u/ha14d)
   TD_PopulateOther();            // CandleClose/Open/High/Low/Time/Volume
   Populate_Indicator_Arrays();   // everything in FG_IndicatorsV9.mqh (incl. MT_UP_Stoc / MT_Down_Stoc)
   TD_Populate_SETUParray();      // SETUP[] from UP/DOWN_SETUP_COUNT and Req_SETUPS

   bool buySignal  = (SETUP[shift] == 1 && MT_UP_Stoc[shift]   == 1);
   bool sellSignal = (SETUP[shift] == 2 && MT_Down_Stoc[shift] == 2);

   if(!buySignal && !sellSignal)
      return;

   int buys = 0, sells = 0;
   TD_CountPositions(buys, sells);

   if(buySignal)
     {
      if(EA_CloseOnOpposite && sells > 0)
        {
         TD_CloseSide(OP_SELL);
         TD_CountPositions(buys, sells);
        }
      if(!EA_OnePositionOnly || (buys + sells) == 0)
         TD_OpenTrade(OP_BUY);
     }
   else
      if(sellSignal)
        {
         if(EA_CloseOnOpposite && buys > 0)
           {
            TD_CloseSide(OP_BUY);
            TD_CountPositions(buys, sells);
           }
         if(!EA_OnePositionOnly || (buys + sells) == 0)
            TD_OpenTrade(OP_SELL);
        }
  }
//+------------------------------------------------------------------+