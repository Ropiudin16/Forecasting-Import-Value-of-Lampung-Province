clc;clear;close all;warning off;
 
% Proses membaca data latih dari excel
rng(100)
filename = 'DATA SKRIPSI.xlsx';
sheet = 3;
xlRange = 'B3:E92';
 
Data = xlsread(filename, sheet, xlRange);
data_ramalan = Data(:,1:3)';
target_ramalan = Data(:,4)';
[m,n] = size(data_ramalan);
 
% Pembuatan JST
net = newff(minmax(data_ramalan),[20 1],{'tansig','purelin'},'trainlm');
 
% Memberikan nilai untuk mempengaruhi proses pelatihan
net.trainParam.goal = 0.001;
net.trainParam.show = 25;
net.trainParam.epochs = 1000;
net.trainParam.mc = 0.9;
net.trainParam.lr = 0.01;
 
% Proses training
[net_keluaran,tr,Y,E] = train(net,data_ramalan,target_ramalan);
 
% Hasil setelah pelatihan
jumlah_iterasi = tr.num_epochs;
nilai_keluaran = Y;
nilai_error = E;
error_MSE = (1/n)*sum(nilai_error.^2);

% Hasil prediksi
hasil_ramalan_norm = sim(net_keluaran,data_ramalan);
max_data = 480.08;
min_data = 61.8;
hasil_ramalan = ((hasil_ramalan_norm-0.1)*(max_data-min_data)/0.8)+min_data;
 
% Performansi hasil prediksi
filename = 'DATA SKRIPSI.xlsx';
sheet = 1;
xlRange = 'K3:K92';
 
target_ramalan_asli = xlsread(filename, sheet, xlRange);
target_ramalan_asli = target_ramalan_asli';
 
figure,
plotregression(target_ramalan_asli,hasil_ramalan,'Regression')
 
figure,
plotperform(tr)
 
figure,
plot(hasil_ramalan,'bo-')
hold on
plot(target_ramalan_asli,'ro-')
hold off
grid on
title(strcat(['Grafik Keluaran JST vs Target dengan nilai MSE = ',...
num2str(error_MSE)]))
xlabel('Pola ke-')
ylabel('Nilai Impor')
legend('Keluaran JST','Target','Location','Best')

%NILAI MSE
e1 = target_ramalan - hasil_ramalan_norm;
mse1 = mse(e1);
e2 = target_ramalan_asli - hasil_ramalan;
mse2 = mse(e2);

%NILAI MAPE
mape1 = ((abs(e1))./target_ramalan).*100;
MAPE1 = sum(mape1)/90;
mape2 = ((abs(e2))./target_ramalan_asli).*100;
MAPE2 = sum(mape2)/90;

% menyiapkan data prediksi normalisasi
data_prediksi_norm = hasil_ramalan_norm(end-89:end);
% melakukan transpose terhadap data prediksi normalisai
data_prediksi_norm = data_prediksi_norm';

% melakukan prediksi
hasil_prediksi_norm = sim(net_keluaran,data_prediksi_norm);

% melakukan denormalisai terhadap hasil prediksi normalisasi 
max_data = 480.08;
min_data = 61.8;
hasil_prediksi = ((hasil_prediksi_norm-0.1)*(max_data-min_data)/0.8)+min_data;



