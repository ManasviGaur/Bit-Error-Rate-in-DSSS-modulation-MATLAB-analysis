function [output1] = receivedGen(input1,input2,input3)
    output1 = [];
    for i = 1:length(input1)
        crop = input2((((i-1)*length(input3))+1):i*length(input3));
        if(input1(i)==1)
            output1 = [output1 crop];
        else
            output1 = [output1 (-1)*crop];
        end    
    end 
end

