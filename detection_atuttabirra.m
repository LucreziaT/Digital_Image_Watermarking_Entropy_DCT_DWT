
function [destruction, wpsnr] = detection_atuttabirra(original_img, watermarked_img, attacked_img)

%% Loading image
I = imread(original_img);
IW = imread(watermarked_img);
AI = imread(attacked_img);

%% Usefull parameters
n_block = 8;

J = entropyfilt(I);
J=uint8(J);
bw = imbinarize(J,  graythresh(J) + 0.004);

alpha=0.35;

%% Division phase of treshold and original image

ITB = DivisionInBlock(bw, n_block); %immagine treshold in blocchi
IBO = DivisionInBlock(I, n_block); %immagine originale in blocchi
IWB = DivisionInBlock(IW, n_block);
AWB = DivisionInBlock(AI, n_block); %immagine watermarkata attaccata in blocchi

entropy_values = 0;
%% calculationg best block of treshold image
for j=1:n_block*n_block
    block  = ITB{j};
    block = uint8(block);
    n_entropy(j) = sum(block, 'all');
    entropy_values = n_entropy(j) + entropy_values;
end

%% Sorting best block
[entropy_sort, entropy_index] = sort(n_entropy, 'descend');

s = 0;
% s_new = 0;
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
w_dctn = IWB;

cA=IBO;
cH=IBO;
cV=IBO;
cD=IBO;

cWA=IWB;
cWH=IWB;
cWV=IWB;
cWD=IWB;

cAWA=AWB;
cAWH=AWB;
cAWV=AWB;
cAWD=AWB;

for i=1:64    
    [cA{i},cH{i},cV{i},cD{i}] = dwt2(IBO{i},'haar');        % DWT Original
    dctn{i}=dct2(cA{i});                                    % DCT
    dctn_dwt{i}=reshape(dctn{i},1,32*32);
    [cWA{i},cWH{i},cWV{i},cWD{i}] = dwt2(IWB{i},'haar');    % DWT Watermarked
    w_dctn{i}=dct2(cWA{i});                                 % DCT
    w_dctn_dwt{i}=reshape(w_dctn{i},1,32*32);
    [cAWA{i},cAWH{i},cAWV{i},cAWD{i}] = dwt2(AWB{i},'haar');% DWT Attacked
    aw_dctn{i}=dct2(cAWA{i});                               % DCT
    aw_dctn_dwt{i}=reshape(aw_dctn{i},1,32*32);
end

mark_bit = 0;
n = 0;
[~,q] = size(new_factors);
w = zeros(1, 1024);
w_ext = w;

for i=1:q
    
    if(mark_bit < 1024)                         % insert only if there are still mark_bit

        dwt_mat = dctn_dwt{1,entropy_index(i)};
        w_dwt_mat = w_dctn_dwt{1,entropy_index(i)};
        aw_dwt_mat = aw_dctn_dwt{1,entropy_index(i)};

        %% Coefficient selection (hint: use sign, abs and sort functions)
        It_mod = abs(dwt_mat);
        Itw_mod = abs(w_dwt_mat);
        Itaw_mod = abs(aw_dwt_mat);
        [~, Ix] = sort(It_mod, 'descend');
    
        %% Embedding
        k=2;
        for j = 1:new_factors(i)
            if(mark_bit < 1024)                 % i insert as n mark_bit as i calculated before each information block
                m = Ix(k);
                if i==1
                    w(j) = (Itw_mod(m) - It_mod(m)) / (alpha * It_mod(m));
                    w_ext(j) = (Itaw_mod(m) - It_mod(m)) / (alpha * It_mod(m));
                    n=new_factors(i);
                    if(w(j) >= 0.5)
                        w(j) = 1;
                    else
                        w(j) = 0;
                    end
                    if(w_ext(j) >= 0.5)
                        w_ext(j) = 1;
                    else
                        w_ext(j) = 0;
                    end
                else
                    n=n+1;
                    w(n) = (Itw_mod(m) - It_mod(m)) / (alpha * It_mod(m));
                    w_ext(n) = (Itaw_mod(m) - It_mod(m)) / (alpha * It_mod(m));
                    if(w(n) >= 0.5)
                        w(n) = 1;
                    else
                        w(n) = 0;
                    end
                    if(w_ext(n) >= 0.5)
                        w_ext(n) = 1;
                    else
                        w_ext(n) = 0;
                    end
                end
                k = k + 1;
                mark_bit = mark_bit + 1; 
            end
        end
        
    end
    
end

%% Detection
SIM=(w * w_ext')/sqrt(w_ext * w_ext');

%% Compute threshold ->
% randWatermarks = round(rand(999, size(w,2)));
% x = zeros(1, 1000);
% 
% x(1) = SIM;
% for i = 1:999
%     w_rand = randWatermarks(i, :);
%     x(i+1) = w * w_rand' / sqrt(w_rand * w_rand');
% end
% 
% x = abs(x);
% x = sort(x, 'descend');
% t = x(2);
% T = t + 0.1*t;
% 
% fprintf('Threshold T: %f\n', T);
T = 14;

%% Decision
if SIM > T
    d = 1; %1
else
    d = 0; %0
end

q2 = WPSNR(AI, IW);

% disp('Done');

destruction = d;
wpsnr = q2;

end

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
