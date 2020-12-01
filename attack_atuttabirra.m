close all; clear all; clc;

%% This function applies attacks on images

destruction = 0;
wpsnr = 0;
best_wpsnr = 0;

imName='lena';
groupname='atuttabirra';
attacked_groupname = 'gruppoA';
ext = 'bmp';
filename = fullfile('C:\Users\Lucrezia\Documents\EserciziMatlabMDS\Finale\AttackedImages', sprintf('%s_%s_%s.%s', groupname, attacked_groupname, imName, ext));
% filename = sprintf('%s_%s_%s.%s', groupname, attacked_groupname, imName, ext);

Original = sprintf('%s.%s', imName, ext);
Watermarked = sprintf('%s_%s.%s', imName, groupname, ext);
Attacked = Watermarked;

% [destruction, wpsnr] = DCTentropyDetectionFunction_atuttabirra(Original, Watermarked, Attacked);
% watermarkedatt_image = test_median(imread(Original), 20, 20);
attack_name = ["median","awgn","sharp","blur","jpeg","resize"];
wpsnr_s = [0,0,0,0,0,0];
for i=1:6
    [wpsnr_s(i), best_wpsnr] = attacks(destruction, wpsnr, Original, Watermarked, Attacked, attack_name(i), filename, best_wpsnr);
end

function [wpsnr_s, best_wpsnr] = attacks(destruction, wpsnr, original, watermarked, attacked, attack_name, filename, best_wpsnr)
    
    
    
    switch attack_name

        %% Median
        case 'median'
            fprintf('Median attack in course...\n');
            
            Im = imread(watermarked);
            indice = 0;
            media = 7.0;
            wpsnr_previous = 0;
            na = media;
            nb = na;
            nprec = na; 
            accuracy = 1; %smallest value that i can set
            done = 0; %tells me when the attack is done
            check = 0;

            while indice==0 %quando indice diventa 1 ho trovato il valore limite tale per cui il wpsnr è il più alto e ho distrutto l immagine 
                
%                 fprintf('WPSNR tentativo con na= %f: %f  \n', na, wpsnr);
%                 fprintf('WPSNR tentativo con wpsnr_previous= %f: %f  \n', wpsnr_previous, wpsnr);
                wpsnr_previous=wpsnr;
                Ima = test_median(Im, na, nb);
                imwrite(Ima, 'attacked.bmp')
%                 [destruction, wpsnr] = DWTDCTEntropyDetectionFunction_atuttabirra(original, watermarked, 'attacked.bmp');
                [destruction, wpsnr] = detection_atuttabirra(original, watermarked, 'attacked.bmp');

                if destruction == 0 %watermark dead
                    nprec=na; 
                    media=media-1;%media che utilizzerò nxt giro
                    if (media == 0)
                        fprintf('Ineffective attack\n');
                        wpsnr_s = wpsnr;
                        break;
                    end
                    na=media;
                    nb=na;
                    check = 1;
                    
                elseif destruction == 1 %watermark alive
%                     fprintf('Found\n');
                    if wpsnr < 35
                        fprintf('Ineffective attack\n');
                        wpsnr_s = wpsnr;
                        break;
                    end
                    if check == 1
                        if nprec-na == accuracy
                            done = 1;
                        else
                            nprec=na;
                            media=media+1;%media che utilizzerò nxt giro
                            na=media; 
                            nb=na;
                        end
                    else
                        nprec=na;
                        media=media+1;%media che utilizzerò nxt giro
                        na=media; 
                        nb=na;  
                    end   
                end

                if done == 1
                    
                    a = nprec;
                    b = nprec;
                    wpsnrn = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
                    a_w = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
                    b_w = a_w;
                    n = 0;
                    
                    for i=1:4
                        for j=1:4
                            if (a-i+2 > 0 && b-j+2 > 0)
                                Ima = test_median(Im, a-i+2, b-j+2);
                                imwrite(Ima, 'attacked.bmp')
    %                             [destruction, wpsnr] = DWTDCTEntropyDetectionFunction_atuttabirra(original, watermarked, 'attacked.bmp');
                                [destruction, wpsnr] = detection_atuttabirra(original, watermarked, 'attacked.bmp');
                                if destruction == 0
                                    n = n + 1;
                                    wpsnrn(n) = wpsnr;
                                    a_w(n) = a-i+2;
                                    b_w(n) = b-j+2;
                                end
                            end
                        end
                    end
                    
                    [sorted,i]=sort(wpsnrn,'descend');  
                    wpsnr_s = sorted(1);
                    
                    fprintf('Trovato il tradeoff migliore: wpsnr: %f \n', sorted(1));
                    fprintf('Valori ottimali utilizzati: %f %f \n', a_w(i(1)), b_w(i(1)));
                    figure;
                    subplot(1,2,1);imshow(watermarked);title("Original");
                    subplot(1,2,2);imshow(attacked);title("Median Attacked");
                    indice = 1;
                        
                end
                
            end
            
            if wpsnr_s > best_wpsnr
                imwrite(Ima, filename);
                best_wpsnr = wpsnr_s;
            end
            
            fprintf('Median attack done.\n');
            
        %% Awgn
        case 'awgn'
            fprintf('Awgn attack in course...\n');
            
            Im = imread(watermarked);
            indice = 0;
            wpsnr_previous = 0;
            NoisePower = 0.0001;   %ocio a sti valori senno non finisce mai il ciclo
            nprec = NoisePower;
            seed = 3; %123 e forse piu aggressivo
            media = NoisePower;
            accuracy = 0.00005;      %
            done = 0;
            check = 0;
            
            while indice==0 %quando indice diventa 1 ho trovato il valore limite tale per cui il wpsnr è il più alto e ho distrutto l immagine 
                
%                 fprintf('WPSNR tentativo con na= %f: %f  \n', NoisePower, wpsnr);
%                 fprintf('WPSNR tentativo con wpsnr_previous= %f: %f  \n', wpsnr_previous, wpsnr);
                wpsnr_previous=wpsnr;
                Ima = test_awgn(Im, NoisePower, seed);
                imwrite(Ima, 'attacked.bmp')
%                 [destruction, wpsnr] = DWTDCTEntropyDetectionFunction_atuttabirra(original, watermarked, 'attacked.bmp');
                [destruction, wpsnr] = detection_atuttabirra(original, watermarked, 'attacked.bmp');
                if destruction == 0 %watermark dead
                    nprec=NoisePower; 
                    media=round((media-media/2)*1000000)/1000000;%media che utilizzerò nxt giro
                    NoisePower=media;
                    check = 1;
                elseif destruction == 1 %watermark alive
                    if wpsnr < 35
                        fprintf('Ineffective attack\n');
                        wpsnr_s = wpsnr;
                        break;
                    end
                    if check == 1
                        if nprec-NoisePower < accuracy && nprec-NoisePower ~= 0
                            done = 1;
                        else
                            nprec=NoisePower;
                            media=round((media+media/2)*1000000)/1000000;%media che utilizzerò nxt giro
                            NoisePower=media; 
                        end
                    else
                        nprec=NoisePower;
                        media=round((media+media/2)*1000000)/1000000;%media che utilizzerò nxt giro
                        NoisePower=media; 
                    end
                    
                end

                if done == 1
                    while destruction == 1
                        NoisePower = NoisePower + 0.0001;
                        Ima = test_awgn(Im, NoisePower, seed);
                        imwrite(Ima, 'attacked.bmp')
%                         [destruction, wpsnr] = DWTDCTEntropyDetectionFunction_atuttabirra(original, watermarked, 'attacked.bmp');
                        [destruction, wpsnr] = detection_atuttabirra(original, watermarked, 'attacked.bmp');
                    end
                    while destruction == 0
                        NoisePower = NoisePower - 0.00001;
                        Ima = test_awgn(Im, NoisePower, seed);
                        imwrite(Ima, 'attacked.bmp')
%                         [destruction, wpsnr] = DWTDCTEntropyDetectionFunction_atuttabirra(original, watermarked, 'attacked.bmp');
                        [destruction, wpsnr] = detection_atuttabirra(original, watermarked, 'attacked.bmp');
                    end
                    fprintf('Trovato il tradeoff migliore: wpsnr: %f \n', wpsnr);
                    fprintf('Valori ottimali utilizzati: %f \n', NoisePower);
                    figure;
                    subplot(1,2,1);imshow(watermarked);title("Original");
                    subplot(1,2,2);imshow(attacked);title("Awgn Attacked");
                    wpsnr_s = wpsnr;
                    indice=1;
                end

            end
            
            if wpsnr_s > best_wpsnr
                imwrite(Ima, filename);
                best_wpsnr = wpsnr_s;
            end
            
            fprintf('Awgn attack done.\n');

        %% Sharp
        case 'sharp' %attacco del minkio
            fprintf('Sharp attack in course...\n');
            
            Im = imread(watermarked);
            nRad = 1;      % positive number
            nPower = 1;    % scalar
            thr = 0;        % [0,1] 0 is stronger
            indice = 0;
            wpsnr_previous = 0;
            nprec = nPower;
            media = nPower;
            accuracy = 0.1;      
            done = 0;
            check = 0;
            ineffective = 0;
            
            while indice==0 %quando indice diventa 1 ho trovato il valore limite tale per cui il wpsnr è il più alto e ho distrutto l immagine 
                
%                 fprintf('WPSNR tentativo con na= %f: %f  \n', nPower, wpsnr);
%                 fprintf('WPSNR tentativo con wpsnr_previous= %f: %f  \n', wpsnr_previous, wpsnr);
                wpsnr_previous=wpsnr;
                Ima = test_sharpening(Im, nRad, nPower, thr);
                imwrite(Ima, 'attacked.bmp')
%                 [destruction, wpsnr] = DWTDCTEntropyDetectionFunction_atuttabirra(original, watermarked, 'attacked.bmp');
                [destruction, wpsnr] = detection_atuttabirra(original, watermarked, 'attacked.bmp');
                if destruction == 0 %watermark dead
                    nprec=nPower; 
                    media=round((media-media/2)*1000000)/1000000;%media che utilizzerò nxt giro
                    nPower=media;
                    check = 1;
                elseif destruction == 1 %watermark alive
                    if wpsnr < 35
                        fprintf('Ineffective attack\n');
                        wpsnr_s = wpsnr;
                        break;
                    end
                    if check == 1
                        if nprec-nPower <= accuracy
                            done = 1;
                        else
                            nprec=nPower;
                            media=round((media+media/2)*1000000)/1000000;%media che utilizzerò nxt giro
                            nPower=media;
                        end
                    else
                        nprec=nPower;
                        media=round((media+media/2)*1000000)/1000000;%media che utilizzerò nxt giro
                        nPower=media; 
                    end
                    
                end

                if done == 1
                    while destruction == 1
                        nPower = nPower + 0.1;
                        Ima = test_sharpening(Im, nRad, nPower, thr);
                        imwrite(Ima, 'attacked.bmp')
%                         [destruction, wpsnr] = DWTDCTEntropyDetectionFunction_atuttabirra(original, watermarked, 'attacked.bmp');
                        [destruction, wpsnr] = detection_atuttabirra(original, watermarked, 'attacked.bmp');
                        if wpsnr < 35
                            ineffective = 1;
                            fprintf('Ineffective attack\n');
                            wpsnr_s = wpsnr;
                            break;
                        end
                    end
                    if ineffective == 1
                        fprintf('The Image has been Broken\n');
                        wpsnr_s = wpsnr;
                        break;
                    end
                    while destruction == 0
                        nPower = nPower - 0.01;
                        Ima = test_sharpening(Im, nRad, nPower, thr);
                        imwrite(Ima, 'attacked.bmp')
                        wpsnr_previous = wpsnr;
%                         [destruction, wpsnr] = DWTDCTEntropyDetectionFunction_atuttabirra(original, watermarked, 'attacked.bmp');
                        [destruction, wpsnr] = detection_atuttabirra(original, watermarked, 'attacked.bmp');
                    end
                    fprintf('Trovato il tradeoff migliore: wpsnr: %f \n', wpsnr_previous);
                    fprintf('Valori ottimali utilizzati: %f \n', nPower);
                    figure;
                    subplot(1,2,1);imshow(watermarked);title("Original");
                    subplot(1,2,2);imshow(attacked);title("Sharp Attacked");
                    wpsnr_s = wpsnr_previous;
                    indice=1;
                end

            end
            
            if wpsnr_s > best_wpsnr
                imwrite(Ima, filename);
                best_wpsnr = wpsnr_s;
            end
            
            fprintf('Sharp attack done.\n');
            
       %% Blur
        case 'blur'
            fprintf('Blur attack in course...\n');
            
            Im = imread(watermarked);
            indice=0;
            media=0.5; % default
            wpsnr_previous=0;
            NoisePower=media;
            nprec=0;
            accuracy = 1.3;      
            done = 0;
            check = 0;
            
            while indice==0 %quando indice diventa 1 ho trovato il valore limite tale per cui il wpsnr è il più alto e ho distrutto l immagine 
                
%                 fprintf('WPSNR tentativo con na= %f: %f  \n', NoisePower, wpsnr);
%                 fprintf('WPSNR tentativo con wpsnr_previous= %f: %f  \n', wpsnr_previous, wpsnr);
                wpsnr_previous=wpsnr;
                Ima = test_blur(Im, NoisePower);
                imwrite(Ima, 'attacked.bmp')
%                 [destruction, wpsnr] = DWTDCTEntropyDetectionFunction_atuttabirra(original, watermarked, 'attacked.bmp');
                [destruction, wpsnr] = detection_atuttabirra(original, watermarked, 'attacked.bmp');
                if destruction == 0 %watermark dead
                    nprec=NoisePower; 
                    media=round((media-media/2)*10000)/10000;%media che utilizzerò nxt giro
                    NoisePower=media;
                    check = 1;
                elseif destruction == 1 %watermark alive
                    if wpsnr < 35
                        fprintf('Ineffective attack\n');
                        wpsnr_s = wpsnr;
                        break;
                    end
                    if check == 1
                        if abs(nprec-NoisePower) <= accuracy
                            done = 1;
                        else
                            nprec=NoisePower;
                            media=round((media+media/2)*10000)/10000;%media che utilizzerò nxt giro
                            NoisePower=media;
                        end
                    else
                        nprec=NoisePower;
                        media=round((media+media/2)*10000)/10000;%media che utilizzerò nxt giro
                        NoisePower=media;
                    end
                    
                end

                if done == 1
                    while destruction == 1
%                         fprintf('WPSNR tentativo con na= %f: %f  \n', NoisePower, wpsnr);
%                         fprintf('WPSNR tentativo con wpsnr_previous= %f: %f  \n', wpsnr_previous, wpsnr);
                        wpsnr_previous=wpsnr;
                        NoisePower = NoisePower + 0.01;
                        Ima = test_blur(Im, NoisePower);
                        imwrite(Ima, 'attacked.bmp')
%                         [destruction, wpsnr] = DWTDCTEntropyDetectionFunction_atuttabirra(original, watermarked, 'attacked.bmp');   
                        [destruction, wpsnr] = detection_atuttabirra(original, watermarked, 'attacked.bmp');
                    end
                    while destruction == 0
%                         fprintf('WPSNR tentativo con na= %f: %f  \n', NoisePower, wpsnr);
%                         fprintf('WPSNR tentativo con wpsnr_previous= %f: %f  \n', wpsnr_previous, wpsnr);
                        wpsnr_previous=wpsnr;
                        NoisePower = NoisePower - 0.001;
                        Ima = test_blur(Im, NoisePower);
                        imwrite(Ima, 'attacked.bmp')
%                         [destruction, wpsnr] = DWTDCTEntropyDetectionFunction_atuttabirra(original, watermarked, 'attacked.bmp');   
                        [destruction, wpsnr] = detection_atuttabirra(original, watermarked, 'attacked.bmp');
                    end
                    while destruction == 1
%                         fprintf('WPSNR tentativo con na= %f: %f  \n', NoisePower, wpsnr);
%                         fprintf('WPSNR tentativo con wpsnr_previous= %f: %f  \n', wpsnr_previous, wpsnr);
                        wpsnr_previous=wpsnr;
                        NoisePower = NoisePower + 0.0001;
                        Ima = test_blur(Im, NoisePower);
                        imwrite(Ima, 'attacked.bmp')
%                         [destruction, wpsnr] = DWTDCTEntropyDetectionFunction_atuttabirra(original, watermarked, 'attacked.bmp');   
                        [destruction, wpsnr] = detection_atuttabirra(original, watermarked, 'attacked.bmp');
                    end
                    while destruction == 0
%                         fprintf('WPSNR tentativo con na= %f: %f  \n', NoisePower, wpsnr);
%                         fprintf('WPSNR tentativo con wpsnr_previous= %f: %f  \n', wpsnr_previous, wpsnr);
                        wpsnr_previous=wpsnr;
                        NoisePower = NoisePower - 0.00001;
                        Ima = test_blur(Im, NoisePower);
                        imwrite(Ima, 'attacked.bmp')
%                         [destruction, wpsnr] = DWTDCTEntropyDetectionFunction_atuttabirra(original, watermarked, 'attacked.bmp');   
                        [destruction, wpsnr] = detection_atuttabirra(original, watermarked, 'attacked.bmp');
                    end
                    while destruction == 1
%                         fprintf('WPSNR tentativo con na= %f: %f  \n', NoisePower, wpsnr);
%                         fprintf('WPSNR tentativo con wpsnr_previous= %f: %f  \n', wpsnr_previous, wpsnr);
                        wpsnr_previous=wpsnr;
                        NoisePower = NoisePower + 0.000001;
                        Ima = test_blur(Im, NoisePower);
                        imwrite(Ima, 'attacked.bmp')
%                         [destruction, wpsnr] = DWTDCTEntropyDetectionFunction_atuttabirra(original, watermarked, 'attacked.bmp');   
                        [destruction, wpsnr] = detection_atuttabirra(original, watermarked, 'attacked.bmp');
                    end
                    fprintf('Trovato il tradeoff migliore: wpsnr: %f \n', wpsnr);
                    fprintf('Valori ottimali utilizzati: %f \n', NoisePower);
                    figure;
                    subplot(1,2,1);imshow(watermarked);title("Original");
                    subplot(1,2,2);imshow(attacked);title("Blur Attacked");
                    wpsnr_s = wpsnr;
                    indice=1;
                end

            end
            
            if wpsnr_s > best_wpsnr
                imwrite(Ima, filename);
                best_wpsnr = wpsnr_s;
            end
            
            fprintf('Blur attack done.\n');

        %% Jpeg
        case 'jpeg'
            fprintf('Jpeg attack in course...\n');
            
            Im = imread(watermarked);
            indice=0;
            media=100;
            wpsnr_previous=0;
            QF=media;
            nprec=0;
            accuracy = 1;      
            done = 0;
            check = 0;
            
            while indice==0 %quando indice diventa 1 ho trovato il valore limite tale per cui il wpsnr è il più alto e ho distrutto l immagine 
%                 fprintf('WPSNR tentativo con na= %f: %f  \n', QF, wpsnr);
%                 fprintf('WPSNR tentativo con wpsnr_previous= %f: %f  \n', wpsnr_previous, wpsnr);
                wpsnr_previous=wpsnr;
                Ima = test_jpeg(Im, QF);
                imwrite(Ima, 'attacked.bmp')
%                 [destruction, wpsnr] = DWTDCTEntropyDetectionFunction_atuttabirra(original, watermarked, 'attacked.bmp');
                [destruction, wpsnr] = detection_atuttabirra(original, watermarked, 'attacked.bmp');
                if destruction == 0 %watermark dead
                    nprec=QF; 
                    media=media+accuracy;%media che utilizzerò nxt giro
                    QF=media;
                    check = 1;
                elseif destruction == 1 %watermark alive
                    if wpsnr < 35
                        fprintf('Ineffective attack\n');
                        wpsnr_s = wpsnr;
                        break;
                    end
                    if check == 1
                        if abs(nprec-QF) <= accuracy
                            done = 1;
                        else
                            nprec=QF;
                            media=media-accuracy;%media che utilizzerò nxt giro
                            QF=media;
                        end
                    else
                        nprec=QF;
                        media=media-accuracy;%media che utilizzerò nxt giro
                        QF=media;
                    end
                    
                end

                if done == 1
                    while destruction == 1
%                         fprintf('WPSNR tentativo con na= %f: %f  \n', QF, wpsnr);
%                         fprintf('WPSNR tentativo con wpsnr_previous= %f: %f  \n', wpsnr_previous, wpsnr);
                        wpsnr_previous=wpsnr;
                        QF = QF - 0.01;
                        Ima = test_jpeg(Im, QF);
                        imwrite(Ima, 'attacked.bmp')
%                         [destruction, wpsnr] = DWTDCTEntropyDetectionFunction_atuttabirra(original, watermarked, 'attacked.bmp');
                        [destruction, wpsnr] = detection_atuttabirra(original, watermarked, 'attacked.bmp');
                    end
                    while destruction == 0
%                         fprintf('WPSNR tentativo con na= %f: %f  \n', QF, wpsnr);
%                         fprintf('WPSNR tentativo con wpsnr_previous= %f: %f  \n', wpsnr_previous, wpsnr);
                        wpsnr_previous=wpsnr;
                        QF = QF + 0.001;
                        Ima = test_jpeg(Im, QF);
                        imwrite(Ima, 'attacked.bmp')
%                         [destruction, wpsnr] = DWTDCTEntropyDetectionFunction_atuttabirra(original, watermarked, 'attacked.bmp');
                        [destruction, wpsnr] = detection_atuttabirra(original, watermarked, 'attacked.bmp');
                    end
                    while destruction == 1
%                         fprintf('WPSNR tentativo con na= %f: %f  \n', QF, wpsnr);
%                         fprintf('WPSNR tentativo con wpsnr_previous= %f: %f  \n', wpsnr_previous, wpsnr);
                        wpsnr_previous=wpsnr;
                        QF = QF - 0.0001;
                        Ima = test_jpeg(Im, QF);
                        imwrite(Ima, 'attacked.bmp')
%                         [destruction, wpsnr] = DWTDCTEntropyDetectionFunction_atuttabirra(original, watermarked, 'attacked.bmp');
                        [destruction, wpsnr] = detection_atuttabirra(original, watermarked, 'attacked.bmp');
                    end
                    fprintf('Trovato il tradeoff migliore: wpsnr: %f \n', wpsnr);
                    fprintf('Valori ottimali utilizzati: %f \n', QF);
                    figure;
                    subplot(1,2,1);imshow(watermarked);title("Original");
                    subplot(1,2,2);imshow(attacked);title("Jpeg Attacked");
                    wpsnr_s = wpsnr;
                    indice=1;
                end

            end
            
            if wpsnr_s > best_wpsnr
                imwrite(Ima, filename);
                best_wpsnr = wpsnr_s;
            end
            
            fprintf('Jpeg attack done.\n');

       %% Resize
        case 'resize'
            fprintf('Resize attack in course...\n');
            
            Im = imread(watermarked);
            indice=0;
            media=1;
            wpsnr_previous=0;
            Scale=media;
            nprec=0;
            accuracy = 0.1;      
            done = 0;
            check = 0;
            
            while indice==0 %quando indice diventa 1 ho trovato il valore limite tale per cui il wpsnr è il più alto e ho distrutto l immagine 
%                 fprintf('WPSNR tentativo con na= %f: %f  \n', Scale, wpsnr);
%                 fprintf('WPSNR tentativo con wpsnr_previous= %f: %f  \n', wpsnr_previous, wpsnr);
                wpsnr_previous=wpsnr;
                Ima = test_resize(Im, Scale);
                imwrite(Ima, 'attacked.bmp')
%                 [destruction, wpsnr] = DWTDCTEntropyDetectionFunction_atuttabirra(original, watermarked, 'attacked.bmp');
                [destruction, wpsnr] = detection_atuttabirra(original, watermarked, 'attacked.bmp');
                if destruction == 0 %watermark dead
                    nprec=Scale; 
                    media=media+accuracy;%media che utilizzerò nxt giro
                    Scale=media;
                    check = 1;
                elseif destruction == 1 %watermark alive
                    if wpsnr < 35
                        fprintf('Ineffective attack\n');
                        wpsnr_s = wpsnr;
                        break;
                    end
                    if check == 1
                        if abs(nprec-Scale) <= accuracy
                            done = 1;
                        else
                            nprec=Scale;
                            media=media-accuracy;%media che utilizzerò nxt giro
                            Scale=media;
                        end
                    else
                        nprec=Scale;
                        media=media-accuracy;%media che utilizzerò nxt giro
                        Scale=media; 
                    end      
                end

                if done == 1
                    while destruction == 1
%                         fprintf('WPSNR tentativo con na= %f: %f  \n', Scale, wpsnr);
%                         fprintf('WPSNR tentativo con wpsnr_previous= %f: %f  \n', wpsnr_previous, wpsnr);
                        wpsnr_previous=wpsnr;
                        Scale = Scale - 0.01;
                        Ima = test_resize(Im, Scale);
                        imwrite(Ima, 'attacked.bmp')
%                         [destruction, wpsnr] = DWTDCTEntropyDetectionFunction_atuttabirra(original, watermarked, 'attacked.bmp');
                        [destruction, wpsnr] = detection_atuttabirra(original, watermarked, 'attacked.bmp');
                    end
                    while destruction == 0
%                         fprintf('WPSNR tentativo con na= %f: %f  \n', Scale, wpsnr);
%                         fprintf('WPSNR tentativo con wpsnr_previous= %f: %f  \n', wpsnr_previous, wpsnr);
                        wpsnr_previous=wpsnr;
                        Scale = Scale + 0.001;
                        Ima = test_resize(Im, Scale);
                        imwrite(Ima, 'attacked.bmp')
%                         [destruction, wpsnr] = DWTDCTEntropyDetectionFunction_atuttabirra(original, watermarked, 'attacked.bmp');
                        [destruction, wpsnr] = detection_atuttabirra(original, watermarked, 'attacked.bmp');
                    end
                    while destruction == 1
%                         fprintf('WPSNR tentativo con na= %f: %f  \n', Scale, wpsnr);
%                         fprintf('WPSNR tentativo con wpsnr_previous= %f: %f  \n', wpsnr_previous, wpsnr);
                        wpsnr_previous=wpsnr;
                        Scale = Scale - 0.0001;
                        Ima = test_resize(Im, Scale);
                        imwrite(Ima, 'attacked.bmp')
%                         [destruction, wpsnr] = DWTDCTEntropyDetectionFunction_atuttabirra(original, watermarked, 'attacked.bmp');
                        [destruction, wpsnr] = detection_atuttabirra(original, watermarked, 'attacked.bmp');
                    end
                    while destruction == 0
%                         fprintf('WPSNR tentativo con na= %f: %f  \n', Scale, wpsnr);
%                         fprintf('WPSNR tentativo con wpsnr_previous= %f: %f  \n', wpsnr_previous, wpsnr);
                        wpsnr_previous=wpsnr;
                        Scale = Scale + 0.00001;
                        Ima = test_resize(Im, Scale);
                        imwrite(Ima, 'attacked.bmp')
%                         [destruction, wpsnr] = DWTDCTEntropyDetectionFunction_atuttabirra(original, watermarked, 'attacked.bmp');
                        [destruction, wpsnr] = detection_atuttabirra(original, watermarked, 'attacked.bmp');
                    end
                    while destruction == 1
%                         fprintf('WPSNR tentativo con na= %f: %f  \n', Scale, wpsnr);
%                         fprintf('WPSNR tentativo con wpsnr_previous= %f: %f  \n', wpsnr_previous, wpsnr);
                        wpsnr_previous=wpsnr;
                        Scale = Scale - 0.000001;
                        Ima = test_resize(Im, Scale);
                        imwrite(Ima, 'attacked.bmp')
%                         [destruction, wpsnr] = DWTDCTEntropyDetectionFunction_atuttabirra(original, watermarked, 'attacked.bmp');
                        [destruction, wpsnr] = detection_atuttabirra(original, watermarked, 'attacked.bmp');
                    end
                    fprintf('Trovato il tradeoff migliore: wpsnr: %f \n', wpsnr);
                    fprintf('Valori ottimali utilizzati: %f \n', Scale);
                    figure;
                    subplot(1,2,1);imshow(watermarked);title("Original");
                    subplot(1,2,2);imshow(attacked);title("Resize Attacked");
                    wpsnr_s = wpsnr;
                    indice=1;
                end

            end
            
            if wpsnr_s > best_wpsnr
                imwrite(Ima, filename);
                best_wpsnr = wpsnr_s;
            end
            
            fprintf('Resize attack done.\n');
            
    end

end