pbs<-read.table("~/analysis/data/fst/allpbs5kb",header=FALSE,stringsAsFactors = FALSE)
pbsname<-c("Scaf","start","end","BBpbs","VBpbs","PBpbs","SJpbs","BNPpbs","keep")
colnames(pbs)<-pbsname

col<-c()
for (i in 1:5){
  col[i]<-quantile(pbs[,i+3],prob=.99,na.rm=TRUE)
}

colb<-c()
for (i in 1:3){
  colb[i]<-quantile(pbs[,i+3],prob=.95,na.rm=TRUE)
}

nsnps <-pbs[,"keep"]
subw<-nsnps>0
#chr<-read.table("~/analysis/fst/scripts/chr_colors",stringsAsFactors=FALSE,sep="\t")

library(stringr)
library(dplyr)
library(gtools)

#plot(pbs[subw,4],pch=20,cex=.5,col=factor(pbs[subw,1]))
#plot(pbs[subw,4],pch=20,cex=.5,col=chr[pbs[subw,1],2])
#legend('topright',legend=levels(mixedsort(pbs[,1])),col=1:2,cex=.5,pch=1)

pbsct<-pbs %>% filter(str_detect(Scaf,"chr"))

nsnps <-pbsct[,"keep"]
subwc<-nsnps>0


pbsc<-pbsct[subwc,]
rownames(pbsc)<-seq(1:dim(pbsc[subwc,])[1])
pbsc<-pbsc[,1:8]


###Doing this on merged windows to avoid patchyness of peak coloration

pbs_out_temp<-read.table("~/analysis/data/fst/PBSoutliers_5kb_all_max.bed",stringsAsFactors = FALSE) #loads a pbs vector with windows merged within 50kb of each other and with max and windows count statistics
names<-c("Scaf","start","end","BBmax","BBcount","VBmax","VBcount","PBmax","PBcount","SJmax","SJcount","BNPmax","BNPcount")
colnames(pbs_out_temp)<-names

pbs_out<-pbs_out_temp %>% filter(str_detect(Scaf,"chr"))

#checking for whether those are outliers in different groups
all<-pbs_out[,4]>colb[1] & pbs_out[,6]>colb[2] & pbs_out[,8]>colb[3] & pbs_out[,10]>col[4] & pbs_out[,12]>col[5]
res<-pbs_out[,4]>colb[1] & pbs_out[,6]>colb[2] & pbs_out[,8]>colb[3] & pbs_out[,10]<col[4] & pbs_out[,12]<col[5]
interm<-pbs_out[,4]<colb[1] & pbs_out[,6]<colb[2] & pbs_out[,8]<colb[3] & pbs_out[,10]>col[4] & pbs_out[,12]>col[5]
bbu<-pbs_out[,4]>colb[1] & pbs_out[,6]<colb[2] & pbs_out[,8]<colb[3] & pbs_out[,10]<col[4] & pbs_out[,12]<col[5]
vbu<-pbs_out[,4]<colb[1] & pbs_out[,6]>colb[2] & pbs_out[,8]<colb[3] & pbs_out[,10]<col[4] & pbs_out[,12]<col[5]
pbu<-pbs_out[,4]<colb[1] & pbs_out[,6]<colb[2] & pbs_out[,8]>colb[3] & pbs_out[,10]<col[4] & pbs_out[,12]<col[5]
sju<-pbs_out[,4]<colb[1] & pbs_out[,6]<colb[2] & pbs_out[,8]<colb[3] & pbs_out[,10]>col[4] & pbs_out[,12]<col[5]
bnpu<-pbs_out[,4]<colb[1] & pbs_out[,6]<colb[2] & pbs_out[,8]<colb[3] & pbs_out[,10]<col[4] & pbs_out[,12]>col[5]

#write.table(pbsc[,1:3],"~/analysis/data/fst/PBS_keep_5kb.bed",row.names = FALSE,col.names = FALSE,quote=FALSE)
write.table(pbs_out[all,1:3],"~/analysis/data/fst/pbs_regions_sharedall_5%res.bed",row.names = FALSE,col.names = FALSE,quote = FALSE)
write.table(pbs_out[res,1:3],"~/analysis/data/fst/pbs_regions_sharedres_5%res.bed",row.names = FALSE,col.names = FALSE,quote = FALSE)
write.table(pbs_out[interm,1:3],"~/analysis/data/fst/pbs_regions_sharedinterm_5%res.bed",row.names = FALSE,col.names = FALSE,quote = FALSE)
write.table(pbs_out[bbu,1:3],"~/analysis/data/fst/pbs_regions_sharedbbu_5%res.bed",row.names = FALSE,col.names = FALSE,quote = FALSE)
write.table(pbs_out[vbu,1:3],"~/analysis/data/fst/pbs_regions_sharedvbu_5%res.bed",row.names = FALSE,col.names = FALSE,quote = FALSE)
write.table(pbs_out[pbu,1:3],"~/analysis/data/fst/pbs_regions_sharedpbu_5%res.bed",row.names = FALSE,col.names = FALSE,quote = FALSE)
write.table(pbs_out[sju,1:3],"~/analysis/data/fst/pbs_regions_sharedsju_5%res.bed",row.names = FALSE,col.names = FALSE,quote = FALSE)
write.table(pbs_out[bnpu,1:3],"~/analysis/data/fst/pbs_regions_sharedbnpu_5%res.bed",row.names = FALSE,col.names = FALSE,quote = FALSE)

source("http://bioconductor.org/biocLite.R")
biocLite()
library("rtracklayer")

bed1=import("~/analysis/data/fst/PBS_keep_5kb.bed")

bedall=import("~/analysis/data/fst/pbs_regions_sharedall_5%res.bed")
bed1overlall=bed1[bed1 %over% bedall]
hitsall<-findOverlaps(bedall,bed1)
allhit<-subjectHits(hitsall)

bedres=import("~/analysis/data/fst/pbs_regions_sharedres_5%res.bed")
bed1overlres=bed1[bed1 %over% bedres]
hitsres<-findOverlaps(bedres,bed1)
reshit<-subjectHits(hitsres)

bedinterm=import("~/analysis/data/fst/pbs_regions_sharedinterm_5%res.bed")
bed1overlinterm=bed1[bed1 %over% bedinterm]
hitsinterm<-findOverlaps(bedinterm,bed1)
intermhit<-subjectHits(hitsinterm)

bedbbu=import("~/analysis/data/fst/pbs_regions_sharedbbu_5%res.bed")
bed1overlbbu=bed1[bed1 %over% bedbbu]
hitsbbu<-findOverlaps(bedbbu,bed1)
bbuhit<-subjectHits(hitsbbu)

bedvbu=import("~/analysis/data/fst/pbs_regions_sharedvbu_5%res.bed")
bed1overlvbu=bed1[bed1 %over% bedvbu]
hitsvbu<-findOverlaps(bedvbu,bed1)
vbuhit<-subjectHits(hitsvbu)

bedpbu=import("~/analysis/data/fst/pbs_regions_sharedpbu_5%res.bed")
bed1overlpbu=bed1[bed1 %over% bedpbu]
hitspbu<-findOverlaps(bedpbu,bed1)
pbuhit<-subjectHits(hitspbu)

bedsju=import("~/analysis/data/fst/pbs_regions_sharedsju_5%res.bed")
bed1overlsju=bed1[bed1 %over% bedsju]
hitssju<-findOverlaps(bedsju,bed1)
sjuhit<-subjectHits(hitssju)

bedbnpu=import("~/analysis/data/fst/pbs_regions_sharedbnpu_5%res.bed")
bed1overlbnpu=bed1[bed1 %over% bedbnpu]
hitsbnpu<-findOverlaps(bedbnpu,bed1)
bnpuhit<-subjectHits(hitsbnpu)

pbsc<-cbind(pbsc,0,0,0,0,0,0,0,0)
newn<-c("Scaf","start","end","BB","VB","PB","SJ","BNP","all","res","interm","bbu","vbu","pbu","sju","bnpu")
colnames(pbsc)<-newn
pbsc[allhit,"all"]<-pbsc[allhit,"all"]+1
pbsc[reshit,"res"]<-pbsc[reshit,"res"]+1
pbsc[intermhit,"interm"]<-pbsc[intermhit,"interm"]+1
pbsc[bbuhit,"bbu"]<-pbsc[bbuhit,"bbu"]+1
pbsc[vbuhit,"vbu"]<-pbsc[vbuhit,"vbu"]+1
pbsc[pbuhit,"pbu"]<-pbsc[pbuhit,"pbu"]+1
pbsc[sjuhit,"sju"]<-pbsc[sjuhit,"sju"]+1
pbsc[bnpuhit,"bnpu"]<-pbsc[bnpuhit,"bnpu"]+1

##plotting in 5kb windows
####Plotting common regions

palette(c("grey50","grey70"))
par(mfrow=c(5,1),mar=c(0,3,0,0))
plot(pbsc[,4],pch=20,cex=1.2,
     col=ifelse((all),"purple",
                ifelse((res),"black",
                       ifelse((interm),"firebrick2",
                              ifelse((bbu),"gold2",
                                     ifelse(pbsc[,4]>col[1],"green2",sort(as.factor(pbsc[,1]))))))),
     xlab="",xaxt='n',ylab="BB (PBS)",cex.lab=1,cex.axis=2.2,bty="n",ylim=c(-.5,3.8),xaxs="i",yaxs="i")

# legend("topright",legend=c("Shared by all adapted","Resistant only","Intermediate only","Shared (group non-specific)","Local"),
#        col=c("purple","black","firebrick2","green2","gold2"),pch=20,cex=1.8,y.intersp=.5,x.intersp=.8,bty='n')

plot(pbsc[,5],pch=20,cex=1.2,
     col=ifelse((all),"purple",
                ifelse((res),"black",
                       ifelse((interm),"firebrickas.numeric(rownames(pbsc))==allhit2",
                              ifelse((vbu),"gold2",
                                     ifelse(pbsc[,5]>col[2],"green2",sort(as.factor(pbsc[,1]))))))),
     xlab="",xaxt='n',ylab="VB (PBS)",cex.lab=1,cex.axis=2.2,bty="n",ylim=c(-.5,3.8),xaxs="i",yaxs="i")

plot(pbsc[,6],pch=20,cex=1.2,
     col=ifelse((all),"purple",
                ifelse((res),"black",
                       ifelse((interm),"firebrick2",
                              ifelse((pbu),"gold2",
                                     ifelse(pbsc[,6]>col[3],"green2",sort(as.factor(pbsc[,1]))))))),
     xlab="",xaxt='n',ylab="PB (PBS)",cex.lab=1,cex.axis=2.2,bty="n",ylim=c(-.5,3.8),xaxs="i",yaxs="i")

plot(pbsc[,7],pch=20,cex=1.2,
     col=ifelse((all),"purple",
                ifelse((res),"black",
                       ifelse((interm),"firebrick2",
                              ifelse((sju),"gold2",
                                     ifelse(pbsc[,7]>col[4],"green2",sort(as.factor(pbsc[,1]))))))),
     xlab="",xaxt='n',ylab="SJ (PBS)",cex.lab=1,cex.axis=2.2,bty="n",ylim=c(-.5,3.8),xaxs="i",yaxs="i")

plot(pbsc[,8],pch=20,cex=1.2,
     col=ifelse((all),"purple",
                ifelse((res),"black",
                       ifelse((interm),"firebrick2",
                              ifelse((bnpu),"gold2",
                                     ifelse(pbsc[,8]>col[5],"green2",sort(as.factor(pbsc[,1]))))))),
     xlab="",xaxt='n',ylab="BNP (PBS)",cex.lab=1,cex.axis=2.2,bty="n",ylim=c(-.5,3.8),xaxs="i",yaxs="i")
