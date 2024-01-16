function fftResult = my16fft(xm0, wl, fl, wl2, fl2)
    % Check if the input sequence has the correct size
    if numel(xm0) ~= 16
        error('# Input sequence must be a 1x16 vector.');
    end

    F = fimath('OverflowAction','Saturate','RoundingMethod','Floor');
    
    % Perform the 16-point FFT
    %% twiddle factor: w16_0 ~ w16_7 -> Wnr1 ~Wnr8
    for r=0:7
        Wnr(r+1)  = cos(2*pi*r/16) - 1i*sin(2*pi*r/16);
    end

    if wl2 == 0
    else
        Wnr = fi(Wnr, 1, wl2, fl2, F);
    end

%     disp('W16_0 ~ W16_7:');
%     disp(Wnr);
%     disp('Intput:');
%     disp(xm0);

    xm0 = fi(xm0, 1, wl, fl, F);

    %% stage1
    xm1(1)  = xm0(1) + xm0(9);
    xm1(2)  = xm0(2) + xm0(10);
    xm1(3)  = xm0(3) + xm0(11);
    xm1(4)  = xm0(4) + xm0(12);
    xm1(5)  = xm0(5) + xm0(13);
    xm1(6)  = xm0(6) + xm0(14);
    xm1(7)  = xm0(7) + xm0(15);
    xm1(8)  = xm0(8) + xm0(16);
    xm1(9)  = xm0(1) - xm0(9);
    xm1(10) = xm0(2) - xm0(10);
    xm1(11) = xm0(3) - xm0(11);
    xm1(12) = xm0(4) - xm0(12);
    xm1(13) = xm0(5) - xm0(13);
    xm1(14) = xm0(6) - xm0(14);
    xm1(15) = xm0(7) - xm0(15);
    xm1(16) = xm0(8) - xm0(16);
    
    xm1 = fi(xm1, 1, wl, fl, F);

    xm1(10) = xm1(10) * Wnr(2);
    xm1(11) = xm1(11) * Wnr(3);
    xm1(12) = xm1(12) * Wnr(4);
    xm1(13) = xm1(13) * Wnr(5);
    xm1(14) = xm1(14) * Wnr(6);
    xm1(15) = xm1(15) * Wnr(7);
    xm1(16) = xm1(16) * Wnr(8);

    xm1 = fi(xm1, 1, wl, fl, F);

%     disp('stage1:');
%     disp(xm1);

    %% stage2
    xm2(1)  = xm1(1) + xm1(5);
    xm2(2)  = xm1(2) + xm1(6);
    xm2(3)  = xm1(3) + xm1(7);
    xm2(4)  = xm1(4) + xm1(8);
    xm2(5)  = xm1(1) - xm1(5);
    xm2(6)  = xm1(2) - xm1(6);
    xm2(7) = xm1(3) - xm1(7);
    xm2(8) = xm1(4) - xm1(8);
    xm2(9)  = xm1(9) + xm1(13);
    xm2(10) = xm1(10) + xm1(14);
    xm2(11) = xm1(11) + xm1(15);
    xm2(12) = xm1(12) + xm1(16);
    xm2(13) = xm1(9) - xm1(13);
    xm2(14) = xm1(10) - xm1(14);
    xm2(15) = xm1(11) - xm1(15);
    xm2(16) = xm1(12) - xm1(16);

    xm2 = fi(xm2, 1, wl, fl, F);

    xm2(6)  = xm2(6) * Wnr(3);
    xm2(7) = xm2(7) * Wnr(5);
    xm2(8) = xm2(8) * Wnr(7);
    xm2(14) = xm2(14) * Wnr(3);
    xm2(15) = xm2(15) * Wnr(5);
    xm2(16) = xm2(16) * Wnr(7);

    xm2 = fi(xm2, 1, wl, fl, F);


%     disp('stage2:');
%     disp(xm2);

    %% stage3
    xm3(1)  = xm2(1) + xm2(3);
    xm3(2)  = xm2(2) + xm2(4);
    xm3(3)  = xm2(1) - xm2(3);
    xm3(4) = xm2(2) - xm2(4);
    xm3(5)  = xm2(5) + xm2(7);
    xm3(6)  = xm2(6) + xm2(8);
    xm3(7)  = xm2(5) - xm2(7);
    xm3(8) = xm2(6) - xm2(8);
    xm3(9)  = xm2(9) + xm2(11);
    xm3(10) = xm2(10) + xm2(12);
    xm3(11) = xm2(9) - xm2(11);
    xm3(12) = xm2(10) - xm2(12);
    xm3(13) = xm2(13) + xm2(15);
    xm3(14) = xm2(14) + xm2(16);
    xm3(15) = xm2(13) - xm2(15);
    xm3(16) = xm2(14) - xm2(16);

    xm3 = fi(xm3, 1, wl, fl, F);

    xm3(4) = xm3(4) * Wnr(5);
    xm3(8) = xm3(8) * Wnr(5);
    xm3(12) = xm3(12) * Wnr(5);
    xm3(16) = xm3(16) * Wnr(5);

    xm3 = fi(xm3, 1, wl, fl, F);


%     disp('stage3:');
%     disp(xm3);
    
    %% stage4
    xm4(1)  = xm3(1) + xm3(2);
    xm4(2)  = xm3(1) - xm3(2);
    xm4(3)  = xm3(3) + xm3(4);
    xm4(4)  = xm3(3) - xm3(4);
    xm4(5)  = xm3(5) + xm3(6);
    xm4(6)  = xm3(5) - xm3(6);
    xm4(7)  = xm3(7) + xm3(8);
    xm4(8)  = xm3(7) - xm3(8);
    xm4(9)  = xm3(9) + xm3(10);
    xm4(10) = xm3(9) - xm3(10);
    xm4(11) = xm3(11) + xm3(12);
    xm4(12) = xm3(11) - xm3(12);
    xm4(13) = xm3(13) + xm3(14);
    xm4(14) = xm3(13) - xm3(14);
    xm4(15) = xm3(15) + xm3(16);
    xm4(16) = xm3(15) - xm3(16);

    xm4 = fi(xm4, 1, wl, fl, F);

%     disp('stage4:');
%     disp(xm4);
    
    %% output re-order
    fftResult(1)  = xm4(1);
    fftResult(2)  = xm4(9);
    fftResult(3)  = xm4(5);
    fftResult(4)  = xm4(13);
    fftResult(5)  = xm4(3);
    fftResult(6)  = xm4(11);
    fftResult(7)  = xm4(7);
    fftResult(8)  = xm4(15);
    fftResult(9)  = xm4(2);
    fftResult(10) = xm4(10);
    fftResult(11) = xm4(6);
    fftResult(12) = xm4(14);
    fftResult(13) = xm4(4);
    fftResult(14) = xm4(12);
    fftResult(15) = xm4(8);
    fftResult(16) = xm4(16);

end
