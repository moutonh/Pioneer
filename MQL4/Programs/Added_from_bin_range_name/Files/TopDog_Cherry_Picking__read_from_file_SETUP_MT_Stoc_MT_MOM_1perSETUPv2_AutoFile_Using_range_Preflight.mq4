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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input double RiskAmount     = 50;    // Risk per trade in account currency (sets the lot size)
input bool   UseCommonFolder = true; // Must match InpUseCommonFolder of the indicator
input int    MagicNumber    = 1;
input string FileName       = "";    // "" = automatic: the file that contains the test start date (longest coverage ahead); or type an exact file name
input bool   StopOnPreflightError = true; // Stop at once if the pre-run checks find a problem that makes trading impossible
input bool   StopAtFileEnd        = true; // Stop the run when the tester passes the last bar in the file
input int    AlignSampleBars     = 500;  // Pre-run check: how many chart bars to compare with the file bar times
input int    ProgressEveryBars   = 5000; // Print a one-line status every N bars (0 = off)

#define SMS_MAGIC      0x54444F47
#define SMS_VERSION    1
#define SMS_HDR_BYTES  60

struct SetupFileInfo
  {
   int               version;
   int               period;
   int               lookback;
   int               count;
   datetime          exported;
   datetime          first;
   datetime          last;
   string            symbol;
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime g_t[];            // bar open times (ascending)
uchar    g_v[];            // 0 / 1 / 2
int      g_count = 0;
string   g_file = "";
datetime g_lastBar = 0;

int g_barsChecked = 0, g_barsMissing = 0, g_barsWhileOpen = 0;
int g_buySignals = 0, g_sellSignals = 0, g_ordersOK = 0, g_ordersFailed = 0;
bool     g_halted = false;
string   g_haltReason = "";
int g_barsSeen = 0, g_barsBeforeFile = 0, g_barsAfterFile = 0, g_missInRange = 0;
int g_seen1 = 0, g_seen2 = 0, g_blkUsed = 0, g_blkOpen = 0, g_blkMACD = 0;

//+------------------------------------------------------------------+
int CommonFlag()
  {
   return(UseCommonFolder ? FILE_COMMON : 0);
  }
//+------------------------------------------------------------------+
string FilePrefix()
  {
   return("TopDog_SETUP_MT_Stoc_" + Symbol() + "_" + IntegerToString(Period()));
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
//| Automatic file choice. Only files of this symbol/timeframe count. |
//| 1) files whose date range contains the start date (tester start   |
//|    = TimeCurrent() in OnInit): the one reaching furthest ahead    |
//| 2) otherwise the widest date range; ties -> newest export.        |
//+------------------------------------------------------------------+
void ConsiderFile(const string n, datetime ref, string &best, long &bestScore, long &bestSpan, datetime &bestExp)
  {
   datetime tt[];
   uchar    vv[];
   SetupFileInfo fi;
   string e = "";
   if(!LoadSetupFile(n, tt, vv, fi, e))
      return;
   if(fi.symbol != Symbol() || fi.period != Period())
      return;
   bool startIn = (ref >= fi.first && ref <= fi.last);
   long score   = startIn ? (long)(fi.last - ref) : 0;
   long span    = (long)(fi.last - fi.first);
   Print("   candidate file ", n, ": ", TimeToString(fi.first, TIME_DATE | TIME_MINUTES), " -> ", TimeToString(fi.last, TIME_DATE | TIME_MINUTES),
         ", exported ", TimeToString(fi.exported, TIME_DATE | TIME_MINUTES), (startIn ? ", contains the start date" : ""));
   if(best == "" || score > bestScore || (score == bestScore && (span > bestSpan || (span == bestSpan && fi.exported > bestExp))))
     {
      best      = n;
      bestScore = score;
      bestSpan  = span;
      bestExp   = fi.exported;
     }
  }
//+------------------------------------------------------------------+
string ChooseFile()
  {
   if(FileName != "")
      return(FileName);
   string   best = "", name = "";
   long     bestScore = -1, bestSpan = -1;
   datetime bestExp = 0;
   datetime ref = TimeCurrent();
   string   legacy = FilePrefix() + ".bin";
   if(FileIsExist(legacy, CommonFlag()))
      ConsiderFile(legacy, ref, best, bestScore, bestSpan, bestExp);
   long fh = FileFindFirst(FilePrefix() + "_*.bin", name, CommonFlag());
   if(fh != INVALID_HANDLE)
     {
      do
         ConsiderFile(name, ref, best, bestScore, bestSpan, bestExp);
      while(FileFindNext(fh, name));
      FileFindClose(fh);
     }
   return(best);
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
//| Helpers for the pre-run report and the run-time diagnostics      |
//+------------------------------------------------------------------+
string TStr(datetime t)
  {
   return(TimeToString(t, TIME_DATE | TIME_MINUTES));
  }
//+------------------------------------------------------------------+
//| First index with t[i] >= key (n if none)                         |
//+------------------------------------------------------------------+
int LowerBound(datetime &t[], int n, datetime key)
  {
   int lo = 0, hi = n;
   while(lo < hi)
     {
      int mid = (lo + hi) >> 1;
      if(t[mid] < key)
         lo = mid + 1;
      else
         hi = mid;
     }
   return(lo);
  }
//+------------------------------------------------------------------+
//| File bar time closest to 'key' (0 if the file is empty)          |
//+------------------------------------------------------------------+
datetime NearestFileTime(datetime key)
  {
   if(g_count <= 0)
      return(0);
   int lb = LowerBound(g_t, g_count, key);
   datetime a = (lb < g_count ? g_t[lb] : 0);
   datetime b = (lb > 0 ? g_t[lb - 1] : 0);
   if(a == 0)
      return(b);
   if(b == 0)
      return(a);
   return(((long)a - (long)key) < ((long)key - (long)b) ? a : b);
  }
//+------------------------------------------------------------------+
//| Stop the run: message, flag (OnTick becomes a no-op), and ask the |
//| terminal to end the test.                                        |
//+------------------------------------------------------------------+
void HaltTest(const string why)
  {
   if(g_halted)
      return;
   g_halted     = true;
   g_haltReason = why;
   Print("*** EA HALTED: ", why);
   if(IsTesting())
      ExpertRemove();
  }
//+------------------------------------------------------------------+
void PrintProgress(datetime bar0)
  {
   Print("PROGRESS ", TStr(bar0), ": bars ", g_barsSeen, " (matched ", g_barsChecked, ", before file ", g_barsBeforeFile, ", after file ", g_barsAfterFile,
         ", no match ", g_missInRange, ") | signals seen 1/2: ", g_seen1, "/", g_seen2,
         " | blocked used/open/MACD: ", g_blkUsed, "/", g_blkOpen, "/", g_blkMACD, " | orders ok/failed: ", g_ordersOK, "/", g_ordersFailed);
  }
//+------------------------------------------------------------------+
//| PRE-RUN REPORT. Returns false if no trade could ever be placed.  |
//| On a live chart the same report is printed (the EA then stays    |
//| idle): attach it there BEFORE starting a long tester run.        |
//+------------------------------------------------------------------+
bool Preflight(SetupFileInfo &info, int n1, int n2)
  {
   bool ok = true;
   int  nb = iBars(NULL, 0);
   datetime hFirst = (nb > 0 ? iTime(NULL, 0, nb - 1) : 0);
   datetime hLast  = (nb > 0 ? iTime(NULL, 0, 0) : 0);

   Print("======== PREFLIGHT (", (IsTesting() ? "strategy tester" : "live chart"), (IsVisualMode() ? ", visual" : ""),
         (IsOptimization() ? ", optimization" : ""), ") ========");
   Print("Terminal : build ", TerminalInfoInteger(TERMINAL_BUILD), ", data folder ", TerminalInfoString(TERMINAL_DATA_PATH));
   Print("Chart    : ", Symbol(), " period ", Period(), ", ", nb, " bars of history (", TStr(hFirst), " -> ", TStr(hLast), ")");
   if(nb < 200)
      Print("WARNING: only ", nb, " bars of history; iMACD(15,60,75) needs warm-up, early signals may be filtered out.");

//--- 1) the file itself
   Print("File     : ", g_file, " | ", g_count, " bars, ", TStr(info.first), " -> ", TStr(info.last), " | signals in file: BUY ", n1, ", SELL ", n2);
   if(n1 + n2 == 0)
     {
      Print("ERROR: the file holds no 1 or 2 values - no trade is possible.");
      ok = false;
     }
   Print("TESTER SETTING TO USE: tick 'Use date', From ", TimeToString(info.first, TIME_DATE), " To ", TimeToString(info.last, TIME_DATE),
         ". Dates outside the file cannot trade and only make the FXT file bigger and the run longer.");

//--- 2) test window versus file range
   if(IsTesting())
     {
      datetime st = TimeCurrent();
      if(st > info.last)
        {
         Print("ERROR: tester start ", TStr(st), " is AFTER the last bar in the file (", TStr(info.last), ") - no trade is possible.");
         ok = false;
        }
      else
         if(st < info.first)
            Print("WARNING: tester start ", TStr(st), " is ", (int)(((long)info.first - (long)st) / 86400), " days BEFORE the file starts; nothing can trade until ", TStr(info.first), ".");
         else
            Print("Start    : ", TStr(st), " is inside the file range, ", (int)(((long)info.last - (long)st) / 86400), " days of file ahead.");
     }
   else
      if(nb > 0 && (hLast < info.first || hFirst > info.last))
        {
         Print("ERROR: the chart history (", TStr(hFirst), " -> ", TStr(hLast), ") does not overlap the file range.");
         ok = false;
        }

//--- 3) bar-time alignment: do the chart's bar open times exist in the file?
   int sample = 0, hits = 0, shown = 0;
   int cap = MathMax(AlignSampleBars, 1);
   for(int k = 0; k < nb && k < 500000 && sample < cap; k++)
     {
      datetime bt = iTime(NULL, 0, k);
      if(bt < info.first)
         break;
      if(bt > info.last)
         continue;
      sample++;
      if(FindTimeIndex(g_t, g_count, bt) >= 0)
         hits++;
      else
         if(shown < 3)
           {
            shown++;
            datetime nr = NearestFileTime(bt);
            Print("   no file entry for chart bar ", TStr(bt), "; nearest file bar ", TStr(nr), " (", (int)(((long)nr - (long)bt) / 60), " min away)");
           }
     }
   if(sample == 0)
      Print("Alignment: no chart bar inside the file range yet; it is checked again during the run.");
   else
      if(hits == 0)
        {
         Print("ERROR: 0 of ", sample, " chart bars exist in the file. Bar open times differ (data feed, GMT offset/DST or bar alignment), so every lookup will fail and no trade can happen.");
         ok = false;
        }
      else
         if(hits < sample)
            Print("WARNING: only ", hits, " of ", sample, " chart bars exist in the file (", DoubleToString(100.0 * hits / sample, 1), "%).");
         else
            Print("Alignment: OK, ", hits, " of ", sample, " chart bars found in the file.");

//--- 4) dry run of the order parameters
   double sumR = 0;
   int    cnt  = 0;
   for(int j = 1; j <= 100 && j < nb; j++)
     {
      sumR += iHigh(NULL, 0, j) - iLow(NULL, 0, j);
      cnt++;
     }
   double slD     = (cnt > 0 ? sumR / cnt : 0) + Point * 20;
   double lots    = CalculateLotSize(Symbol(), slD, RiskAmount);
   double tv      = MarketInfo(Symbol(), MODE_TICKVALUE);
   double stopLvl = MarketInfo(Symbol(), MODE_STOPLEVEL) * Point;
   Print("Trading  : typical SL ", DoubleToString(slD, Digits), " (average range of the last ", cnt, " bars + 20 points) -> ", DoubleToString(lots, 2),
         " lots for risk ", DoubleToString(RiskAmount, 2), " | lot min/step/max ", DoubleToString(MarketInfo(Symbol(), MODE_MINLOT), 2), "/",
         DoubleToString(MarketInfo(Symbol(), MODE_LOTSTEP), 2), "/", DoubleToString(MarketInfo(Symbol(), MODE_MAXLOT), 2),
         " | tick value ", DoubleToString(tv, 5), " | stop level ", DoubleToString(MarketInfo(Symbol(), MODE_STOPLEVEL), 0), " pts | spread ",
         DoubleToString(MarketInfo(Symbol(), MODE_SPREAD), 0), " pts");
   if(lots <= 0)
     {
      Print("ERROR: lot size is 0 - every order would be refused.");
      ok = false;
     }
   if(tv <= 0.0000001)
      Print("NOTE: tick value is 0 here; CalculateLotSize uses its backtest fallback, check the lot size above is sensible.");
   if(slD < stopLvl)
      Print("WARNING: typical SL (", DoubleToString(slD, Digits), ") is below the broker stop level (", DoubleToString(stopLvl, Digits), "): orders may fail with error 130.");
   double need = MarketInfo(Symbol(), MODE_MARGINREQUIRED) * lots;
   if(need > AccountFreeMargin())
      Print("WARNING: margin needed for ", DoubleToString(lots, 2), " lots (", DoubleToString(need, 2), ") exceeds free margin (", DoubleToString(AccountFreeMargin(), 2), "): orders would fail with error 134.");

//--- 5) FXT reminder
   if(IsTesting())
      Print("NOTE: the tester builds the FXT tick file BEFORE this EA starts, so this report cannot prevent it. FXT files sit in ",
            TerminalInfoString(TERMINAL_DATA_PATH), "\\tester\\history\\ (one per symbol/timeframe/model, never deleted automatically).");

   Print("======== PREFLIGHT RESULT: ", (ok ? "PASSED" : "FAILED"), " ========");
   return(ok);
  }
//+------------------------------------------------------------------+
int OnInit()
  {
   SetupFileInfo info;
   string err = "";
   Print("---- TopDog file EA: choosing file (start date ", TimeToString(TimeCurrent(), TIME_DATE | TIME_MINUTES), ") ----");
   g_file = ChooseFile();
   if(g_file == "")
     {
      Print("FILE READ FAILED: no file '", FilePrefix(), "*.bin' found in ", (UseCommonFolder ? "Common\\Files" : "MQL4\\Files"));
      return(INIT_FAILED);
     }
   Print("Reading ", g_file, (UseCommonFolder ? " (common folder)" : " (local folder)"));

   if(!LoadSetupFile(g_file, g_t, g_v, info, err))
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

//--- pre-run report: everything that can make the run pointless is checked here
   bool pf = Preflight(info, n1, n2);
   if(!IsTesting())
     {
      g_halted = true;                   // live chart = report only, this EA never trades live
      Alert("TopDog file EA PREFLIGHT ", (pf ? "PASSED" : "FAILED"), " - see the Experts log. EA is idle on a live chart (backtest only).");
      return(pf ? INIT_SUCCEEDED : INIT_FAILED);
     }
   if(!pf && StopOnPreflightError)
     {
      g_haltReason = "preflight failed";
      Print("PREFLIGHT FAILED - EA stopped before the run. Fix the ERROR lines above.");
      return(INIT_FAILED);
     }
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Print("---- TopDog file EA summary ----");
   Print("File used                      : ", g_file);
   if(g_halted)
      Print("Run halted early               : ", g_haltReason);
   Print("Bars checked with a file value : ", g_barsChecked);
   Print("Bars NOT in file (no trade)    : ", g_barsMissing, "  (before file start ", g_barsBeforeFile, ", after file end ", g_barsAfterFile,
         ", inside range but no exact time match ", g_missInRange, ")");
   Print("Bars skipped, trade was open   : ", g_barsWhileOpen);
   Print("Signal bars seen               : value 1 = ", g_seen1, ", value 2 = ", g_seen2);
   Print("Signals blocked                : sequence already used ", g_blkUsed, ", trade already open ", g_blkOpen, ", MACD filter ", g_blkMACD);
   Print("Signals found                  : BUY ", g_buySignals, ", SELL ", g_sellSignals);
   Print("Orders                         : sent OK ", g_ordersOK, ", failed ", g_ordersFailed);
   if(g_ordersOK == 0 && g_barsSeen > 0)
     {
      if(g_barsChecked == 0)
         Print("WHY NO TRADES: not one tester bar matched the file (before file ", g_barsBeforeFile, ", after file ", g_barsAfterFile,
               ", inside range but no exact time match ", g_missInRange, ").");
      else
         if(g_seen1 + g_seen2 == 0)
            Print("WHY NO TRADES: ", g_barsChecked, " bars matched the file but none holds a 1 or 2 (no signals in the tested window).");
         else
            if(g_ordersFailed > 0)
               Print("WHY NO TRADES: signals passed the filters but OrderSend failed ", g_ordersFailed, " times - see the ORDER FAILED lines.");
            else
               Print("WHY NO TRADES: ", g_seen1 + g_seen2, " signal bars seen, all blocked: sequence already used ", g_blkUsed,
                     ", trade already open ", g_blkOpen, ", MACD filter ", g_blkMACD, ".");
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
 
input bool OneTradePerSequence = true; // true: a sequence is used up on its FIRST bar (even if MACD fails or a trade is open)
// false: used up only when an order is really sent (first bar where all conditions pass)
bool g_buyUsed = false, g_sellUsed = false, g_stateInit = false;

//--- true if no value 'want' occurs between the last 0 and this bar (= this bar starts a new sequence)
bool IsRunStart(int idx, int want)
  {
   for(int k = idx - 1; k >= 0; k--)
     {
      if(g_v[k] == 0)
         return(true);
      if(g_v[k] == want)
         return(false);
     }
   return(true);
  }
//+------------------------------------------------------------------+
//| Once per new bar: read the value of the last closed bar (shift 1) |
//| from the file; trade on the open of the current bar.             |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(g_halted)
      return;
   datetime bar0 = iTime(NULL, 0, 0);
   if(bar0 == g_lastBar)
      return;
   g_lastBar = bar0;
   g_barsSeen++;
   if(ProgressEveryBars > 0 && g_barsSeen % ProgressEveryBars == 0)
      PrintProgress(bar0);

   datetime signalBar = iTime(NULL, 0, 1);
   if(g_barsSeen == 1)
      Print("RUN STARTED: first tester bar ", TStr(bar0), ", file covers ", TStr(g_t[0]), " -> ", TStr(g_t[g_count - 1]));
   int idx = FindTimeIndex(g_t, g_count, signalBar);
   if(idx < 0)
     {
      g_barsMissing++;
      if(signalBar < g_t[0])
        {
         g_barsBeforeFile++;
         if(g_barsBeforeFile == 1)
            Print("Tester bar ", TStr(signalBar), " is BEFORE the file start (", TStr(g_t[0]),
                  "): nothing can trade until the file begins. Set the tester From date to the file start to save time and FXT size.");
        }
      else
         if(signalBar > g_t[g_count - 1])
           {
            g_barsAfterFile++;
            if(g_barsAfterFile == 1)
               Print("Tester bar ", TStr(signalBar), " is AFTER the last file bar (", TStr(g_t[g_count - 1]), "): nothing more can trade.");
            if(StopAtFileEnd)
               HaltTest("tester passed the last bar in the file (" + TStr(g_t[g_count - 1]) + "), nothing left to trade");
           }
         else
           {
            g_missInRange++;
            if(g_missInRange <= 5)
               Print("TIME MISMATCH: tester bar ", TStr(signalBar), " is inside the file range but has no entry; nearest file bar ",
                     TStr(NearestFileTime(signalBar)), " (", (int)(((long)NearestFileTime(signalBar) - (long)signalBar) / 60), " min away)");
            if(StopOnPreflightError && g_barsChecked == 0 && g_missInRange >= 50)
               HaltTest("50 tester bars inside the file range and NONE found in the file: bar times differ (data feed / GMT offset / DST / bar alignment)");
           }
      return;
     }
   g_barsChecked++;
   int val = (int)g_v[idx];
   if(val == 1)
      g_seen1++;
   else
      if(val == 2)
         g_seen2++;

//--- 1) sequence state is updated on EVERY bar, before anything can return
   if(val == 0)
     {
      g_buyUsed  = false;
      g_sellUsed = false;
     }
   if(!g_stateInit)                      // EA started in the middle of a run: wait for the next sequence
     {
      g_stateInit = true;
      if(val == 1 && !IsRunStart(idx, 1)) g_buyUsed  = true;
      if(val == 2 && !IsRunStart(idx, 2)) g_sellUsed = true;
     }

//--- 2) one trade at a time
   bool tradeOpen = (CountOpenTrades() > 0);
   if(tradeOpen)
      g_barsWhileOpen++;

   double m1 = iMACD(NULL, 0, 15, 60, 75, PRICE_CLOSE, MODE_MAIN, 1);
   double m2 = iMACD(NULL, 0, 15, 60, 75, PRICE_CLOSE, MODE_MAIN, 2);

   if(val == 1 && !g_buyUsed)
     {
      if(!tradeOpen && m1 > m2)
        {
         g_buySignals++;
         Print("Signal 1 on bar ", TimeToString(signalBar, TIME_DATE | TIME_MINUTES), " -> BUY at open of ", TimeToString(bar0, TIME_DATE | TIME_MINUTES));
         OpenTrade(OP_BUY);
         g_buyUsed = true;
        }
      else
         if(tradeOpen)
            g_blkOpen++;
         else
            g_blkMACD++;
      //else
      //   if(OneTradePerSequence)
      //      g_buyUsed = true;            // sequence used up, no late entry
     }
   else
      if(val == 2 && !g_sellUsed)
        {
         if(!tradeOpen && m1 < m2)
           {
            g_sellSignals++;
            Print("Signal 2 on bar ", TimeToString(signalBar, TIME_DATE | TIME_MINUTES), " -> SELL at open of ", TimeToString(bar0, TIME_DATE | TIME_MINUTES));
            OpenTrade(OP_SELL);
            g_sellUsed = true;
           }
         else
            if(tradeOpen)
               g_blkOpen++;
            else
               g_blkMACD++;
         //else
         //   if(OneTradePerSequence)
         //      g_sellUsed = true;
        }
      else
         if(val == 1 || val == 2)
            g_blkUsed++;                 // sequence already used by an earlier bar
  }
//+------------------------------------------------------------------+
