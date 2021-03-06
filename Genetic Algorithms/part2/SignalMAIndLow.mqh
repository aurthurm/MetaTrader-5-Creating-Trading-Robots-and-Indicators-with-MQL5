﻿//+------------------------------------------------------------------+
//|                                               SignalMAIndLow.mqh |
//|                                            Copyright 2018, NOVTS |
//|                                                 http://novts.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, NOVTS"
#property link      "http://novts.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#include <Expert\Signal\SignalMA.mqh>
class CSignalMAIndLow : public CSignalMA
  {
  public:
  virtual int       BarsCalculatedInd();
  virtual int       LongConditionInd(int ind, int amount, double close, double open, double low);
  virtual int       ShortConditionInd(int ind, int amount, double close, double open, double high);                  
  };
  
//+------------------------------------------------------------------+
//| Refresh indicators.                                               |
//+------------------------------------------------------------------+  
int CSignalMAIndLow:: BarsCalculatedInd(){
m_ma.Refresh();
int bars = m_ma.BarsCalculated();
return bars;
}
//+------------------------------------------------------------------+
//| "Voting" that price will grow.                                   |
//+------------------------------------------------------------------+
int CSignalMAIndLow::LongConditionInd(int idx, int amount, double close, double open, double low)
  {
  int handle=m_ma.Handle();
  double         iMABuffer[]; 
   if(CopyBuffer(handle,0,0,amount,iMABuffer)<0) 
     { 
      PrintFormat("Failed to copy data from iMA indicator, error code %d",GetLastError()); 
      
      return(-1); 
     } 
   ArraySetAsSeries(iMABuffer,true); 
  
   int result=0;
   
   double DiffCloseMA = close - iMABuffer[idx];
   double DiffOpenMA = open - iMABuffer[idx];
   double DiffMA = iMABuffer[idx] - iMABuffer[idx+1];
   double DiffLowMA = low - iMABuffer[idx];
//--- analyze positional relationship of the close price and the indicator at the first analyzed bar
   if(DiffCloseMA<0.0)
     {
      //--- the close price is below the indicator
      if(IS_PATTERN_USAGE(1) && DiffOpenMA>0.0 && DiffMA>0.0)
        {
         //--- the open price is above the indicator (i.e. there was an intersection), but the indicator is directed upwards
         result=m_pattern_1;
         //--- consider that this is an unformed "piercing" and suggest to enter the market at the current price
         m_base_price=0.0;
        }
     }
   else
     {
      //--- the close price is above the indicator (the indicator has no objections to buying)
      if(IS_PATTERN_USAGE(0))
         result=m_pattern_0;
      //--- if the indicator is directed upwards
      if(DiffMA>0.0)
        {
         if(DiffOpenMA<0.0)
           {
            //--- if the model 2 is used
            if(IS_PATTERN_USAGE(2))
              {
               //--- the open price is below the indicator (i.e. there was an intersection)
               result=m_pattern_2;
               //--- suggest to enter the market at the "roll back"
               m_base_price=m_symbol.NormalizePrice(iMABuffer[idx]);
              }
           }
         else
           {
            //--- if the model 3 is used and the open price is above the indicator
            if(IS_PATTERN_USAGE(3) && DiffLowMA<0.0)
              {
               //--- the low price is below the indicator
               result=m_pattern_3;
               //--- consider that this is a formed "piercing" and suggest to enter the market at the current price
               m_base_price=0.0;
              }
           }
        }
     }
//--- return the result
   return(result);
  }
//+------------------------------------------------------------------+
//| "Voting" that price will fall.                                   |
//+------------------------------------------------------------------+
int CSignalMAIndLow::ShortConditionInd(int idx, int amount, double close, double open, double high)
  {
  int handle=m_ma.Handle();
  double         iMABuffer[]; 
   if(CopyBuffer(handle,0,0,amount,iMABuffer)<0) 
     {  
      PrintFormat("Failed to copy data from iMA indicator, error code %d",GetLastError()); 
      
      return(-1); 
     } 
   ArraySetAsSeries(iMABuffer,true);  

   int result=0;
   
   double DiffCloseMA = close - iMABuffer[idx];
   double DiffOpenMA = open - iMABuffer[idx];
   double DiffMA = iMABuffer[idx] - iMABuffer[idx+1];
   double DiffHighMA = high - iMABuffer[idx];
   
//--- analyze positional relationship of the close price and the indicator at the first analyzed bar
   if(DiffCloseMA>0.0)
     {
      //--- the close price is above the indicator
      if(IS_PATTERN_USAGE(1) && DiffOpenMA<0.0 && DiffMA<0.0)
        {
         //--- the open price is below the indicator (i.e. there was an intersection), but the indicator is directed downwards
         result=m_pattern_1;
         //--- consider that this is an unformed "piercing" and suggest to enter the market at the current price
         m_base_price=0.0;
        }
     }
   else
     {
      //--- the close price is below the indicator (the indicator has no objections to buying)
      if(IS_PATTERN_USAGE(0))
         result=m_pattern_0;
      //--- the indicator is directed downwards
      if(DiffMA<0.0)
        {
         if(DiffOpenMA>0.0)
           {
            //--- if the model 2 is used
            if(IS_PATTERN_USAGE(2))
              {
               //--- the open price is above the indicator (i.e. there was an intersection)
               result=m_pattern_2;
               //--- suggest to enter the market at the "roll back"
               m_base_price=m_symbol.NormalizePrice(iMABuffer[idx]);
              }
           }
         else
           {
            //--- if the model 3 is used and the open price is below the indicator
            if(IS_PATTERN_USAGE(3) && DiffHighMA>0.0)
              {
               //--- the high price is above the indicator
               result=m_pattern_3;
               //--- consider that this is a formed "piercing" and suggest to enter the market at the current price
               m_base_price=0.0;
              }
           }
        }
     }
//--- return the result
   return(result);
  }
//+------------------------------------------------------------------+
