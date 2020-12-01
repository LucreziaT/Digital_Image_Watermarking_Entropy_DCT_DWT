close all; clear all; clc;

%% divido il mark in byte e li inserisco nei 128 blocchi piu significativi
%% gli 0 non modificano i componenti della DCT mentre gli 1 seguono la motiplicative

%% Loading image
imName='lena';
groupname='atuttabirra';
ext = 'bmp';
I = imread(sprintf('%s.%s', imName, ext));
w = load('atuttabirra.mat').w;
figure; 
imshow(w);
%% usefull parameters
n_block = 8;

J = entropyfilt(I);
J=uint8(J);
bw = imbinarize(J,  graythresh(J) + 0.0039);
figure;
%subplot(1,3,1);imshow(I);title('Original');
%subplot(1,3,2);imshow(J,[]);title('Entropy');
%imshow(bw,[]);title('Threshold');
%imwrite(J,'Threshold.jpg');
IW = I;

alpha=0.35; % con la SS moltiplicative non puo essere maggiore di 1 senno taglia valoriii!

%% Division phase of treshold and original image
ITB = DivisionInBlock(bw, n_block);
IBO = DivisionInBlock(I, n_block);
IWB = DivisionInBlock(w, n_block);
entropy_values = 0;
%% calculationg best block
for j=1:n_block*n_block
    block = ITB{j};
    block = uint8(block);
    n_entropy(j) = sum(block, 'all');
    entropy_values = n_entropy(j) + entropy_values;
end

%% Sorting best block
[entropy_sort, entropy_index] = sort(n_entropy, 'descend');

s = 0;
s_new = 0;
n_min = 10*entropy_values/1024;
new_entropy_values = 0;
for i=1:64
    if(entropy_sort(i) >= n_min) % se il rapporto entropia/index e almeno 10
        new_entropy_sort(i) = entropy_sort(i);
        n = entropy_sort(i)/(entropy_values/1024);
        s = s + n;
        new_entropy_values = new_entropy_sort(i) + new_entropy_values;
    end
end
[~,n] = size(new_entropy_sort);
i = 1;
while s < 1024
    new_entropy_sort(n+i) = entropy_sort(n+i);
    new_entropy_values = new_entropy_sort(n+i) + new_entropy_values;
    i = i + 1;
    s = s + entropy_sort(i)/(entropy_values/1024);
end

index = floor(new_entropy_values/1024);
new_factors = round(new_entropy_sort/index);

%% DCT Embedding
dctn = IBO;

cA=IBO;
cH=IBO;
cV=IBO;
cD=IBO;

for i=1:64
    [cA{i},cH{i},cV{i},cD{i}] = dwt2(IBO{i},'haar');    % DWT
    dctn{i}=dct2(cA{i});                                % DCT
    ca_dct{i}=reshape(dctn{i},1,32*32);
    I_watn{i} = cA{i};
end

w = reshape(w, 1, 32*32);
mark_bit = 0;
n = 0;
[~,q] = size(new_factors);

for i=1:q

    if(mark_bit < 1024)                         % insert only if there are still mark_bit

        ca_mat = ca_dct{1,entropy_index(i)};

        %% Coefficient selection (hint: use sign, abs and sort functions)
        It_sng = sign(ca_mat);
        It_mod = abs(ca_mat);
        [It_sort, Ix] = sort(It_mod, 'descend');
    
        %% Embedding
        Itw_mod = It_mod;
        k=2; %490
        for j = 1:new_factors(i)
            if(mark_bit < 1024)
                m = Ix(k);
                if i==1
                    a=1 + alpha * w(j);
                    Itw_mod(m) = It_mod(m) * (a);
                    n=new_factors(i);
                else
                    n=n+1;
                    a=1 + alpha * w(n);
                    Itw_mod(m) = It_mod(m) * (a); % without ; it print the values on Command Window
                end
                k = k + 1;
                mark_bit = mark_bit + 1; 
            end
        end

        %% Restore the sign and go back to matrix representation using reshape
        It_new=Itw_mod .* It_sng;               %rimette a posto i segni
        It_newi=reshape(It_new,32,32);          %ricrea matrice
        
        %% Inverse DCT
        I_wat=idct2(It_newi);
        I_watn{entropy_index(i)} = I_wat;
        
    end
    
end

%% Inverse DWT
for i=1:64
    Idwt_watn{i} = idwt2(I_watn{i},cH{i},cV{i},cD{i},'haar');
end

%% Rebuild image
ctr = 1;
block = 512/n_block;
for i=1:n_block
    start_y = (i-1)*block+1;
    finish_y = i*block;
    for j=1:n_block
        start_x = (j-1)*block+1;
        finish_x = j*block;   
        IW((start_x: finish_x), (start_y:finish_y)) = Idwt_watn{ctr};
        ctr = ctr + 1;
    end
end

%% calculate WPSNR
q2 = WPSNR(I, IW);
fprintf('WPSNR = +%5.2f dB\n',q2);

imwrite(IW,sprintf('%s_%s.%s', imName, groupname, ext));

figure;
subplot(1,2,1)
imshow(I);
title('Original');

subplot(1,2,2)
imshow(IW);
title('Watermarked');
disp('Done');

function result = DivisionInBlock(I,n_block)
    [dimx,dimy] = size(I);
    block = dimx/n_block;
    ctr = 1;
    for i=1:n_block
        start_y = (i-1)*block+1;
        finish_y = i*block;
        for j=1:n_block
            start_x = (j-1)*block+1;
            finish_x = j*block;   
            IB(ctr) = {I((start_x: finish_x), (start_y:finish_y))};
            ctr =ctr + 1;
        end
    end
    result = IB;
end
