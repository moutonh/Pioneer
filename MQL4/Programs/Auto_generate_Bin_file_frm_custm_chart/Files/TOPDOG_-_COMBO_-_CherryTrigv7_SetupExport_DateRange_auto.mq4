//---
//---
//---
//---
//---     v4 - Add MA support Resistance
//---     v6 - Change TIGGER_7 to TRIGGER_8
//---        - Add Filtered
//---
//---
//---
//---
//---
//------------------------------------------------------------------
#property copyright ""
#property link      ""
#property description ""
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 33
#property indicator_color1  LimeGreen
#property indicator_color2  PaleVioletRed
#property indicator_color3  LimeGreen
#property indicator_color4  PaleVioletRed
#property indicator_color5  LimeGreen
#property indicator_color6  PaleVioletRed
#property indicator_color7  LimeGreen
#property indicator_color8  PaleVioletRed
#property indicator_color9  LimeGreen
#property indicator_color10  PaleVioletRed
#property indicator_color11  LimeGreen
#property indicator_color12  PaleVioletRed
#property indicator_color13  LimeGreen
#property indicator_color14  PaleVioletRed
#property indicator_color15  LimeGreen
#property indicator_color16  PaleVioletRed
#property indicator_color17  LimeGreen
#property indicator_color18  PaleVioletRed
#property indicator_color19  LimeGreen
#property indicator_color20  PaleVioletRed
#property indicator_color21  LimeGreen
#property indicator_color22  PaleVioletRed
#property indicator_color23  LimeGreen
#property indicator_color24  PaleVioletRed
#property indicator_color25  LimeGreen
#property indicator_color26  PaleVioletRed
#property indicator_color27  LimeGreen
#property indicator_color28  PaleVioletRed
#property indicator_color29  LimeGreen
#property indicator_color30  PaleVioletRed
#property indicator_minimum 0
#property indicator_maximum 16
#property indicator_height 150
#property indicator_label1 "test"
#property indicator_label2 "test1"
#property indicator_label3 "test2"
#property indicator_label4 "test3"
#property indicator_label5 "test"
#property indicator_label6 "test1"
#property indicator_label7 "test2"
#property indicator_label8 "test3"
#property indicator_label9 "test"
#property indicator_label10 "test1"
#property indicator_label11 "test2"
#property indicator_label12 "test3"
#property indicator_label13 "test"
#property indicator_label14 "test1"
#property indicator_label15 "test2"
#property indicator_label16 "Trend cont."

#property indicator_level1 0.5
#property indicator_level2 1.5
#property indicator_level3 2.5
#property indicator_level4 3.5
#property indicator_level5 4.5
#property indicator_level6 5.5
#property indicator_level7 6.5
#property indicator_level8 7.5
#property indicator_level9 8.5
#property indicator_level10 9.5
#property indicator_level11 10.5
#property indicator_level12 11.5
#property indicator_level13 12.5
#property indicator_level14 13.5
#property indicator_level15 14.5

////--- set color of horizontal levels
#property indicator_levelcolor clrWhite
////--- set style of horizontal levels
#property indicator_levelstyle STYLE_SOLID
#property indicator_levelwidth 0
#define CHECK_ARRAY_INDEX(array, index) CheckArrayIndex(array, #array, __FUNCTION__, __LINE__, index)
//--- v7.3: the include files (and the files they pull in, e.g. EA_Debug_LogV2.mqh, FG_Global_VariablesV4/V5/V6.mqh)
//--- must not add fields to this indicator's Inputs tab. While they are compiled, extern/input mean "nothing",
//--- so their variables become ordinary globals with the same default value. The include files are NOT modified.
//--- (If the compiler ever complains about these 6 lines, delete them - only the Inputs tab is affected.)
#define extern
#define input
#define sinput
#include <FG_Global_VariablesV7.mqh>
//#include <EA_Debug_LogV2.mqh>
#include <FG_IndicatorsV9_1.mqh>
#include <FG_K_D_MomV4.mqh>
#include <FG_TriggersV7.mqh>
#undef extern
#undef input
#undef sinput

int    LinesWidth = 0;

//+------------------------------------------------------------------+
//| v7 additions : SETUP_MT_Stoc  -> file export / read-back          |
//| (nothing in the *.mqh includes was changed)                       |
//| v7.1 : file name carries the data range:                          |
//|   TopDog_SETUP_MT_Stoc_<symbol>_<tf>_<YYYYMMDD first>_<YYYYMMDD last>.bin |
//| v7.2 : optional date range to export (InpExportFrom / InpExportTo)|
//| v7.3 : the number of bars is NOT an input any more. It is derived |
//|        from the date range and checked against the real history   |
//|        BEFORE anything is calculated (clear message, no waiting). |
//|        Only InpExportFrom / InpExportTo are inputs.               |
//| v7.4 : measures its own speed first and refuses (with a message)  |
//|        a calculation that would take too long; stage-by-stage     |
//|        progress                                                   |
//| v7.5 : AUTOMATIC WINDOW MODE. Give BOTH dates for a range far     |
//|        back in a huge chart: the indicator builds a small offline |
//|        chart with only that range (+ warm-up), opens it, attaches |
//|        itself there and the .bin file is produced on that chart.  |
//|        Nothing to do by hand.                                     |
//+------------------------------------------------------------------+
input datetime InpExportFrom    = 0;     // Export from this date (0 = auto: DEFAULT_BARS bars back). The calculation starts at the newest bar and reaches back to this date automatically
input datetime InpExportTo      = 0;     // Export up to this date (0 = newest closed bar)

//--- v7.3: fixed internal settings (no longer shown as inputs)
#define DEFAULT_BARS           2000      // bars calculated when no InpExportFrom is given
#define WARMUP_BARS            600       // bars kept free at the oldest end of the chart (indicator warm-up)
#define SETTLE_BARS            150       // oldest calculated bars NOT exported (state machines still settling)
#define MAX_CALC_BARS          60000     // SAFETY: hard limit on the bars calculated in one go
#define MAX_CALC_SECONDS       240       // SAFETY: refuse to start when the measured speed predicts a longer calculation than this
#define PILOT_FROM_BARS        3000      // ranges above this are first timed with a short pilot run
#define WINDOW_SUFFIX          "_W"      // symbol suffix of the automatic offline window chart (GBPUSD -> GBPUSD_W)
#define WINDOW_MIN_SKIP_BARS   2000      // window mode starts when at least this many bars lie NEWER than InpExportTo ...
#define WINDOW_MIN_WANTED      5000      // ... and a direct calculation would need more than this many bars
#define WINDOW_PRE_ROLL_BARS   3000      // history bars put BEFORE InpExportFrom into the window (indicator warm-up, lets the 405-period EMAs settle)
#define WINDOW_POST_ROLL_BARS  3         // bars put AFTER InpExportTo (the newest bar of a chart counts as still forming)
#define WINDOW_TEMPLATE        "TopDog_WindowAuto"   // temporary chart template (terminal data folder \templates)
#define EXPORT_TO_FILE         true      // write SETUP_MT_Stoc to file
#define EXPORT_EVERY_NEW_BAR   false     // false = export once after first calculation (backtest use)
#define USE_COMMON_FOLDER      true      // true = Terminal\Common\Files (visible to EA and Strategy Tester)

#define SMS_MAGIC      0x54444F47
#define SMS_VERSION    1
#define SMS_HDR_BYTES  60                // 5 ints (20) + 3 longs (24) + 16 symbol chars

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

double SETUP_MT_Stoc[];                  // 1 = UP at MT stoc extreme, 2 = DOWN at MT stoc extreme, 0 = none
double fileUp[], fileDn[];               // bottom row (level 1) drawn from the FILE

int    g_currentBar   = 0;
bool   g_exportedOnce = false;
string g_fileName     = "";           // file written / read back (name carries the data range)
bool   g_windowSpawned = false;       // window chart already launched in this session
string g_winMsg = "";
string g_lastProblem = "";           // last error text printed (avoids flooding the Experts log)
string g_statBars = "", g_statCalc = "", g_statExport = "", g_statRepaint = "", g_statVerify = "";

//+------------------------------------------------------------------+
int CommonFlag()
  {
   return(USE_COMMON_FOLDER ? FILE_COMMON : 0);
  }
//+------------------------------------------------------------------+
//| v7.5: window charts (offline, built automatically)                |
//| carry the real symbol + WINDOW_SUFFIX. Export file name and file  |
//| header always use the REAL symbol, so the EA finds the file.      |
//+------------------------------------------------------------------+
bool IsWindowChart()
  {
   int n = StringLen(currentSymbol), s = StringLen(WINDOW_SUFFIX);
   return(n > s && StringSubstr(currentSymbol, n - s) == WINDOW_SUFFIX);
  }
string DataSymbol()
  {
   if(IsWindowChart())
      return(StringSubstr(currentSymbol, 0, StringLen(currentSymbol) - StringLen(WINDOW_SUFFIX)));
   return(currentSymbol);
  }
string WindowTip()
  {
   if(IsWindowChart())
      return("");
   return(" TIP: enter BOTH InpExportFrom and InpExportTo - the indicator then builds and opens a small chart that holds only that range, automatically.");
  }
//+------------------------------------------------------------------+
string SetupFilePrefix()
  {
   return("TopDog_SETUP_MT_Stoc_" + DataSymbol() + "_" + IntegerToString((int)currentTimeframe));
  }
//+------------------------------------------------------------------+
string DateTag(datetime t)
  {
   return(StringFormat("%04d%02d%02d", TimeYear(t), TimeMonth(t), TimeDay(t)));
  }
//+------------------------------------------------------------------+
//| <prefix>_<first YYYYMMDD>_<last YYYYMMDD>.bin                     |
//+------------------------------------------------------------------+
string SetupFileNameForRange(datetime first, datetime last)
  {
   return(SetupFilePrefix() + "_" + DateTag(first) + "_" + DateTag(last) + ".bin");
  }
//+------------------------------------------------------------------+
void ClearFileBuffers(int bars)
  {
   for(int i = 0; i < bars; i++)
     {
      fileUp[i] = EMPTY_VALUE;
      fileDn[i] = EMPTY_VALUE;
     }
  }
//+------------------------------------------------------------------+
//| Populate SETUP_MT_Stoc (index = shift, same as SETUP[])           |
//+------------------------------------------------------------------+
void Populate_SETUP_MT_Stoc()
  {
   ArrayResize(SETUP_MT_Stoc, LookBack + 2);
   ArrayInitialize(SETUP_MT_Stoc, 0);
   for(int i = 1; i <= LookBack; i++)
     {
      if(SETUP[i] == 1 && MT_UP_Stoc[i] == 1)
        {
         SETUP_MT_Stoc[i] = 1;
        }
      else
        {
         if(SETUP[i] == 2 && MT_Down_Stoc[i] == 2)
           {
            SETUP_MT_Stoc[i] = 2;
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Binary search on an ascending datetime array. Returns -1 if none  |
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
//| File layout (binary):                                             |
//|  header 60 bytes: magic,version,period,lookback,count (int x5),   |
//|                   exportTime,firstBar,lastBar (long x3),          |
//|                   symbol (16 x char)                              |
//|  then count x datetime (bar open times, ascending)                |
//|  then count x uchar    (0/1/2)                                    |
//| The EA can load it with LoadSetupFile() below, once, in OnInit.   |
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
   int magic    = FileReadInteger(h, INT_VALUE);
   info.version = FileReadInteger(h, INT_VALUE);
   info.period  = FileReadInteger(h, INT_VALUE);
   info.lookback = FileReadInteger(h, INT_VALUE);
   info.count   = FileReadInteger(h, INT_VALUE);
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
//| Remember <name> if it is a valid file for this symbol/timeframe   |
//| and was exported later than the best one found so far             |
//+------------------------------------------------------------------+
void ConsiderSetupFile(const string name, string &best, datetime &bestExp)
  {
   datetime tt[];
   uchar    vv[];
   SetupFileInfo fi;
   string e = "";
   if(LoadSetupFile(name, tt, vv, fi, e) && fi.symbol == DataSymbol() && fi.period == (int)currentTimeframe &&
      (best == "" || fi.exported >= bestExp))
     {
      best    = name;
      bestExp = fi.exported;
     }
  }
//+------------------------------------------------------------------+
//| Newest file (by export time) for this symbol/timeframe, any range |
//| (an old file without the range in its name is also considered)    |
//+------------------------------------------------------------------+
string LatestSetupFile()
  {
   string   best = "", name = "";
   datetime bestExp = 0;
   string   legacy = SetupFilePrefix() + ".bin";
   if(FileIsExist(legacy, CommonFlag()))
      ConsiderSetupFile(legacy, best, bestExp);
   long fh = FileFindFirst(SetupFilePrefix() + "_*.bin", name, CommonFlag());
   if(fh != INVALID_HANDLE)
     {
      do
         ConsiderSetupFile(name, best, bestExp);
      while(FileFindNext(fh, name));
      FileFindClose(fh);
     }
   return(best);
  }
//+------------------------------------------------------------------+
//| Write to <name>.tmp, then move over the real file                 |
//+------------------------------------------------------------------+
bool WriteSetupFile(const string fin, datetime &t[], uchar &v[], int count, string &err)
  {
   string tmp = fin + ".tmp";
   ResetLastError();
   int h = FileOpen(tmp, FILE_BIN | FILE_WRITE | CommonFlag());
   if(h == INVALID_HANDLE)
     {
      err = "cannot create '" + tmp + "', error " + IntegerToString(GetLastError());
      return(false);
     }
   FileWriteInteger(h, SMS_MAGIC, INT_VALUE);
   FileWriteInteger(h, SMS_VERSION, INT_VALUE);
   FileWriteInteger(h, (int)currentTimeframe, INT_VALUE);
   FileWriteInteger(h, LookBack, INT_VALUE);
   FileWriteInteger(h, count, INT_VALUE);
   FileWriteLong(h, (long)TimeCurrent());
   FileWriteLong(h, (long)t[0]);
   FileWriteLong(h, (long)t[count - 1]);
   for(int c = 0; c < 16; c++)
     {
      int ch = (c < StringLen(DataSymbol())) ? StringGetChar(DataSymbol(), c) : 0;
      FileWriteInteger(h, ch, CHAR_VALUE);
     }
   FileWriteArray(h, t, 0, count);
   FileWriteArray(h, v, 0, count);
   FileClose(h);

   ResetLastError();
   if(!FileMove(tmp, CommonFlag(), fin, FILE_REWRITE | CommonFlag()))
     {
      err = "cannot move tmp file over '" + fin + "', error " + IntegerToString(GetLastError());
      return(false);
     }
   return(true);
  }
//+------------------------------------------------------------------+
//| Export SETUP_MT_Stoc (closed bars only, shift 1 ... exportOldest) |
//+------------------------------------------------------------------+
void ExportSetupFile()
  {
   uint t0 = GetTickCount();
   int exportOldest = MathMax(LookBack - SETTLE_BARS, 1);   // oldest settled bar
   int exportNewest = 1;                                       // newest closed bar
   //--- v7.2: optional date range
   if(InpExportFrom > 0)
     {
      int shFrom = iBarShift(currentSymbol, currentTimeframe, InpExportFrom, false);
      if(shFrom >= 0 && Time[shFrom] < InpExportFrom)
         shFrom--;                                             // first exported bar must not be older than InpExportFrom
      if(shFrom >= 1 && shFrom < exportOldest)
         exportOldest = shFrom;
     }
   if(InpExportTo > 0)
     {
      int shTo = iBarShift(currentSymbol, currentTimeframe, InpExportTo, false);
      if(shTo >= 0 && Time[shTo] > InpExportTo)
         shTo++;                                               // last exported bar must not be newer than InpExportTo
      if(shTo > exportNewest)
         exportNewest = shTo;
     }
   int count = exportOldest - exportNewest + 1;
   if(count <= 0)
     {
      g_statExport = "EXPORT SKIPPED: no settled bars inside the wanted range. Calculated bars reach " +
                     TimeToString(Time[MathMax(LookBack - SETTLE_BARS, 1)], TIME_DATE | TIME_MINUTES) + " -> " + TimeToString(Time[1], TIME_DATE | TIME_MINUTES);
      return;
     }
   if(count > MAX_CALC_BARS)                                      // safety, normally never reached
     {
      exportOldest = exportNewest + MAX_CALC_BARS - 1;
      count = MAX_CALC_BARS;
     }
   datetime t[];
   uchar    v[];
   ArrayResize(t, count);
   ArrayResize(v, count);

   int n0 = 0, n1 = 0, n2 = 0;
   for(int k = 0; k < count; k++)
     {
      int shift = exportOldest - k;          // ascending time
      t[k] = Time[shift];
      int val = (int)SETUP_MT_Stoc[shift];
      v[k] = (uchar)val;
      if(val == 1)
         n1++;
      else
         if(val == 2)
            n2++;
         else
            n0++;
     }

   string note = "";
   if(InpExportFrom > 0 && t[0] - InpExportFrom > 7 * 86400)
      note += " | NOTE: starts later than InpExportFrom (not enough history or settle bars)";
   if(InpExportTo > 0 && InpExportTo - t[count - 1] > 7 * 86400)
      note += " | NOTE: ends earlier than InpExportTo (not covered by the calculated bars)";
   string fname = SetupFileNameForRange(t[0], t[count - 1]);   // v7.1: range is part of the file name

   //--- repaint check against the newest previous file (any range)
   g_statRepaint = "Repaint check: no previous file";
   datetime pt[];
   uchar    pv[];
   SetupFileInfo pinfo;
   string perr = "";
   string prevFile = LatestSetupFile();
   if(prevFile != "" && LoadSetupFile(prevFile, pt, pv, pinfo, perr))
     {
      int overlap = 0, changed = 0;
      for(int k = 0; k < count; k++)
        {
         int idx = FindTimeIndex(pt, pinfo.count, t[k]);
         if(idx < 0)
            continue;
         overlap++;
         if(pv[idx] != v[k])
            changed++;
        }
      g_statRepaint = "Repaint check vs " + prevFile + " (" + TimeToString(pinfo.exported, TIME_DATE | TIME_MINUTES) + "): " +
                      IntegerToString(overlap) + " bars overlap, " + IntegerToString(changed) + " changed";
     }

   string err = "";
   bool ok = WriteSetupFile(fname, t, v, count, err);
   uint ms = GetTickCount() - t0;
   if(ok)
     {
      g_exportedOnce = true;
      g_fileName = fname;
      g_statExport = "EXPORT OK: " + fname + " | " + IntegerToString(count) + " bars (" +
                     TimeToString(t[0], TIME_DATE | TIME_MINUTES) + " -> " + TimeToString(t[count - 1], TIME_DATE | TIME_MINUTES) + ") | " +
                     IntegerToString(SMS_HDR_BYTES + count * 9) + " bytes | UP=" + IntegerToString(n1) +
                     " DOWN=" + IntegerToString(n2) + " none=" + IntegerToString(n0) + " | " + IntegerToString((int)ms) + " ms" + note;
     }
   else
     {
      g_statExport = "EXPORT FAILED: " + err;
     }
  }
//+------------------------------------------------------------------+
//| Read the file back, compare with the live array, draw bottom row  |
//+------------------------------------------------------------------+
void ReadBackAndDraw()
  {
   datetime ft[];
   uchar    fv[];
   SetupFileInfo fi;
   string err = "";
   uint t0 = GetTickCount();
   string rbName = (g_fileName != "") ? g_fileName : LatestSetupFile();
   if(rbName == "")
     {
      g_statVerify = "READ-BACK FAILED: no file '" + SetupFilePrefix() + "_*.bin' found";
      return;
     }
   if(!LoadSetupFile(rbName, ft, fv, fi, err))
     {
      g_statVerify = "READ-BACK FAILED: " + err;
      return;
     }
   bool hdrOK = (fi.symbol == DataSymbol() && fi.period == (int)currentTimeframe);

   int drawUp = 0, drawDn = 0, compared = 0, mismatch = 0;
   for(int i = 1; i <= LookBack; i++)
     {
      int idx = FindTimeIndex(ft, fi.count, Time[i]);
      if(idx < 0)
         continue;
      int fval = (int)fv[idx];
      if(fval == 1)
        {
         fileUp[i] = 1;
         drawUp++;
        }
      else
         if(fval == 2)
           {
            fileDn[i] = 1;
            drawDn++;
           }
      compared++;
      if(fval != (int)SETUP_MT_Stoc[i])
         mismatch++;
     }
   int notOnChart = fi.count - compared;
   bool pass = (hdrOK && mismatch == 0 && notOnChart == 0);
   g_statVerify = "READ-BACK " + (pass ? "PASS" : "CHECK") + ": " + IntegerToString(fi.count) + " bars read, header " +
                  (hdrOK ? "OK" : "MISMATCH (" + fi.symbol + "/" + IntegerToString(fi.period) + ")") +
                  ", compared " + IntegerToString(compared) + ", differences vs live array " + IntegerToString(mismatch) +
                  ", file bars not on chart " + IntegerToString(notOnChart) +
                  " | drawn UP=" + IntegerToString(drawUp) + " DOWN=" + IntegerToString(drawDn) +
                  " | " + IntegerToString((int)(GetTickCount() - t0)) + " ms";
  }
//+------------------------------------------------------------------+
void ProcessFile()
  {
   bool doExport = EXPORT_TO_FILE && (EXPORT_EVERY_NEW_BAR || !g_exportedOnce);
   if(doExport)
      ExportSetupFile();
   ReadBackAndDraw();

   string s = "TopDog CherryTrig v7.5 - SETUP_MT_Stoc\n" + g_statBars + "\n" + g_statCalc + "\n" +
              (g_statExport == "" ? "Export: disabled / not yet done" : g_statExport) + "\n" + g_statRepaint + "\n" + g_statVerify;
   Comment(s);
   Print(s);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double trends[];
double ha1u[], ha1d[], ha2u[], ha2d[], ha3u[], ha3d[], ha4u[], ha4d[], ha5u[], ha5d[];
double ha6u[], ha6d[], ha7u[], ha7d[], ha8u[], ha8d[], ha9u[], ha9d[], ha10u[], ha10d[];
double ha11u[], ha11d[], ha12u[], ha12d[], ha13u[], ha13d[], ha14u[], ha14d[], ha15u[], ha15d[];

int subWindow = -1;
int shortSearch = 0;                     // v7.3: was extern (showed up in Inputs)


double MT_MomWave3UP[],MT_MomWave3DOWN[],MT_MomWave2UP[],MT_MomWave2DOWN[],MT_X_Mark_The_SpotUP[],MT_X_Mark_The_SpotDOWN[],MT_Impulse_Without_retraceUP[],MT_Impulse_Without_retraceDOWN[];

double MT_UP_MOMentum[];
double MT_DOWN_MOMentum[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(33);
   g_currentBar   = 0;      // force full recalculation after (re)init
   g_windowSpawned = false;  // v7.5
   g_winMsg = "";
   g_exportedOnce = false;
   g_fileName = "";
   DrawHorizontalLineInSubwindow();
// Set up indicator buffers
   SetIndexBuffer(0, ha1u);
   SetIndexBuffer(1, ha1d);
   SetIndexBuffer(2, ha2u);
   SetIndexBuffer(3, ha2d);
   SetIndexBuffer(4, ha3u);
   SetIndexBuffer(5, ha3d);
   SetIndexBuffer(6, ha4u);
   SetIndexBuffer(7, ha4d);
   SetIndexBuffer(8, ha5u);
   SetIndexBuffer(9, ha5d);
   SetIndexBuffer(10, ha6u);
   SetIndexBuffer(11, ha6d);
   SetIndexBuffer(12, ha7u);
   SetIndexBuffer(13, ha7d);
   SetIndexBuffer(14, ha8u);
   SetIndexBuffer(15, ha8d);
   SetIndexBuffer(16, ha9u);
   SetIndexBuffer(17, ha9d);
   SetIndexBuffer(18, ha10u);
   SetIndexBuffer(19, ha10d);
   SetIndexBuffer(20, ha11u);
   SetIndexBuffer(21, ha11d);
   SetIndexBuffer(22, ha12u);
   SetIndexBuffer(23, ha12d);
   SetIndexBuffer(24, ha13u);
   SetIndexBuffer(25, ha13d);
   SetIndexBuffer(26, ha14u);
   SetIndexBuffer(27, ha14d);
   SetIndexBuffer(28, ha15u);
   SetIndexBuffer(29, ha15d);
   SetIndexBuffer(30, trends);
   SetIndexBuffer(31, fileUp);   // v7: bottom row, read back from file
   SetIndexBuffer(32, fileDn);

// Set level texts
   //IndicatorSetString(INDICATOR_LEVELTEXT, 0, "After LOSS Filter");
   //IndicatorSetString(INDICATOR_LEVELTEXT, 1, "MA's S/R  ");
   //IndicatorSetString(INDICATOR_LEVELTEXT, 2, "TD Align.");
   //IndicatorSetString(INDICATOR_LEVELTEXT, 3, "ST Stoc Div. ");
   //IndicatorSetString(INDICATOR_LEVELTEXT, 4, "PA ");
   IndicatorSetString(INDICATOR_LEVELTEXT, 0, "FILE SETUP_MT_Stoc");
   IndicatorSetString(INDICATOR_LEVELTEXT, 5, "ST K");
   IndicatorSetString(INDICATOR_LEVELTEXT, 6, "ST MOM");
   IndicatorSetString(INDICATOR_LEVELTEXT, 7, "ST D");
   IndicatorSetString(INDICATOR_LEVELTEXT, 8, "MT MOM");
   IndicatorSetString(INDICATOR_LEVELTEXT, 9, "MT D");
   IndicatorSetString(INDICATOR_LEVELTEXT, 10, "MT K");
   IndicatorSetString(INDICATOR_LEVELTEXT, 11, "AGAINST momentum");
   IndicatorSetString(INDICATOR_LEVELTEXT, 12, "AGAINST trend");
   IndicatorSetString(INDICATOR_LEVELTEXT, 13, "MT Trigger NOT @ Stoc Extreme");
   IndicatorSetString(INDICATOR_LEVELTEXT, 14, "MT Trigger @ Stoc Extreme");

   IndicatorSetString(INDICATOR_SHORTNAME, "                                    CherryTrigv9_excl LTcon.");

   for(int i = 0; i < 30; i++)
     {
      SetIndexStyle(i, DRAW_ARROW, EMPTY, LinesWidth);
      SetIndexArrow(i, 110);
     }
   SetIndexStyle(31, DRAW_ARROW, EMPTY, LinesWidth, clrLimeGreen);
   SetIndexArrow(31, 110);
   SetIndexLabel(31, "File SETUP_MT_Stoc UP");
   SetIndexStyle(32, DRAW_ARROW, EMPTY, LinesWidth, clrPaleVioletRed);
   SetIndexArrow(32, 110);
   SetIndexLabel(32, "File SETUP_MT_Stoc DOWN");
   SetIndexEmptyValue(31, EMPTY_VALUE);
   SetIndexEmptyValue(32, EMPTY_VALUE);

   if(subWindow < 0)
     {
      subWindow = ChartWindowFind();
     }

// Initialize arrays on first load


   return(0);
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   EventKillTimer();
   Comment("");
   DeleteRec();
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawHorizontalLineInSubwindow()
  {
   int subWindow = ChartWindowFind();
   if(subWindow < 0)
      return;
   string lineName = "Level_2.5_Line";
   if(!ObjectCreate(0, lineName, OBJ_HLINE, subWindow, 0, 2.5))
      return;
   ObjectSetInteger(0, lineName, OBJPROP_COLOR, clrBlue);
   ObjectSetInteger(0, lineName, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, lineName, OBJPROP_WIDTH, 1);

   string lineName1 = "Level_5.5_Line";
   if(!ObjectCreate(0, lineName1, OBJ_HLINE, subWindow, 0, 5.5))
      return;
   ObjectSetInteger(0, lineName1, OBJPROP_COLOR, clrBlue);
   ObjectSetInteger(0, lineName1, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, lineName1, OBJPROP_WIDTH, 1);

   string lineName2 = "Level_11.5_Line";
   if(!ObjectCreate(0, lineName2, OBJ_HLINE, subWindow, 0, 11.5))
      return;
   ObjectSetInteger(0, lineName2, OBJPROP_COLOR, clrBlue);
   ObjectSetInteger(0, lineName2, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, lineName2, OBJPROP_WIDTH, 1);
  }
//+------------------------------------------------------------------+
//| Delete Rectangles                                                |
//+------------------------------------------------------------------+
void DeleteRec()
  {
   int obj_total = ObjectsTotal();
   string name;
   for(int i = 0; i < obj_total; i++)
     {
      name = ObjectName(i);
      if(name != "")
        {
         if(StringFind(name, "Rubber", 0) != -1 ||
            StringFind(name, "SwingEndoftrend", 0) != -1 ||
            StringFind(name, "WaveCount_", 0) != -1 ||
            StringFind(name, "WaveCount", 0) != -1||
            StringFind(name, "SuppText-", 0) != -1)
           {
            ObjectDelete(name);
            int err = GetLastError();
            i = i - 1;
           }
        }
     }
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ClearArrowBuffers(int bars)
  {
   for(int i = 0; i < bars; i++)
     {
      ha1u[i] = ha1d[i] = ha2u[i] = ha2d[i] = ha3u[i] = ha3d[i] =
            ha4u[i] = ha4d[i] = ha5u[i] = ha5d[i] = ha6u[i] = ha6d[i] =
                                             ha7u[i] = ha7d[i] = ha8u[i] = ha8d[i] = ha9u[i] = ha9d[i] =
                                                   ha10u[i] = ha10d[i] = ha11u[i] = ha11d[i] = ha12u[i] = ha12d[i] =
                                                         ha13u[i] = ha13d[i] = ha14u[i] = ha14d[i] = ha15u[i] = ha15d[i] = EMPTY_VALUE;
     }
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Populate_SETUParray()
  {
//-- To clear up the dashboard only display colors in the direction of the setup
//-- Determine the the SETUP =1 or =2 for the MAXbars/LookBack for each bar
//--- Notice the count of the different setups
   GetSETUPcnt();

   ArrayResize(SETUP,LookBack + 2);

   for(int t=1; t <= LookBack; t++)
     {
      SETUP[t] = 0;

      if(DOWN_SETUP_COUNT[t] >= Req_SETUPS)
        {
         SETUP[t] = 2;
        }
      if(UP_SETUP_COUNT[t] >= Req_SETUPS)
        {
         SETUP[t] = 1;
        }
     }
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetSetup(int i)
  {
   int SetupUP = 0;
   int SetupDOWN = 0;
   int ret = 0;
//---
//---   UP counter
//---
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
   //if(LT_Conservative[i] ==1)
   //   SetupUP = SetupUP+1;

//---
//---   DOWN counter
//---

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
   //if(LT_Conservative[i] ==2)
   //   SetupDOWN = SetupDOWN+1;

   if(SetupUP > 0 && SetupDOWN == 0)
     {
      ret = 1;
      //  ArrowTimeless(StringConcatenate("WaveCount SwingHighCounter", i), Time[i], Low[i] - 250 * Point, clrGreen, 174);
     }
   else
     {
      if(SetupDOWN > 0 && SetupUP == 0)
        {
         ret = 2;

        }
      else
        {
         // mixed
        }
     }

   return(ret);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int PopulateOther()
  {
   ArraySetAsSeries(CandleClose, true);
   ArraySetAsSeries(CandleOpen, true);
   ArraySetAsSeries(CandleHigh, true);
   ArraySetAsSeries(CandleLow, true);
   ArraySetAsSeries(CandleTime, true);
   ArraySetAsSeries(CandleVolume, true);

// Make everything LookBack + 5 for consistency
   ArrayResize(CandleClose, LookBack + 150);
   ArrayResize(CandleOpen, LookBack + 150);
   ArrayResize(CandleHigh, LookBack + 150);
   ArrayResize(CandleLow, LookBack + 150);
   ArrayResize(CandleTime, LookBack + 150);
   ArrayResize(CandleVolume, LookBack + 150);

// Copy the same amount as array size
   actualCopied = CopyClose(currentSymbol, currentTimeframe, 0, LookBack + 150, CandleClose);
   CopyOpen(currentSymbol, currentTimeframe, 0, LookBack + 150, CandleOpen);
   CopyHigh(currentSymbol, currentTimeframe, 0, LookBack + 150, CandleHigh);
   CopyLow(currentSymbol, currentTimeframe, 0, LookBack + 150, CandleLow);
   CopyTime(currentSymbol, currentTimeframe, 0, LookBack + 150, CandleTime);
   CopyTickVolume(currentSymbol, currentTimeframe, 0, LookBack + 150, CandleVolume);

   if(actualCopied <= 0)            // v7.4: Copy*() can fail on offline (window) charts -> use the chart's own series
     {
      int nOwn = MathMin(LookBack + 150, Bars);
      for(int k = 0; k < nOwn; k++)
        {
         CandleClose[k]  = Close[k];
         CandleOpen[k]   = Open[k];
         CandleHigh[k]   = High[k];
         CandleLow[k]    = Low[k];
         CandleTime[k]   = Time[k];
         CandleVolume[k] = (datetime)Volume[k];
        }
      actualCopied = nOwn;
     }

   return(0);
  }
//+------------------------------------------------------------------+
//---
//---    The *.mqh files needs these to 2 arrays in order for subsequent processing
//---   1) SETUP  - Needed to generate momentum
//---   2) D_K_MOM - Needed to generate the Triggers
//---
//---
//+------------------------------------------------------------------+
int Populate_SETUP()
  {
//ArrayResize(SETUP,LookBack + 2);
   ArrayResize(D_K_MOM,LookBack + 2);
   for(int i=1; i <= LookBack; i++)
     {
      if(GetSetup(i) == 1)
        {
         D_K_MOM[i] =1;
         // SETUP[i] = 1;
        }
      if(GetSetup(i) == 2)
        {
         D_K_MOM[i] =2;
         // SETUP[i] = 2;
        }
     }
   return(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| v7.3 helpers: automatic bar detection + history check            |
//+------------------------------------------------------------------+
string DT(datetime tm)
  {
   return(TimeToString(tm, TIME_DATE | TIME_MINUTES));
  }
//+------------------------------------------------------------------+
//| Why is the wanted date not available, and what can be done?       |
//+------------------------------------------------------------------+
string HistoryHint(datetime wantedStart)
  {
   long srv = 0;
   ResetLastError();
   if(wantedStart > 0 && SeriesInfoInteger(currentSymbol, currentTimeframe, SERIES_SERVER_FIRSTDATE, srv) && srv > 0 && wantedStart < (datetime)srv)
      return(" The broker's server has no " + currentSymbol + " data before " + DT((datetime)srv) + " - choose a later date.");
   return(" The data may exist on the server but is not loaded in the terminal: raise Tools > Options > Charts > 'Max bars in history' and " +
          "'Max bars in chart', restart the terminal, scroll the chart back (Home key) or download the data in the History Center (F2), then re-attach the indicator.");
  }
//+------------------------------------------------------------------+
//| Works out, from the date range only, how many bars must be        |
//| calculated and verifies that the chart really holds them.         |
//|   lb     = LookBack to use (bars calculated)                      |
//|   wanted = bars the range needs (can be larger than lb when the   |
//|            range starts a few days before the history)            |
//| Returns false + err when nothing sensible can be calculated.      |
//+------------------------------------------------------------------+
bool ResolveLookBack(int &lb, int &wanted, bool &window, string &err)
  {
   window = false;
   lb = 0;
   wanted = 0;
   err = "";
   string pair   = currentSymbol + " " + StringSubstr(EnumToString(currentTimeframe), 7);
   int    minLB  = SETTLE_BARS + 50;                      // fewer calculated bars than this leaves (almost) nothing to export
   int    maxLB  = Bars - WARMUP_BARS;                    // the most the loaded history can support
   if(maxLB < minLB)
     {
      err = "NOT ENOUGH HISTORY: " + pair + " has only " + IntegerToString(Bars) + " bars loaded, at least " +
            IntegerToString(WARMUP_BARS + minLB) + " are needed (" + IntegerToString(WARMUP_BARS) + " warm-up + " + IntegerToString(minLB) +
            " to calculate)." + HistoryHint(0);
      return(false);
     }

   datetime newest   = Time[1];                                       // newest closed bar
   datetime oldest   = Time[MathMax(maxLB - SETTLE_BARS, 1)];          // oldest bar that can be exported with the loaded history
   datetime tol      = (datetime)MathMax(4 * 86400, 2 * PeriodSeconds(currentTimeframe)); // weekend / holiday tolerance

   //--- 1. the dates themselves
   if(InpExportFrom > 0 && InpExportTo > 0 && InpExportFrom >= InpExportTo)
     {
      err = "INVALID DATE RANGE: InpExportFrom (" + DT(InpExportFrom) + ") must be earlier than InpExportTo (" + DT(InpExportTo) + ").";
      return(false);
     }
   if(InpExportFrom > 0 && InpExportFrom > newest)
     {
      err = "INVALID DATE RANGE: InpExportFrom (" + DT(InpExportFrom) + ") is later than the newest closed bar (" + DT(newest) + ").";
      return(false);
     }

   //--- 2. do the dates lie inside the loaded history?
   if(InpExportFrom > 0 && InpExportFrom + tol < oldest)
     {
      err = "DATE NOT AVAILABLE: InpExportFrom (" + DT(InpExportFrom) + ") is older than the history of " + pair + ". " +
            "The oldest bar that can be exported is " + DT(oldest) + " (" + IntegerToString(Bars) + " bars loaded, " +
            IntegerToString(WARMUP_BARS) + " kept for warm-up, " + IntegerToString(SETTLE_BARS) + " for settling). Nothing was calculated." +
            HistoryHint(InpExportFrom);
      return(false);
     }
   if(InpExportTo > 0 && InpExportTo + tol < oldest)
     {
      err = "DATE NOT AVAILABLE: InpExportTo (" + DT(InpExportTo) + ") is older than the history of " + pair + ". " +
            "The oldest bar that can be exported is " + DT(oldest) + ". Nothing was calculated." + HistoryHint(InpExportTo);
      return(false);
     }

   //--- 3. how many bars does the range need? (the calculation always starts at the newest bar)
   if(InpExportFrom > 0)
     {
      int shFrom = iBarShift(currentSymbol, currentTimeframe, InpExportFrom, false);
      if(shFrom < 0)
        {
         err = "Cannot locate InpExportFrom (" + DT(InpExportFrom) + ") on the chart of " + pair + ", error " + IntegerToString(GetLastError()) + ".";
         return(false);
        }
      if(Time[shFrom] < InpExportFrom)
         shFrom--;                                                   // first exported bar must not be older than InpExportFrom
      shFrom = MathMax(shFrom, 1);
      wanted = shFrom + SETTLE_BARS + 2;
     }
   else
     {
      wanted = DEFAULT_BARS;
      if(InpExportTo > 0)                                            // only an end date: keep DEFAULT_BARS bars of export before it
        {
         int shTo = iBarShift(currentSymbol, currentTimeframe, InpExportTo, false);
         if(shTo > 0)
            wanted = shTo + DEFAULT_BARS;
        }
      if(InpExportTo == 0 && IsWindowChart())                        // window chart, no dates: use the whole window
         wanted = maxLB;
     }

   //--- 3b. range far back in a big chart -> do not calculate everything newer than InpExportTo: build a window chart instead
   if(!IsWindowChart() && InpExportFrom > 0 && InpExportTo > 0)
     {
      int shT = iBarShift(currentSymbol, currentTimeframe, InpExportTo, false);
      if(shT >= WINDOW_MIN_SKIP_BARS && wanted > WINDOW_MIN_WANTED)
        {
         window = true;
         return(true);
        }
     }

   //--- 4. safety cap
   if(wanted > MAX_CALC_BARS)
     {
      err = "RANGE TOO LARGE: the wanted range needs " + IntegerToString(wanted) + " bars (the calculation starts at the newest bar) but the safety limit is " +
            IntegerToString(MAX_CALC_BARS) + " bars. Nothing was calculated. Choose a later InpExportFrom (the oldest allowed is about " +
            DT(Time[MathMax(MAX_CALC_BARS - SETTLE_BARS, 1)]) + ")." + WindowTip();
      return(false);
     }

   lb = MathMin(wanted, maxLB);
   return(true);
  }
//+------------------------------------------------------------------+
//| Show the reason on the chart; log it once per distinct message    |
//+------------------------------------------------------------------+
void ShowProblem(string msg)
  {
   string s = "TopDog CherryTrig v7.5 - NOTHING CALCULATED\n" + msg;
   Comment(s);
   if(msg != g_lastProblem)
     {
      Print(s);
      g_lastProblem = msg;
     }
  }

//+------------------------------------------------------------------+
//| v7.5 AUTOMATIC WINDOW MODE                                       |
//|  1. start():   saves this chart as template (indicator + inputs)  |
//|                and closes an old window chart                     |
//|  2. OnTimer(): writes the window history (range + warm-up bars)   |
//|                as offline symbol <SYMBOL>_W, opens that chart and |
//|                applies the template -> the indicator starts there |
//+------------------------------------------------------------------+
void ShowNote(string msg)
  {
   string s = "TopDog CherryTrig v7.5 - " + msg;
   Comment(s);
   if(msg != g_lastProblem)
     {
      Print(s);
      g_lastProblem = msg;
     }
  }
//+------------------------------------------------------------------+
void CloseWindowCharts(string sym)
  {
   long ids[];
   int  n = 0;
   long id = ChartFirst();
   while(id >= 0)
     {
      if(ChartSymbol(id) == sym && (int)ChartPeriod(id) == (int)currentTimeframe)
        {
         ArrayResize(ids, n + 1);
         ids[n++] = id;
        }
      id = ChartNext(id);
     }
   for(int k = 0; k < n; k++)
      ChartClose(ids[k]);
  }
//+------------------------------------------------------------------+
void HstWriteText(int h, string s, int len)
  {
   int n = StringLen(s);
   for(int k = 0; k < len; k++)
      FileWriteInteger(h, (k < n) ? StringGetChar(s, k) : 0, CHAR_VALUE);
  }
//+------------------------------------------------------------------+
//| Writes <SYMBOL>_W<period>.hst (version 401) with the range plus   |
//| WINDOW_PRE_ROLL_BARS warm-up bars before it                       |
//+------------------------------------------------------------------+
bool BuildWindowFile(int &written, string &err)
  {
   written = 0;
   string dst   = currentSymbol + WINDOW_SUFFIX;
   int    per   = (int)currentTimeframe;
   int    total = iBars(currentSymbol, currentTimeframe);

   int shFrom = iBarShift(currentSymbol, currentTimeframe, InpExportFrom, false);
   if(shFrom < 0)
     {
      err = "WINDOW CHART FAILED: cannot locate InpExportFrom (" + DT(InpExportFrom) + "), error " + IntegerToString(GetLastError()) + ".";
      return(false);
     }
   if(shFrom > 0 && iTime(currentSymbol, currentTimeframe, shFrom) < InpExportFrom)
      shFrom--;                                                       // first bar of the range must not be older than InpExportFrom
   int shTo = iBarShift(currentSymbol, currentTimeframe, InpExportTo, false);
   if(shTo < 0)
      shTo = 0;

   int shStart = MathMin(shFrom + WINDOW_PRE_ROLL_BARS, total - 1);    // oldest bar written
   int shEnd   = MathMax(shTo - WINDOW_POST_ROLL_BARS, 0);             // newest bar written
   int preRoll = shStart - shFrom;
   if(shEnd >= shFrom)
     {
      err = "WINDOW CHART FAILED: the range " + DT(InpExportFrom) + " -> " + DT(InpExportTo) + " contains no bars.";
      return(false);
     }
   int needPre = WARMUP_BARS + SETTLE_BARS + 10;
   if(preRoll < needPre)
     {
      err = "NOT ENOUGH HISTORY BEFORE THE START DATE: only " + IntegerToString(preRoll) + " bars exist before InpExportFrom (" + DT(InpExportFrom) +
            "), the indicator needs at least " + IntegerToString(needPre) + " for warm-up and settling. Choose a later InpExportFrom." + HistoryHint(InpExportFrom);
      return(false);
     }

   string fname = dst + IntegerToString(per) + ".hst";
   int h = FileOpenHistory(fname, FILE_BIN | FILE_WRITE | FILE_SHARE_WRITE | FILE_SHARE_READ);
   if(h < 0)
     {
      err = "WINDOW CHART FAILED: cannot create the history file " + fname + " (error " + IntegerToString(GetLastError()) +
            "). If the chart '" + dst + "' is still open, close it and re-attach the indicator.";
      return(false);
     }
   FileWriteInteger(h, 401, LONG_VALUE);                              // version
   HstWriteText(h, "(C)opyright TopDog window chart", 64);            // copyright
   HstWriteText(h, dst, 12);                                          // symbol
   FileWriteInteger(h, per, LONG_VALUE);                              // period
   FileWriteInteger(h, (int)MarketInfo(currentSymbol, MODE_DIGITS), LONG_VALUE);   // digits
   FileWriteInteger(h, 0, LONG_VALUE);                                // timesign
   FileWriteInteger(h, 0, LONG_VALUE);                                // last sync
   for(int u = 0; u < 13; u++)
      FileWriteInteger(h, 0, LONG_VALUE);                             // unused

   MqlRates r;
   for(int sh = shStart; sh >= shEnd; sh--)
     {
      r.time        = iTime(currentSymbol, currentTimeframe, sh);
      r.open        = iOpen(currentSymbol, currentTimeframe, sh);
      r.high        = iHigh(currentSymbol, currentTimeframe, sh);
      r.low         = iLow(currentSymbol, currentTimeframe, sh);
      r.close       = iClose(currentSymbol, currentTimeframe, sh);
      r.tick_volume = iVolume(currentSymbol, currentTimeframe, sh);
      r.spread      = 0;
      r.real_volume = 0;
      FileWriteStruct(h, r);
      written++;
     }
   FileClose(h);
   return(true);
  }
//+------------------------------------------------------------------+
//| Called from start() on the REAL chart                             |
//+------------------------------------------------------------------+
void HandleWindowMode(int wantedBars)
  {
   string dst = currentSymbol + WINDOW_SUFFIX;
   if(g_windowSpawned)                       // already launched (start() runs again on every new bar)
     {
      ShowNote(g_winMsg);
      return;
     }
   if(StringLen(dst) > 11)
     {
      ShowProblem("WINDOW CHART NOT POSSIBLE: the symbol name '" + dst + "' is too long for a history file (max 11 characters).");
      return;
     }
   ResetLastError();
   if(!ChartSaveTemplate(0, WINDOW_TEMPLATE))
     {
      ShowProblem("WINDOW CHART FAILED: cannot save the chart template, error " + IntegerToString(GetLastError()) + ".");
      return;
     }
   CloseWindowCharts(dst);                   // an open old window chart would lock its history file
   g_windowSpawned = true;
   g_winMsg = "WINDOW MODE: " + DT(InpExportFrom) + " -> " + DT(InpExportTo) + " lies far back in this chart (a direct calculation would need " +
              IntegerToString(wantedBars) + " bars). A small chart with only this range is being built and opened automatically as '" + dst +
              "'. The result is calculated on that new chart - nothing is calculated on this one.";
   ShowNote(g_winMsg);
   EventSetTimer(2);                         // step 2 runs after the template has really been saved
  }
//+------------------------------------------------------------------+
//| Step 2 of the window mode (real chart only)                       |
//+------------------------------------------------------------------+
void OnTimer()
  {
   EventKillTimer();
   if(!g_windowSpawned || IsWindowChart())
      return;
   string dst = currentSymbol + WINDOW_SUFFIX;
   string tf  = StringSubstr(EnumToString(currentTimeframe), 7);
   string err = "";
   int    n   = 0;
   if(!BuildWindowFile(n, err))
     {
      ShowProblem(err);
      return;
     }
   ResetLastError();
   long id = ChartOpen(dst, currentTimeframe);
   if(id <= 0)
     {
      ShowNote("WINDOW FILE WRITTEN (" + IntegerToString(n) + " bars) but the chart could not be opened automatically (error " + IntegerToString(GetLastError()) +
               "). Do it by hand: File > Open Offline > '" + dst + "," + tf + "' > Open, then attach this indicator there with the same two dates.");
      return;
     }
   ResetLastError();
   if(!ChartApplyTemplate(id, WINDOW_TEMPLATE))
     {
      ShowNote("WINDOW CHART OPENED (" + IntegerToString(n) + " bars) but the indicator could not be attached automatically (error " + IntegerToString(GetLastError()) +
               "). Attach this indicator to the chart '" + dst + "' by hand with the same two dates.");
      return;
     }
   g_winMsg = "WINDOW MODE: the chart '" + dst + "," + tf + "' (" + IntegerToString(n) + " bars incl. " + IntegerToString(WINDOW_PRE_ROLL_BARS) +
              " warm-up bars) was opened and the indicator started there. Switch to that chart: it shows progress, and the .bin file is written when it finishes.";
   ShowNote(g_winMsg);
  }

//+------------------------------------------------------------------+
//| v7.4: timing, progress, pilot run                                |
//+------------------------------------------------------------------+
uint   g_stageT0 = 0, g_calcT0 = 0;
string g_estNote = "";

string FormatSeconds(double s)
  {
   if(s < 60.0)
      return(DoubleToString(s, 1) + " s");
   int m = (int)(s / 60.0);
   return(IntegerToString(m) + " min " + IntegerToString((int)(s - m * 60.0)) + " s");
  }
//+------------------------------------------------------------------+
//| One line per finished stage in the Experts log + chart comment    |
//+------------------------------------------------------------------+
void StageDone(bool verbose, int n, string what)
  {
   if(!verbose)
      return;
   uint   now   = GetTickCount();
   string stage = FormatSeconds((now - g_stageT0) / 1000.0);
   string total = FormatSeconds((now - g_calcT0) / 1000.0);
   g_stageT0 = now;
   Print("CherryTrig v7.5 | ", LookBack, " bars | stage ", n, "/9 finished: ", what, " | stage ", stage, " | total ", total);
   Comment("TopDog CherryTrig v7.5 - calculating " + IntegerToString(LookBack) + " bars\n" +
           "stage " + IntegerToString(n) + "/9 finished: " + what + "\n" +
           "this stage " + stage + " | total so far " + total + (g_estNote != "" ? "\n" + g_estNote : ""));
   ChartRedraw();
  }
//+------------------------------------------------------------------+
//| The complete calculation (same calls, same order as before)      |
//+------------------------------------------------------------------+
void RunCalculation(int lb, bool verbose)
  {
   LookBack  = lb;                    // global from FG_Global_VariablesV7.mqh
   g_calcT0  = GetTickCount();
   g_stageT0 = g_calcT0;

   PopulateOther();                                                  //Calc. CandleClose/Open/High/Low
   StageDone(verbose, 1, "candle data");
   Populate_Indicator_Arrays();
   StageDone(verbose, 2, "indicator arrays (MA, MACD, Stochastic ...)");
   Populate_SETUParray();                                            // UP_SETUP_COUNT[]; DOWN_SETUP_COUNT[]
   StageDone(verbose, 3, "setups");
   Populate_K_D_MOM_Arrays();
   StageDone(verbose, 4, "K/D/MOM");
   Populate_Trigger_Arrays();
   StageDone(verbose, 5, "triggers");
   PopulateTomDeMarkArrays();
   StageDone(verbose, 6, "TomDeMark");
   CheckMAResistance(1);
   ClearArray(AfterLOSS_filter);
   ArrayResize(AfterLOSS_filter, LookBack + 2);
   StageDone(verbose, 7, "MA resistance");
   Populate_KDMOM_TRIGGER_cnt();                                     // UP_K_D_MOM_COUNT[]; DOWN_K_D_MOM_COUNT[]; UP_TRIGGER_COUNT[]; DOWN_TRIGGER_COUNT[]
   StageDone(verbose, 8, "K/D/MOM + trigger counters");
   Populate_SETUP_MT_Stoc();                                         // built from SETUP[], MT_UP_Stoc[], MT_Down_Stoc[]
   StageDone(verbose, 9, "SETUP_MT_Stoc");
  }
//+------------------------------------------------------------------+
//| Times three short runs (the first one is a warm-up), derives how  |
//| the cost grows with the number of bars and extrapolates to        |
//| 'bars'. Result in seconds. Does not touch the chart buffers.     |
//+------------------------------------------------------------------+
double EstimateSeconds(int bars)
  {
   int n1 = 500, n2 = 1000;
   RunCalculation(250, false);                                       // warm-up, not timed
   uint a = GetTickCount();
   RunCalculation(n1, false);
   uint b = GetTickCount();
   RunCalculation(n2, false);
   uint c = GetTickCount();
   double t1 = (b - a) / 1000.0, t2 = (c - b) / 1000.0;
   double k  = 1.0;                                                  // growth exponent: 1 = linear, 2 = quadratic
   if(t1 >= 0.05 && t2 > t1)
      k = MathLog(t2 / t1) / MathLog((double)n2 / (double)n1);
   k = MathMax(1.0, MathMin(k, 3.0));
   return(t2 * MathPow((double)bars / (double)n2, k));
  }

//+------------------------------------------------------------------+
//| start                                                            |
//+------------------------------------------------------------------+
int start()
  {
   int limit;
   bool isUp = false;
   int counted_bars = IndicatorCounted();

   static int clr;

   if(g_currentBar != Bars)
     {
      g_currentBar = Bars;

      ClearArrowBuffers(Bars);
      ClearFileBuffers(Bars);
      currentSymbol = Symbol();
      currentTimeframe = Period();

      //--- v7.3: the number of bars is derived from the date range and checked against the real history
      //--- BEFORE any calculation. Nothing is calculated when the history cannot deliver the wanted range.
      int effLB = 0, wanted = 0;
      string problem = "";
      bool window = false;
      if(!ResolveLookBack(effLB, wanted, window, problem))
        {
         ShowProblem(problem);
         return(0);
        }
      if(window)                                     // v7.5: far-back range -> small offline window chart, calculated there
        {
         HandleWindowMode(wanted);
         return(0);
        }
      g_lastProblem = "";
      LookBack = effLB;      // global from FG_Global_VariablesV7.mqh - every loop in the includes runs to LookBack
      g_statBars = "Bars on chart " + IntegerToString(Bars) + " | bars calculated " + IntegerToString(LookBack) +
                   " (auto-detected, needed " + IntegerToString(wanted) + ", warm-up " + IntegerToString(WARMUP_BARS) + ")";
      if(InpExportFrom > 0 || InpExportTo > 0)
         g_statBars += " | wanted export range " + (InpExportFrom > 0 ? TimeToString(InpExportFrom, TIME_DATE) : "oldest") + " -> " +
                       (InpExportTo > 0 ? TimeToString(InpExportTo, TIME_DATE) : "newest");
      //limit = Bars - counted_bars;
      //limit = MathMin(limit,Bars - (LookBack +2));
      //limit = MathMin(limit,LookBack);
      limit = MathMin(Bars,LookBack);

      g_estNote = "";
      if(effLB > PILOT_FROM_BARS)
        {
         double est = EstimateSeconds(effLB);                        // short timed pilot runs -> predicted total time
         g_estNote = "estimated total " + FormatSeconds(est);
         if(est > MAX_CALC_SECONDS)
           {
            LookBack = effLB;
            ShowProblem("TOO SLOW: calculating " + IntegerToString(effLB) + " bars is predicted to take about " + FormatSeconds(est) +
                        " on this PC (limit " + FormatSeconds(MAX_CALC_SECONDS) + "). Nothing was calculated. Choose a shorter date range." + WindowTip());
            return(0);
           }
         string startMsg = "TopDog CherryTrig v7.5 - calculating " + IntegerToString(effLB) + " bars, " + g_estNote +
                           ". MT4 cannot repaint or react while an indicator calculates - this is normal. Progress is logged in the Experts tab after every stage.";
         Comment(startMsg);
         Print(startMsg);
         ChartRedraw();
        }

      RunCalculation(effLB, true);
      limit = MathMin(Bars, LookBack);
      g_statCalc = "Calculation time " + FormatSeconds((GetTickCount() - g_calcT0) / 1000.0) + (g_estNote != "" ? " (" + g_estNote + ")" : "");
      
      for(int i = limit; i > 0 && i < actualCopied; i--)
        {
         static bool diagnosed = false;
         if(i >= Bars - 5)
            continue; // Skip if too close to end
         for(int k = 15; k >= 0; k--)
           {
            switch(k)
              {
               case 14: // MT_Stoc Extreme
                  // if(GetSetup(i) == 1 && MT_UP_Stoc[i] == 1)
                  if(SETUP[i] == 1 && MT_UP_Stoc[i] == 1)
                    {
                     ha14u[i] = k + 1;
                     ha14d[i] = EMPTY_VALUE;
                    }
                  else
                    {
                     //  if(GetSetup(i) == 2 && MT_Down_Stoc[i] == 2)
                     if(SETUP[i] == 2 && MT_Down_Stoc[i] == 2)
                       {
                        ha14d[i] = k + 1;
                        ha14u[i] = EMPTY_VALUE;
                       }
                    }
                  break;
               case 13:// MT_Stoc NOT Extreme
                  // if(GetSetup(i) == 1 && MT_UP_Stoc[i] != 1)
                  if(SETUP[i] == 1 && MT_UP_Stoc[i] != 1)
                    {
                     ha1u[i] = k + 1;
                     ha1d[i] = EMPTY_VALUE;
                    }
                  else
                    {
                     //if(GetSetup(i) == 2 && MT_Down_Stoc[i] != 2)
                     if(SETUP[i] == 2 && MT_Down_Stoc[i] != 2)
                       {
                        ha1d[i] = k + 1;
                        ha1u[i] = EMPTY_VALUE;
                       }
                    }

                  break;

               case 12: //Setup Against trend
                  //if(GetSetup(i) == 2 && MT_MA150[i]>MT_MA150[i+1] && CandleClose[i] > MT_MA150[i])
                  if(SETUP[i] == 2 && MT_MA150[i]>MT_MA150[i+1] && CandleClose[i] > MT_MA150[i])
                    {
                     ha3u[i] = k + 1;
                     ha3d[i] = EMPTY_VALUE;
                    }
                  else
                    {
                     //if(GetSetup(i) == 1 && MT_MA150[i]<MT_MA150[i+1] && CandleClose[i] < MT_MA150[i])
                     if(SETUP[i] == 1 && MT_MA150[i]<MT_MA150[i+1] && CandleClose[i] < MT_MA150[i])
                       {
                        ha3d[i] = k + 1;
                        ha3u[i] = EMPTY_VALUE;
                       }
                    }
                  break;
               //MT_UP_MOMentum[i]= 0;
               //MT_DOWN_MOMentum[i]=0;
               case 11://Setup Against MOMENTUM
                  if((ha14d[i] != EMPTY_VALUE || ha1d[i] != EMPTY_VALUE) && MT_Divergence_UP_Counter[i]>0)

                    {
                     ha4u[i] = k + 1;
                     ha4d[i] = EMPTY_VALUE;
                    }
                  else
                    {
                     if((ha14u[i] != EMPTY_VALUE || ha1u[i] != EMPTY_VALUE) && MT_Divergence_DOWN_Counter[i]>0)
                       {
                        ha4d[i] = k + 1;
                        ha4u[i] = EMPTY_VALUE;
                       }
                    }
                  break;
               //--- D,K,MOM

               //***************************************************************************************
               case 10:  // MT_Stoc_K angle
                  //  if(GetSetup(i) == 1 && MT_Stoc_K[i] > MT_Stoc_K[i+1])
                  if(MT_K_Angle[i] == 1)
                    {
                     ha13u[i] = k + 1;
                     ha13d[i] = EMPTY_VALUE;
                    }
                  else
                    {
                     //   if(GetSetup(i) == 2 && MT_Stoc_K[i] < MT_Stoc_K[i+1])
                     if(MT_K_Angle[i] == 2)
                       {
                        ha13d[i] = k + 1;
                        ha13u[i] = EMPTY_VALUE;
                       }
                    }
                  break;

               case 9: // MT_Stoc_D angle
                  //  if(GetSetup(i) == 1 && MT_Stoc_D[i] > MT_Stoc_D[i+1])
                  if(MT_D_Angle[i] == 1)
                    {
                     ha7u[i] = k + 1;
                     ha7d[i] = EMPTY_VALUE;
                    }
                  else
                    {
                     if(MT_D_Angle[i] == 2)
                        //  if(GetSetup(i) == 2 && MT_Stoc_D[i] < MT_Stoc_D[i+1])
                       {
                        ha7d[i] = k + 1;
                        ha7u[i] = EMPTY_VALUE;
                       }
                    }
                  break;

               case 8: // MT_MOM
                  //if(GetSetup(i) == 1 && MT_MACD_MOM[i] > MT_MACD_MOM[i+1])
                  if(MT_MOM_Angle[i] == 1)
                    {
                     ha6u[i] = k + 1;
                     ha6d[i] = EMPTY_VALUE;
                    }
                  else
                    {
                     // if(GetSetup(i) == 2 && MT_MACD_MOM[i] < MT_MACD_MOM[i+1])
                     if(MT_MOM_Angle[i] == 2)
                       {
                        ha6d[i] = k + 1;
                        ha6u[i] = EMPTY_VALUE;
                       }
                    }
                  break;

               case 7: // ST_Stoc_D angle
                  //     if(GetSetup(i) == 1 && ST_Stoc_D[i] > ST_Stoc_D[i+1] && (ha6u[i] != EMPTY_VALUE || ha13u[i] != EMPTY_VALUE))
                  if(ST_D_Angle[i] == 1)
                    {
                     ha10u[i] = k + 1;
                     ha10d[i] = EMPTY_VALUE;
                    }
                  else
                    {
                     //        if(GetSetup(i) == 2 && ST_Stoc_D[i] < ST_Stoc_D[i+1] && (ha6d[i] != EMPTY_VALUE || ha13d[i] != EMPTY_VALUE))
                     if(ST_D_Angle[i] == 2)
                       {
                        ha10d[i] = k + 1;
                        ha10u[i] = EMPTY_VALUE;
                       }
                    }
                  break;

               case 6: // ST_MOM
                  if(ST_MOM_Angle[i] ==1)
                     //   if(GetSetup(i) == 1 && ST_MACD_MOM[i] > ST_MACD_MOM[i+1] && (ha6u[i] != EMPTY_VALUE || ha13u[i] != EMPTY_VALUE))
                    {
                     ha15u[i] = k + 1;
                     ha15d[i] = EMPTY_VALUE;
                    }
                  else
                    {
                     if(ST_MOM_Angle[i] ==2)
                        //if(GetSetup(i) == 2 && ST_MACD_MOM[i] < ST_MACD_MOM[i+1] && (ha6d[i] != EMPTY_VALUE || ha13d[i] != EMPTY_VALUE))
                       {
                        ha15d[i] = k + 1;
                        ha15u[i] = EMPTY_VALUE;
                       }
                    }
                  break;

               case 5: // ST Stoch K
                  if(ST_K_Angle[i] == 1)
                     //if(GetSetup(i) == 1 && ST_Stoc_K[i] > ST_Stoc_K[i+1] && (ha6u[i] != EMPTY_VALUE || ha13u[i] != EMPTY_VALUE) && ST_Stoc_D[i] < 55)
                    {
                     ha5u[i] = k + 1;
                     ha5d[i] = EMPTY_VALUE;
                    }
                  else
                    {
                     if(ST_K_Angle[i] == 2)
                        //  if(GetSetup(i) == 2 && ST_Stoc_K[i] < ST_Stoc_K[i+1] && (ha6d[i] != EMPTY_VALUE || ha13d[i] != EMPTY_VALUE) && ST_Stoc_D[i] > 45)
                       {
                        ha5d[i] = k + 1;
                        ha5u[i] = EMPTY_VALUE;
                       }
                    }
                  break;
               //--- TRIGGER

//               case 4: // Price action bars
//                  if(PriceActionBar[i] == 1) //GetSetup(i) == 1 && ConsiderTriggerOnlyWhen(i,1)&&
//                    {
//                     ha11u[i] = k + 1;
//                     ha11d[i] = EMPTY_VALUE;
//                    }
//                  else
//                    {
//                     if(PriceActionBar[i] == 2) //GetSetup(i) == 2 && ConsiderTriggerOnlyWhen(i,2)&&
//                       {
//                        ha11d[i] = k + 1;
//                        ha11u[i] = EMPTY_VALUE;
//                       }
//                    }
//                  break; // FIXED: Added missing break
//
//               case 3: // Divergence
//                  if(ST_Stoc_Divergence[i] == 1) //GetSetup(i) == 1 && ConsiderTriggerOnlyWhen(i,1) &&
//                    {
//                     ha12u[i] = k + 1;
//                     ha12d[i] = EMPTY_VALUE;
//                    }
//                  else
//                    {
//                     if(ST_Stoc_Divergence[i] == 2) //GetSetup(i) == 2 && ConsiderTriggerOnlyWhen(i,2) &&
//                       {
//                        ha12d[i] = k + 1;
//                        ha12u[i] = EMPTY_VALUE;
//                       }
//                    }
//                  break;
//               case 2:// TD Trigger
//                  if(TDAlignmentTrigger[i] == 1)//GetSetup(i) == 1 && ConsiderTriggerOnlyWhen(i,1) && (TD_AligmentResult[i] == 1 || TD_Aligment_InTrend_Result[i] == 1) && (TD_Alignment[i] - TD_Alignment[i+2]) > 1)
//                    {
//                     //
//                     ha9u[i] = k + 1;
//                     ha9d[i] = EMPTY_VALUE;
//                    }
//                  else
//                    {
//                     if(TDAlignmentTrigger[i] == 2)//GetSetup(i) == 2 && ConsiderTriggerOnlyWhen(i,2) && (TD_AligmentResult[i] == 2 || TD_Aligment_InTrend_Result[i] == 2) && (TD_Alignment[i+2] - TD_Alignment[i]) > 1)
//                       {
//                        //
//                        ha9d[i] = k + 1;
//                        ha9u[i] = EMPTY_VALUE;
//                       }
//                    }
//                  break;
//
//
//               case 1: // MA Support/Resistance
//                  if(MA_SUPPORT_RESISTANCE[i] == 1)//   (ha9u[i] != EMPTY_VALUE || ha12u[i] != EMPTY_VALUE || ha11u[i] != EMPTY_VALUE)  && MA_Resistance[i] == 1) //
//                    {
//                     ha2u[i] = k + 1;
//                     ha2d[i] = EMPTY_VALUE;
//                    }
//                  else
//                    {
//                     if(MA_SUPPORT_RESISTANCE[i] == 2)// (ha9d[i] != EMPTY_VALUE || ha12d[i] != EMPTY_VALUE || ha11d[i] != EMPTY_VALUE)  && MA_Support[i] == 1)//(ha12u[i] == 2 || ha11u[i] == 2 ) &&
//                       {
//                        ha2d[i] = k + 1;
//                        ha2u[i] = EMPTY_VALUE;
//                       }
//                    }
//                  break;
//
//
//               case 0: // Filtered
//
//                   if(AfterLOSS_filter[i] == 1)
//                    {
//                  //   DebugSetup(i);
//                     ha8u[i] = k + 1;
//                     ha8d[i] = EMPTY_VALUE;
//                    }
//                  else
//                    {
//                     //if(ha2d[i] != EMPTY_VALUE && AdditionalFilteringPassed(2,i) == 1)
//                     if(AfterLOSS_filter[i] == 2)
//                       {
//                     //  DebugSetup(i);
//                        ha8d[i] = k + 1;
//                        ha8u[i] = EMPTY_VALUE;
//                       }
//                    }
//                  break;
              }
           }
        }

      ProcessFile();                 // v7: export, read back, draw bottom row, statistics
     }

   return(0); // FIXED: Added return statement
  }
//+------------------------------------------------------------------+
