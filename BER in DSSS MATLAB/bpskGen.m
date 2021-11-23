function [output1,output2] = bpskGen(input1,input2,input3)
    s0 = -1*cos(2*pi*input3*input2);
    s1 = cos(2*pi*input3*input2);
    output2 = [];
    output1 = [];
    for i = 1:length(input1)
        if (input1(i) == 1)
            output1 = [output1 s1];
        elseif (input1(i) == -1)
            output1 = [output1 s0];
        end 
        output2 = [output2 s1];
    end
end

