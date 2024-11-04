set_property MARK_DEBUG true [get_nets ALARM_OBUF]
set_property MARK_DEBUG true [get_nets CLK_IBUF]
set_property MARK_DEBUG true [get_nets RST_IBUF]

create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 2048 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list CLK_IBUF_BUFG]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 2 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {current_state[0]} {current_state[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 2 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {p_1_in[0]} {p_1_in[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 32 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {CNT_Wait[0]} {CNT_Wait[1]} {CNT_Wait[2]} {CNT_Wait[3]} {CNT_Wait[4]} {CNT_Wait[5]} {CNT_Wait[6]} {CNT_Wait[7]} {CNT_Wait[8]} {CNT_Wait[9]} {CNT_Wait[10]} {CNT_Wait[11]} {CNT_Wait[12]} {CNT_Wait[13]} {CNT_Wait[14]} {CNT_Wait[15]} {CNT_Wait[16]} {CNT_Wait[17]} {CNT_Wait[18]} {CNT_Wait[19]} {CNT_Wait[20]} {CNT_Wait[21]} {CNT_Wait[22]} {CNT_Wait[23]} {CNT_Wait[24]} {CNT_Wait[25]} {CNT_Wait[26]} {CNT_Wait[27]} {CNT_Wait[28]} {CNT_Wait[29]} {CNT_Wait[30]} {CNT_Wait[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 2 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {SENSOR[0]} {SENSOR[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 32 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {CNT_Seg[0]} {CNT_Seg[1]} {CNT_Seg[2]} {CNT_Seg[3]} {CNT_Seg[4]} {CNT_Seg[5]} {CNT_Seg[6]} {CNT_Seg[7]} {CNT_Seg[8]} {CNT_Seg[9]} {CNT_Seg[10]} {CNT_Seg[11]} {CNT_Seg[12]} {CNT_Seg[13]} {CNT_Seg[14]} {CNT_Seg[15]} {CNT_Seg[16]} {CNT_Seg[17]} {CNT_Seg[18]} {CNT_Seg[19]} {CNT_Seg[20]} {CNT_Seg[21]} {CNT_Seg[22]} {CNT_Seg[23]} {CNT_Seg[24]} {CNT_Seg[25]} {CNT_Seg[26]} {CNT_Seg[27]} {CNT_Seg[28]} {CNT_Seg[29]} {CNT_Seg[30]} {CNT_Seg[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 1 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list ALARM_OBUF]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 1 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list CLK_IBUF]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 1 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list count_done]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 1 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list RST_IBUF]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 1 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list start_count]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets CLK_IBUF_BUFG]
