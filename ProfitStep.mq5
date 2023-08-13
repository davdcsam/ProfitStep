//+------------------------------------------------------------------+
//|                                                   ProfitStep.mq5 |
//|                                         Copyright 2023, DavdCsam |
//|                                      https://github.com/davdcsam |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, DavdCsam"
#property link      "https://github.com/davdcsam"

#include "features\\timer.mqh"
#include "features\\send_order.mqh"
#include "features\\get_section.mqh"
#include "features\\remove_position_order.mqh"
#include "features\\trailing_step.mqh"

void operation_module()
    {
        if(get_section_state == ON && get_section_first_time_flag == ON && get_section_day_current == OFF)
            {
                send_order_risk_calc(high_higher, low_lower);
            
                if(price_close < high_higher)
                    {
                        buy_stop_function(high_higher);
                    } else
                        {
                            buy_function();
                        }
                    
                if(price_close > low_lower)
                    {
                        sell_stop_function(low_lower);
                    } else 
                        {
                            sell_function();
                        }
                
                all_orders_deployed = ON;
               
                flag_first_history = ON;                         
            }   
    }

int OnInit()
    {

        return(INIT_SUCCEEDED);
    }

void OnDeinit(const int reason) {Comment("");}

void OnTick()
    {
        timer_ontick();
    
        get_section_ontick();
        
        get_trade_price_ontick();
        
        send_order_ontick();
       
        trailing_step_ontick();
        
        remove_position_order_ontick(high_higher, low_lower);
        
        operation_module();
        
        Comment(
               timer_string,
               get_section_string,
               send_order_string,
               trailing_step_string,
               remove_position_order_string
       );
    }
    

void OnTradeTransaction(const MqlTradeTransaction& transaction, const MqlTradeRequest& request, const MqlTradeResult& result)
    {
         remove_order_ttoa(transaction.type);
         
         remove_order_ttha(transaction.type);
    }    