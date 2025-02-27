//+------------------------------------------------------------------+
//| BreakEvenHorizon.mq5                                             |
//| Copyright 2025 @ domstefis                                       |
//| Distributed under MIT License - Free to use, modify, and share   |
//| Post freely on Reddit or elsewhere with attribution              |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, domstefis"
#property link      "https://github.com/domstefis"
#property version   "1.00"
#property strict
#property description "Draws a horizontal line at the break-even point between oldest and newest open positions"

//--- Input Parameters
input int    InpUpdateInterval = 5;         // Update Interval (seconds)
input color  InpLineColor      = clrGreen;  // Break-Even Line Color
input int    InpLineWidth      = 2;         // Break-Even Line Width (1-5)
input ENUM_LINE_STYLE InpLineStyle = STYLE_SOLID; // Break-Even Line Style

//--- Global Variables
const string BREAK_EVEN_LINE = "BreakEvenHorizon";
int          g_timerCounter   = 0;
bool         g_isLineVisible  = false;
double       g_breakEvenPrice = 0.0;

//+------------------------------------------------------------------+
//| Expert Advisor Initialization                                    |
//+------------------------------------------------------------------+
int OnInit()
{
   EventSetTimer(1);           // Set 1-second timer
   g_timerCounter = InpUpdateInterval; // Trigger immediate update
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert Advisor Deinitialization                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ObjectDelete(0, BREAK_EVEN_LINE); // Clean up line object
   EventKillTimer();                // Remove timer
}

//+------------------------------------------------------------------+
//| Timer Handler                                                    |
//+------------------------------------------------------------------+
void OnTimer()
{
   g_timerCounter++;
   if(g_timerCounter >= InpUpdateInterval)
   {
      g_timerCounter = 0;
      UpdateBreakEvenLine();
   }
}

//+------------------------------------------------------------------+
//| Chart Event Handler                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, 
                 const double &dparam, const string &sparam)
{
   if(id == CHARTEVENT_CHART_CHANGE && g_isLineVisible && g_breakEvenPrice != 0)
   {
      DrawBreakEvenLine(g_breakEvenPrice);
   }
}

//+------------------------------------------------------------------+
//| Updates the break-even line based on open positions              |
//+------------------------------------------------------------------+
void UpdateBreakEvenLine()
{
   int positionCount = 0;
   datetime oldestTime = 0;
   datetime newestTime = 0;
   double oldestPrice = 0.0;
   double newestPrice = 0.0;
   
   // Scan all open positions
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket)) continue;
      
      if(PositionGetString(POSITION_SYMBOL) == _Symbol)
      {
         positionCount++;
         datetime posTime = (datetime)PositionGetInteger(POSITION_TIME);
         double posPrice = PositionGetDouble(POSITION_PRICE_OPEN);
         
         if(oldestTime == 0 || posTime < oldestTime)
         {
            oldestTime = posTime;
            oldestPrice = posPrice;
         }
         
         if(newestTime == 0 || posTime > newestTime)
         {
            newestTime = posTime;
            newestPrice = posPrice;
         }
      }
   }
   
   // Update visualization based on position count
   if(positionCount > 1)
   {
      g_breakEvenPrice = NormalizeDouble((oldestPrice + newestPrice) / 2.0, _Digits);
      DrawBreakEvenLine(g_breakEvenPrice);
   }
   else if(g_isLineVisible)
   {
      RemoveBreakEvenLine();
   }
}

//+------------------------------------------------------------------+
//| Draws or updates the break-even line                             |
//+------------------------------------------------------------------+
void DrawBreakEvenLine(double price)
{
   ObjectDelete(0, BREAK_EVEN_LINE);
   if(ObjectCreate(0, BREAK_EVEN_LINE, OBJ_HLINE, 0, 0, price))
   {
      ObjectSetInteger(0, BREAK_EVEN_LINE, OBJPROP_COLOR, InpLineColor);
      ObjectSetInteger(0, BREAK_EVEN_LINE, OBJPROP_WIDTH, fmax(1, fmin(5, InpLineWidth)));
      ObjectSetInteger(0, BREAK_EVEN_LINE, OBJPROP_STYLE, InpLineStyle);
      ObjectSetString(0, BREAK_EVEN_LINE, OBJPROP_TEXT, 
                     "Break-Even Horizon: " + DoubleToString(price, _Digits));
      g_isLineVisible = true;
      ChartRedraw();
   }
}

//+------------------------------------------------------------------+
//| Removes the break-even line from the chart                       |
//+------------------------------------------------------------------+
void RemoveBreakEvenLine()
{
   ObjectDelete(0, BREAK_EVEN_LINE);
   g_isLineVisible = false;
   g_breakEvenPrice = 0.0;
   ChartRedraw();
}

//+------------------------------------------------------------------+
