clc;clear;close all;warning off;
 
% Proses membaca data latih dari excel
rng(100)
filename = 'DATA SKRIPSI.xlsx';
sheet = 2;
xlRange = 'B3:E65';
 
Data = xlsread(filename, sheet, xlRange);
data_latih = Data(:,1:3)';
target_latih = Data(:,4)';
[m,n] = size(data_latih);
 
% Pembuatan JST
net = newff(minmax(data_latih),[20 1],{'tansig','purelin'},'trainlm');
 
% pembobotan awal pelatihan
bobotAwal_hidden = net.IW{1,1};
bobotAwal_keluaran = net.LW{2,1};
biasAwal_hidden = net.b{1,1};
biasAwal_keluaran = net.b{2,1};

% Memberikan parameter nilai untuk mempengaruhi proses pelatihan
net.trainParam.goal = 0.001;
net.trainParam.show = 25;
net.trainParam.epochs = 1000;
net.trainParam.mc = 0.9;
net.trainParam.lr = 0.01;
 
% Proses training
[net_keluaran,tr,Y,E] = train(net,data_latih,target_latih);
 
% pembobotan akhir pelatihan
bobotAkhir_hidden = net_keluaran.IW{1,1};
bobotAkhir_keluaran = net_keluaran.LW{2,1};
biasAkhir_hidden = net_keluaran.b{1,1};
biasAkhir_keluaran = net_keluaran.b{2,1};

% Hasil setelah pelatihan
jumlah_iterasi = tr.num_epochs;
nilai_keluaran = Y;
nilai_error = E;
error_MSE = (1/n)*sum(nilai_error.^2);

 
% Hasil prediksi
hasil_latih_norm = sim(net_keluaran,data_latih);
max_data = 480.08;
min_data = 61.8;
hasil_latih = ((hasil_latih_norm-0.1)*(max_data-min_data)/0.8)+min_data;
 
% Performansi hasil prediksi
filename = 'DATA SKRIPSI.xlsx';
sheet = 1;
xlRange = 'K3:K65';
 
target_latih_asli = xlsread(filename, sheet, xlRange);
target_latih_asli =target_latih_asli';

%NILAI MSE
e1 = target_latih_asli - hasil_latih;
mse1 = mse(e1);

%NILAI MAPE
mape1 = ((abs(e1))./target_latih_asli).*100;
MAPE1 = sum(mape1)/63;
 
figure,
plotregression(target_latih_asli,hasil_latih,'Regression')
 
figure,
plotperform(tr)
 
figure,
plot(hasil_latih,'bo-')
hold on
plot(target_latih_asli,'ro-')
hold off
grid on
title(strcat(['Grafik Keluaran JST vs Target dengan nilai MSE = ',...
num2str(error_MSE)]))
xlabel('Pola ke-')
ylabel('Nilai Impor')
legend('Keluaran JST','Target','Location','Best')