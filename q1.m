function [h, codewords, codewordsSF] = q1()
%h stores source entropy
%codewords contains codewords after hamming's code
%codewordsSF contains codewords after shannon-fano code
clear
format long
A = readmatrix("https://www.maths.cam.ac.uk/undergrad/catam/data/II-19-2-dataA.txt");
A(end, :) = [];
A = A + 1;%add one to every letter, so we work in 1= space, 2 = A, 3 = B, ... to fit matlab better
%disp(A)
%first need to create list of probabilities for alphabet in this text.
n = 400*25; %is the number of characters in the text
p = zeros(27, 1);
for i = 1:n
    for j = 1:27
        if A(i) == (j)
            p(j) = p(j) + 1;
        end
    end
end
%now divide all entries of p my n so that it is a probability
p = p./n;

%with this we can work out source entropy
h = 0;
for i = 1:27
    h = h - p(i) * log2(p(i));
end

letters = [1:1:27]';

p = [letters p];

psorted = sortrows(p, 2, {'descend'});%sorted by probabilities

codewords = strings(27, 1);%This will store the code words corresponding to the alphabet
%where position 1 stores cw for space, position 2 stores cw for A, etc.

I = num2cell(psorted); %first create copy of p as cell

for i = 1:26
    last1 = cell2mat(I(end, 1));
    last2 = cell2mat(I(end-1, 1));
    
    for k = 1:size(last1, 2)
        codewords(last1(k)) = '1' + codewords(last1(k));
    end
    for l = 1 : size(last2, 2)
        codewords(last2(l)) = '0' + codewords(last2(l));
    end
    
    I(end-1, 1) = {[last2, last1]};
    I{end-1, 2} = I{end-1, 2} + I{end, 2};
    I(end, :) = [];
    I = sortrows(I, 2, 'descend');
end

%now with codewords we can work out expected word length, E
E = 0;
for i = 1:27
    E = E + p(i, 2) * strlength(codewords(i));
end

%Now that's done do the same for Shannon-fano

lengths = ceil(-log2(p(:, 2)));
%lengths = [letters lengths];
%lengths = sortrows(lengths, 2);

cumulativep = zeros(27, 1);%will store the cumulative probabilities of the sorted p

for i = 2:27
    cumulativep(i) = cumulativep(i-1) + psorted(i-1, 2);
end

cumulativep = [psorted(:, 1) cumulativep];
cumulativep = sortrows(cumulativep, 1, 'ascend');

%Now workout codewords. again pos1 stores space, pos2 stores A etc
codewordsSF = strings(27, 1);

for i = 1:27
    for j = 1:lengths(i)
        temp = cumulativep(i, 2)*2;
        if temp >= 1
            codewordsSF(i) = codewordsSF(i) + '1';
            cumulativep(i, 2) = cumulativep(i, 2)*2 - 1;
        else
            codewordsSF(i) = codewordsSF(i) + '0';
            cumulativep(i, 2) = cumulativep(i, 2)*2;
        end
    end
end

%now work out corresponding expected length
ESF = 0;

for i = 1:27
    ESF = ESF + p(i, 2)*strlength(codewordsSF(i));
end

end

