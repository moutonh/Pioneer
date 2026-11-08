//+------------------------------------------------------------------+
//| TEST_TopDog_FileEA.mq4                                           |
//| Test EA: trades the SETUP_MT_Stoc values that the indicator      |
//| CherryTrigv7_SetupExport wrote to file (one file per symbol/TF). |
//|                                                                  |
//|  value 1 -> BUY  at the open of the bar after the signal bar     |
//|  value 2 -> SELL at the open of the bar after the signal bar     |
//|  value 0 / no value -> nothing                                   |
//|  SL = range of the signal bar + 20 points, TP = 1.5 x SL         |
//|  (same as TEST_LTTTMBars). Only one trade at a time.             |
//+------------------------------------------------------------------+
#property copyright "TopDog test"
#property strict

input double RiskAmount     = 50;    // Risk per trade in account currency (sets the lot size)
input bool   UseCommonFolder = true; // Must match InpUseCommonFolder of the indicator
input int    MagicNumber    = 1;

#define SMS_MAGIC      0x54444F47
#define SMS_VERSION    1
#define SMS_HDR_BYTES  60

struct SetupFileInfo
  {
   int      version;
   int      period;
   int      lookback;
   int      count;
   datetime exported;
   datetime first;
   datetime last;
   string   symbol;
  };

datetime g_t[];            // bar open times (ascending)
uchar    g_v[];            // 0 / 1 / 2
int      g_count = 0;
datetime g_lastBar = 0;

int g_barsChecked = 0, g_barsMissing = 0, g_barsWhileOpen = 0;
int g_buySignals = 0, g_sellSignals = 0, g_ordersOK = 0, g_ordersFailed = 0;

//+------------------------------------------------------------------+
int CommonFlag()
  {
   return(UseCommonFolder ? FILE_COMMON : 0);
  }
//+------------------------------------------------------------------+
string SetupFileName()
  {
   return("TopDog_SETUP_MT_Stoc_" + Symbol() + "_" + IntegerToString(Period()) + ".bin");
  }
//+------------------------------------------------------------------+
//| Binary search on an ascending datetime array. Returns -1 if none |
//+------------------------------------------------------------------+
int FindTimeIndex(datetime &t[], int n, datetime key)
  {
   int lo = 0, hi = n - 1;
   while(lo <= hi)
     {
      int mid = (lo + hi) >> 1;
      if(t[mid] == key)
         return(mid);
      if(t[mid] < key)
         lo = mid + 1;
      else
         hi = mid - 1;
     }
   return(-1);
  }
//+------------------------------------------------------------------+
//| Same loader as in the indicator: header, size check, 2 arrays     |
//+------------------------------------------------------------------+
bool LoadSetupFile(const string fname, datetime &t[], uchar &v[], SetupFileInfo &info, string &err)
  {
   ResetLastError();
   int h = FileOpen(fname, FILE_BIN | FILE_READ | CommonFlag());
   if(h == INVALID_HANDLE)
     {
      err = "cannot open '" + fname + "', error " + IntegerToString(GetLastError());
      return(false);
     }
   long fsize = (long)FileSize(h);
   if(fsize < SMS_HDR_BYTES)
     {
      FileClose(h);
      err = "file too small (" + IntegerToString((int)fsize) + " bytes)";
      return(false);
     }
   int magic     = FileReadInteger(h, INT_VALUE);
   info.version  = FileReadInteger(h, INT_VALUE);
   info.period   = FileReadInteger(h, INT_VALUE);
   info.lookback = FileReadInteger(h, INT_VALUE);
   info.count    = FileReadInteger(h, INT_VALUE);
   info.exported = (datetime)FileReadLong(h);
   info.first    = (datetime)FileReadLong(h);
   info.last     = (datetime)FileReadLong(h);
   string sym = "";
   for(int c = 0; c < 16; c++)
     {
      int ch = FileReadInteger(h, CHAR_VALUE);
      if(ch > 0)
         sym += CharToString((uchar)ch);
     }
   info.symbol = sym;

   if(magic != SMS_MAGIC)
     {
      FileClose(h);
      err = "bad magic number";
      return(false);
     }
   if(info.version != SMS_VERSION)
     {
      FileClose(h);
      err = "unsupported file version " + IntegerToString(info.version);
      return(false);
     }
   if(info.count <= 0 || fsize != SMS_HDR_BYTES + (long)info.count * 9)
     {
      FileClose(h);
      err = "size mismatch: file " + IntegerToString((int)fsize) + " bytes, header says " + IntegerToString(info.count) + " bars";
      return(false);
     }
   ArrayResize(t, info.count);
   ArrayResize(v, info.count);
   int rt = FileReadArray(h, t, 0, info.count);
   int rv = FileReadArray(h, v, 0, info.count);
   FileClose(h);
   if(rt != info.count || rv != info.count)
     {
      err = "short read: times " + IntegerToString(rt) + ", values " + IntegerToString(rv) + " of " + IntegerToString(info.count);
      return(false);
     }
   return(true);
  }
//+------------------------------------------------------------------+
//| Lot size from risk amount and SL distance                        |
//+------------------------------------------------------------------+
double CalculateLotSize(string symbol, double stopLossDistance, double riskAmount)
  {
   if(stopLossDistance <= 0 || riskAmount <= 0)
      return(0);

   double minLot    = MarketInfo(symbol, MODE_MINLOT);
   double maxLot    = MarketInfo(symbol, MODE_MAXLOT);
   double lotStep   = MarketInfo(symbol, MODE_LOTSTEP);
   double point     = MarketInfo(symbol, MODE_POINT);
   double tickValue = MarketInfo(symbol, MODE_TICKVALUE);
   double tickSize  = MarketInfo(symbol, MODE_TICKSIZE);

   if(point <= 0)
      point = 0.00001;

// Backtest fix: calculate the tick value manually if it is zero
   if(tickValue <= 0.0000001)
     {
      double contractSize = MarketInfo(symbol, MODE_LOTSIZE);
      if(contractSize <= 0)
         contractSize = 100000;

      if(StringFind(symbol, "USD", 3) >= 0)
        {
         tickValue = tickSize * contractSize;
        }
      else
         if(StringFind(symbol, "USD", 0) >= 0)
           {
            double currentPrice = (MarketInfo(symbol, MODE_BID) + MarketInfo(symbol, MODE_ASK)) / 2;
            if(currentPrice > 0)
               tickValue = (tickSize / currentPrice) * contractSize;
           }
         else
           {
            tickValue = tickSize * contractSize;
           }
     }

   if(tickValue <= 0)
      return(minLot);

   double slPoints = stopLossDistance / point;
   double pipValue = tickValue;
   if(tickSize != point && tickSize > 0)
      pipValue = tickValue * (point / tickSize);

   double slValueFor1Lot = slPoints * pipValue;
   if(slValueFor1Lot <= 0)
      return(minLot);

   double lots = riskAmount / slValueFor1Lot;
   if(lotStep > 0)
      lots = MathFloor(lots / lotStep) * lotStep;

   if(lots < minLot)
      lots = minLot;
   else
      if(lots > maxLot)
         lots = maxLot;

   return(NormalizeDouble(lots, 2));
  }
//+------------------------------------------------------------------+
//| Number of open market orders of this EA on this symbol           |
//+------------------------------------------------------------------+
int CountOpenTrades()
  {
   int n = 0;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         continue;
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() <= OP_SELL)
         n++;
     }
   return(n);
  }
//+------------------------------------------------------------------+
//| Open a trade. SL = signal bar range + 20 points, TP = 1.5 x SL   |
//+------------------------------------------------------------------+
void OpenTrade(int orderType)
  {
   string sym = Symbol();
   double SL  = iHigh(NULL, 0, 1) - iLow(NULL, 0, 1) + Point * 20;

   double entryPrice = (orderType == OP_BUY) ? MarketInfo(sym, MODE_ASK) : MarketInfo(sym, MODE_BID);
   double stopLoss, takeProfit;
   if(orderType == OP_BUY)
     {
      stopLoss   = entryPrice - SL;
      takeProfit = entryPrice + SL * 1.5;
     }
   else
     {
      stopLoss   = entryPrice + SL;
      takeProfit = entryPrice - SL * 1.5;
     }
   stopLoss   = NormalizeDouble(stopLoss, Digits);
   takeProfit = NormalizeDouble(takeProfit, Digits);

   double lots = CalculateLotSize(sym, SL, RiskAmount);
   if(lots <= 0)
     {
      Print("ORDER NOT SENT: lot size is 0 (SL distance ", DoubleToString(SL, Digits), ")");
      g_ordersFailed++;
      return;
     }

   color clr = (orderType == OP_BUY) ? clrGreen : clrRed;
   int ticket = OrderSend(sym, orderType, lots, entryPrice, 3, stopLoss, takeProfit, "TopDog file EA", MagicNumber, 0, clr);
   if(ticket > 0)
     {
      g_ordersOK++;
      Print("Trade OPENED: ticket ", ticket, (orderType == OP_BUY ? " BUY " : " SELL "), DoubleToString(lots, 2),
            " lots @ ", DoubleToString(entryPrice, Digits), " SL ", DoubleToString(stopLoss, Digits), " TP ", DoubleToString(takeProfit, Digits));
     }
   else
     {
      g_ordersFailed++;
      Print("ORDER FAILED: error ", GetLastError(), (orderType == OP_BUY ? " BUY " : " SELL "), DoubleToString(lots, 2),
            " lots SL ", DoubleToString(stopLoss, Digits), " TP ", DoubleToString(takeProfit, Digits));
     }
  }
//+------------------------------------------------------------------+
int OnInit()
  {
   SetupFileInfo info;
   string err = "";
   Print("---- TopDog file EA: reading ", SetupFileName(), (UseCommonFolder ? " (common folder)" : " (local folder)"), " ----");

   if(!LoadSetupFile(SetupFileName(), g_t, g_v, info, err))
     {
      Print("FILE READ FAILED: ", err);
      return(INIT_FAILED);
     }
   g_count = info.count;

   //--- validate content
   int n0 = 0, n1 = 0, n2 = 0, nBad = 0, nOrder = 0;
   for(int k = 0; k < g_count; k++)
     {
      if(g_v[k] == 0)
         n0++;
      else
         if(g_v[k] == 1)
            n1++;
         else
            if(g_v[k] == 2)
               n2++;
            else
               nBad++;
      if(k > 0 && g_t[k] <= g_t[k - 1])
         nOrder++;
     }
   bool symOK = (info.symbol == Symbol());
   bool tfOK  = (info.period == Period());

   Print("Header   : symbol ", info.symbol, " (", (symOK ? "OK" : "MISMATCH, chart is " + Symbol()), "), timeframe ", info.period,
         " (", (tfOK ? "OK" : "MISMATCH, chart is " + IntegerToString(Period())), "), LookBack ", info.lookback,
         ", exported ", TimeToString(info.exported, TIME_DATE | TIME_MINUTES));
   Print("Records  : ", g_count, " bars read, ", TimeToString(info.first, TIME_DATE | TIME_MINUTES), " -> ", TimeToString(info.last, TIME_DATE | TIME_MINUTES),
         " | size check OK");
   Print("Values   : 0 = ", n0, ", 1 (BUY) = ", n1, ", 2 (SELL) = ", n2, ", invalid = ", nBad, " | time order errors = ", nOrder);

   if(!symOK || !tfOK || nBad > 0 || nOrder > 0)
     {
      Print("FILE CHECK FAILED - EA stopped.");
      return(INIT_FAILED);
     }
   Print("ALL ", g_count, " VALUES READ SUCCESSFULLY. Trades are only possible between the file dates above.");
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Print("---- TopDog file EA summary ----");
   Print("Bars checked with a file value : ", g_barsChecked);
   Print("Bars NOT in file (no trade)    : ", g_barsMissing, (g_barsMissing > 0 ? "  <- outside the file date range" : ""));
   Print("Bars skipped, trade was open   : ", g_barsWhileOpen);
   Print("Signals found                  : BUY ", g_buySignals, ", SELL ", g_sellSignals);
   Print("Orders                         : sent OK ", g_ordersOK, ", failed ", g_ordersFailed);
  }
//+------------------------------------------------------------------+
//| Once per new bar: read the value of the last closed bar (shift 1) |
//| from the file; trade on the open of the current bar.             |
//+------------------------------------------------------------------+
void OnTick()
  {
   datetime bar0 = iTime(NULL, 0, 0);
   if(bar0 == g_lastBar)
      return;
   g_lastBar = bar0;

   if(CountOpenTrades() > 0)
     {
      g_barsWhileOpen++;
      return;
     }

   datetime signalBar = iTime(NULL, 0, 1);
   int idx = FindTimeIndex(g_t, g_count, signalBar);
   if(idx < 0)
     {
      g_barsMissing++;
      if(g_barsMissing <= 3)
         Print("No file value for bar ", TimeToString(signalBar, TIME_DATE | TIME_MINUTES), " (file covers ",
               TimeToString(g_t[0], TIME_DATE | TIME_MINUTES), " -> ", TimeToString(g_t[g_count - 1], TIME_DATE | TIME_MINUTES), ")");
      return;
     }
   g_barsChecked++;

   int val = (int)g_v[idx];
   if(val == 1)
     {
      g_buySignals++;
      Print("Signal 1 on bar ", TimeToString(signalBar, TIME_DATE | TIME_MINUTES), " -> BUY at open of ", TimeToString(bar0, TIME_DATE | TIME_MINUTES));
      OpenTrade(OP_BUY);
     }
   else
      if(val == 2)
        {
         g_sellSignals++;
         Print("Signal 2 on bar ", TimeToString(signalBar, TIME_DATE | TIME_MINUTES), " -> SELL at open of ", TimeToString(bar0, TIME_DATE | TIME_MINUTES));
         OpenTrade(OP_SELL);
        }
  }
//+------------------------------------------------------------------+
