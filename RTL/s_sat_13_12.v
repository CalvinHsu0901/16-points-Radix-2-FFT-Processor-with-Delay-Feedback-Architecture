module s_sat_13_12 #(
    // (1, 13, 7) to (1, 12, 7)
    parameter   WIN  = 13,
    parameter   WOUT = 12
)(
    input  signed     [WIN-1:0]  din,
    output reg signed [WOUT-1:0] dout
);

always  @(*) begin
    // Negative Overflow Check
    if ((din[WIN-1] == 1'b1) && (din[WIN-2:WOUT-1] != { {WIN-WOUT}{1'b1} })) begin
        dout = {1'b1,{{WOUT-1}{1'b0}}};
    end
    // Positive Overflow Check
    else if ((din[WIN-1] == 1'b0) && (din[WIN-2:WOUT-1] != { {WIN-WOUT}{1'b0} })) begin
        dout = {1'b0,{{WOUT-1}{1'b1}}};
    end
    // 
    else begin
        dout = din[WOUT-1:0];
    end
end

endmodule