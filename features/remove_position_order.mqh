#include "enum.mqh"
#include "send_order.mqh"
#include "get_section.mqh"
#include "close_position.mqh"

input string description_remove_position_order = "       Remove Pending Order Data";// ...

input turn remove_pending_order_when_first_done = OFF; // Remove Pending Order When First Done

input turn remove_order_out_section = ON; // Remove Order Out Section

input int remove_order_out_section_hour = 19; // Time in Hours

input int remove_order_out_section_minute = 30; // Time in Minute

input turn remove_position_out_section = ON; // Close Position Out Section

input int remove_position_out_section_hour = 22; // Time in Hours

input int remove_position_out_section_minute = 30; // Time in Minute

turn flag_first_history = OFF;

turn all_orders_deployed = OFF;

turn all_orders_saved = OFF;

ulong last_order_active[2];

double last_order_value[2];

ulong current_order_active[2];

double current_order_value[2];

string remove_position_order_string;

void remove_order_ttoa(ENUM_TRADE_TRANSACTION_TYPE transaction_type)
    {
        if(transaction_type == TRADE_TRANSACTION_ORDER_ADD && all_orders_deployed == ON && remove_pending_order_when_first_done == ON)
            {
               for(int i=0; i < OrdersTotal(); i++)
                    {
                        ulong ticket = OrderGetTicket(i);
                                
                        if(OrderSelect(ticket))
                            {
                                last_order_active[i] = ticket;
                            }
                    }

                all_orders_deployed = OFF;
            }
    }        
    
void remove_order_ttha(ENUM_TRADE_TRANSACTION_TYPE transaction_type)
    {
        if(transaction_type == TRADE_TRANSACTION_HISTORY_ADD && flag_first_history == ON && remove_pending_order_when_first_done == ON)
            {
               for(int i=0; i < OrdersTotal(); i++)
                    {
                        ulong ticket = OrderGetTicket(i);
                                
                        if(OrderSelect(ticket))
                            {
                                current_order_active[i] = ticket;
                            }
                    }
                    
               all_orders_saved = ON;
               
               flag_first_history = OFF;
            }
    }
    
void remove_position_order_ontick(double line_up, double line_down)
    {        
        if(all_orders_saved == ON && remove_pending_order_when_first_done == ON)
            {
                double line_middle = (line_up + line_down) / 2;
                
                where location;
                
                if(iClose(_Symbol, PERIOD_CURRENT, 0) < line_middle)
                    {
                        location = DOWN;
                    } else location = UP;

                for(int i=0;i<ArraySize(current_order_active);i++)
                    {
                        ulong ticket = current_order_active[i];

                        if(OrderSelect(ticket))
                            {
                                current_order_value[i] = OrderGetDouble(ORDER_PRICE_OPEN);
                            }

                        if(location == DOWN)
                            {
                                if(current_order_value[i] > line_middle && current_order_active[i] != 0)
                                    {
                                        trade.OrderDelete(current_order_active[i]);
                                    }
                            } else if(location == UP)
                                        {
                                            if(current_order_value[i] < line_middle && current_order_active[i] != 0)
                                                {
                                                    trade.OrderDelete(current_order_active[i]);
                                                }   
                                     }
                                     
                        ArrayPrint(current_order_active);                                     
                    }

                all_orders_saved = OFF;             
            }
        
        if(remove_order_out_section == ON)
            {
                if(remove_order_out_section_hour < Hours && remove_order_out_section_minute < Minutes)
                    {
                        for(int i=0; i < OrdersTotal(); i++)
                            {
                                ulong ticket = OrderGetTicket(i);
                                        
                                trade.OrderDelete(ticket);
                            }                        
                    }
                    
                if(remove_position_out_section_hour < Hours && remove_position_out_section_minute < Minutes)
                    {
                        close_position_magic_symbol();
                    }
                    
                if(Hours == 1 || Hours == 2)
                    {
                        for(int i=0; i < OrdersTotal(); i++)
                            {
                                ulong ticket = OrderGetTicket(i);
                                        
                                trade.OrderDelete(ticket);
                            }
                            
                        close_position_magic_symbol();
                    }                    
            }   
            
        remove_position_order_string =
            "\n" +
            "      Remove then First Done " + EnumToString(remove_pending_order_when_first_done) +
            "\n"
            "      Remove Order Out Section " + EnumToString(remove_order_out_section) + " After " + IntegerToString(remove_order_out_section_hour) + ":" + IntegerToString(remove_order_out_section_minute) +
            "\n"
            "      Close Position Out Section " + EnumToString(remove_position_out_section) + " After " + IntegerToString(remove_position_out_section_hour) + ":" + IntegerToString(remove_position_out_section_minute) +
            "\n";           
    }