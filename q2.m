function [] = q2()

clear
format long
A = readmatrix("https://www.maths.cam.ac.uk/undergrad/catam/data/II-19-2-dataA.txt");
A(end, :) = [];
A = A + 1;%add one to every letter, so we work in 1= space, 2 = A, 3 = B, ... to fit matlab better
%disp(A)
%first need to create list of probabilities for alphabet in this text.
n = 400*25; %is the number of characters in the text

%now create a new alphabet consisting of any combination of pairs of
%letters
alphabet = zeros(27*27, 2);
m = 27*27; %size of alphabet

for i = 1:27
    for j = 1:27
        alphabet((i-1)*27 + j, :) = [i, j];
    end
end

A = A';%take A transposed so we go through entries row by row of original A
p = zeros(m, 1);
for i = 1:2:n-1
    for j = 1:m
        if A(i) == alphabet(j, 1) && A(i+1) == alphabet(j, 2)
            p(j) = p(j) + 1;
        end
    end
end

%A contains n/2 pairs
p = p./(n/2);



%rename alphabet for easier process
L = [1:1:27*27]';
p = [L p];

psorted = sortrows(p, 2, 'descend');

%we can delete rows where probability is 0, as we assume those cannot
%occur.
for i = m:-1:1
    if psorted(i, 2) == 0
        psorted(i, :) = [];
    end
end

% %with this we can work out source entropy(Actually not needed)
% h = 0;
% for i = 1:size(psorted, 1)
%     h = h - psorted(i, 2) * log2(psorted(i, 2));
% end

%Now do Huffman again
codewords = strings(m, 1);

I = num2cell(psorted); %first create copy of p as cell

for i = 1:size(psorted, 1)-1
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

%Now find expected length
E = 0;
for i = 1:m
    E = E + p(i, 2) * strlength(codewords(i))/2;
end

end

