#we need a rstudio without the VOLUME definition
#VOLUME breaks mounting of user directories
#install with:
#docker build . -t rstudio-ipb 
#docker run -d --restart=always -p 80:8787 -v "/vol:/vol" -v "/mnt/ifs:/mnt/ifs" -v "/home:/home" -v "/raid:/raid" --name rstudio-ipb-run rstudio-ipb
FROM rmeier/rstudio:3.6.2

MAINTAINER Kristian Peters <kpeters@ipb-halle.de>

LABEL Description="Full-blown RStudio Server metabolomics installation."

ENV PASSWORD=docker
ENV DEBIAN_FRONTEND=noninteractive

COPY rootfs /

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    nslcd \
    libnss-ldapd \
    libpam-ldapd \
    libxml2-dev \
    libnetcdf-dev \
    libbz2-dev \
    liblzma-dev \
    libpcre3-dev \
    libpng-dev \
    libgmp3-dev \
    librsvg2-dev \
    libmariadbclient-dev \
    libgeos-dev \
    mesa-common-dev \
    libglu1-mesa-dev \
    openjdk-11-jdk-headless \
  && apt -y upgrade \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/

RUN R -e 'if (!requireNamespace("BiocManager", quietly = TRUE)) \
  install.packages("BiocManager"); \
  BiocManager::install(version = "3.10")'
#from GitHub
RUN R -e 'BiocManager::install(c("devtools", \
  "remotes", \
  "lgatto/ProtGenerics", \
  "sneumann/mzR", \
  "lgatto/MSnbase", \
  "sneumann/xcms", \
  "CDK-R/rinchi", \
  "cbroeckl/RAMClustR", \
  "ipb-halle/MetFragR/metfRag", \
  "dragua/xlsx", \
  "jcapelladesto/geoRge", \
  "vbonhomme/Momocs", \
  "vbonhomme/eigenfaces", \
  "ramnathv/rCharts"))'
#from Bioc
RUN R -e 'BiocManager::install(c("akima",  \
  "arm", \
  "ArrayExpress", \
  "arrayQuality", \
  "ArrayTools", \
  "CAMERA", \
  "cba", \
  "ChemmineR", \
  "clValid", \
  "corrplot", \
  "cpca", \
  "cummeRbund", \
  "ddCt", \
  "dendextend", \
  "DEXSeq", \
  "diverse", \
  "doMC", \
  "doSNOW", \
  "easyRNASeq", \
  "extrafont", \
  "FactoMineR", \
  "FD", \
  "flexclust", \
  "gage", \
  "gcrma", \
  "geiger", \
  "ggbio", \
  "ggtree", \
  "gmapR", \
  "GOstats", \
  "gplots", \
  "GSVA", \
  "gtools", \
  "hash", \
  "hopach", \
  "HTqPCR", \
  "intCor", \
  "KEGGprofile", \
  "klaR", \
  "languageR", \
  "lmerTest", \
  "mda", \
  "metabolomics", \
  "MetStaT", \
  "mixOmics", \
  "mtbls2", \
  "multcomp", \
  "multisom", \
  "pathview", \
  "picante", \
  "plgem", \
  "plotly", \
  "plotrix", \
  "pryr", \
  "pvclust", \
  "qtlcharts", \
  "randomForest", \
  "rcdk", \
  "RCy3", \
  "Rdisop", \
  "Risa", \
  "rmarkdown", \
  "RMySQL", \
  "ropls", \
  "rsm", \
  "Rsubread", \
  "squash", \
  "SRAdb", \
  "sva", \
  "topGO", \
  "VennDiagram", \
  "WGCNA"))'

RUN R -e 'update.packages()'

RUN  echo 'R_LIBS_USER=~/R/x86_64-pc-linux-gnu-library/3.6' >> /usr/local/lib/R/etc/Renviron 

