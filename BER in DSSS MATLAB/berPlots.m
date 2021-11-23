clear all;

fs = 1000;
fc = 100;
fp = 2;
bit_t = 0.1;

nSNR = 25;
nAvg = 100;
snrStep = -2;
error1 = zeros(3,nSNR);
error2 = zeros(3,nSNR);
erro3 = zeros(3,nSNR);

ricianChan = ricianchan(1/fs,0,3);
ricianChan.PathDelays = [0 1e-6 1e-7];
ricianChan.ResetBeforeFiltering = 0;
ricianChan.NormalizePathGains = 1;

for w = 1:3
    messageBit = randi([0 1], 1, 20);
    for bit = 1:length(messageBit)
        if(messageBit(bit)==0)
            messageBit(bit) = -1;
        end
    end
    message = repmat(messageBit,fp,1);
    message = reshape(message,1,[]);
    pseudoNumber = randi([0,1],1,length(messageBit)*fp);
    for bit = 1:length(pseudoNumber)
        if(pseudoNumber(bit)==0)
            pseudoNumber(bit) = -1;
        end
    end
    dsss = message.*pseudoNumber;
    t = 0:1/fs:(bit_t-1/fs);
    s0 = -1*cos(2*pi*fc*t);
    s1 = cos(2*pi*fc*t);
    carrier = [];
    binaryPhase = [];
    for i = 1:length(dsss)
        if (dsss(i) == 1)
            binaryPhase = [binaryPhase s1];
        elseif (dsss(i) == -1)
            binaryPhase = [binaryPhase s0];
        end
        carrier = [carrier s1];
    end
    filteredRician = filter(ricianChan,binaryPhase);
    for h=1:nSNR
        noise = [];
        ber1 = 0;
        ber2 = 0;
        ber3 = 0;
        for y=1:nAvg
            noise = awgn(binaryPhase,(snrStep*h));
            ricianRX = awgn(filteredRician,(snrStep*h));
            N0 = 1/10^((snrStep*h+11)/10);
            rayleighChan = 1/sqrt(2)*[randn(1,length(binaryPhase)) + j*randn(1,length(binaryPhase))];
            tempRay = rayleighChan.*binaryPhase + sqrt(N0/2)*(randn(1,length(binaryPhase))+i*randn(1,length(binaryPhase)));
            rayleighRX = tempRay./rayleighChan;
            rx1 =[];
            rx2 =[];
            rx3 =[];
            for i = 1:length(pseudoNumber)
                if(pseudoNumber(i)==1)
                    rx1 = [rx1 noise((((i-1)*length(t))+1):i*length(t))];
                    rx2 = [rx2 rayleighRX((((i-1)*length(t))+1):i*length(t))];
                    rx3 = [rx3 ricianRX((((i-1)*length(t))+1):i*length(t))];
                else
                    rx1 = [rx1 (-1)*noise((((i-1)*length(t))+1):i*length(t))];
                    rx2 = [rx2 (-1)*rayleighRX((((i-1)*length(t))+1):i*length(t))];
                    rx3 = [rx3 (-1)*ricianRX((((i-1)*length(t))+1):i*length(t))];
                end
            end
            result1 = zeros(1,length(messageBit));
            result2 = zeros(1,length(messageBit));
            result3 = zeros(1,length(messageBit));
            for i = 1:length(messageBit)
                x = length(t)*fp;
                cx1 = sum(carrier(((i-1)*x)+1:i*x).*rx1(((i-1)*x)+1:i*x));
                cx2 = sum(carrier(((i-1)*x)+1:i*x).*rx2(((i-1)*x)+1:i*x));
                cx3 = sum(carrier(((i-1)*x)+1:i*x).*rx3(((i-1)*x)+1:i*x));
                if(cx1>0)
                    result1(i) = 1;
                else
                    result1(i) = -1;
                end
                if(cx2>0)
                    result2(i) = 1;
                else
                    result2(i) = -1;
                end
                if(cx3>0)
                    result3(i) = 1;
                else
                    result3(i) = -1;
                end
            end
            counter1 = 0;
            counter2 = 0;
            counter3 = 0;
            for z=1:length(messageBit)
            if messageBit(z)~=result1(z)
                counter1 = counter1+1;
            end
            if messageBit(z)~=result2(z)
                counter2 = counter2+1;
            end
            if messageBit(z)~=result3(z)
                counter3 = counter3+1;
            end
            end
            ber1 = ber1 + counter1/length(messageBit);
            ber2 = ber2 + counter2/length(messageBit);
            ber3 = ber3 + counter3/length(messageBit);
        end
        error1(w,h) = (ber1/nAvg);
        error2(w,h) = (ber2/nAvg);
        erro3(w,h) = (ber3/nAvg);
    end
    fp = fp+2;
end
    
time_vec = (10):snrStep:((nSNR-1)*snrStep+10);

figure;
semilogy(time_vec,error1(1,:),'g--o',time_vec,error1(2,:),'r--o',time_vec,error1(3,:),'b--o')
axis([ -40 10 0 1 ])
title(['White Gaussian Noise']);
xlabel('SNR (dB)');
ylabel('BER values');

figure;
semilogy(time_vec,error2(1,:),'g--o',time_vec,error2(2,:),'r--o',time_vec,error2(3,:),'b--o')
axis([ -30 30 0 1 ])
title(['Rayleigh Channel']);
xlabel('SNR (dB)');
ylabel('BER values');

figure;
semilogy(time_vec,erro3(1,:),'g--o',time_vec,erro3(2,:),'r--o',time_vec,erro3(3,:),'b--o')
axis([ -40 10 0 1 ])
title(['Rician Channel']);
xlabel('SNR (dB)');
ylabel('BER values');

figure;
semilogy(time_vec,error1(3,:),'g--o',time_vec,error2(3,:),'r--o',time_vec,erro3(3,:),'b--o')
legend('BER of AWGN', 'BER of Rayleigh','BER for Rician')
axis([ -30 30 0 1 ])
title(['BER comparisons at N=6 bits ']);
xlabel('SNR (dB)');
ylabel('BER values');