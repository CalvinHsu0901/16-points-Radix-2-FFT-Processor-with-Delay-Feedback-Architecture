module fft_16 #(
    // system data width (1, 12, 7)
    parameter WD = 12,
    parameter WNRD = 9
)(
    // global
    input                  clk,
    input                  rst_n,
    input                  en,
    // stream in
    input  signed [WD-1:0] sin_re,
    input  signed [WD-1:0] sin_im,
    // stream out
    output signed [WD-1:0] sout_re,
    output signed [WD-1:0] sout_im
);
    // ------------------------------------------------------------
    // Parameters
    // ------------------------------------------------------------
    // Twiddle Factor Wnr (r = 1: 22.5 degress, and so on)
    localparam W16_1_RE = 9'b011101100;
    localparam W16_1_IM = 9'b110011110;
    localparam W16_2_RE = 9'b010110101;
    localparam W16_2_IM = 9'b101001010;
    localparam W16_3_RE = 9'b001100001;
    localparam W16_3_IM = 9'b100010011;
    localparam W16_4_RE = 9'b000000000;
    localparam W16_4_IM = 9'b100000000;
    localparam W16_5_RE = 9'b110011110;
    localparam W16_5_IM = 9'b100010011;
    localparam W16_6_RE = 9'b101001010;
    localparam W16_6_IM = 9'b101001010;
    localparam W16_7_RE = 9'b100010011;
    localparam W16_7_IM = 9'b110011110;

    // ------------------------------------------------------------
    // Register & Wire
    // ------------------------------------------------------------
    // control
    reg [3:0] count;
    reg  signed [WNRD-1:0] w1_re, w1_im, w2_re, w2_im;
    wire signed [WNRD-1:0] w3_re, w3_im;

    // stage 1
    reg  signed [WD-1:0] d1_re [0:7];
    reg  signed [WD-1:0] d1_im [0:7];

    wire signed [WD-1:0] bf1_a_re;
    wire signed [WD-1:0] bf1_a_im;
    wire signed [WD-1:0] bf1_b_re;
    wire signed [WD-1:0] bf1_b_im;

    wire signed [WD-1:0] mux1_a_re;
    wire signed [WD-1:0] mux1_a_im;
    wire signed [WD-1:0] mux1_b_re;
    wire signed [WD-1:0] mux1_b_im;

    wire signed [WD-1:0] tf1_re;
    wire signed [WD-1:0] tf1_im;

    wire signed [WD-1:0] mux1_out_re;
    wire signed [WD-1:0] mux1_out_im;

    reg signed  [WD-1:0] stage1_out_re;
    reg signed  [WD-1:0] stage1_out_im;

    // stage 2
    reg  signed [WD-1:0] d2_re [0:3];
    reg  signed [WD-1:0] d2_im [0:3];

    wire signed [WD-1:0] bf2_a_re;
    wire signed [WD-1:0] bf2_a_im;
    wire signed [WD-1:0] bf2_b_re;
    wire signed [WD-1:0] bf2_b_im;

    wire signed [WD-1:0] mux2_a_re;
    wire signed [WD-1:0] mux2_a_im;
    wire signed [WD-1:0] mux2_b_re;
    wire signed [WD-1:0] mux2_b_im;

    wire signed [WD-1:0] tf2_re;
    wire signed [WD-1:0] tf2_im;

    wire signed [WD-1:0] mux2_out_re;
    wire signed [WD-1:0] mux2_out_im;

    reg signed  [WD-1:0] stage2_out_re;
    reg signed  [WD-1:0] stage2_out_im;

    // stage 3
    reg  signed [WD-1:0] d3_re [0:1];
    reg  signed [WD-1:0] d3_im [0:1];

    wire signed [WD-1:0] bf3_a_re;
    wire signed [WD-1:0] bf3_a_im;
    wire signed [WD-1:0] bf3_b_re;
    wire signed [WD-1:0] bf3_b_im;

    wire signed [WD-1:0] mux3_a_re;
    wire signed [WD-1:0] mux3_a_im;
    wire signed [WD-1:0] mux3_b_re;
    wire signed [WD-1:0] mux3_b_im;

    wire signed [WD-1:0] tf3_re;
    wire signed [WD-1:0] tf3_im;

    wire signed [WD-1:0] mux3_out_re;
    wire signed [WD-1:0] mux3_out_im;

    reg signed  [WD-1:0] stage3_out_re;
    reg signed  [WD-1:0] stage3_out_im;

    // stage 4
    reg  signed [WD-1:0] d4_re;
    reg  signed [WD-1:0] d4_im;

    wire signed [WD-1:0] bf4_a_re;
    wire signed [WD-1:0] bf4_a_im;
    wire signed [WD-1:0] bf4_b_re;
    wire signed [WD-1:0] bf4_b_im;

    wire signed [WD-1:0] mux4_a_re;
    wire signed [WD-1:0] mux4_a_im;
    wire signed [WD-1:0] mux4_b_re;
    wire signed [WD-1:0] mux4_b_im;

    reg signed  [WD-1:0] stage4_out_re;
    reg signed  [WD-1:0] stage4_out_im;

    // ------------------------------------------------------------
    // Control
    // ------------------------------------------------------------
    // count
    always @(posedge clk) begin
        if (!rst_n)
            count <= 4'd0;
        else if (en)
            count <= count + 1'b1;
        else
            count <= 4'd0;
    end

    // stage 1 mux a, b, out
    assign mux1_a_re = (count[3])? bf1_a_re : d1_re[7];
    assign mux1_a_im = (count[3])? bf1_a_im : d1_im[7];
    assign mux1_b_re = (count[3])? bf1_b_re : sin_re;
    assign mux1_b_im = (count[3])? bf1_b_im : sin_im;

    assign mux1_out_re = ((count > 4'd0) & (count < 4'd8))? tf1_re : mux1_a_re;     // (only 1 ~ 7 * Wnr)
    assign mux1_out_im = ((count > 4'd0) & (count < 4'd8))? tf1_im : mux1_a_im;
    // stage 1 Wnr (1~7)
    always @(*) begin
        w1_re <= W16_1_RE;
        w1_im <= W16_1_IM;
        case(count)
            4'd2: begin
                w1_re <= W16_2_RE;
                w1_im <= W16_2_IM;
            end
            4'd3: begin
                w1_re <= W16_3_RE;
                w1_im <= W16_3_IM;
            end
            4'd4: begin
                w1_re <= W16_4_RE;
                w1_im <= W16_4_IM;
            end
            4'd5: begin
                w1_re <= W16_5_RE;
                w1_im <= W16_5_IM;
            end
            4'd6: begin
                w1_re <= W16_6_RE;
                w1_im <= W16_6_IM;
            end
            4'd7: begin
                w1_re <= W16_7_RE;
                w1_im <= W16_7_IM;
            end
            default: begin
                w1_re <= W16_1_RE;
                w1_im <= W16_1_IM;
            end
        endcase
    end

    // stage 2 mux a, b, out
    assign mux2_a_re = ((count == 0) | (count > 12) | (count > 4 & count < 9))? bf2_a_re : d2_re[3];
    assign mux2_a_im = ((count == 0) | (count > 12) | (count > 4 & count < 9))? bf2_a_im : d2_im[3];
    assign mux2_b_re = ((count == 0) | (count > 12) | (count > 4 & count < 9))? bf2_b_re : stage1_out_re;
    assign mux2_b_im = ((count == 0) | (count > 12) | (count > 4 & count < 9))? bf2_b_im : stage1_out_im;

    assign mux2_out_re = ((count > 1 & count < 5) | (count > 9 & count < 13))? tf2_re : mux2_a_re;
    assign mux2_out_im = ((count > 1 & count < 5) | (count > 9 & count < 13))? tf2_im : mux2_a_im;
    // stage 2 Wnr (2,4,6)
    always @(*) begin
        w2_re <= W16_2_RE;
        w2_im <= W16_2_IM;
        case(count)
            4'd3: begin
                w2_re <= W16_4_RE;
                w2_im <= W16_4_IM;
            end
            4'd4: begin
                w2_re <= W16_6_RE;
                w2_im <= W16_6_IM;
            end
            4'd11: begin
                w2_re <= W16_4_RE;
                w2_im <= W16_4_IM;
            end
            4'd12: begin
                w2_re <= W16_6_RE;
                w2_im <= W16_6_IM;
            end
            default: begin
                w2_re <= W16_2_RE;
                w2_im <= W16_2_IM;
            end
        endcase
    end

    // stage 3 mux a, b, out
    assign mux3_a_re = (~count[1])?
                        bf3_a_re : d3_re[1];
    assign mux3_a_im = (~count[1])?
                        bf3_a_im : d3_im[1];
    assign mux3_b_re = (~count[1])?
                        bf3_b_re : stage2_out_re;
    assign mux3_b_im = (~count[1])?
                        bf3_b_im : stage2_out_im;

    assign mux3_out_re = ((count==3) | (count==7) | (count==11) | (count==15))? tf3_re : mux3_a_re;
    assign mux3_out_im = ((count==3) | (count==7) | (count==11) | (count==15))? tf3_im : mux3_a_im;
    // stage 3 Wnr (4)
    assign w3_re = W16_4_RE;
    assign w3_im = W16_4_IM;

    // stage 4 mux a, b
    assign mux4_a_re = (~count[0])? bf4_a_re : d4_re;
    assign mux4_a_im = (~count[0])? bf4_a_im : d4_im;
    assign mux4_b_re = (~count[0])? bf4_b_re : stage3_out_re;
    assign mux4_b_im = (~count[0])? bf4_b_im : stage3_out_im;


    // ------------------------------------------------------------
    // Stage 1
    // ------------------------------------------------------------
    always @(posedge clk) begin
        if (!rst_n) begin
            d1_re[0] <= 12'd0;
            d1_im[0] <= 12'd0;
            d1_re[1] <= 12'd0;
            d1_im[1] <= 12'd0;
            d1_re[2] <= 12'd0;
            d1_im[2] <= 12'd0;
            d1_re[3] <= 12'd0;
            d1_im[3] <= 12'd0;
            d1_re[4] <= 12'd0;
            d1_im[4] <= 12'd0;
            d1_re[5] <= 12'd0;
            d1_im[5] <= 12'd0;
            d1_re[6] <= 12'd0;
            d1_im[6] <= 12'd0;
            d1_re[7] <= 12'd0;
            d1_im[7] <= 12'd0;
        end
        else begin
            d1_re[0] <= mux1_b_re;
            d1_im[0] <= mux1_b_im;
            d1_re[1] <= d1_re[0];
            d1_im[1] <= d1_im[0];
            d1_re[2] <= d1_re[1];
            d1_im[2] <= d1_im[1];
            d1_re[3] <= d1_re[2];
            d1_im[3] <= d1_im[2];
            d1_re[4] <= d1_re[3];
            d1_im[4] <= d1_im[3];
            d1_re[5] <= d1_re[4];
            d1_im[5] <= d1_im[4];
            d1_re[6] <= d1_re[5];
            d1_im[6] <= d1_im[5];
            d1_re[7] <= d1_re[6];
            d1_im[7] <= d1_im[6];
        end
    end

    butterfly bf1
    (
    .din_a_re   (d1_re[7]),
    .din_a_im   (d1_im[7]),
    .din_b_re   (sin_re),
    .din_b_im   (sin_im),
    .dout_a_re  (bf1_a_re),
    .dout_a_im  (bf1_a_im),
    .dout_b_re  (bf1_b_re),
    .dout_b_im  (bf1_b_im)
    );

    tf_multi tf1
    (
    .din_re     (mux1_a_re),
    .din_im     (mux1_a_im),
    .wnr_re     (w1_re),
    .wnr_im     (w1_im),
    .dout_re    (tf1_re),
    .dout_im    (tf1_im)
    );

    always @(posedge clk) begin
        if (!rst_n) begin
            stage1_out_re <= 12'd0;
            stage1_out_im <= 12'd0;
        end
        else begin
            stage1_out_re <= mux1_out_re;
            stage1_out_im <= mux1_out_im;
        end
    end

    // ------------------------------------------------------------
    // Stage 2
    // ------------------------------------------------------------
    always @(posedge clk) begin
        if (!rst_n) begin
            d2_re[0] <= 12'd0;
            d2_im[0] <= 12'd0;
            d2_re[1] <= 12'd0;
            d2_im[1] <= 12'd0;
            d2_re[2] <= 12'd0;
            d2_im[2] <= 12'd0;
            d2_re[3] <= 12'd0;
            d2_im[3] <= 12'd0;
        end
        else begin
            d2_re[0] <= mux2_b_re;
            d2_im[0] <= mux2_b_im;
            d2_re[1] <= d2_re[0];
            d2_im[1] <= d2_im[0];
            d2_re[2] <= d2_re[1];
            d2_im[2] <= d2_im[1];
            d2_re[3] <= d2_re[2];
            d2_im[3] <= d2_im[2];
        end
    end

    butterfly bf2
    (
    .din_a_re   (d2_re[3]),
    .din_a_im   (d2_im[3]),
    .din_b_re   (stage1_out_re),
    .din_b_im   (stage1_out_im),
    .dout_a_re  (bf2_a_re),
    .dout_a_im  (bf2_a_im),
    .dout_b_re  (bf2_b_re),
    .dout_b_im  (bf2_b_im)
    );

    tf_multi tf2
    (
    .din_re     (mux2_a_re),
    .din_im     (mux2_a_im),
    .wnr_re     (w2_re),
    .wnr_im     (w2_im),
    .dout_re    (tf2_re),
    .dout_im    (tf2_im)
    );

    always @(posedge clk) begin
        if (!rst_n) begin
            stage2_out_re <= 12'd0;
            stage2_out_im <= 12'd0;
        end
        else begin
            stage2_out_re <= mux2_out_re;
            stage2_out_im <= mux2_out_im;
        end
    end

    // ------------------------------------------------------------
    // Stage 3
    // ------------------------------------------------------------
    always @(posedge clk) begin
        if (!rst_n) begin
            d3_re[0] <= 12'd0;
            d3_im[0] <= 12'd0;
            d3_re[1] <= 12'd0;
            d3_im[1] <= 12'd0;
        end
        else begin
            d3_re[0] <= mux3_b_re;
            d3_im[0] <= mux3_b_im;
            d3_re[1] <= d3_re[0];
            d3_im[1] <= d3_im[0];
        end
    end

    butterfly bf3
    (
    .din_a_re   (d3_re[1]),
    .din_a_im   (d3_im[1]),
    .din_b_re   (stage2_out_re),
    .din_b_im   (stage2_out_im),
    .dout_a_re  (bf3_a_re),
    .dout_a_im  (bf3_a_im),
    .dout_b_re  (bf3_b_re),
    .dout_b_im  (bf3_b_im)
    );

    tf_multi tf3
    (
    .din_re     (mux3_a_re),
    .din_im     (mux3_a_im),
    .wnr_re     (w3_re),
    .wnr_im     (w3_im),
    .dout_re    (tf3_re),
    .dout_im    (tf3_im)
    );

    always @(posedge clk) begin
        if (!rst_n) begin
            stage3_out_re <= 12'd0;
            stage3_out_im <= 12'd0;
        end
        else begin
            stage3_out_re <= mux3_out_re;
            stage3_out_im <= mux3_out_im;
        end
    end

    // ------------------------------------------------------------
    // Stage 4
    // ------------------------------------------------------------
    always @(posedge clk) begin
        if (!rst_n) begin
            d4_re <= 12'd0;
            d4_im <= 12'd0;
        end
        else begin
            d4_re <= mux4_b_re;
            d4_im <= mux4_b_im;
        end
    end

    butterfly bf4
    (
    .din_a_re   (d4_re),
    .din_a_im   (d4_im),
    .din_b_re   (stage3_out_re),
    .din_b_im   (stage3_out_im),
    .dout_a_re  (bf4_a_re),
    .dout_a_im  (bf4_a_im),
    .dout_b_re  (bf4_b_re),
    .dout_b_im  (bf4_b_im)
    );

    always @(posedge clk) begin
        if (!rst_n) begin
            stage4_out_re <= 12'd0;
            stage4_out_im <= 12'd0;
        end
        else begin
            stage4_out_re <= mux4_a_re;
            stage4_out_im <= mux4_a_im;
        end
    end

    assign sout_re = stage4_out_re;
    assign sout_im = stage4_out_im;

    // ------------------------------------------------------------

endmodule