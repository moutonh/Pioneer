//+------------------------------------------------------------------+
//|                                                     SMAAngle.mq4 |
//|                                                                  |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property  copyright "jpkfox"
#property  link      "http://www.strategybuilderfx.com/forums/showthread.php?t=15274&page=1&pp=8"
//---- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 5
#property  indicator_color1  LimeGreen
#property  indicator_color2  Red
#property  indicator_color3 FireBrick
#property  indicator_color3 Black
#property  indicator_color4 Black
//#property indicator_minimum -1
//#property indicator_maximum 1
#property  indicator_level1  0.02
#property  indicator_level2 -0.02
#property  indicator_level3  0.05
#property  indicator_level4 -0.05
#property indicator_levelcolor       clrSilver
#property indicator_levelstyle       STYLE_DASH
#property indicator_levelwidth       1

//---- indicator parameters
extern int SMAPeriod=150;
extern double AngleTreshold=0;
extern int MA_Sensitivity=6;
extern int MA_FlatSensitivity = 3;
//---- indicator buffers
double UpBuffer[];
double DownBuffer[];
double ZeroBuffer[];
double AllBuffer[];
double SignalBuffer[];
int EndSMAShift = 0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- 2 additional buffers are used for counting.
   IndicatorBuffers(3);
//---- drawing settings
   SetIndexStyle(0,DRAW_HISTOGRAM,STYLE_SOLID,2);
   SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_SOLID,2);
   SetIndexStyle(2,DRAW_HISTOGRAM,STYLE_SOLID,2);
   SetIndexStyle(3,DRAW_LINE,STYLE_SOLID,1);
   SetIndexStyle(4,DRAW_LINE,STYLE_SOLID,1);
//----
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)+2);
   SetIndexBuffer(0,UpBuffer);
   SetIndexBuffer(1,DownBuffer);
   SetIndexBuffer(2,ZeroBuffer);
   SetIndexBuffer(3,AllBuffer);
   SetIndexBuffer(4,SignalBuffer);
////---- 3 indicator buffers mapping
//   if(!SetIndexBuffer(0,UpBuffer) &&
//      !SetIndexBuffer(1,DownBuffer) &&
//      !SetIndexBuffer(2,ZeroBuffer))
//      Print("cannot set indicator buffers!");
////---- name for DataWindow and indicator subwindow label
   IndicatorShortName("SMAAngleV3("+SMAPeriod+","+AngleTreshold+","+MA_Sensitivity+","+MA_FlatSensitivity+")");
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| The angle for SMA                                                |
//+------------------------------------------------------------------+
int start()
  {
   double fEndMA, fStartMA;
   double fAngle, mFactor, dFactor;
   int nLimit, i;
   int nCountedBars;
   double angle,ATR;
   int ShiftDif;
//----
   if(EndSMAShift>=MA_Sensitivity)
     {
      Print("Error: EndSMAShift >= StartSMAShift");
      MA_Sensitivity=6;
      EndSMAShift=0;
     }
   nCountedBars=IndicatorCounted();
//---- check for possible errors
   if(nCountedBars<0)
      return(-1);
//---- last counted bar will be recounted
   if(nCountedBars>0)
      nCountedBars--;
   nLimit=Bars-nCountedBars;
//---- main loop
   for(i=0; i<nLimit; i++)
      //  for(i=0; i<700; i++)
     {
      fEndMA=iMA(NULL,0,SMAPeriod,0,MODE_SMA,PRICE_MEDIAN,i+EndSMAShift);
      fStartMA=iMA(NULL,0,SMAPeriod,0,MODE_SMA,PRICE_MEDIAN,i+MA_Sensitivity);
      ATR = iATR(NULL,0,1000,i);

      // Calculate slope
      double deltaY = fEndMA - fStartMA;
      double deltaX = MA_Sensitivity-EndSMAShift;

      // Calculate angle in radians, then convert to degrees
      double angleRad = MathArctan(deltaY / deltaX);
      if(ATR==0)
        {
         ATR=High[i]-Low[i];
         ATR = MathMax(0.00001,ATR);
        }
      fAngle = (deltaY/ATR)/deltaX;

      //   Print("(fEndMA - fStartMA)/(StartSMAShift-EndSMAShift) = ",MathArctan((fEndMA - fStartMA)/(StartSMAShift-EndSMAShift)));

      //    Print(" angleRad = ",angleRad);
      // Print(" fEndMA = ",fEndMA," fStartMA = ",fStartMA," = ",fEndMA-fStartMA," ATR = ",ATR,"deltaY/ATR = ",deltaY/ATR," fAngle = ",fAngle);

      //     // 10000.0 : Multiply by 10000 so that the unir becomes pips per bar
      //     fAngle=mFactor * (fEndMA - fStartMA)/(StartSMAShift-EndSMAShift);
      ////     MathArctangent(deltaY / deltaX);
      //     fAngle = MathArctan(fAngle)/dFactor;
      // Divide with with dFactor so that unit of fAngle becomes pips per bar
      DownBuffer[i]=0.0;
      UpBuffer[i]=0.0;
      ZeroBuffer[i]=0.0;

      if(iMA(NULL,0,SMAPeriod,0,MODE_SMA,PRICE_MEDIAN,i+MA_FlatSensitivity)>iMA(NULL,0,SMAPeriod,0,MODE_SMA,PRICE_MEDIAN,i) && fAngle > 0)
        {
         fAngle ==0;
        }
      if(iMA(NULL,0,SMAPeriod,0,MODE_SMA,PRICE_MEDIAN,i+MA_FlatSensitivity)<iMA(NULL,0,SMAPeriod,0,MODE_SMA,PRICE_MEDIAN,i) && fAngle < 0)
        {
         fAngle ==0;
        }
      //----
      if(fAngle > AngleTreshold)
        {
         UpBuffer[i]=fAngle;
         AllBuffer[i]=fAngle;
        }
      else
         if(fAngle < AngleTreshold)
           {
            DownBuffer[i]=fAngle;
            AllBuffer[i]=fAngle;
           }
         else
           {
            ZeroBuffer[i]=fAngle;
            AllBuffer[i]=fAngle;
           }
      if(i<100)
        {
         //   Print("i = ",i," DownBuffer[i] = ",DownBuffer[i]," UpBuffer[i] = ",UpBuffer[i]);//," fAngle = ",fAngle);
        }
     }

   for(i=0; i<nLimit; i++)
      SignalBuffer[i]=iMAOnArray(AllBuffer,Bars,21,0,MODE_EMA,i);


   return(0);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
