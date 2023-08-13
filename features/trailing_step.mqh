#include "enum.mqh"
#include "send_order.mqh"
#include "get_trade_price.mqh"

input string description_trailling_stop      = "       Trailing Step Data";// ...

input turn active_trailing_step              = ON; // Trailing Step

string trailing_step_string;

void trailing_step_type_sell_general(double position_price_open, double position_take_profit, double position_current_price, double position_stop_lose, ulong position_ticket)
    {
        double distance_tp_po = position_price_open - position_take_profit;
    
        for(int i=0; i < ArraySize(risk); i++)
            {
                if(position_current_price < (position_price_open - risk[i]))
                    {
                        double new_sl = position_price_open - risk[i] + risk[0];
                        
                        if(new_sl < position_stop_lose)
                            {
                                trade.PositionModify(position_ticket, new_sl, position_take_profit);
                            }                     
                        
                        break;
                    }
            }        
    
    }

void trailing_step_type_buy_general(double position_price_open, double position_take_profit, double position_current_price, double position_stop_lose, ulong position_ticket)
    {
        double distance_tp_po = position_take_profit - position_price_open;
        
        for(int i=0; i < ArraySize(risk); i++)
            {
                if(position_current_price > (position_price_open + risk[i]))
                    {
                        double new_sl = position_price_open + risk[i] - risk[0];
                        
                        if(new_sl > position_stop_lose)
                            {
                                trade.PositionModify(position_ticket, new_sl, position_take_profit);
                            }
                            
                        break;
                    }
            }
    }

void trailing_step_ontick()
    {
        if(active_trailing_step == ON)
            {
                for(int i = PositionsTotal() -1; i >= 0; i--)
                    {
                        ulong position_ticket = PositionGetTicket(i);
                                                    
                        if(PositionSelectByTicket(position_ticket))
                            {
                                if(PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == magic_number)
                                    {
                                        double position_price_open = PositionGetDouble(POSITION_PRICE_OPEN);
                                                           
                                        double position_stop_lose = PositionGetDouble(POSITION_SL);
                                                           
                                        double position_take_profit = PositionGetDouble(POSITION_TP);
                                                           
                                        double position_current_price = PositionGetDouble(POSITION_PRICE_CURRENT);

                                        if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
                                            {
                                                trailing_step_type_sell_general(position_price_open, position_take_profit, position_current_price, position_stop_lose, position_ticket);                  
                                            }
                                        
                                        if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
                                            {
                                                trailing_step_type_buy_general(position_price_open, position_take_profit, position_current_price, position_stop_lose, position_ticket);
                                            }    
                                    }
                            }
                    }
            }
            
        trailing_step_string =
               "\n"                                    +
               "      Trailing Step               "    + EnumToString( active_trailing_step )                          +
               "\n";        
    }

/*

input turn active_trailing_stop              = ON; // Trailing Step

input type_trailing_stop trailing_stop       = BREAK; // Type

input double init_percent_trailing_stop      = 33.3; // Percent Line to Start

input double deviation_percent_trailing_stop = 0; // Deviation

string trailing_stop_string;


void trailing_stop_type_sell_general(double position_price_open, double position_take_profit, double position_current_price, double position_stop_lose, ulong position_ticket)
    {
        double distance_tp_po = position_price_open - position_take_profit;
                                                    
        double init_line_trailing_stop = position_price_open - distance_tp_po * (init_percent_trailing_stop / 100);
                                                                      
        double deviation_trailing_stop = distance_tp_po * (deviation_percent_trailing_stop / 100);
                                                                      
        if(trailing_stop == TRAILING)
            {                  
                double new_sl = position_current_price + deviation_trailing_stop;
                                                                                 
                if(new_sl < position_stop_lose && position_current_price < init_line_trailing_stop)
                    {
                        trade.PositionModify(position_ticket, new_sl, position_take_profit);
                    }
            }
                                                                                                
        if(trailing_stop == BREAK)
            {       
                double new_sl = position_price_open - deviation_trailing_stop;
                                                                                 
                if(new_sl < position_stop_lose && position_current_price < init_line_trailing_stop)
                    {
                        trade.PositionModify(position_ticket, new_sl, position_take_profit);
                    }
            }    
    }

void trailing_stop_type_buy_general(double position_price_open, double position_take_profit, double position_current_price, double position_stop_lose, ulong position_ticket)
    {
        double distance_tp_po = position_take_profit - position_price_open;
                                                                      
        double init_line_trailing_stop = position_price_open + distance_tp_po * (init_percent_trailing_stop / 100);
                                                                      
        double deviation_trailing_stop = distance_tp_po * (deviation_percent_trailing_stop / 100);
                                                                      
        if(trailing_stop == TRAILING)
                    {
                        double new_sl = position_current_price - deviation_trailing_stop;
                                                                             
                        if(new_sl > position_stop_lose && position_current_price > init_line_trailing_stop)
                            {
                                trade.PositionModify(position_ticket, new_sl, position_take_profit);
                            }
                    }
                                                                      
        if(trailing_stop == BREAK)
            {
                double new_sl = position_price_open + deviation_trailing_stop;
                                                                                 
                if(new_sl > position_stop_lose && position_current_price > init_line_trailing_stop)
                    {
                        trade.PositionModify(position_ticket, new_sl, position_take_profit);
                    }
            }    
    }

void trailing_stop_ontick()
    {
        if(active_trailing_stop == ON)
            {
                for(int i = PositionsTotal() -1; i >= 0; i--)
                    {
                        ulong position_ticket = PositionGetTicket(i);
                                                    
                        if(PositionSelectByTicket(position_ticket))
                            {
                                if(PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == magic_number)
                                    {
                                        double position_price_open = PositionGetDouble(POSITION_PRICE_OPEN);
                                                           
                                        double position_stop_lose = PositionGetDouble(POSITION_SL);
                                                           
                                        double position_take_profit = PositionGetDouble(POSITION_TP);
                                                           
                                        double position_current_price = PositionGetDouble(POSITION_PRICE_CURRENT);

                                        if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
                                            {
                                                trailing_stop_type_sell_general(position_price_open, position_take_profit, position_current_price, position_stop_lose, position_ticket);                  
                                            }
                                        
                                        if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
                                            {
                                                trailing_stop_type_buy_general(position_price_open, position_take_profit, position_current_price, position_stop_lose, position_ticket);
                                            }    
                                    }
                            }
                    }
            }
            
        trailing_stop_string =
               "\n"                                    +
               "      Trailing Stop               "    + EnumToString( active_trailing_stop )                          +
               "\n"
               "      Type                         "   + EnumToString( trailing_stop )                                 +
               "\n"
               "      Percent Init Line          "     + DoubleToString( init_percent_trailing_stop, 1 ) + "%"         +
               "\n"
               "      Deviation                    "   + DoubleToString( deviation_percent_trailing_stop, 1 ) + "%"    +
               "\n";            
    }
    
*/    