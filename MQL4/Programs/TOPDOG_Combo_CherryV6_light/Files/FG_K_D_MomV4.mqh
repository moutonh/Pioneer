//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+

#property strict
#include <FG_Global_VariablesV5.mqh>

//MT_K_Angle
//MT_D_Angle
//MT_MOM
//ST_K_Angle
//ST_D_Angle
//ST_MOM
//+------------------------------------------------------------------+
void Populate_K_D_MOM_Arrays()//string symbol, ENUM_TIMEFRAMES timeframe
  {

   ArrayResize(MT_K_Angle,LookBack + 2);
   ArrayResize(MT_D_Angle,LookBack + 2);
   ArrayResize(MT_MOM_Angle,LookBack + 2);
   ArrayResize(ST_K_Angle,LookBack + 2);
   ArrayResize(ST_D_Angle,LookBack + 2);
   ArrayResize(ST_MOM_Angle,LookBack + 2);

   ClearAllarrays_K_D_Mom();
   int Valid_K_MOMsetup;


   for(int i= LookBack-100 ; i>0; i--)
     {

      Valid_K_MOMsetup =0;

      //  if(MT_MACD_MOM[i] > MT_MACD_MOM[i+1] || MT_Stoc_K[i] > MT_Stoc_K[i+1])
      if(SETUP[i] ==1 && (MT_MACD_MOM[i] > MT_MACD_MOM[i+1] || MT_Stoc_K[i] > MT_Stoc_K[i+1]))
         Valid_K_MOMsetup =1;
      if(SETUP[i] ==2 && (MT_MACD_MOM[i] < MT_MACD_MOM[i+1] || MT_Stoc_K[i] < MT_Stoc_K[i+1]))
         Valid_K_MOMsetup =2;

      if(Valid_K_MOMsetup ==1 && ST_Stoc_K[i] > ST_Stoc_K[i+1]  && ST_Stoc_D[i] < 55) // && SETUP[i] ==1
         ST_K_Angle[i] = 1;

      if(Valid_K_MOMsetup ==2 && ST_Stoc_K[i] < ST_Stoc_K[i+1] && ST_Stoc_D[i] > 45)  // && SETUP[i] ==2
         ST_K_Angle[i] = 2;

      if(ST_Stoc_D[i] > ST_Stoc_D[i+1]     && Valid_K_MOMsetup ==1)  //&& SETUP[i] ==1 &&(MT_MACD_MOM[i] > MT_MACD_MOM[i+1] || MT_Stoc_K[i] > MT_Stoc_K[i+1]))
         ST_D_Angle[i] = 1;
      //
      if(ST_Stoc_D[i] < ST_Stoc_D[i+1]    && Valid_K_MOMsetup ==2)  //&& SETUP[i] ==2
         ST_D_Angle[i] = 2;

      if(Valid_K_MOMsetup ==1 && ST_MACD_MOM[i] > ST_MACD_MOM[i+1])   //  && SETUP[i] ==1
         ST_MOM_Angle[i] = 1;

      if(Valid_K_MOMsetup ==2 && ST_MACD_MOM[i] < ST_MACD_MOM[i+1])  //  && SETUP[i] ==2
         ST_MOM_Angle[i] = 2;



      if(MT_Stoc_K[i] > MT_Stoc_K[i+1]&& SETUP[i] ==1)  //  
         MT_K_Angle[i] = 1;
      if(MT_Stoc_K[i] < MT_Stoc_K[i+1]&& SETUP[i] ==2)  //  
         MT_K_Angle[i] = 2;

      if(MT_Stoc_D[i] > MT_Stoc_D[i+1]&& SETUP[i] ==1)   // 
         MT_D_Angle[i] = 1;
      if(MT_Stoc_D[i] < MT_Stoc_D[i+1]&& SETUP[i] ==2)  // 
         MT_D_Angle[i] = 2;

      if(MT_MACD_MOM[i] > MT_MACD_MOM[i+1]&& SETUP[i] ==1)  //  
         MT_MOM_Angle[i] = 1;
      if(MT_MACD_MOM[i] < MT_MACD_MOM[i+1]&& SETUP[i] ==2) //  
         MT_MOM_Angle[i] = 2;




     }
  }
//+------------------------------------------------------------------+
//// Define this helper function once in your indicator file
//void ClearArray(double &arr[])
//  {
//   int size = ArraySize(arr);
//   for(int i = 0; i < size; i++)
//      arr[i] = 0;
//  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ClearAllarrays_K_D_Mom()
  {
// Call this after ArrayResize() for each array:
   ClearArray(MT_K_Angle);
   ClearArray(MT_D_Angle);
   ClearArray(MT_MOM_Angle);
   ClearArray(ST_K_Angle);
   ClearArray(ST_D_Angle);
   ClearArray(ST_MOM_Angle);
  }
//+------------------------------------------------------------------+
