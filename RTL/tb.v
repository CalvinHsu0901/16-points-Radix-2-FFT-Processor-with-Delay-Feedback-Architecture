`timescale 1ns / 1ps

module tb #(
    parameter WD = 12
)();
    // Inputs
    reg clk, rst_n, en;
    reg signed [WD-1:0] sin_re, sin_im ;

    // Outputs
    wire signed [WD-1:0] sout_re, sout_im;

    // Data
    reg signed [WD-1:0] data_re[1:32000];
    reg signed [WD-1:0] data_im[1:32000];

    // Others
    reg start;
    integer i;

    // DUT
    fft_16 fft_16_dut 
    (
    .clk(clk),
    .rst_n(rst_n),
    .en(en),
    .sin_re(sin_re),
    .sin_im(sin_im),
    .sout_re(sout_re),
    .sout_im(sout_im)
    );

    // Time Out
    integer timeout = (1000000);
    initial begin
        while(timeout >= 1) begin
            @(posedge clk);
            timeout = timeout - 1;
        end
        $display($time, "Simualtion Hang ....");
        $finish;
    end

    // clock
    initial begin
        clk = 1;
        forever begin
            #5 clk = ~clk;
        end
    end

    // Read input
    initial begin
    $readmemb("/home/calvin0901/dspic/fft16/input_real_bin.txt", data_re);
    $readmemb("/home/calvin0901/dspic/fft16/input_image_bin.txt", data_im);
    end

    // Initialize
    initial begin
        rst_n = 0;
        en = 0;
        start = 0;
        sin_re = 0;
        sin_im = 0;
        i = 0;
        @(negedge clk); @(negedge clk);
        rst_n = 1;
        en = 1;
        start = 1;
    end
    
    // Simulation
    initial begin
        @(posedge start) begin
            for(i=1; i<=32000; i=i+1) begin
                sin_re = data_re[i];
                sin_im = data_im[i];
                @(negedge clk);
            end
        end
    end

endmodule