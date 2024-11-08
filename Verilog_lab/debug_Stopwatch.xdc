connect_debug_port u_ila_0/probe16 [get_nets [list p_0_in7_in]]
connect_debug_port u_ila_0/probe17 [get_nets [list p_0_in10_in]]
set_property MARK_DEBUG true [get_nets BTN1_IBUF]
connect_debug_port u_ila_0/probe12 [get_nets [list BTN0_pressed]]
connect_debug_port u_ila_0/probe14 [get_nets [list BTN1_pressed]]
connect_debug_port u_ila_0/probe13 [get_nets [list BTN1_IBUF]]
connect_debug_port u_ila_0/probe19 [get_nets [list p_0_in]]
set_property MARK_DEBUG true [get_nets p_0_in10_in]
set_property MARK_DEBUG true [get_nets p_0_in7_in]

create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 4096 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list CLK_IBUF_BUFG]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 32 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {CNT_1s[0]} {CNT_1s[1]} {CNT_1s[2]} {CNT_1s[3]} {CNT_1s[4]} {CNT_1s[5]} {CNT_1s[6]} {CNT_1s[7]} {CNT_1s[8]} {CNT_1s[9]} {CNT_1s[10]} {CNT_1s[11]} {CNT_1s[12]} {CNT_1s[13]} {CNT_1s[14]} {CNT_1s[15]} {CNT_1s[16]} {CNT_1s[17]} {CNT_1s[18]} {CNT_1s[19]} {CNT_1s[20]} {CNT_1s[21]} {CNT_1s[22]} {CNT_1s[23]} {CNT_1s[24]} {CNT_1s[25]} {CNT_1s[26]} {CNT_1s[27]} {CNT_1s[28]} {CNT_1s[29]} {CNT_1s[30]} {CNT_1s[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 3 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {Save_flag[0]} {Save_flag[1]} {Save_flag[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 6 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {Time_sec[0]} {Time_sec[1]} {Time_sec[2]} {Time_sec[3]} {Time_sec[4]} {Time_sec[5]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 7 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {AN_OBUF[0]} {AN_OBUF[1]} {AN_OBUF[2]} {AN_OBUF[3]} {AN_OBUF[4]} {AN_OBUF[5]} {AN_OBUF[6]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 32 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {CNT_LOAD[0]} {CNT_LOAD[1]} {CNT_LOAD[2]} {CNT_LOAD[3]} {CNT_LOAD[4]} {CNT_LOAD[5]} {CNT_LOAD[6]} {CNT_LOAD[7]} {CNT_LOAD[8]} {CNT_LOAD[9]} {CNT_LOAD[10]} {CNT_LOAD[11]} {CNT_LOAD[12]} {CNT_LOAD[13]} {CNT_LOAD[14]} {CNT_LOAD[15]} {CNT_LOAD[16]} {CNT_LOAD[17]} {CNT_LOAD[18]} {CNT_LOAD[19]} {CNT_LOAD[20]} {CNT_LOAD[21]} {CNT_LOAD[22]} {CNT_LOAD[23]} {CNT_LOAD[24]} {CNT_LOAD[25]} {CNT_LOAD[26]} {CNT_LOAD[27]} {CNT_LOAD[28]} {CNT_LOAD[29]} {CNT_LOAD[30]} {CNT_LOAD[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 32 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {CNT_CLR[0]} {CNT_CLR[1]} {CNT_CLR[2]} {CNT_CLR[3]} {CNT_CLR[4]} {CNT_CLR[5]} {CNT_CLR[6]} {CNT_CLR[7]} {CNT_CLR[8]} {CNT_CLR[9]} {CNT_CLR[10]} {CNT_CLR[11]} {CNT_CLR[12]} {CNT_CLR[13]} {CNT_CLR[14]} {CNT_CLR[15]} {CNT_CLR[16]} {CNT_CLR[17]} {CNT_CLR[18]} {CNT_CLR[19]} {CNT_CLR[20]} {CNT_CLR[21]} {CNT_CLR[22]} {CNT_CLR[23]} {CNT_CLR[24]} {CNT_CLR[25]} {CNT_CLR[26]} {CNT_CLR[27]} {CNT_CLR[28]} {CNT_CLR[29]} {CNT_CLR[30]} {CNT_CLR[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 4 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list {Digit_10s[0]} {Digit_10s[1]} {Digit_10s[2]} {Digit_10s[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 4 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list {Dig2Seg[0]} {Dig2Seg[1]} {Dig2Seg[2]} {Dig2Seg[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 4 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list {Digit_1s[0]} {Digit_1s[1]} {Digit_1s[2]} {Digit_1s[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 3 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list {Max_Save_flag[0]} {Max_Save_flag[1]} {Max_Save_flag[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 30 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list {Time_save[0]} {Time_save[1]} {Time_save[2]} {Time_save[3]} {Time_save[4]} {Time_save[5]} {Time_save[6]} {Time_save[7]} {Time_save[8]} {Time_save[9]} {Time_save[10]} {Time_save[11]} {Time_save[12]} {Time_save[13]} {Time_save[14]} {Time_save[15]} {Time_save[16]} {Time_save[17]} {Time_save[18]} {Time_save[19]} {Time_save[20]} {Time_save[21]} {Time_save[22]} {Time_save[23]} {Time_save[24]} {Time_save[25]} {Time_save[26]} {Time_save[27]} {Time_save[28]} {Time_save[29]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 2 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list {next_state[0]} {next_state[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe12]
set_property port_width 2 [get_debug_ports u_ila_0/probe12]
connect_debug_port u_ila_0/probe12 [get_nets [list {current_state[0]} {current_state[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe13]
set_property port_width 1 [get_debug_ports u_ila_0/probe13]
connect_debug_port u_ila_0/probe13 [get_nets [list BTN0_press]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe14]
set_property port_width 1 [get_debug_ports u_ila_0/probe14]
connect_debug_port u_ila_0/probe14 [get_nets [list BTN1_chk2]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe15]
set_property port_width 1 [get_debug_ports u_ila_0/probe15]
connect_debug_port u_ila_0/probe15 [get_nets [list BTN1_press]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe16]
set_property port_width 1 [get_debug_ports u_ila_0/probe16]
connect_debug_port u_ila_0/probe16 [get_nets [list CA_OBUF]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe17]
set_property port_width 1 [get_debug_ports u_ila_0/probe17]
connect_debug_port u_ila_0/probe17 [get_nets [list CLK_IBUF_BUFG]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe18]
set_property port_width 1 [get_debug_ports u_ila_0/probe18]
connect_debug_port u_ila_0/probe18 [get_nets [list CLR]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe19]
set_property port_width 1 [get_debug_ports u_ila_0/probe19]
connect_debug_port u_ila_0/probe19 [get_nets [list load]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe20]
set_property port_width 1 [get_debug_ports u_ila_0/probe20]
connect_debug_port u_ila_0/probe20 [get_nets [list p_0_in7_in]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe21]
set_property port_width 1 [get_debug_ports u_ila_0/probe21]
connect_debug_port u_ila_0/probe21 [get_nets [list p_0_in10_in]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe22]
set_property port_width 1 [get_debug_ports u_ila_0/probe22]
connect_debug_port u_ila_0/probe22 [get_nets [list p_1_in]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe23]
set_property port_width 1 [get_debug_ports u_ila_0/probe23]
connect_debug_port u_ila_0/probe23 [get_nets [list Pos_Sel]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe24]
set_property port_width 1 [get_debug_ports u_ila_0/probe24]
connect_debug_port u_ila_0/probe24 [get_nets [list tick]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe25]
set_property port_width 1 [get_debug_ports u_ila_0/probe25]
connect_debug_port u_ila_0/probe25 [get_nets [list time_start]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe26]
set_property port_width 1 [get_debug_ports u_ila_0/probe26]
connect_debug_port u_ila_0/probe26 [get_nets [list wait_clear]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe27]
set_property port_width 1 [get_debug_ports u_ila_0/probe27]
connect_debug_port u_ila_0/probe27 [get_nets [list wait_load]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets CLK_IBUF_BUFG]
