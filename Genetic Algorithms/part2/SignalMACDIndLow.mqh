﻿//+------------------------------------------------------------------+
//|                                             SignalMACDIndLow.mqh |
//|                                            Copyright 2018, NOVTS |
//|                                                 http://novts.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, NOVTS"
#property link      "http://novts.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#include <Expert\Signal\SignalMACD.mqh>

class CSignalMACDIndLow : public CSignalMACD
  {
  public: 
  virtual int       BarsCalculatedInd();                  
  virtual int       LongConditionInd(int ind, int amount, double &low[], double &high[]);
  virtual int       ShortConditionInd(int ind, int amount, double &low[], double &high[]);
  protected:
  int               StateMain(int ind,double &Main[]);
  bool              ExtState(int ind, double &Main[], double &low[], double &high[]);
  };
 //+------------------------------------------------------------------+
//| Refresh indicators.                                               |
//+------------------------------------------------------------------+  
int CSignalMACDIndLow:: BarsCalculatedInd(){
m_MACD.Refresh();
int bars = m_MACD.BarsCalculated();
return bars;
}

//+------------------------------------------------------------------+
//| "Voting" that price will grow.                                   |
//+------------------------------------------------------------------+
int CSignalMACDIndLow::LongConditionInd(int idx, int amount, double &low[], double &high[])
  {
  
int handle=m_MACD.Handle();
double         MACDBuffer[]; 
double         SignalBuffer[];  
   if(CopyBuffer(handle,0,0,amount,MACDBuffer)<0) 
     { 
      PrintFormat("Failed to copy data from iMA indicator, error code %d",GetLastError()); 
     
      return(-1); 
     }
     if(CopyBuffer(handle,1,0,amount,SignalBuffer)<0) 
     { 
      PrintFormat("Failed to copy data from iMA indicator, error code %d",GetLastError()); 
      
      return(-1); 
     }  
   ArraySetAsSeries(MACDBuffer,true);
   ArraySetAsSeries(SignalBuffer,true); 
   int result=0;
   
   double DiffMain = MACDBuffer[idx]-MACDBuffer[idx+1];
   double DiffMain_1 = MACDBuffer[idx+1]-MACDBuffer[idx+2];
   double State = MACDBuffer[idx]- SignalBuffer[idx];
   double State_1 = MACDBuffer[idx+1]- SignalBuffer[idx+1];
   
//--- check direction of the main line
   if(DiffMain>0.0)
     {
      //--- the main line is directed upwards, and it confirms the possibility of price growth
      if(IS_PATTERN_USAGE(0))
         result=m_pattern_0;      // "confirming" signal number 0
      //--- if the model 1 is used, look for a reverse of the main line
      if(IS_PATTERN_USAGE(1) && DiffMain_1<0.0)
         result=m_pattern_1;      // signal number 1
      //--- if the model 2 is used, look for an intersection of the main and signal line
      if(IS_PATTERN_USAGE(2) && State>0.0 && State_1<0.0)
         result=m_pattern_2;      // signal number 2
      //--- if the model 3 is used, look for an intersection of the main line and the zero level
      if(IS_PATTERN_USAGE(3) && MACDBuffer[idx]>0.0 && MACDBuffer[idx+1]<0.0)
         result=m_pattern_3;      // signal number 3
      //--- if the models 4 or 5 are used and the main line turned upwards below the zero level, look for divergences
      if((IS_PATTERN_USAGE(4) || IS_PATTERN_USAGE(5)) && MACDBuffer[idx]<0.0)
        {
         //--- perform the extended analysis of the oscillator state
         ExtState(idx, MACDBuffer, low, high);
         //--- if the model 4 is used, look for the "divergence" signal
         if(IS_PATTERN_USAGE(4) && CompareMaps(1,1)) // 0000 0001b
            result=m_pattern_4;   // signal number 4
         //--- if the model 5 is used, look for the "double divergence" signal
         if(IS_PATTERN_USAGE(5) && CompareMaps(0x11,2)) // 0001 0001b
            return(m_pattern_5);  // signal number 5
        }
     }
//--- return the result
   return(result);
  }
//+------------------------------------------------------------------+
//| "Voting" that price will fall.                                   |
//+------------------------------------------------------------------+
int CSignalMACDIndLow::ShortConditionInd(int idx, int amount, double &low[], double &high[])
  {
   int handle=m_MACD.Handle();
double         MACDBuffer[]; 
double         SignalBuffer[];  
   if(CopyBuffer(handle,0,0,amount,MACDBuffer)<0) 
     { 
      PrintFormat("Failed to copy data from iMA indicator, error code %d",GetLastError()); 
     
      return(-1); 
     }
     if(CopyBuffer(handle,1,0,amount,SignalBuffer)<0) 
     { 
      PrintFormat("Failed to copy data from iMA indicator, error code %d",GetLastError()); 
      
      return(-1); 
     }  
   ArraySetAsSeries(MACDBuffer,true);
   ArraySetAsSeries(SignalBuffer,true); 
   int result=0;
   
   double DiffMain = MACDBuffer[idx]-MACDBuffer[idx+1];
   double DiffMain_1 = MACDBuffer[idx+1]-MACDBuffer[idx+2];
   double State = MACDBuffer[idx]- SignalBuffer[idx];
   double State_1 = MACDBuffer[idx+1]- SignalBuffer[idx+1];
   
//--- check direction of the main line
   if(DiffMain<0.0)
     {
      //--- main line is directed downwards, confirming a possibility of falling of price
      if(IS_PATTERN_USAGE(0))
         result=m_pattern_0;      // "confirming" signal number 0
      //--- if the model 1 is used, look for a reverse of the main line
      if(IS_PATTERN_USAGE(1) && DiffMain_1>0.0)
         result=m_pattern_1;      // signal number 1
      //--- if the model 2 is used, look for an intersection of the main and signal line
      if(IS_PATTERN_USAGE(2) && State<0.0 && State_1>0.0)
         result=m_pattern_2;      // signal number 2
      //--- if the model 3 is used, look for an intersection of the main line and the zero level
      if(IS_PATTERN_USAGE(3) && MACDBuffer[idx]<0.0 && MACDBuffer[idx+1]>0.0)
         result=m_pattern_3;      // signal number 3
      //--- if the models 4 or 5 are used and the main line turned downwards above the zero level, look for divergences
      if((IS_PATTERN_USAGE(4) || IS_PATTERN_USAGE(5)) && MACDBuffer[idx]>0.0)
        {
         //--- perform the extended analysis of the oscillator state
         ExtState(idx, MACDBuffer, low, high);
         //--- if the model 4 is used, look for the "divergence" signal
         if(IS_PATTERN_USAGE(4) && CompareMaps(1,1)) // 0000 0001b
            result=m_pattern_4;   // signal number 4
         //--- if the model 5 is used, look for the "double divergence" signal
         if(IS_PATTERN_USAGE(5) && CompareMaps(0x11,2)) // 0001 0001b
            return(m_pattern_5);  // signal number 5
        }
     }
//--- return the result
   return(result);
  }
//+------------------------------------------------------------------+  
//+------------------------------------------------------------------+
//| Check of the oscillator state.                                   |
//+------------------------------------------------------------------+
int CSignalMACDIndLow::StateMain(int ind, double &Main[])
  {
   int    res=0;
   double var;
//---
   for(int i=ind;;i++)
     {
      if(Main[i+1]==EMPTY_VALUE)
         break;
      var=(Main[i]-Main[i+1]);
      if(res>0)
        {
         if(var<0)
            break;
         res++;
         continue;
        }
      if(res<0)
        {
         if(var>0)
            break;
         res--;
         continue;
        }
      if(var>0)
         res++;
      if(var<0)
         res--;
     }
//---
   return(res);
  }
//+------------------------------------------------------------------+
//| Extended check of the oscillator state consists                  |
//| in forming a bit-map according to certain rules,                 |
//| which shows ratios of extremums of the oscillator and price.     |
//+------------------------------------------------------------------+
bool CSignalMACDIndLow::ExtState(int ind, double &Main[], double &low[], double &high[])
  {
//--- operation of this method results in a bit-map of extremums
//--- practically, the bit-map of extremums is an "array" of 4-bit fields
//--- each "element of the array" definitely describes the ratio
//--- of current extremums of the oscillator and the price with previous ones
//--- purpose of bits of an element of the analyzed bit-map
//--- bit 3 - not used (always 0)
//--- bit 2 - is equal to 1 if the current extremum of the oscillator is "more extreme" than the previous one
//---         (a higher peak or a deeper valley), otherwise - 0
//--- bit 1 - not used (always 0)
//--- bit 0 - is equal to 1 if the current extremum of price is "more extreme" than the previous one
//---         (a higher peak or a deeper valley), otherwise - 0
//--- in addition to them, the following is formed:
//--- array of values of extremums of the oscillator,
//--- array of values of price extremums and
//--- array of "distances" between extremums of the oscillator (in bars)
//--- it should be noted that when using the results of the extended check of state,
//--- you should consider, which extremum of the oscillator (peak or valley)
//--- is the "reference point" (i.e. was detected first during the analysis)
//--- if a peak is detected first then even elements of all arrays
//--- will contain information about peaks, and odd elements will contain information about valleys
//--- if a valley is detected first, then respectively in reverse
   int    pos=ind,off,index;
   uint   map;                 // intermediate bit-map for one extremum
//---
   m_extr_map=0;
   for(int i=0;i<10;i++)
     {
      off=StateMain(pos, Main);
      if(off>0)
        {
         //--- minimum of the oscillator is detected
         pos+=off;
         m_extr_pos[i]=pos;
         m_extr_osc[i]=Main[pos];
         if(i>1)
           {
           index = ArrayMinimum (low,pos-2,5);
            m_extr_pr[i]=low[index];
            //--- form the intermediate bit-map
            map=0;
            if(m_extr_pr[i-2]<m_extr_pr[i])
               map+=1;  // set bit 0
            if(m_extr_osc[i-2]<m_extr_osc[i])
               map+=4;  // set bit 2
            //--- add the result
            m_extr_map+=map<<(4*(i-2));
           }
         else
         index = ArrayMinimum (low,pos-1,4);
            m_extr_pr[i]=low[index];
        }
      else
        {
         //--- maximum of the oscillator is detected
         pos-=off;
         m_extr_pos[i]=pos;
         m_extr_osc[i]=Main[pos];
         if(i>1)
           {
           index = ArrayMaximum (high,pos-2,5);
            m_extr_pr[i]=high[index];
            //--- form the intermediate bit-map
            map=0;
            if(m_extr_pr[i-2]>m_extr_pr[i])
               map+=1;  // set bit 0
            if(m_extr_osc[i-2]>m_extr_osc[i])
               map+=4;  // set bit 2
            //--- add the result
            m_extr_map+=map<<(4*(i-2));
           }
         else
         index = ArrayMaximum (high,pos-1,4);
            m_extr_pr[i]=high[index];
        }
     }
//---
   return(true);
  }
