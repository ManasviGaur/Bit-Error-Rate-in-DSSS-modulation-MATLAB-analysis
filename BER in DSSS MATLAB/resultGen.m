function [output1] = resultGen(input1,input2,input3,input4,input5)
    demodSignal = input1.*input2;
    output1 = [];
    for i = 1:length(input4)
       x = length(input3)*input5;
       cropCarrier = sum(input2(((i-1)*x)+1:i*x).*demodSignal(((i-1)*x)+1:i*x));
       if(cropCarrier>0)
           output1 = [output1 1];
       else
           output1 = [output1 -1];
       end
    end
end

