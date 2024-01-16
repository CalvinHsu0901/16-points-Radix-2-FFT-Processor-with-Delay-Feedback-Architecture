module tf_multi #(
    parameter WD   = 12,
    parameter WNRD = 9
)(
    input  signed [WD-1:0]   din_re,
    input  signed [WD-1:0]   din_im,
    input  signed [WNRD-1:0] wnr_re,
    input  signed [WNRD-1:0] wnr_im,

    output signed [WD-1:0]   dout_re,
    output signed [WD-1:0]   dout_im
);
    // R*R-I*I, R*I+I*R
    wire signed [WD+WNRD-1:0] m0, m1, m2, m3;

    assign m0 = din_re * wnr_re;
    assign m1 = din_im * wnr_im;
    assign m2 = din_re * wnr_im;
    assign m3 = din_im * wnr_re;

    wire signed [WD+WNRD:0] s0, s1;

    assign s0 = m0 - m1;    // real
    assign s1 = m2 + m3;    // image

    // Saturation (1, 22, 15) ti (1, 12, 7)
    s_sat_22_12 sat0
    (
        .din(s0),
        .dout(dout_re)
    );
    s_sat_22_12 sat1
    (
        .din(s1),
        .dout(dout_im)
    );


endmodule