function [input1] = phaseShift(input1)
    for i = 1:length(input1)
       if(input1(i)==0)
            input1(i) = -1;
       end
    end 
end

