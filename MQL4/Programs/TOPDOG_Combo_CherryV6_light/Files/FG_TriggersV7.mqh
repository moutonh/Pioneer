//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+

#property strict
#include <FG_Global_VariablesV6.mqh>
#define CHECK_ARRAY_INDEX(array, index) CheckArrayIndex(array, #array, __FUNCTION__, __LINE__, index)
double TRIGGER[];
double BearArrowBuffer[];
double BullArrowBuffer[];
//+------------------------------------------------------------------+
void Populate_Trigger_Arrays()//string symbol, ENUM_TIMEFRAMES timeframe
  {

   ArrayResize(PriceActionBar,LookBack + 2);
   ArrayResize(TRIGGER,LookBack + 2);
   ArrayResize(ST_Stoc_Divergence,LookBack + 2);
   ArrayResize(ST_Stoc_Convergence,LookBack + 2);
   ArrayResize(BearArrowBuffer,LookBack + 2);
   ArrayResize(BullArrowBuffer,LookBack + 2);
   ArrayResize(ST_Stoc_Divergence_AI,LookBack + 2);
   ArrayResize(ST_Trigger_StocX,LookBack + 2);
   ArrayResize(ST_Trigger_Stoc3X,LookBack + 2);
   ArrayResize(TDAlignmentTrigger,LookBack + 2);
   
   ClearAllarrays_Triggers();

   for(int i=LookBack-5; i>=1 && i<actualCopied; i--)
     {
      PinBar(i); //1,2
      PinocioDbleBar(i); //6,5
      Fakey(i);// 7,8
      OutsideBar_Less_Conservative(i); //13,14
      FullBar(i);  //10,9

      //  Print("Triggers i=",i);
      //if( D_K_MOM[i] ==1 )
      //Print("FG Triggers :  i = ",i," D_K_MOM[i] = ",D_K_MOM[i]);
      //if( D_K_MOM[i] ==2 )
      //Print("FG Triggers :  i = ",i," D_K_MOM[i] = ",D_K_MOM[i]);
      if(SETUP[i] ==2) //ConsiderTriggerOnlyWhen(i,2) && 
        {

         if((TRIGGER[i] == 2 ||
             TRIGGER[i] == 6 ||
             TRIGGER[i] == 8 ||
             TRIGGER[i] == 14 ||
             TRIGGER[i] == 10)) //
            PriceActionBar[i]    = 2;
         if(Stocdivergence(i) == 2)
            ST_Stoc_Divergence[i]  = 2;
        }


      if( SETUP[i] ==1) //ConsiderTriggerOnlyWhen(i,1) &&
        {
         if((TRIGGER[i] == 1 ||
             TRIGGER[i] == 5 ||
             TRIGGER[i] == 7 ||
             TRIGGER[i] == 13 ||
             TRIGGER[i] == 9)) //
            PriceActionBar[i]    = 1;
         if(Stocdivergence(i) == 1)
            ST_Stoc_Divergence[i] = 1;
        }

      //      if(StocConvergence(i) == 1&& D_K_MOM[i] ==1)
      //         ST_Stoc_Divergence[i] = 1;//ST_Stoc_Convergence[i] = 1;
      //      if(StocConvergence(i) == 2 && D_K_MOM[i] ==2)
      //         ST_Stoc_Divergence[i]  = 2;//ST_Stoc_Convergence[i] = 2;
      //
      //      if(Get_Stoc_Divergence_AI(i) ==1&& D_K_MOM[i] ==1)
      //         ST_Stoc_Divergence[i] = 1; // ST_Stoc_Divergence_AI[i] = 1;
      //      if(Get_Stoc_Divergence_AI(i) ==2 && D_K_MOM[i] ==2)
      //         ST_Stoc_Divergence[i]  = 2;// ST_Stoc_Divergence_AI[i] = 2;

      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      StocX(i);
      Stoc3X(i);
     }
  }

//+------------------------------------------------------------------+
//| Populate Arrays Function                                         |
//+------------------------------------------------------------------+
void PopulateTomDeMarkArrays()
  {
   ArrayResize(ROC, LookBack + 2);
   ArrayResize(REI, LookBack + 2);
   ArrayResize(Pressure, LookBack + 2);
   ArrayResize(DeMarker, LookBack + 2);
   ArrayResize(DeMarkII, LookBack + 2);
   ArrayResize(TD_Alignment, LookBack + 2);
   ArrayResize(TD_AligmentResult, LookBack + 2);
   ArrayResize(TD_Aligment_InTrend_Result, LookBack + 2);


   TDPopulateArrays();

// Calculate TD alignment
   CalCulate_If_TD_Indicators_Extended();
   GetTDAlignment();
   GetTDAlignment_In_Trend();
   GetTDAlignmentTrigger();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ClearAllarrays_Triggers()
  {
// Call this after ArrayResize() for each array:
   ClearArray(PriceActionBar);
   ClearArray(TRIGGER);
   ClearArray(ST_Stoc_Convergence);
   ClearArray(ST_Stoc_Divergence);
   ClearArray(ST_Stoc_Divergence_AI);
   ClearArray(ST_Trigger_StocX);
   ClearArray(ST_Trigger_Stoc3X);
   ClearArray(TDAlignmentTrigger);
  }
//+------------------------------------------------------------------+
//| Object Rectangle - Quick reference
//|
//|
//+------------------------------------------------------------------+
void Rectangle(string name,datetime time,double price,datetime time1,double price1,color kleur)
  {
   if(1==2)
     {
      ObjectCreate(name,OBJ_RECTANGLE,0,time,price,time1,price1);
      ObjectSet(name,OBJPROP_COLOR,kleur);
     }
  }
//+------------------------------------------------------------------+
//| Pinbar                                                           |
//+------------------------------------------------------------------+
int PinBar(int N)
  {
   int detected=0;
// if((CandleHigh[N]-CandleLow[N])>50*Point )//&& (CandleHigh[N]-CandleLow[N])<200*Point)
     {
      if((CandleHigh[N]-CandleLow[N])*0.33>(CandleClose[N]-CandleLow[N]) ||
         (CandleHigh[N]-CandleLow[N])*0.33>(CandleOpen[N]-CandleLow[N]))
        {
         if((((CandleHigh[N]-CandleLow[N])*0.65<(CandleHigh[N]-CandleClose[N]) &&
              (CandleHigh[N]-CandleLow[N])*0.5<(CandleHigh[N]-CandleOpen[N]) &&
              CandleHigh[N]>CandleHigh[N+1] &&
              CandleHigh[N]>CandleHigh[N+2]) // &&
             // (CandleHigh[N]-CandleLow[N])*0.25<CandleHigh[N]-CandleHigh[N+1])// && (CandleHigh[N]-CandleLow[N])*0.95>iATR(NULL,0,4,1)
            )
            ||
            ((CandleHigh[N]-CandleLow[N])*0.78<(CandleHigh[N]-CandleClose[N]) &&
             (CandleHigh[N]-CandleLow[N])*0.4<(CandleHigh[N]-CandleOpen[N]) &&
             CandleHigh[N]>CandleHigh[N+1] &&
             CandleHigh[N]>CandleHigh[N+2]) // &&
            // (CandleHigh[N]-CandleLow[N])*0.25<CandleHigh[N]-CandleHigh[N+1]) //&& (CandleHigh[N]-CandleLow[N])*0.95>iATR(NULL,0,4,1)
           )
           {
            Rectangle(StringConcatenate("pinbar",N),CandleTime[N+1],CandleHigh[N],CandleTime[N-1],CandleLow[N],clrSalmon);
            TRIGGER[N]=2;
           }
        }
      if((CandleHigh[N]-CandleLow[N])*0.33>(CandleHigh[N]-CandleClose[N]) ||
         (CandleHigh[N]-CandleLow[N])*0.33>(CandleHigh[N]-CandleOpen[N]))
        {

         if((((CandleHigh[N]-CandleLow[N])*0.65<(CandleClose[N]-CandleLow[N]) &&
              (CandleHigh[N]-CandleLow[N])*0.5<(CandleOpen[N]-CandleLow[N]) &&
              CandleLow[N]<CandleLow[N+1] &&
              CandleLow[N]<CandleLow[N+2]) // &&
             // (CandleHigh[N]-CandleLow[N])*0.25<CandleLow[N+1]-CandleLow[N]//&& (CandleHigh[N]-CandleLow[N])*0.95>iATR(NULL,0,4,1)
            )
            ||
            ((CandleHigh[N]-CandleLow[N])*0.78<(CandleClose[N]-CandleLow[N]) &&
             (CandleHigh[N]-CandleLow[N])*0.4<(CandleOpen[N]-CandleLow[N]) &&
             CandleLow[N]<CandleLow[N+1] &&
             CandleLow[N]<CandleLow[N+2]  // &&
             //(CandleHigh[N]-CandleLow[N])*0.25<CandleLow[N+1]-CandleLow[N]// && (CandleHigh[N]-CandleLow[N])*0.95>iATR(NULL,0,4,1)
            ))
           {
            Rectangle(StringConcatenate("pinbar",N),CandleTime[N+1],CandleHigh[N],CandleTime[N-1],CandleLow[N],clrCornflowerBlue);
            TRIGGER[N]=1;
            // Print("TRIGGER[N]=1;");
           }
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
//| Pinocio Double Bar                                                     |
//+------------------------------------------------------------------+
int PinocioDbleBar(int N)
  {
   double Tweeser_lowest;
   double Tweeser_highest;
   if(CandleLow[N]<CandleLow[N+1])
     {
      Tweeser_lowest=CandleLow[N];
     }
   else
     {
      Tweeser_lowest=CandleLow[N+1];
     }
   if(CandleHigh[N]>CandleHigh[N+1])
     {
      Tweeser_highest=CandleHigh[N];
     }
   else
     {
      Tweeser_highest=CandleHigh[N+1];
     }

///#######################   AT TOP
   if(//CandleOpen[N+1]<CandleHigh[N+2] &&
//&& CandleClose[N1]>CandleHigh[N2] &&
      CandleLow[N+1]>=CandleLow[N+2] &&
//       CandleOpen[N]>CandleHigh[N2] &&
//  CandleClose[N]<CandleHigh[N+2] && CandleLow[N]>=CandleLow[N+2] &&

      CandleHigh[N+2]<(((Tweeser_highest-Tweeser_lowest)/1.5)+Tweeser_lowest) && // Nose stick out at least half a candle lenght past first eye
//  CandleOpen[N1]>=CandleClose[N]&&                                                      // Pinbar - negative
//   (CandleHigh[N]-CandleOpen[N])>(2*(CandleOpen[N]-CandleClose[N]))&&                               // 2nd Bar - nose = 2x Body
      ((Tweeser_highest-Tweeser_lowest)/3>CandleOpen[N+1]-Tweeser_lowest) &&
      ((Tweeser_highest-Tweeser_lowest)/3>CandleClose[N]-Tweeser_lowest) &&
      ((Tweeser_highest-Tweeser_lowest)/3>Tweeser_highest-CandleClose[N+1])
   ) // O/C in the low 1/3 of its bar range.
     {
      if(N!=0)
        {
         Rectangle(StringConcatenate("PinocioDbleBar",N),CandleTime[N+2],Tweeser_highest,CandleTime[N-1],Tweeser_lowest,clrLightCoral);
        }
      TRIGGER[N]=6;
     }

///#######################   At  BOTTOM
   if(
// CandleOpen[N+1]>CandleLow[N+2] &&
// //CandleClose[N1]<CandleLow[N2]  &&
      CandleHigh[N+1]<=CandleHigh[N+2] &&
// //    CandleClose[N]>CandleLow[N2] &&
// CandleClose[N]>CandleLow[N+2] && CandleHigh[N]<=CandleHigh[N+2] &&

      CandleLow[N+2]>(Tweeser_highest-((Tweeser_highest-Tweeser_lowest)/1.5)) && // Nose stick out at least half a candle lenght past first eye
// CandleOpen[N1]>=CandleClose[N]&&                                                       // 2nd Bar - Positive
      ((Tweeser_highest-Tweeser_lowest)/3>Tweeser_highest-CandleClose[N]) && // O/C in the upper 1/3 of its bar range.
      ((Tweeser_highest-Tweeser_lowest)/3>Tweeser_highest-CandleOpen[N+1]) &&
      (Tweeser_highest-Tweeser_lowest)/3>CandleClose[N+1]-Tweeser_lowest) // O/C in the upper 1/3 of its bar range.

     {
      if(N!=0)
        {
         Rectangle(StringConcatenate("PinocioDbleBar",N),CandleTime[N+2],Tweeser_highest,CandleTime[N-1],Tweeser_lowest,clrSkyBlue);
        }
      TRIGGER[N]=5;
     }
   return(0);
  }

//+------------------------------------------------------------------+
//| THE FAKEY                                                        |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Fakey(int N)
  {
   int N1,N2,N3,N4,N5;
   N1 = N+1;
   N2 = N1+1;
   N3 = N2+1;
   N4 = N3+1;

   string name="FakeyBar";
   double bodiesHigh;
   double bodiesLow;
//######################## Make the trade DOWN  ######################
   if(((CandleHigh[N] - CandleLow[N])*0.5 + CandleLow[N])> CandleClose[N])
     {
      if(CandleHigh[N2]>CandleHigh[N1] && CandleLow[N2]<CandleLow[N1] &&
         CandleHigh[N2]>CandleOpen[N] && CandleLow[N2]<CandleOpen[N] &&
         CandleHigh[N2]>CandleClose[N] && CandleLow[N2]<CandleClose[N] &&
         CandleHigh[N2]<CandleHigh[N])
        {
         //      Rectangle(StringConcatenate(name,N),Time[N2],CandleHigh[N2],Time[N-1],CandleLow[N2],clrPeachPuff);
         //   ArrowTimeless(StringConcatenate(name,N),Time[N],CandleHigh[N]+1000*Point,clrFireBrick,167);
         TRIGGER[N]=8;

        }
      if(CandleHigh[N3]>CandleHigh[N2] && CandleLow[N3]<CandleLow[N2] &&
         CandleHigh[N3]>CandleHigh[N1] && CandleLow[N3]<CandleLow[N1] &&
         CandleHigh[N3]>CandleOpen[N] && CandleLow[N3]<CandleOpen[N] &&
         CandleHigh[N3]>CandleClose[N] && CandleLow[N3]<CandleClose[N] &&
         CandleHigh[N3]<CandleHigh[N])
        {
         //     Rectangle(StringConcatenate(name,N),Time[N3],CandleHigh[N3],Time[N-1],CandleLow[N3],clrPeachPuff);
         //     ArrowTimeless(StringConcatenate(name,N),Time[N],CandleHigh[N]+1000*Point,clrPeachPuff,167);
         TRIGGER[N]=8;

        }
      if(CandleHigh[N4]>CandleHigh[N3] && CandleLow[N4]<CandleLow[N3] &&
         CandleHigh[N4]>CandleHigh[N2] && CandleLow[N4]<CandleLow[N2] &&
         CandleHigh[N4]>CandleHigh[N1] && CandleLow[N4]<CandleLow[N1] &&
         CandleHigh[N4]>CandleOpen[N] && CandleLow[N4]<CandleOpen[N] &&
         CandleHigh[N4]>CandleClose[N] && CandleLow[N4]<CandleClose[N] &&
         CandleHigh[N4]<CandleHigh[N])
        {
         //     Rectangle(StringConcatenate(name,N),Time[N4],CandleHigh[N4],Time[N-1],CandleLow[N4],clrPeachPuff);
         //     ArrowTimeless(StringConcatenate(name,N),Time[N],CandleHigh[N]+1000*Point,clrPeachPuff,167);
         TRIGGER[N]=8;

        }
      if(CandleHigh[N4+1]>CandleHigh[N4] && CandleLow[N4+1]<CandleLow[N4] &&
         CandleHigh[N4+1]>CandleHigh[N3] && CandleLow[N4+1]<CandleLow[N3] &&
         CandleHigh[N4+1]>CandleHigh[N2] && CandleLow[N4+1]<CandleLow[N2] &&
         CandleHigh[N4+1]>CandleHigh[N1] && CandleLow[N4+1]<CandleLow[N1] &&
         CandleHigh[N4+1]>CandleOpen[N] && CandleLow[N4+1]<CandleOpen[N] &&
         CandleHigh[N4+1]>CandleClose[N] && CandleLow[N4+1]<CandleClose[N] &&
         CandleHigh[N4+1]<CandleHigh[N])
        {
         //      Rectangle(StringConcatenate(name,N),Time[N4+1],CandleHigh[N4+1],Time[N-1],CandleLow[N4+1],clrPeachPuff);
         //       ArrowTimeless(StringConcatenate(name,N),Time[N],CandleHigh[N]+1000*Point,clrPeachPuff,167);
         TRIGGER[N]=8;

        }
     }
//######################## Going UP  ######################
   if(((CandleHigh[N] - CandleLow[N])*0.5 + CandleLow[N])< CandleClose[N])
     {
      if(CandleHigh[N2]>CandleHigh[N1] && CandleLow[N2]<CandleLow[N1] &&
         CandleHigh[N2]>CandleOpen[N] && CandleLow[N2]<CandleOpen[N] &&
         CandleHigh[N2]>CandleClose[N] && CandleLow[N2]<CandleClose[N] &&
         CandleLow[N2]>CandleLow[N])
        {
         //    Rectangle(StringConcatenate(name,N),Time[N2],CandleHigh[N2],Time[N-1],CandleLow[N2],clrLavender);
         //     ArrowTimeless(StringConcatenate(name,N),Time[N],CandleHigh[N]+1000*Point,clrLavender,167);
         TRIGGER[N]=7;

        }
      if(CandleHigh[N3]>CandleHigh[N2] && CandleLow[N3]<CandleLow[N2] &&
         CandleHigh[N3]>CandleHigh[N1] && CandleLow[N3]<CandleLow[N1] &&
         CandleHigh[N3]>CandleOpen[N] && CandleLow[N3]<CandleOpen[N] &&
         CandleHigh[N3]>CandleClose[N] && CandleLow[N3]<CandleClose[N] &&
         CandleLow[N3]>CandleLow[N])
        {
         //     Rectangle(StringConcatenate(name,N),Time[N3],CandleHigh[N3],Time[N-3],CandleLow[N3],clrLavender);
         //     ArrowTimeless(StringConcatenate(name,N),Time[N],CandleHigh[N]+1000*Point,clrLavender,167);
         TRIGGER[N]=7;

        }
      // Before accessing CandleHigh[N4], add this check:
      if(N4 >= 0 && N4 < ArraySize(CandleHigh))
        {
         // Safe to access CandleHigh[N4]
         double high_value = CandleHigh[N4];
        }
      else
        {
         Print("Warning: N4 (", N4, ") is out of bounds for CandleHigh array size ", ArraySize(CandleHigh));
         return(0); // or handle error appropriately
        }
      if(CandleHigh[N4]>CandleHigh[N3] && CandleLow[N4]<CandleLow[N3] &&
         CandleHigh[N4]>CandleHigh[N2] && CandleLow[N4]<CandleLow[N2] &&
         CandleHigh[N4]>CandleHigh[N1] && CandleLow[N4]<CandleLow[N1] &&
         CandleHigh[N4]>CandleOpen[N] && CandleLow[N4]<CandleOpen[N] &&
         CandleHigh[N4]>CandleClose[N] && CandleLow[N4]<CandleClose[N] &&
         CandleLow[N4]>CandleLow[N])
        {
         //     Rectangle(StringConcatenate(name,N),Time[N4],CandleHigh[N4],Time[N-1],CandleLow[N4],clrLavender);
         //    ArrowTimeless(StringConcatenate(name,N),Time[N],CandleHigh[N]+1000*Point,clrLavender,167);
         TRIGGER[N]=7;

        }
      if(CandleHigh[N4+1]>CandleHigh[N4] && CandleLow[N4+1]<CandleLow[N4] &&
         CandleHigh[N4+1]>CandleHigh[N3] && CandleLow[N4+1]<CandleLow[N3] &&
         CandleHigh[N4+1]>CandleHigh[N2] && CandleLow[N4+1]<CandleLow[N2] &&
         CandleHigh[N4+1]>CandleHigh[N1] && CandleLow[N4+1]<CandleLow[N1] &&
         CandleHigh[N4+1]>CandleOpen[N] && CandleLow[N4+1]<CandleOpen[N] &&
         CandleHigh[N4+1]>CandleClose[N] && CandleLow[N4+1]<CandleClose[N] &&
         CandleLow[N4+1]>CandleLow[N])
        {
         //     Rectangle(StringConcatenate(name,N),Time[N4+1],CandleHigh[N4+1],Time[N-1],CandleLow[N4+1],clrLavender);
         //      ArrowTimeless(StringConcatenate(name,N),Time[N],CandleHigh[N]+1000*Point,clrLavender,167);
         TRIGGER[N]=7;

        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
//| Outside bar - less conservative                                                          |
//+------------------------------------------------------------------+
int OutsideBar_Less_Conservative(int N)
  {
   int detected=0;
// if((CandleHigh[N]-CandleLow[N])>50*Point )//&& (CandleHigh[N]-CandleLow[N])<200*Point)
     {
      if((CandleHigh[N+1]<=CandleHigh[N]) &&
         //  CandleHigh[N]-CandleLow[N]>iATR(NULL,0,14,N) &&
         (CandleLow[N+1]>CandleClose[N]))
        {
           {
            //          Rectangle(StringConcatenate("OutsideBar_Less_Conservative (14)",N),Time[N+2],CandleHigh[N],Time[N-1],CandleLow[N],clrMaroon);
            TRIGGER[N]=14;
           }

        }
      if((CandleLow[N+1]>=CandleLow[N]) &&
         //     CandleHigh[N]-CandleLow[N]>iATR(NULL,0,14,N) &&
         CandleHigh[N+1]<(CandleClose[N]))
        {
           {
            //         Rectangle(StringConcatenate("OutsideBar_Less_Conservative (13)",N),Time[N+2],CandleHigh[N],Time[N-1],CandleLow[N],clrDarkGreen);
            TRIGGER[N]=13;
           }
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int FullBar(int N)
  {
   if((CandleHigh[N]-CandleLow[N])*0.1>CandleClose[N]-CandleLow[N])// && (CandleHigh[N]-CandleLow[N]) >iATR(NULL,0,4,1))
     {
      //   Print(" N = ",N," : Full bar ");
      Rectangle(StringConcatenate("Full bar",CandleTime[N]),CandleTime[N+1],CandleHigh[N],CandleTime[N-1],CandleLow[N],clrMaroon);
      TRIGGER[N]=10;
     }
   if((CandleHigh[N]-CandleLow[N])*0.1>CandleHigh[N]-CandleClose[N])//&& (CandleHigh[N]-CandleLow[N]) >iATR(NULL,0,4,1))
     {
      //    Print(" N = ",N," : Full bar ");
      Rectangle(StringConcatenate("Full bar",CandleTime[N]),CandleTime[N+1],CandleHigh[N],CandleTime[N-1],CandleLow[N],clrDarkGreen);
      TRIGGER[N]=9;
     }
   return(0);
  }
//+------------------------------------------------------------------+
//---
//---
//---Stoc  Divergences
//---
//---
//---
//|                                                                |
//+------------------------------------------------------------------+
int StocConvergence(int i)
  {
   double SwingValue = 0;
   double PriceFirstValue,PriceSecondValue;
   int Swing,SwingCnt;
   int ret = 0;

   double StocSwingValue = 0;
   double StocPriceFirstValue,StocPriceSecondValue;
   int StocSwing,StocSwingCnt;


// -STOC
//---
//---    AT The BOTTOM
//---
   if(ST_Stoc_K[i] > ST_Stoc_K[i+1] && ST_Stoc_K[i+2] > ST_Stoc_K[i+1])
     {
      StocSwingCnt = 0;
      for(int k = i; k<i+100 && k+2 < LookBack; k++)
        {
         if(ST_Stoc_K[k+1]>50)
           {
            StocSwingCnt =0;
            //    ArrowTimeless(StringConcatenate("RubberBand Low",k),Time[k],CandleLow[k],clrBlack,171);
            break;
           }
         if(ST_Stoc_K[k]  > ST_Stoc_K[k+1] && ST_Stoc_K[k+2] > ST_Stoc_K[k+1])
           {
            //StocPriceSecondValue = iStochastic(NULL,0,5,2,3,MODE_SMA,0,MODE_SIGNAL,k+1);
            //PriceSecondValue = MathMin(CandleClose[k+1],MathMin(CandleClose[k+2],CandleClose[k+3]));
            //StocSwing = k+1;
            StocSwingCnt = StocSwingCnt +1;
            //ArrowTimeless(StringConcatenate("RubberBand Low",k),Time[k],CandleLow[k],clrGreen,108);
            //TextTimeless(StringConcatenate("SwingEndoftrend",i),Time[i],CandleClose[i]+ 100*Point,clrBlack,7,StocSwingCnt,90.0);
           }
         if(StocSwingCnt >1)
           {
            //ArrowTimeless(StringConcatenate("RubberBand Low",i),Time[i],CandleLow[i],clrGreen,108);
            ret = 1;
            break;
           }

        }
     }
//  TextTimeless(StringConcatenate("SwingEndoftrend",i),Time[i],CandleClose[i]+ 100*Point,clrBlack,7,StocSwingCnt,90.0);



   StocSwingCnt = 0;
   if(ST_Stoc_K[i] < ST_Stoc_K[i+1] && ST_Stoc_K[i+2] < ST_Stoc_K[i+1])
     {
      for(int k = i ; k<i+100 && k+2<LookBack; k++)
        {
         if(ST_Stoc_K[k+1]<50)
           {
            break;
           }
         if(ST_Stoc_K[k] < ST_Stoc_K[k+1] && ST_Stoc_K[k+2] < ST_Stoc_K[k+1])
           {

            StocSwingCnt = StocSwingCnt +1;
            // TextTimeless(StringConcatenate("SwingEndoftrend",i),Time[i],CandleClose[i]+ 100*Point,clrBlack,7,StocSwingCnt,90.0);
           }
         if(StocSwingCnt >1)
           {
            //   ArrowTimeless(StringConcatenate("RubberBand Low",i),Time[i ],CandleHigh[i ]+300*Point,clrRed,108);
            ret = 2;
            break;
           }
        }
     }
   return(ret);
  }
//+------------------------------------------------------------------+
//|     Stoc                                                             |
//+------------------------------------------------------------------+
int Stocdivergence(int i)
  {
   double SwingValue = 0;
   double PriceFirstValue,PriceSecondValue;
   int Swing,SwingCnt;
   int ret = 0;

   double StocSwingValue = 0;
   double StocFirstValue,StocSecondValue;
   int StocSwing,StocSwingCnt;


//// -STOC
////--BUY
   if(ST_Stoc_K[i] <50 && ST_Stoc_K[i] > ST_Stoc_K[i+1])
     {
      for(int k = i; k<i+100 && k+2<LookBack; k++)
        {
         if(ST_Stoc_K[k+1]>50)
           {
            StocSwingCnt = 0;
            //  ArrowTimeless(StringConcatenate("RubberBand Low",k),Time[k ],CandleLow[k ],clrGreen,108);
            break;
           }
         if(ST_Stoc_K[k]  > ST_Stoc_K[k+1] && ST_Stoc_K[k+2] > ST_Stoc_K[k+1])
           {
            StocFirstValue = StocSecondValue;
            StocSecondValue =  ST_Stoc_K[k+1];
            PriceFirstValue = PriceSecondValue;
            PriceSecondValue = CandleClose[k+1];
            StocSwing = k+1;
            StocSwingCnt = StocSwingCnt +1;
            //   ArrowTimeless(StringConcatenate("RubberBand Low",k),Time[k],CandleLow[k],clrGreen,108);
           }
         if(StocSwingCnt == 2)
           {
            //    ArrowTimeless(StringConcatenate("RubberBand Low",i),Time[k],CandleLow[k],clrGreen,108);
            if(PriceFirstValue < PriceSecondValue && StocFirstValue > StocSecondValue)
              {
               ret = 1;
               break;
              }
           }
        }
     }
//-- SELL
   if(ST_Stoc_K[i] >50 && ST_Stoc_K[i] < ST_Stoc_K[i+1])
     {
      for(int k = i; k<i+100 && k+2<LookBack; k++)
        {
         if(ST_Stoc_K[k]<50)
           {
            StocSwingCnt = 0;
            // ArrowTimeless(StringConcatenate("RubberBand Low",k+1),Time[k+1],CandleHigh[k+1]+300*Point,clrRed,171);
            break;
           }
         if(ST_Stoc_K[k] < ST_Stoc_K[k+1] && ST_Stoc_K[k+2] < ST_Stoc_K[k+1])
           {
            StocFirstValue = StocSecondValue;
            StocSecondValue =  ST_Stoc_K[k+1];
            PriceFirstValue = PriceSecondValue;
            PriceSecondValue = CandleClose[k+1];// MathMax(CandleClose[k+1],MathMax(CandleClose[k+2],CandleClose[k+3]));
            StocSwing = k+1;
            StocSwingCnt = StocSwingCnt +1;
            //   ArrowTimeless(StringConcatenate("RubberBand Low",k+1),Time[k+1],CandleHigh[k+1]+300*Point,clrRed,108);
            //   TextTimeless(StringConcatenate("SwingEndoftrend",k+1),Time[k+1],CandleClose[k+1]+5000*_Point,clrBlack,7,StocSwingCnt,90.0);
            // break;
           }
         if(StocSwingCnt == 2)
           {
            if(PriceFirstValue > PriceSecondValue && StocFirstValue < StocSecondValue)
              {
               //  ArrowTimeless(StringConcatenate("RubberBand Low",i),Time[i ],CandleHigh[i ]+300*Point,clrRed,108);
               ret = 2;
               break;
              }
           }
        }
     }
   return(ret);
  }
//+------------------------------------------------------------------+
int DivergenceLookback = 30;
double BearishLevel = 55.0;
double BullishLevel = 45.0;
double OversoldConvergeLevel = 25.0;
double OverboughtConvergeLevel = 75.0;


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int  Get_Stoc_Divergence_AI(int i)
//for(int i = limit; i >= 0; i--)
  {
   double k = ST_Stoc_K[i];
   double k2;
   int ret =0;
//double d = iStochastic(NULL, 0, KPeriod, DPeriod, Slowing, MODE_SMA, 0, MODE_SIGNAL, i);
//KBuffer[i] = ST_Stoc_K[i];
//DBuffer[i] = ST_Stoc_D[i];

   BearArrowBuffer[i] = EMPTY_VALUE;
   BullArrowBuffer[i] = EMPTY_VALUE;
//OversoldConvBuffer[i] = EMPTY_VALUE;
//OverboughtConvBuffer[i] = EMPTY_VALUE;

   if(IsSwingHigh(i) && k > BearishLevel)
     {
      for(int j = i + 1; j < i + DivergenceLookback && j < LookBack - DivergenceLookback; j++)
        {
         double k2 = ST_Stoc_K[j];
         if(IsSwingHigh(j) && k2 > BearishLevel && CandleHigh[i] > CandleHigh[j] && k < k2 && AllStochAbove(i, j, BearishLevel))
           {
            BearArrowBuffer[i] = k;
            ret = 2;
            //     DrawLine("BearDivPrice_", Time[j], CandleHigh[j], Time[i], CandleHigh[i], Red, 0);
            //     DrawLine("BearDivInd_", Time[j], k2, Time[i], k, Red, win);
            break;
           }
        }
     }

   if(IsSwingLow(i) && k < BullishLevel)
     {
      for(int j = i + 1; j < i + DivergenceLookback && j < LookBack - DivergenceLookback; j++)
        {
         k2 = ST_Stoc_K[j];
         if(IsSwingLow(j) && k2 < BullishLevel && CandleLow[i] < CandleLow[j] && k > k2 && AllStochBelow(i, j, BullishLevel))
           {
            BullArrowBuffer[i] = k;
            ret =1;
            //   DrawLine("BullDivPrice_", Time[j], CandleLow[j], Time[i], CandleLow[i], Lime, 0);
            //   DrawLine("BullDivInd_", Time[j], k2, Time[i], k, Lime, win);
            break;
           }
        }
     }
   return (ret);
//   if(IsSwingLow(i) && k < OversoldConvergeLevel)
//     {
//      for(j = i + 1; j < i + DivergenceLookback && j < LookBack - 1; j++)
//        {
//         k2 = ST_Stoc_K[j];
//         if(IsSwingLow(j) && k2 < OversoldConvergeLevel && CandleLow[i] > CandleLow[j] && k < k2 && AllStochBelow(i, j, OversoldConvergeLevel))
//           {
//            OversoldConvBuffer[i] = k;
//            //DrawLine("OversoldConvPrice_", Time[j], CandleLow[j], Time[i], CandleLow[i], Orange, 0);
//            //DrawLine("OversoldConvInd_", Time[j], k2, Time[i], k, Orange, win);
//            break;
//           }
//        }
//     }
//
//   if(IsSwingHigh(i) && k > OverboughtConvergeLevel)
//     {
//      for(j = i + 1; j < i + DivergenceLookback && j < LookBack - 1; j++)
//        {
//         k2 = ST_Stoc_K[j];
//         if(IsSwingHigh(j) && k2 > OverboughtConvergeLevel && CandleHigh[i] < CandleHigh[j] && k > k2 && AllStochAbove(i, j, OverboughtConvergeLevel))
//           {
//            OverboughtConvBuffer[i] = k;
//            //DrawLine("OverboughtConvPrice_", Time[j], CandleHigh[j], Time[i], CandleHigh[i], Aqua, 0);
//            //DrawLine("OverboughtConvInd_", Time[j], k2, Time[i], k, Aqua, win);
//            break;
//           }
//        }
//     }
  }

//return (0);
//  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool AllStochAbove(int i1, int i2, double level)
  {
   for(int k = i1 + 1; k < i2; k++)
     {
      if(ST_Stoc_K[k] < level)
         return false;
     }
   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool AllStochBelow(int i1, int i2, double level)
  {
   for(int k = i1 + 1; k < i2; k++)
     {
      if(ST_Stoc_K[k] > level)
         return false;
     }
   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsSwingHigh(int i)
  {
   return (i > 0 && i < LookBack - 1 && CandleHigh[i] > CandleHigh[i + 1] && CandleHigh[i] > CandleHigh[i - 1]);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsSwingLow(int i)
  {
   return (i > 0 && i < LookBack - 1 && CandleLow[i] < CandleLow[i + 1] && CandleLow[i] < CandleLow[i - 1]);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|     Stoc                                                             |
//+------------------------------------------------------------------+
int Stoc3X(int i)
  {
//   int ret = 0;
   int count = 0;
////SELL
// BUY
   if(ST_Stoc_K[i]>70 && ST_Stoc_K[i]<ST_Stoc_D[i] &&
      ST_Stoc_K[i+1]>ST_Stoc_D[i+1])
     {
      for(int k = i; k<i+100 && k<actualCopied && k+2<LookBack; k++)
        {
         if(ST_Stoc_K[k]<50)
           {
            count = 0;
            break;
           }
         if(ST_Stoc_K[k]<ST_Stoc_D[k] &&
            ST_Stoc_K[k+1]>ST_Stoc_D[k+1])
           {
            //  ArrowTimeless(StringConcatenate("RubberBand Low",k ),Time[k ],Low[k ],clrGreen,108);
            count = count +1;
            //  break;
           }

         if(count == 3)
           {
            ST_Trigger_Stoc3X[i] =1;
            //     ret = 2;
            //  ArrowTimeless(StringConcatenate("RubberBand Low",k),Time[k ],Low[k ],clrYellow,108);
            break;
           }
        }
     }

// BUY
   if(ST_Stoc_K[i]<30 && ST_Stoc_K[i]>ST_Stoc_D[i] &&
      ST_Stoc_K[i+1]<ST_Stoc_D[i+1])
     {
      for(int k = i; k<i+100 && k+1<actualCopied && k+1<LookBack; k++)
        {
         if(ST_Stoc_K[k]>50)
           {
            count = 0;
            break;
           }
         if(ST_Stoc_K[k]>ST_Stoc_D[k] &&
            ST_Stoc_K[k+1]<ST_Stoc_D[i+1])
           {
            //  ArrowTimeless(StringConcatenate("RubberBand Low",k ),Time[k ],Low[k ],clrGreen,108);
            count = count +1;
            //  break;
           }

         if(count == 3)
           {
            ST_Trigger_Stoc3X[i] =2;
            //   ret = 1;
            //   ArrowTimeless(StringConcatenate("RubberBand Low",k),Time[k ],Low[k ],clrYellow,108);
            break;
           }
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|     Stoc                                                             |
//+------------------------------------------------------------------+
int StocX(int i)
  {
   int ret = 0;
   if(ST_Stoc_K[i+1]>80 && ST_Stoc_K[i]<ST_Stoc_D[i])
      for(int k = i; k<i+100 && k<actualCopied; k++)
        {
         //if(iStochastic(NULL,0,5,3,2,MODE_SMA,0,MODE_MAIN,k+1)<20)
           {
            if(ST_Stoc_K[k]<ST_Stoc_D[k] &&
               ST_Stoc_K[k+1] >ST_Stoc_D[k+1])
              {
               //   ArrowTimeless(StringConcatenate("RubberBand Low",k+1),Time[k+1],Low[k+1],clrGreen,108);
               ST_Trigger_StocX[i] =2;
               break;
              }
           }
        }
   if(ST_Stoc_K[i+1]<20 && ST_Stoc_K[i]>ST_Stoc_D[i])
      for(int k = i; k<i+100 && k<actualCopied; k++)
        {
         //if(iStochastic(NULL,0,5,3,2,MODE_SMA,0,MODE_MAIN,k+1)<20)
           {
            if(ST_Stoc_K[k]>ST_Stoc_D[k] &&
               ST_Stoc_K[k+1]<ST_Stoc_D[k+1])
              {
               //   ArrowTimeless(StringConcatenate("RubberBand Low",k+1),Time[k+1],Low[k+1],clrGreen,108);
               ST_Trigger_StocX[i] =1;
               break;
              }
           }
        }


   return(ret);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalCulate_If_TD_Indicators_Extended()
  {
   int count = 0;
   for(int i=LookBack; i>0; i--)
     {
      count = 0;
      if(DeMarker[i] > DeMarkerI_Max)
         count = count + 1;
      if(DeMarker[i] < DeMarkerI_Min)
         count = count - 1;

      if(DeMarkII[i] > DeMarkerII_Max)
         count = count + 1;
      if(DeMarkII[i] < DeMarkerII_Min)
         count = count - 1;
      if(ROC[i] > ROC_Max)
         count = count + 1;
      if(ROC[i] < ROC_Min)
         count = count - 1;

      if(REI[i] > REI_Max)
         count = count + 1;
      if(REI[i] < REI_Min)
         count = count - 1;

      if(Pressure[i] > Pressure_Max)
         count = count + 1;
      if(Pressure[i] < Pressure_Min)
         count = count - 1;

      TD_Alignment[i] = count;

      //  Print(" i = ",i," TD_Alignment[i] = ",TD_Alignment[i]);
     }
  }

//+------------------------------------------------------------------+
//| TD Populate Arrays Function                                      |
//+------------------------------------------------------------------+
int TDPopulateArrays()
  {
   int vPeriodROC = ROC_vPeriod;
   int vPeriod_DMII = DeMarkerII_vPeriod;
   int vPeriod_DMI = DeMarkerI_vPeriod;
   int vPeriod_pressure = Pressure_vPeriod;
   int vPeriod_REI = REI_vPeriod;
   int idx;
   double Value, Value2, Var1, Var2, Var3, Var4, num_zero, num_zero2;

// REI calculation - fixed loop direction
   for(int i = LookBack; i > vPeriod_REI && i+1 < actualCopied ; i--)
     {
      Value = 0;
      for(int d = 0; d < vPeriod_REI; d++)
        {
         idx = i + d;
         if(idx + 8 >= Bars ||  idx+10 > LookBack || idx+10 > actualCopied)
            continue;  // Safety check

         if(CandleHigh[idx+2] < CandleClose[idx+7] && CandleHigh[idx+2] < CandleClose[idx+8] &&
            CandleHigh[idx] < CandleLow[idx+5] && CandleHigh[idx] < CandleLow[idx+6])
           {
            num_zero = 0;
           }
         else
           {
            num_zero = 1;
           }

         if(CandleLow[idx+2] > CandleClose[idx+7] && CandleLow[idx+2] > CandleClose[idx+8] &&
            CandleLow[idx] > CandleHigh[idx+5] && CandleLow[idx] > CandleHigh[idx+6])
           {
            num_zero2 = 0;
           }
         else
           {
            num_zero2 = 1;
           }

         Var1 = CandleHigh[idx] - CandleHigh[idx+2];
         Var2 = CandleLow[idx] - CandleLow[idx+2];
         Value = (num_zero * num_zero2 * Var1) + (num_zero * num_zero2 * Var2) + Value;
        }

      Value2 = 0;
      for(int d = 0; d < vPeriod_REI; d++)
        {
         idx = i + d;
         if(idx + 2 >= Bars ||  idx+10 > LookBack || idx+10 > actualCopied)
            continue;  // Safety check

         Var3 = MathAbs(CandleHigh[idx] - CandleHigh[idx+2]);
         Var4 = MathAbs(CandleLow[idx] - CandleLow[idx+2]);
         Value2 = Var3 + Var4 + Value2;
        }

      if(Value2 > 0)
        {
         REI[i] = (Value / Value2) * 100;
        }

     }

// Pressure calculation - fixed
   for(int i = LookBack; i > vPeriod_pressure && i+vPeriod_pressure < actualCopied; i--)
     {
      double Accumilated = 0;
      double VolumeAccumulated = 0;
      double Dist_Accumilated = 0;
      double Accumilation = 0;
      double Distrubution = 0;

      for(int d = 0; d < vPeriod_pressure && d < actualCopied; d++)
        {
         idx = i + d;
         Accumilation = 0;
         Distrubution = 0;
         if(idx >= Bars ||  idx+10 > LookBack || idx+10 > actualCopied)
            continue;  // Safety check
         // CHECK_ARRAY_INDEX(CandleVolume,idx);
         long tickVol = CandleVolume[idx];

         if(CandleHigh[idx] - CandleLow[idx] > 0)
           {
            if(CandleClose[idx] - CandleOpen[idx] > 0)
              {
               Accumilation = ((CandleClose[idx] - CandleOpen[idx]) / (CandleHigh[idx] - CandleLow[idx])) * tickVol;
               Accumilated = Accumilated + Accumilation;
              }
            else
              {
               Distrubution = ((CandleOpen[idx] - CandleClose[idx]) / (CandleHigh[idx] - CandleLow[idx])) * tickVol;
               Dist_Accumilated = Distrubution + Dist_Accumilated;
              }
           }
         VolumeAccumulated = VolumeAccumulated + tickVol;
        }

      if(VolumeAccumulated > 0)
        {
         Pressure[i] = ((Accumilated / VolumeAccumulated) + (1 - (Dist_Accumilated / VolumeAccumulated))) * 50;
        }
     }

// DeMarker calculation - fixed
   for(int i = LookBack; i > vPeriod_DMI && i + vPeriod_DMI < actualCopied; i--)
     {

      num_zero = 0;
      num_zero2 = 0;
      Value = 0;
      Value2 = 0;
      for(int d=i; d<(i + vPeriod_DMI) && i + vPeriod_DMI < LookBack; d++)
        {
         if(CandleHigh[d] > CandleHigh[d+1])
           {
            num_zero = CandleHigh[d] - CandleHigh[d+1];
           }
         else
           {
            num_zero = 0;
           }


         if(CandleLow[d] > CandleLow[d+1])
           {
            num_zero2 = 0;
           }
         else
           {
            num_zero2 =  CandleLow[d+1] - CandleLow[d];
           }

         Value = Value +  num_zero;
         Value2 = Value2 +  num_zero2;
        }


      if(((Value+Value2)/(vPeriod_DMI))>0)
        {
         DeMarker[i] = ((Value/(vPeriod_DMI)) / (((Value+Value2)/(vPeriod_DMI))))*100;

        }
     }

//DeMarkIIv3
   for(int i=LookBack; i>0 && i + vPeriod_DMII < LookBack; i--)
     {
      num_zero = 0;
      num_zero2 = 0;
      Value = 0;
      Value2 = 0;
      for(int d=i; d<(i + vPeriod_DMII) && i + vPeriod_DMII < LookBack; d++)
        {
         num_zero = ((CandleHigh[d] - CandleClose[d+1]) + (CandleClose[d]-CandleLow[d]));

         if(num_zero < 0)
           {
            num_zero = 0;
           }


         num_zero2 = (CandleClose[d+1] - CandleLow[d]) + (CandleHigh[d]-CandleClose[d]);

         if(num_zero2 <0)
           {
            num_zero2 = 0;
           }


         Value = Value +  num_zero;
         Value2 = Value2 +  num_zero2;
        }


      if(((Value+Value2)/(vPeriod_DMII)) >0)
        {
         DeMarkII[i] = ((Value/(vPeriod_DMII)) / (((Value+Value2)/(vPeriod_DMII))))*100;

        }
     }
//ROCv3

   for(int i=LookBack; i>0 && i+vPeriodROC < LookBack; i--)
     {

      for(int d=i; d<i + (vPeriodROC) && i+vPeriodROC < LookBack; d++)
        {
         if(CandleClose[i+vPeriodROC] > 0)
           {
            ROC[i] = (CandleClose[i] / CandleClose[i+vPeriodROC])*100;

           }
        }

     }
   return(0);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetTDAlignment()
  {
   int TDOverBought = 0;
   int TDOverSold = 0;

   for(int i=LookBack; i>0; i--)
     {
      //  Print(" i = ",i," TD_Alignment[i+1]  = ", TD_Alignment[i+1]);
      if(TD_Alignment[i+1] > 3.5 && TD_Alignment[i+1] > TD_Alignment[i] && TDOverBought == 0)
        {
         TDOverBought = 1;
        }

      if(TDOverBought == 1 && TD_Alignment[i+1] < 2 && TD_Alignment[i] < 2)
        {
         TDOverBought = 0;
        }

      if(TD_Alignment[i+1] < -3.5 && TD_Alignment[i+1] < TD_Alignment[i] && TDOverSold == 0)
        {
         TDOverSold = 1;
        }
      if(TDOverSold == 1 && TD_Alignment[i+1] > -2 && TD_Alignment[i] > -2)
        {
         TDOverSold = 0;
        }

      if(TDOverSold == 1)
        {
         TD_AligmentResult[i] = 1;
        }
      if(TDOverBought == 1)
        {
         TD_AligmentResult[i] = 2;
        }
      //      Print(" i = ",i," TD_AligmentResult[i] = ",TD_AligmentResult[i]);
     }

   return(0); // ADDED: Missing return statement
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetTDAlignment_In_Trend()
  {
   int TDOverBought = 0;
   int TDOverSold = 0;

   for(int i=MaxBars; i>0; i--)
     {
      if(TD_Alignment[i+1] > 2.5 && TD_Alignment[i+1] > TD_Alignment[i] && TDOverBought == 0  && MT_MA150[i] < MT_MA150[i+1]  && ST_MA50[i] < ST_MA50[i+1] && MT_MACD_DAD[i] < MT_MACD_DAD[i+1])
        {
         TDOverBought = 1;
        }

      if(TDOverBought == 1 && TD_Alignment[i+1] < 0.5 && TD_Alignment[i] < 0.5)
        {
         TDOverBought = 0;
        }

      if(TD_Alignment[i+1] < -2.5 && TD_Alignment[i+1] < TD_Alignment[i] && TDOverSold == 0  && MT_MA150[i] > MT_MA150[i+1]  && ST_MA50[i] > ST_MA50[i+1] && MT_MACD_DAD[i] > MT_MACD_DAD[i+1])
        {
         TDOverSold = 1;
        }
      if(TDOverSold == 1 && TD_Alignment[i+1] > -0.5 && TD_Alignment[i] > -0.5)
        {
         TDOverSold = 0;
        }

      if(TDOverSold == 1)
        {
         TD_Aligment_InTrend_Result[i] = 1;
        }
      if(TDOverBought == 1)
        {
         TD_Aligment_InTrend_Result[i] = 2;
        }
     }
   return(0); // ADDED: Missing return statement
  }
//+------------------------------------------------------------------+
//|  When The MT stoc is not at an extreme level the Cycle and momentum indicator must be at least a Count of 5.
//+------------------------------------------------------------------+
int GetStrongerCycleMoM(int i,int GetSetup, int Required)
  {
   int Count = 0;
   int MOM_or_K = 0;
   if(GetSetup == 1)
     {
      if((MT_MACD_MOM[i] > MT_MACD_MOM[i+1]) || (MT_Stoc_K[i] > MT_Stoc_K[i+1]))          // Must have MT_K or MT_MOM                      //ha6u[i] ||  ha13u[i]
         MOM_or_K = 1;

      if(MT_Stoc_K[i] > MT_Stoc_K[i+1])
         Count++;
      if(MT_Stoc_D[i] > MT_Stoc_D[i+1])
         Count++;
      if(MT_MACD_MOM[i] > MT_MACD_MOM[i+1])
         Count++;
      if(ST_Stoc_D[i] > ST_Stoc_D[i+1] && MOM_or_K == 1)
         Count++;
      if(ST_MACD_MOM[i] > ST_MACD_MOM[i+1] && MOM_or_K == 1)
         Count++;
      if(ST_Stoc_K[i] > ST_Stoc_K[i+1] && MOM_or_K == 1 && ST_Stoc_D[i] < 55)
         Count++;
     }
   if(GetSetup == 2)
     {
      if((MT_MACD_MOM[i] < MT_MACD_MOM[i+1]) || (MT_Stoc_K[i] < MT_Stoc_K[i+1]))          // Must have MT_K or MT_MOM                      //ha6u[i] ||  ha13u[i]
         MOM_or_K = 2;

      if(MT_Stoc_K[i] < MT_Stoc_K[i+1])
         Count++;
      if(MT_Stoc_D[i] < MT_Stoc_D[i+1])
         Count++;
      if(MT_MACD_MOM[i] < MT_MACD_MOM[i+1])
         Count++;
      if(ST_Stoc_D[i] < ST_Stoc_D[i+1] && MOM_or_K == 2)
         Count++;
      if(ST_MACD_MOM[i] < ST_MACD_MOM[i+1] && MOM_or_K == 2)
         Count++;
      if(ST_Stoc_K[i] < ST_Stoc_K[i+1] && MOM_or_K == 2 && ST_Stoc_D[i] > 45)
         Count++;
     }
// Return based on MA count vs threshold
   if(Count >= Required)
      return 1;
   else
      return 0;

  }
//+------------------------------------------------------------------+
//|  When The MT stoc is not at an extreme level the Cycle and momentum indicator must be at least a Count of 5.
//+------------------------------------------------------------------+
int ConsiderTriggerOnlyWhen(int i, int GetSetup)
  {
   if(GetSetup == 1)
     {
      // Must have %K: ST_Stoc_K rising with conditions
      if( ST_Stoc_K[i] > ST_Stoc_K[i+1] &&
         (MT_MACD_MOM[i] > MT_MACD_MOM[i+1] || MT_Stoc_K[i] > MT_Stoc_K[i+1]) &&
         ST_Stoc_D[i] < 55)
        {
//         // ha14u: Setup at extreme - MT_UP_Stoc[i] == 1
//         bool setupAtExtreme = ( MT_UP_Stoc[i] == 1);
//
//         // ha3d: Setup against trend (inverted for BUY check)
//         bool againstTrendDown = (  MT_MA150[i] < MT_MA150[i+1] && CandleClose[i] < MT_MA150[i]);
//
//         // ha4d: Setup against momentum (inverted for BUY check)
//         // First check if we have setup (at extreme or not at extreme)
//         bool hasSetup = ( (MT_UP_Stoc[i] == 1 || MT_UP_Stoc[i] != 1));
//         bool againstMomentumDown = (hasSetup && MT_Divergence_DOWN_Counter[i] > 0);
//
//         // ha15u: ST_MOM rising
//         bool stMomUp = (  ST_MACD_MOM[i] > ST_MACD_MOM[i+1] &&
//                         (MT_MACD_MOM[i] > MT_MACD_MOM[i+1] || MT_Stoc_K[i] > MT_Stoc_K[i+1]));

         if((GetStrongerCycleMoM(i, 1, 5) == 1))// ||  // Setup but not @ extreme: needs at least 5 Stoc+Mom indicators
            //(setupAtExtreme && againstTrendDown == false && againstMomentumDown == false && stMomUp))  // Setup @ Extreme: no extra confirmation
            return 1;
        }
     }

   if(GetSetup == 2)
     {
      // Must have %K: ST_Stoc_K falling with conditions
      if(  ST_Stoc_K[i] < ST_Stoc_K[i+1] &&
         (MT_MACD_MOM[i] < MT_MACD_MOM[i+1] || MT_Stoc_K[i] < MT_Stoc_K[i+1]) &&
         ST_Stoc_D[i] > 45)
        {
//         // ha14d: Setup at extreme - MT_Down_Stoc[i] == 2
//         bool setupAtExtreme = (  MT_Down_Stoc[i] == 2);
//
//         // ha3u: Setup against trend (inverted for SELL check)
//         bool againstTrendUp = ( MT_MA150[i] > MT_MA150[i+1] && CandleClose[i] > MT_MA150[i]);
//
//         // ha4u: Setup against momentum (inverted for SELL check)
//         // First check if we have setup (at extreme or not at extreme)
//         bool hasSetup = (  (MT_Down_Stoc[i] == 2 || MT_Down_Stoc[i] != 2));
//         bool againstMomentumUp = (hasSetup && MT_Divergence_UP_Counter[i] > 0);
//
//         // ha15d: ST_MOM falling
//         bool stMomDown = ( ST_MACD_MOM[i] < ST_MACD_MOM[i+1] &&
//                           (MT_MACD_MOM[i] < MT_MACD_MOM[i+1] || MT_Stoc_K[i] < MT_Stoc_K[i+1]));

         if((GetStrongerCycleMoM(i, 2, 5) == 1) )//||  // Setup but not @ extreme: needs at least 5 Stoc+Mom indicators
         //   (setupAtExtreme && againstTrendUp == false && againstMomentumUp == false && stMomDown))  // Setup @ Extreme: no extra confirmation
            return 1;
        }
     }
   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
 
int GetTDAlignmentTrigger()
  {
   for(int i=LookBack; i>0; i--)
     {  
    if( SETUP[i] ==1 && ConsiderTriggerOnlyWhen(i,1) ) //&& D_K_MOM[i] ==1
     {
      if((TD_Aligment_InTrend_Result[i] == 1 ||  TD_AligmentResult[i] == 1) && (TD_Alignment[i] - TD_Alignment[i+2]) > 1)
        {
         TDAlignmentTrigger[i] = 1;
        }
     }
   if(SETUP[i] ==2  && ConsiderTriggerOnlyWhen(i,2)  )//&& D_K_MOM[i] ==2
     {
      if((TD_Aligment_InTrend_Result[i] == 2 ||  TD_AligmentResult[i] == 2) && (TD_Alignment[i+2] - TD_Alignment[i]) > 1)
        {
         TDAlignmentTrigger[i] = 2;
        }
     }
     }
      return(0);
  }
//+------------------------------------------------------------------+
