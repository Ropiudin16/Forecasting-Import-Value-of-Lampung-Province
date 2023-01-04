clc;clear;close all;warning off;
 
% Proses membaca data latih dari excel
rng(100)
filename = 'DATA SKRIPSI.xlsx';
sheet = 2;
xlRange = 'H3:K29';
 
Data = xlsread(filename, sheet, xlRange);
data_uji = Data(:,1:3)';
target_uji = Data(:,4)';
[m,n] = size(data_uji);
 
% Pembuatan JST
net = newff(minmax(data_uji),[20 1],{'tansig','purelin'},'trainlm');
 
% Memberikan nilai untuk mempengaruhi proses pelatihan
net.trainParam.goal = 0.001;
net.trainParam.show = 25;
net.trainParam.epochs = 1000;
net.trainParam.mc = 0.9;
net.trainParam.lr = 0.01;
 
% Proses training
[net_keluaran,tr,Y,E] = train(net,data_uji,target_uji);
 
% Hasil setelah pelatihan
jumlah_iterasi = tr.num_epochs;
nilai_keluaran = Y;
nilai_error = E;
error_MSE = (1/n)*sum(nilai_error.^2);

% Hasil prediksi
hasil_uji_norm = sim(net_keluaran,data_uji);
max_data = 480.08;
min_data = 61.8;
hasil_uji = ((hasil_uji_norm-0.1)*(max_data-min_data)/0.8)+min_data;
 
% Performansi hasil prediksi
filename = 'DATA SKRIPSI.xlsx';
sheet = 1;
xlRange = 'K66:K92';
 
target_uji_asli = xlsread(filename, sheet, xlRange);
target_uji_asli = target_uji_asli';
 
figure,
plotregression(target_uji_asli,hasil_uji,'Regression')
 
figure,
plotperform(tr)
 
figure,
plot(hasil_uji,'bo-')
hold on
plot(target_uji_asli,'ro-')
hold off
grid on
title(strcat(['Grafik Keluaran JST vs Target dengan nilai MSE = ',...
num2str(error_MSE)]))
xlabel('Pola ke-')
ylabel('Nilai Impor')
legend('Keluaran JST','Target','Location','Best')

%NILAI MSE
e1 = target_uji - hasil_uji_norm;
mse1 = mse(e1);
e2 = target_uji_asli - hasil_uji;
mse2 = mse(e2);

%NILAI MAPE
mape1 = ((abs(e1))./target_uji).*100;
MAPE1 = sum(mape1)/27;
mape2 = ((abs(e2))./target_uji_asli).*100;
MAPE2 = sum(mape2)/27;

% menyiapkan data prediksi normalisasi
data_prediksi_norm = hasil_uji_norm(end-26:end);
% melakukan transpose terhadap data prediksi normalisai
data_prediksi_norm = data_prediksi_norm';

% melakukan prediksi
hasil_prediksi_norm = sim(net_keluaran,data_prediksi_norm);

% melakukan denormalisai terhadap hasil prediksi normalisasi 
max_data = 480.08;
min_data = 61.8;
hasil_prediksi = ((hasil_prediksi_norm-0.1)*(max_data-min_data)/0.8)+min_data;



