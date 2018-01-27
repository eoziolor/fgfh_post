fs <- list.files("~/analysis/data/fst/raw/", "*5kb1kb.bed",full.names=TRUE)

fst <- list()

for (i in 1:21){
	fst[[i]] <- read.table(fs[i],stringsAsFactors=FALSE)
	fst[[i]][,4] <- as.numeric(fst[[i]][,4])
}
print("done reading files")
nfs <- gsub(".*\\/","",fs)
nfs <- gsub(".fst.*","",nfs)
names(fst)<-nfs

pbs <- function(t1,t2,c12){
  
  t1 <- -log(1-t1)
  t2 <- -log(1-t2)
  c12 <- -log(1-c12)
  
  stat <- (t1 + t2 - c12)/2
  return(stat)
}

nsnps <-fst[[1]][,5]

for (i in 2:21){
  
  nsnps <- nsnps + fst[[i]][,5]
}

nsnps <- nsnps/21

subw <- nsnps > 20

sjpbs <- pbs(fst[["BB.SJ"]][,4],fst[["SJ.GB"]][,4],fst[["BB.GB"]][,4])

bnppbs <- pbs(fst[["BB.BNP"]][,4],fst[["BNP.GB"]][,4],fst[["BB.GB"]][,4])
print("done reading files2")

allpbs <- cbind(
  fst[[1]][subw,1:3],
  SJ = sjpbs[subw],
  BNP = bnppbs[subw])
write.table(allpbs,
            file="~/analysis/data/fst/intermpbs5kb.bed",
            sep = "\t", 
            quote = FALSE,
            row.names = FALSE,
            col.names = FALSE)

sjc<-quantile(sjpbs[subw],prob=.99,na.rm=TRUE)
bnpc<-quantile(bnppbs[subw],prob=.99,na.rm=TRUE)

all<-sjpbs[subw]>sjc & bnppbs[subw]>bnpc
write.table(na.omit(allpbs[all,1:3]),"~/analysis/data/fst/interm_pbs_shared.bed",row.names = FALSE,col.names = FALSE,quote = FALSE)
source("http://bioconductor.org/biocLite.R")
biocLite()
library("rtracklayer")

bed1=import("~/analysis/data/fst/intermpbs5kb.bed")

bedall=import("~/analysis/data/fst/interm_pbs_shared.bed")
bed1overlall=bed1[bed1 %over% bedall]
hitsall<-findOverlaps(bedall,bed1)
allhit<-subjectHits(hitsall)

allpbs<-cbind(allpbs,0)
newn<-c("Chr","start","end","sj","bnp","all")
colnames(allpbs)<-newn
allpbs[allhit,"all"]<-allpbs[allhit,"all"]+1

palette(c("grey50","grey70"))
par(mfrow=c(2,1),mar=c(0,3,0,0))
plot(allpbs[,"sj"],pch=20,cex=.5,col=ifelse(allpbs[,"all"]>0,"red",sort(as.factor(allpbs[,1]))),ylim=c(-1,1))
plot(allpbs[,"bnp"],pch=20,cex=.5,col=ifelse(allpbs[,"all"]>0,"red",sort(as.factor(allpbs[,1]))),ylim=c(-1,1))