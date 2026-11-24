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
//--- v8.1 : reads ALL TopDog_SETUP_MT_Stoc_<symbol>_<tf>_<from>_<to>.bin files (the exporter puts the range in the name),
//---        draws them over the WHOLE chart (bottom row = confirmation, row 15 = file row used by the other rows),
//---        reloads files only when they change, no extra input fields (only InpLookBack).
#property indicator_separate_window
#property indicator_buffers 32
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
//--- v8.1: no extern/input declared inside the include files may show up in the Inputs tab (include files are NOT modified).
//--- FG_IndicatorsV9_1 = V9 with a fixed ATR period (the old LookBack-period ATR made the calculation time grow with the square of LookBack).
#define extern
#define input
#define sinput
#include <FG_Global_VariablesV7.mqh>
#include <EA_Debug_LogV2.mqh>
#include <FG_IndicatorsV9_1.mqh>
#include <FG_K_D_MomV4.mqh>
#include <FG_TriggersV7.mqh>
#undef extern
#undef input
#undef sinput

int    LinesWidth = 0;

double trends[];
double ha1u[], ha1d[], ha2u[], ha2d[], ha3u[], ha3d[], ha4u[], ha4d[], ha5u[], ha5d[];
double ha6u[], ha6d[], ha7u[], ha7d[], ha8u[], ha8d[], ha9u[], ha9d[], ha10u[], ha10d[];
double ha11u[], ha11d[], ha12u[], ha12d[], ha13u[], ha13d[], ha14u[], ha14d[], ha15u[], ha15d[];

int subWindow = -1;
int shortSearch = 0;


double MT_MomWave3UP[],MT_MomWave3DOWN[],MT_MomWave2UP[],MT_MomWave2DOWN[],MT_X_Mark_The_SpotUP[],MT_X_Mark_The_SpotDOWN[],MT_Impulse_Without_retraceUP[],MT_Impulse_Without_retraceDOWN[];

double MT_UP_MOMentum[];
double MT_DOWN_MOMentum[];
input int  InpLookBack          = 2000;  // Newest bars for which the calculated rows are worked out (smaller = faster). The FILE rows always cover the whole chart.
#define WARMUP_BARS       600            // bars kept free at the oldest end of the chart (indicator warm-up)

//+------------------------------------------------------------------+
//| v8: row 14 "MT Trigger @ Stoc Extreme" is READ FROM FILE         |
//| (file written by CherryTrigv7_SetupExport, 1 = UP, 2 = DOWN).    |
//| All other rows are still calculated from the includes.           |
//+------------------------------------------------------------------+
#define USE_COMMON_FOLDER true          // must match USE_COMMON_FOLDER of the exporter (Terminal\\Common\\Files)

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

//--- v8.1: ALL files of this symbol/timeframe are merged (ascending times; when two files contain the same bar the newer export wins)
datetime sf_mt[];                 // merged bar open times
uchar    sf_mv[];                 // merged values 0 / 1 / 2
int      sf_mn = 0;               // number of merged bars
string   sf_signature = "";       // names + sizes + modify dates of the files that were loaded
bool     sf_loadedOnce = false;
int      sf_byShift[];            // file value per chart shift: 0/1/2, -1 = no file value for this bar
int      sf_matched = 0, sf_up = 0, sf_dn = 0;
int      sf_okFiles = 0, sf_badFiles = 0;
string   sf_report = "";          // per-file lines for the chart comment

//+------------------------------------------------------------------+
int SfCommonFlag()
  {
   return(USE_COMMON_FOLDER ? FILE_COMMON : 0);
  }
//+------------------------------------------------------------------+
//| the exporter names its files <prefix>_<YYYYMMDD from>_<YYYYMMDD to>.bin |
//+------------------------------------------------------------------+
string DataSym()                  // on the offline window chart (<SYMBOL>_W) the files belong to the real symbol
  {
   string s = Symbol();
   int n = StringLen(s);
   if(n > 2 && StringSubstr(s, n - 2) == "_W")
      return(StringSubstr(s, 0, n - 2));
   return(s);
  }
//+------------------------------------------------------------------+
string SetupFilePrefix()
  {
   return("TopDog_SETUP_MT_Stoc_" + DataSym() + "_" + IntegerToString(Period()));
  }
//+------------------------------------------------------------------+
//| every candidate file: <prefix>_*.bin  (+ an old file without range) |
//+------------------------------------------------------------------+
int ListSetupFiles(string &names[])
  {
   ArrayResize(names, 0);
   string legacy = SetupFilePrefix() + ".bin";
   if(FileIsExist(legacy, SfCommonFlag()))
     {
      ArrayResize(names, 1);
      names[0] = legacy;
     }
   string nm = "";
   long fh = FileFindFirst(SetupFilePrefix() + "_*.bin", nm, SfCommonFlag());
   if(fh != INVALID_HANDLE)
     {
      do
        {
         int n = ArraySize(names);
         ArrayResize(names, n + 1);
         names[n] = nm;
        }
      while(FileFindNext(fh, nm));
      FileFindClose(fh);
     }
   return(ArraySize(names));
  }
//+------------------------------------------------------------------+
//| cheap "did anything change?" test: names, sizes, modify dates     |
//+------------------------------------------------------------------+
string SetupFilesSignature()
  {
   string names[];
   int    n   = ListSetupFiles(names);
   string sig = "";
   for(int k = 0; k < n; k++)
     {
      int h = FileOpen(names[k], FILE_BIN | FILE_READ | FILE_SHARE_READ | FILE_SHARE_WRITE | SfCommonFlag());
      if(h == INVALID_HANDLE)
        {
         sig += names[k] + "|busy;";
         continue;
        }
      sig += names[k] + "|" + IntegerToString((int)FileSize(h)) + "|" + IntegerToString((int)FileGetInteger(h, FILE_MODIFY_DATE)) + ";";
      FileClose(h);
     }
   return(sig);
  }
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
//| headerOnly = true: read and check the header only (fast)          |
//+------------------------------------------------------------------+
bool LoadSetupFile(const string fname, datetime &t[], uchar &v[], SetupFileInfo &info, string &err, bool headerOnly = false)
  {
   ResetLastError();
   int h = FileOpen(fname, FILE_BIN | FILE_READ | SfCommonFlag());
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
   if(headerOnly)
     {
      FileClose(h);
      return(true);
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
//| merge file arrays (ascending) into the master arrays; on equal    |
//| bar times the value of the file being merged wins                 |
//+------------------------------------------------------------------+
void MergeIntoMaster(datetime &ft[], uchar &fv[], int nf)
  {
   datetime rt[];
   uchar    rv[];
   ArrayResize(rt, sf_mn + nf);
   ArrayResize(rv, sf_mn + nf);
   int a = 0, b = 0, o = 0;
   while(a < sf_mn || b < nf)
     {
      if(b >= nf || (a < sf_mn && sf_mt[a] < ft[b]))
        {
         rt[o] = sf_mt[a];
         rv[o] = sf_mv[a];
         a++;
        }
      else
         if(a >= sf_mn || ft[b] < sf_mt[a])
           {
            rt[o] = ft[b];
            rv[o] = fv[b];
            b++;
           }
         else
           {
            rt[o] = ft[b];
            rv[o] = fv[b];
            a++;
            b++;
           }
      o++;
     }
   ArrayResize(sf_mt, o);
   ArrayResize(sf_mv, o);
   ArrayCopy(sf_mt, rt, 0, 0, o);
   ArrayCopy(sf_mv, rv, 0, 0, o);
   sf_mn = o;
  }
//+------------------------------------------------------------------+
//| Read every file of this symbol/timeframe, check it, merge it.     |
//| Only runs when the files are new or changed.                      |
//+------------------------------------------------------------------+
void ReloadSetupFiles()
  {
   string tag = "[SETUP file] ";
   string names[];
   int    n = ListSetupFiles(names);
   sf_signature  = SetupFilesSignature();
   sf_loadedOnce = true;
   sf_mn = 0;
   ArrayResize(sf_mt, 0);
   ArrayResize(sf_mv, 0);
   sf_okFiles = 0;
   sf_badFiles = 0;
   sf_report = "";

   if(n == 0)
     {
      sf_report = "NO SETUP FILE FOUND. Expected '" + SetupFilePrefix() + "_<from>_<to>.bin' in " +
                  (USE_COMMON_FOLDER ? "the Common\\Files folder (" + TerminalInfoString(TERMINAL_COMMONDATA_PATH) + "\\Files)" : "MQL4\\Files") +
                  ". Run the exporter indicator on " + DataSym() + " / timeframe " + IntegerToString(Period()) + " first.";
      Print(tag, sf_report);
      return;
     }

   //--- pass 1: headers only -> which files belong to this chart, and in which order were they exported
   datetime hExp[];
   ArrayResize(hExp, n);
   int valid[];
   int nv = 0;
   for(int k = 0; k < n; k++)
     {
      SetupFileInfo hi;
      datetime tt[];
      uchar    vv[];
      string   e = "";
      hExp[k] = 0;
      if(!LoadSetupFile(names[k], tt, vv, hi, e, true))
        {
         Print(tag, "SKIPPED ", names[k], ": ", e);
         sf_report += "\n  SKIPPED " + names[k] + ": " + e;
         sf_badFiles++;
         continue;
        }
      if(hi.symbol != DataSym() || hi.period != Period())
        {
         Print(tag, "SKIPPED ", names[k], ": header says ", hi.symbol, " / ", hi.period, ", chart is ", DataSym(), " / ", Period());
         sf_report += "\n  SKIPPED " + names[k] + ": header is " + hi.symbol + " / " + IntegerToString(hi.period);
         sf_badFiles++;
         continue;
        }
      hExp[k] = hi.exported;
      ArrayResize(valid, nv + 1);
      valid[nv++] = k;
     }
   for(int x = 0; x < nv - 1; x++)                 // oldest export first, so the newest export wins on overlaps
      for(int y = x + 1; y < nv; y++)
         if(hExp[valid[y]] < hExp[valid[x]])
           {
            int sw = valid[x];
            valid[x] = valid[y];
            valid[y] = sw;
           }

   //--- pass 2: read, check and merge
   for(int q = 0; q < nv; q++)
     {
      string nm = names[valid[q]];
      SetupFileInfo fi;
      datetime ft[];
      uchar    fv[];
      string   err = "";
      if(!LoadSetupFile(nm, ft, fv, fi, err))
        {
         Print(tag, "READ FAILED for ", nm, ": ", err);
         sf_report += "\n  READ FAILED " + nm + ": " + err;
         sf_badFiles++;
         continue;
        }
      int n0 = 0, n1 = 0, n2 = 0, nBad = 0, nOrder = 0;
      for(int k = 0; k < fi.count; k++)
        {
         if(fv[k] == 0)
            n0++;
         else
            if(fv[k] == 1)
               n1++;
            else
               if(fv[k] == 2)
                  n2++;
               else
                  nBad++;
         if(k > 0 && ft[k] <= ft[k - 1])
            nOrder++;
        }
      Print(tag, nm, (USE_COMMON_FOLDER ? " (common folder)" : " (local folder)"), ": ", fi.count, " bars, ",
            TimeToString(fi.first, TIME_DATE | TIME_MINUTES), " -> ", TimeToString(fi.last, TIME_DATE | TIME_MINUTES),
            ", exported ", TimeToString(fi.exported, TIME_DATE | TIME_MINUTES), ", UP ", n1, ", DOWN ", n2, ", none ", n0,
            ", invalid ", nBad, ", time order errors ", nOrder);
      if(nBad > 0 || nOrder > 0)
        {
         Print(tag, "FILE CHECK FAILED for ", nm, " -> file not used.");
         sf_report += "\n  CHECK FAILED " + nm + " (invalid values or time order)";
         sf_badFiles++;
         continue;
        }
      MergeIntoMaster(ft, fv, fi.count);
      sf_okFiles++;
      sf_report += "\n  " + nm + ": " + IntegerToString(fi.count) + " bars " + TimeToString(fi.first, TIME_DATE) + " -> " +
                   TimeToString(fi.last, TIME_DATE) + "  (UP " + IntegerToString(n1) + " / DOWN " + IntegerToString(n2) + ")";
     }
  }
//+------------------------------------------------------------------+
//| Map the merged file values to chart shifts 1..Bars-1 (one pass,   |
//| both lists are sorted by time). Cheap - done on every new bar.    |
//+------------------------------------------------------------------+
void MapFileToChart()
  {
   ArrayResize(sf_byShift, Bars + 2);
   ArrayInitialize(sf_byShift, -1);
   sf_matched = 0;
   sf_up = 0;
   sf_dn = 0;
   if(sf_mn <= 0)
      return;
   int p = 0;
   for(int sh = Bars - 1; sh >= 1; sh--)
     {
      datetime ct = Time[sh];
      while(p < sf_mn && sf_mt[p] < ct)
         p++;
      if(p >= sf_mn)
         break;
      if(sf_mt[p] == ct)
        {
         int v = (int)sf_mv[p];
         sf_byShift[sh] = v;
         sf_matched++;
         if(v == 1)
            sf_up++;
         else
            if(v == 2)
               sf_dn++;
        }
     }
  }
//+------------------------------------------------------------------+
//| Draw the file values on the WHOLE chart (not only the newest      |
//| InpLookBack bars):                                                |
//|   bottom row  (1) = the raw file result = CONFIRMATION            |
//|   row 15      "MT Trigger @ Stoc Extreme (file)" (used by the rows)|
//+------------------------------------------------------------------+
void DrawFileRows()
  {
   for(int sh = Bars - 1; sh >= 1; sh--)
     {
      int v = sf_byShift[sh];
      if(v == 1)
        {
         ha8u[sh]  = 1;
         ha14u[sh] = 15;
        }
      else
         if(v == 2)
           {
            ha8d[sh]  = 1;
            ha14d[sh] = 15;
           }
     }
  }
//+------------------------------------------------------------------+
//| Called after the calculation: (re)load files if changed, map,     |
//| draw, and show the confirmation text on the chart                 |
//+------------------------------------------------------------------+
void LoadAndMapSetupFiles(int limit)
  {
   string sig = SetupFilesSignature();
   if(!sf_loadedOnce || sig != sf_signature)
      ReloadSetupFiles();
   MapFileToChart();
   DrawFileRows();

   string txt;
   if(sf_mn <= 0)
     {
      txt = "SETUP FILE NOT LOADED\n" + sf_report;
     }
   else
     {
      txt = "SETUP FILE LOADED - " + IntegerToString(sf_okFiles) + " file(s)" + (sf_badFiles > 0 ? ", " + IntegerToString(sf_badFiles) + " skipped" : "") +
            ", " + IntegerToString(sf_mn) + " bars, " + TimeToString(sf_mt[0], TIME_DATE | TIME_MINUTES) + " -> " + TimeToString(sf_mt[sf_mn - 1], TIME_DATE | TIME_MINUTES) +
            "\nMatched to this chart: " + IntegerToString(sf_matched) + " bars  |  arrows drawn: UP " + IntegerToString(sf_up) + ", DOWN " + IntegerToString(sf_dn) +
            "  (bottom row = file result, whole chart)\nOther rows are calculated for the newest " + IntegerToString(limit) + " bars only" + sf_report;
      if(sf_matched == 0)
         txt += "\nNOTE: none of the file's bars exist on this chart - scroll back to the file's date range.";
     }
   Comment(txt);
   Print("[SETUP file] ", (sf_mn > 0 ? "chart bars matched " + IntegerToString(sf_matched) + ", arrows UP " + IntegerToString(sf_up) + " / DOWN " + IntegerToString(sf_dn) : "no data"));
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(32);
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

// Set level texts
   //IndicatorSetString(INDICATOR_LEVELTEXT, 0, "After LOSS Filter");
   //IndicatorSetString(INDICATOR_LEVELTEXT, 1, "MA's S/R  ");
   //IndicatorSetString(INDICATOR_LEVELTEXT, 2, "TD Align.");
   //IndicatorSetString(INDICATOR_LEVELTEXT, 3, "ST Stoc Div. ");
   //IndicatorSetString(INDICATOR_LEVELTEXT, 4, "PA ");
   IndicatorSetString(INDICATOR_LEVELTEXT, 0, "SETUP file (confirmation)");
   IndicatorSetString(INDICATOR_LEVELTEXT, 5, "ST K");
   IndicatorSetString(INDICATOR_LEVELTEXT, 6, "ST MOM");
   IndicatorSetString(INDICATOR_LEVELTEXT, 7, "ST D");
   IndicatorSetString(INDICATOR_LEVELTEXT, 8, "MT MOM");
   IndicatorSetString(INDICATOR_LEVELTEXT, 9, "MT D");
   IndicatorSetString(INDICATOR_LEVELTEXT, 10, "MT K");
   IndicatorSetString(INDICATOR_LEVELTEXT, 11, "AGAINST momentum");
   IndicatorSetString(INDICATOR_LEVELTEXT, 12, "AGAINST trend");
   IndicatorSetString(INDICATOR_LEVELTEXT, 13, "MT Trigger NOT @ Stoc Extreme");
   IndicatorSetString(INDICATOR_LEVELTEXT, 14, "MT Trigger @ Stoc Extreme (file)");

   IndicatorSetString(INDICATOR_SHORTNAME, "                                    CherryTrigv9_excl LTcon.");

   for(int i = 0; i < 30; i++)
     {
      SetIndexStyle(i, DRAW_ARROW, EMPTY, LinesWidth);
      SetIndexArrow(i, 110);
     }

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

int start()
  {
   static int currentbar;
   int limit;
   bool isUp = false;
   int counted_bars = IndicatorCounted();

   static int clr;
   static uint lastFileCheck = 0;

   //--- v8.1: a new / changed export file forces a recalculation (rows 11 ... depend on the file row)
   if(currentbar == Bars && GetTickCount() - lastFileCheck >= 3000)
     {
      lastFileCheck = GetTickCount();
      if(SetupFilesSignature() != sf_signature)
         currentbar = 0;
     }

   if(currentbar != Bars)
     {
      
        //--- v7: few-bars fix. LookBack (global in FG_Global_VariablesV7.mqh) is fixed at 2000; every loop in the
      //--- includes runs to LookBack, so on a short chart they walk through bars that do not exist.
      //--- Shrink it to what the chart can support (the include itself is untouched).
      int effLB = MathMin(InpLookBack, Bars - WARMUP_BARS);
      if(effLB < 100)
        {
         string msg = "CherryTrig v7: not enough bars. Have " + IntegerToString(Bars) + ", need at least " +
                      IntegerToString(WARMUP_BARS + 100) + " (warm-up " + IntegerToString(WARMUP_BARS) + " + 100). Load more history.";
         Comment(msg);
         Print(msg);
         return(0);
        }
      LookBack = effLB;    
      
      
      currentbar = Bars;

      ClearArrowBuffers(Bars);
      currentSymbol = Symbol();
      currentTimeframe = Period();
 
    //  limit = MathMin(Bars,LookBack);
      limit = effLB;
      PopulateOther();      //Calc. CandleClose/Open/High/Low
      Populate_Indicator_Arrays();
      Populate_SETUParray();    // Populate --|>   UP_SETUP_COUNT[];DOWN_SETUP_COUNT[];
   //   Populate_SETUP();
      Populate_K_D_MOM_Arrays();
      Populate_Trigger_Arrays();
      PopulateTomDeMarkArrays();
      CheckMAResistance(1);
      
 
   ClearArray(AfterLOSS_filter);
   ArrayResize(AfterLOSS_filter,LookBack + 2);
   
      Populate_KDMOM_TRIGGER_cnt();  // Populate --|>    UP_K_D_MOM_COUNT[];DOWN_K_D_MOM_COUNT[];UP_TRIGGER_COUNT[];DOWN_TRIGGER_COUNT[];
      
      LoadAndMapSetupFiles(limit);      // v8.1: all files -> whole-chart file rows + confirmation text

      for(int i = limit; i > 0 && i < actualCopied; i--)
        {
         static bool diagnosed = false;
         if(i >= Bars - 5)
            continue; // Skip if too close to end
         for(int k = 15; k >= 0; k--)
           {
            switch(k)
              {
               case 14: // MT_Stoc Extreme  -- v8: value read from FILE (SETUP_MT_Stoc), not calculated
                  if(sf_byShift[i] == 1)
                    {
                     ha14u[i] = k + 1;
                     ha14d[i] = EMPTY_VALUE;
                    }
                  else
                    {
                     if(sf_byShift[i] == 2)
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
     }

   return(0); // FIXED: Added return statement
  }
//+------------------------------------------------------------------+
