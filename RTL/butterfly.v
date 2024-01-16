module butterfly #(
    parameter WD = 12
)(
    input  signed [WD-1:0] din_a_re,
    input  signed [WD-1:0] din_a_im,
    input  signed [WD-1:0] din_b_re,
    input  signed [WD-1:0] din_b_im,

    output signed [WD-1:0] dout_a_re,
    output signed [WD-1:0] dout_a_im,
    output signed [WD-1:0] dout_b_re,
    output signed [WD-1:0] dout_b_im
);
    wire signed [WD:0] add_re, add_im, sub_re, sub_im;

    // Up
    assign add_re = din_a_re + din_b_re;
    assign add_im = din_a_im + din_b_im;
    
    // Down
    assign sub_re = din_a_re - din_b_re;
    assign sub_im = din_a_im - din_b_im;

    // Saturation (1, 13, 7) ti (1, 12, 7)
    s_sat_13_12 sa0 (
        .din(add_re),
        .dout(dout_a_re)
    );
    s_sat_13_12 sa1 (
        .din(add_im),
        .dout(dout_a_im)
    );
    
    s_sat_13_12 sa2 (
        .din(sub_re),
        .dout(dout_b_re)
    );
    s_sat_13_12 sa3 (
        .din(sub_im),
        .dout(dout_b_im)
    );



endmodule