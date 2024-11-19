connect_debug_port u_ila_0/probe13 [get_nets [list p_1_in]]

connect_debug_port u_ila_0/probe16 [get_nets [list RXD_IBUF]]

connect_debug_port u_ila_0/probe13 [get_nets [list p_1_in]]

connect_debug_port u_ila_0/probe1 [get_nets [list {CNT_RX_bit[0]} {CNT_RX_bit[1]} {CNT_RX_bit[2]}]]
connect_debug_port u_ila_0/probe2 [get_nets [list {CNT_OVER_CLK[0]} {CNT_OVER_CLK[1]} {CNT_OVER_CLK[2]} {CNT_OVER_CLK[3]} {CNT_OVER_CLK[4]} {CNT_OVER_CLK[5]} {CNT_OVER_CLK[6]} {CNT_OVER_CLK[7]} {CNT_OVER_CLK[8]} {CNT_OVER_CLK[9]}]]
connect_debug_port u_ila_0/probe5 [get_nets [list {RX_DATA[0]} {RX_DATA[1]} {RX_DATA[2]} {RX_DATA[3]} {RX_DATA[4]} {RX_DATA[5]} {RX_DATA[6]} {RX_DATA[7]}]]
connect_debug_port u_ila_0/probe9 [get_nets [list bit_cnt_done]]
connect_debug_port u_ila_0/probe11 [get_nets [list over_sample_cnt_done]]
connect_debug_port u_ila_0/probe12 [get_nets [list p_0_in]]
connect_debug_port u_ila_0/probe15 [get_nets [list RX_start]]


