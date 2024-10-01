
always@(*)
begin
    case(DLY_ADDR)
        5'd0:  DLY_TAP_VALUE = DLY_TAP0_VAL;
        5'd1:  DLY_TAP_VALUE = DLY_TAP1_VAL;
        5'd2:  DLY_TAP_VALUE = DLY_TAP2_VAL;
        5'd3:  DLY_TAP_VALUE = DLY_TAP3_VAL;
        5'd4:  DLY_TAP_VALUE = DLY_TAP4_VAL;
        5'd5:  DLY_TAP_VALUE = DLY_TAP5_VAL;
        5'd6:  DLY_TAP_VALUE = DLY_TAP6_VAL;
        5'd7:  DLY_TAP_VALUE = DLY_TAP7_VAL;
        5'd8:  DLY_TAP_VALUE = DLY_TAP8_VAL;
        5'd9:  DLY_TAP_VALUE = DLY_TAP9_VAL;
        5'd10: DLY_TAP_VALUE = DLY_TAP10_VAL;
        5'd11: DLY_TAP_VALUE = DLY_TAP11_VAL;
        5'd12: DLY_TAP_VALUE = DLY_TAP12_VAL;
        5'd13: DLY_TAP_VALUE = DLY_TAP13_VAL;
        5'd14: DLY_TAP_VALUE = DLY_TAP14_VAL;
        5'd15: DLY_TAP_VALUE = DLY_TAP15_VAL;
        5'd16: DLY_TAP_VALUE = DLY_TAP16_VAL;
        5'd17: DLY_TAP_VALUE = DLY_TAP17_VAL;
        5'd18: DLY_TAP_VALUE = DLY_TAP18_VAL;
        5'd19: DLY_TAP_VALUE = DLY_TAP19_VAL;
        default: DLY_TAP_VALUE = 5'd0;
    endcase
end
