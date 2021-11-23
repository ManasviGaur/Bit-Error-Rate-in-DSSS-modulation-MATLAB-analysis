clear all;

Fs = 1000;
fc = 100;
fp = 4;
bitTime = 0.1;

originalMessage = [0 0 1 1 1 1 0 0 0 0 1 1 0 0 1 1];
originalMessage = phaseShift(originalMessage);

converted =  repmat(originalMessage,fp,1);
converted =  reshape(converted,1,[]);

pseudoNumber = randi([0,1],1,length(originalMessage)*fp);
pseudoNumber = phaseShift(pseudoNumber);

dsss = converted.*pseudoNumber;

t = 0:1/Fs:bitTime-(1/Fs);
[binaryPhase,carrier] = bpskGen(dsss,t,fc);

rx = receivedGen(pseudoNumber,binaryPhase,t);
result = resultGen(rx,carrier,t,originalMessage,fp);

converted1 =  repmat(result,fp,1);
converted1 =  reshape(converted1,1,[]);

pseudoNumberWrong = randi([0,1],1,length(originalMessage)*fp);
rxWrong = receivedGen(pseudoNumberWrong,binaryPhase,t);
resultWrong = resultGen(rxWrong,carrier,t,originalMessage,fp);

converted2 =  repmat(resultWrong,fp,1);
converted2 =  reshape(converted2,1,[]);

pseudoSize = length(pseudoNumber);
demodulated = rx.*carrier;
pseudoTime = linspace(0,length(originalMessage)*bitTime-bitTime/fp,pseudoSize);
messageTime = 0:bitTime/fp:length(originalMessage)*bitTime-bitTime/fp;

figure;
subplot(311)
stairs(messageTime,converted,'linewidth',2)
title('Message signal')
axis([0 length(originalMessage)*bitTime -1 1]);
subplot(312)
stairs(pseudoTime,pseudoNumber,'linewidth',2)
title('Randomised pseudo code');
axis([0 length(originalMessage)*bitTime -1 1]);
subplot(313)
stairs(pseudoTime,dsss,'linewidth',2)
title('Modulated signal');
axis([0 length(originalMessage)*bitTime -1 1]);

figure;
subplot(311)
stairs(messageTime,converted,'linewidth',2)
title('Message signal')
axis([0 length(originalMessage)*bitTime -1 1]);
subplot(312)
stairs(messageTime,converted1,'linewidth',2)
title('Demodulated signal using correct pseudo code')
axis([0 length(originalMessage)*bitTime -1 1]);
subplot(313)
stairs(messageTime,converted2,'linewidth',2)
title('Demodulated signal using wrong pseudo code')
axis([0 length(originalMessage)*bitTime -1 1]);

f = linspace(-Fs/2,Fs/2,1024);
figure;
subplot(311)
plot(f,abs(fftshift(fft(converted,1024))),'linewidth',2);
title('Message signal spectrum')
axis([0 512 0 30]);
subplot(312)
plot(f,abs(fftshift(fft(pseudoNumber,1024))),'linewidth',2);
title('Randomised pseudo code spectrum');
axis([0 512 0 30]);
subplot(313)
plot(f,abs(fftshift(fft(dsss,1024))),'linewidth',2);
title('Modulated signal spectrum');
axis([0 512 0 30]);

figure;
subplot(311)
plot(f,abs(fftshift(fft(binaryPhase,1024))),'linewidth',2);
title('Transmitted signal spectrum');
axis([0 512 0 400]);
subplot(312)
plot(f,abs(fftshift(fft(rx,1024))),'linewidth',2);
title('Spectrum for received signal multiplied by pseudo code');
axis([0 512 0 400]);
subplot(313)
plot(f,abs(fftshift(fft(demodulated,1024))),'linewidth',2);
title('Demodulated signal spectrum');
axis([0 512 0 400]);
