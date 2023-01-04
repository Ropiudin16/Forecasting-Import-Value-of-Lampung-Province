#==============================#
#Input Data
#==============================#

library(readxl)
data1=read_excel("D:/DATA/DATA NILAI IMPOR.xlsx")
data=data1$Nilai
data

#==============================#
#Plot Data Aktual
#==============================#

plot(data,xlab="periode",ylab="harga",type = "l")

#==============================#
#Menentukan Himpunan Semesta
#==============================#

minimum=min(data)
maksimum=max(data)
minimum
maksimum
D1=0
D2=10
min_baru=minimum-D1
max_baru=maksimum+D2
min_baru
max_baru

#==============================#
#Pembentukan Interval
#==============================#

#Jumlah Interval
n = round(1 +(3.322 *logb(length(data), base  = 10)))
n
#Panjang Interval
L = round((max_baru - min_baru)/n)
L

#==============================#
#Batas-batas Interval
#==============================#

intrv_1 = seq(min_baru,max_baru,len = n+1)
intrv_1

#==============================#
#Pembagian Interval dan 
#Membentuk Himpunan Fuzzy
#==============================#

box1 = data.frame(NA,nrow=length(intrv_1)-1,ncol=3)
names(box1) = c("bawah","atas","kel")
for (i in 1:length(intrv_1)-1) {
  box1[i,1]=intrv_1[i]
  box1[i,2]=intrv_1[i+1]
  box1[i,3]=i
}
box1

#==============================#
#Nilai Tengah Interval
#==============================#

n_tengah = data.frame(tengah=(box1[,1]+box1[,2])/2,kel=box1[,3])
n_tengah

#==============================#
#Membentuk Himpunan Fuzzy
#==============================#

fuzifikasi=c() 
for (i in 1:length(data)){
  for (j in 1:nrow(box1)){
    if (i!=which.max(data)){
      if (data[i]>=(box1[j,1])&data[i]<(box1[j,2])){
        fuzifikasi[i]=j
        break
      }
    }
    else {
      if (data[i]>=(box1[j,1])&data[i]<=(box1[j,2])){
        fuzifikasi[i]=j
        break
      }
    }
  }
}
fuzzyfy = cbind(data,fuzifikasi)
fuzzyfy

#==============================#
#FLR dan FLRG
#==============================#

FLR = data.frame(fuzzifikasi=0,left1=NA,left2=NA,left3=NA,right =NA)
for (i in 1:length(fuzifikasi)) {
  FLR[i,1] = fuzifikasi[i]
  FLR[i+3,2] = fuzifikasi[i]
  FLR[i+2,3] = fuzifikasi[i]
  FLR[i+1,4] = fuzifikasi[i]
  FLR[i,5] = fuzifikasi[i]
}
FLR = FLR[-nrow(FLR),]
FLR = FLR[-nrow(FLR),]
FLR = FLR[-1,]
FLR = FLR[-1,]
FLR = FLR[-1,]
FLR

left=c("left1","left2","left3")
FLR$left1left2left3=do.call(paste, c(FLR[left],sep=""))
FLR

library(dplyr)
FLR=FLR %>%
  mutate(left1left2left3=as.integer(left1left2left3)) %>%
  mutate(right=as.integer(right)) %>%
  select(fuzzifikasi,left1left2left3,right)
FLR

FLR=FLR %>%
  mutate(Rank = dense_rank(left1left2left3)) %>%
  select(fuzzifikasi,left1left2left3,right,Rank)
FLR

Rank=cbind(FLR$Rank)
Rank

#FLRG
FLRG = table(FLR[,4:3])
FLRG

#==============================#
#Peramalan Chen
#==============================#

#membuat matrik anggota
chen_m= matrix(rep(0,(nrow(FLRG)*ncol(FLRG))),ncol=ncol(FLRG))
for(i in 1:nrow(FLRG)){
  for(j in 1:ncol(FLRG)){
    if(FLRG[i,j]>0){chen_m[i,j]=1}else
      if(FLRG[i,j]==0){chen_m[i,j]=0}
  }
}
chen_m

#normalisasi matrik anggota
chen_nm= matrix(rep(0,(nrow(FLRG)*ncol(FLRG))),ncol=ncol(FLRG))
for(i in 1:nrow(chen_m)){
  for(j in 1:ncol(chen_m)){
    if(chen_m[i,j]==1){chen_nm[i,j]=1/(sum(chen_m[i,]))}else
      if(chen_m[i,j]==0){chen_nm[i,j]=0}
  }
}
chen_nm

#Perhitungan Ramalan Chen
chen_R=NULL
for (i in 1:nrow(FLR)){
  for (j in 1:(nrow(chen_nm)))        
    if (Rank[i]==j)
    {chen_R[i]=sum(chen_nm[j,]*n_tengah[,1])}else
      if (Rank[i]==0)
      {chen_R[i]=0}
}
Prediksi= cbind(round(chen_R,2))
Prediksi[1:90,]

#==============================#
#Tabel Pembanding
#==============================#

datapakai = data[c(4:length(data))]
galat = (datapakai-Prediksi[1:90,])
galat_kuadrat = galat^2
PE = abs(galat/datapakai*100)
tabel = cbind(datapakai,Prediksi[1:90,],galat,galat_kuadrat,PE)
tabel

#==============================#
#Uji Ketepatan
#==============================#

MSE = mean(galat_kuadrat, na.rm = TRUE)
MAPE = mean(PE, na.rm=TRUE)
ketepatan = cbind(MSE,MAPE)
ketepatan

#Ramalan Periode Kedepan
Ramalan=NULL
for (i in 1:91){
  for (j in 1:(nrow(chen_nm)))        
    if (Rank[i]==j)
    {Ramalan[i]=sum(chen_nm[j,]*n_tengah[,1])}else
      if (Rank[i]==0)
      {Ramalan[i]=0}
}
Ramalan= round(Ramalan[i],2) 
Ramalan
