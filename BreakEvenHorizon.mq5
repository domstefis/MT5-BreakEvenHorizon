//+------------------------------------------------------------------+
//| BreakEvenHorizon.mq5                                             |
//| Copyright 2025 @ domstefis                                       |
//| Distributed under MIT License - Free to use, modify, and share   |
//| Post your version freely on Reddit or elsewhere with attribution |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, domstefis"
#property link      "https://github.com/domstefis"
#property version   "1.01"
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
//| Updates the break-even line based on open positions and lot sizes|
//+------------------------------------------------------------------+
void UpdateBreakEvenLine()
{
   int positionCount = 0;
   double sum_buy_lot = 0.0;
   double sum_buy_lot_price = 0.0;
   double sum_sell_lot = 0.0;
   double sum_sell_lot_price = 0.0;
   
   // Scan all open positions
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket)) continue;
      
      if(PositionGetString(POSITION_SYMBOL) == _Symbol)
      {
         positionCount++;
         double lot_size = PositionGetDouble(POSITION_VOLUME);
         double open_price = PositionGetDouble(POSITION_PRICE_OPEN);
         int pos_type = (int)PositionGetInteger(POSITION_TYPE);
         
         if(pos_type == POSITION_TYPE_BUY)
         {
            sum_buy_lot += lot_size;
            sum_buy_lot_price += lot_size * open_price;
         }
         else if(pos_type == POSITION_TYPE_SELL)
         {
            sum_sell_lot += lot_size;
            sum_sell_lot_price += lot_size * open_price;
         }
      }
   }
   
   // Update visualization based on position count and net lot
   if(positionCount > 1)
   {
      double net_lot = sum_buy_lot - sum_sell_lot;
      if(MathAbs(net_lot) > 1e-5) // Avoid division by zero or near-zero
      {
         double numerator = sum_buy_lot_price - sum_sell_lot_price;
         g_breakEvenPrice = numerator / net_lot;
         g_breakEvenPrice = NormalizeDouble(g_breakEvenPrice, _Digits);
         DrawBreakEvenLine(g_breakEvenPrice);
      }
      else
      {
         RemoveBreakEvenLine();
      }
   }
   else
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
