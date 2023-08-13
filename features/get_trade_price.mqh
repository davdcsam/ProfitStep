#include "enum.mqh"
#include "get_section.mqh"

input int get_trade_price_calc_minutes = 30; // Range Minutes

turn get_trade_price_flag = ON;

double low_lower;

double high_higher;

void get_trade_price_ontick()
    {
        if(get_section_state == ON && get_trade_price_flag == ON)
            { 
                int index_high = iHighest(_Symbol, PERIOD_M1, MODE_HIGH, get_trade_price_calc_minutes, 0);
                
                int index_low = iLowest(_Symbol, PERIOD_M1, MODE_LOW, get_trade_price_calc_minutes, 0);
                
                high_higher = iHigh(_Symbol, PERIOD_M1, index_high);
                
                low_lower = iLow(_Symbol, PERIOD_M1, index_low);
                
                Print( "Index Candle Highest ", IntegerToString(index_high), " ", DoubleToString(high_higher, 1), " and Index Lowest ", IntegerToString(index_low), " ", DoubleToString(low_lower));
   
                get_trade_price_flag = OFF;
            }
    }