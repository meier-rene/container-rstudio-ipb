FROM ubuntu:xenial

MAINTAINER Kristian Peters <kpeters@ipb-halle.de>

LABEL Description="Full-blown RStudio Server metabolomics installation."



# Environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=":1"
ENV PATH="/usr/local/bin/:/usr/local/sbin:/usr/bin:/usr/sbin:/usr/X11R6/bin:/bin:/sbin"
ENV PKG_CONFIG_PATH="/usr/lib64/pkgconfig:/usr/lib/pkgconfig:/usr/local/lib64/pkgconfig:/usr/local/lib/pkgconfig"
ENV LD_LIBRARY_PATH="/usr/lib64:/usr/lib:/usr/local/lib64:/usr/local/lib"

# R packages
ENV PACK_R="abind BH cba clValid corrplot curl DBI dendextend devtools doSNOW eigenfaces extrafont FactoMineR flexclust geometry ggplot2 gplots hash Hmisc httr jsonlite klaR kohonen languageR limma lme4 lmerTest magic Matrix matrixStats mda memoise metabolomics MetStaT mixOmics multcomp multisom plotly plotrix pryr qtlcharts R6 rcdk Rcpp rmarkdown RMySQL rsm rstudioapi RJSONIO RUnit squash tools vegan xlsx"
ENV PACK_BIOC="xcms CAMERA Rdisop mtbls2 pcaMethods Risa ade4 affxparser affy annotate AnnotationDbi ape aroma.affymetrix ArrayExpress arrayQuality ArrayTools Biobase biomaRt Biostrings BSgenome cummeRbund DESeq2 easyRNASeq edgeR gage gcrma geiger genefilter geneplotter genomeIntervals GenomicAlignments GenomicFeatures GenomicRanges ggbio ggplot2 ggtree gmapR GO.db GOstats GSEABase GSVA gtools hopach IRanges KEGG.db KEGGgraph KEGGprofile KEGGREST limma made4 oligo omicade4 pathview plgem RColorBrewer RCy3 RCytoscape ropls Rsamtools Rsubread rtracklayer ShortRead simpleaffy topGO VariantAnnotation VennDiagram WGCNA XMLRPC DEXSeq SRAdb HTqPCR ddCt ShortRead"
ENV PACK_GITHUB="cbroeckl/RAMClustR c-ruttkies/MetFragR/metfRag dragua/xlsx glibiseller/IPO jcapelladesto/geoRge rstudio/rmarkdown sneumann/MetShot vbonhomme/Momocs vbonhomme/eigenfaces ramnathv/rCharts"



# Add cran R backport
RUN apt-get -y update
RUN apt-get -y install apt-transport-https
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9
RUN echo "deb https://mirrors.ebi.ac.uk/CRAN/bin/linux/ubuntu xenial/" >> /etc/apt/sources.list

# Update and upgrade sources
RUN apt-get -y update
RUN apt-get -y dist-upgrade

# Install RStudio-related packages
RUN apt-get -y install wget r-base gdebi-core psmisc libapparmor1 sudo

# Install development files needed for compilation
RUN apt-get -y install cmake ed freeglut3-dev g++ gcc git libcurl4-gnutls-dev libgfortran-4.8-dev libgfortran-5-dev libglu1-mesa-dev libgomp1 libmariadb-client-lgpl-dev libmysqlclient-dev libssl-dev libxml2-dev libxpm-dev pkg-config python unzip xorg-dev

# Install tex-related stuff (needed by some R packages)
RUN apt-get -y install bibtool texlive-base texlive-bibtex-extra texlive-lang-german texlive-lang-english texlive-latex-base texlive-latex-recommended

# Install libraries needed by R packages and Bioconductor
RUN apt-get -y install gdb libbz2-dev libdigest-sha-perl libexpat1-dev libfftw3-dev libgl1-mesa-dev libglu1-mesa-dev libgmp3-dev libgsl0-dev libgsl0-dbg libgsl2 libgtk2.0-dev libgtk-3-dev liblzma-dev libmpfr4-dbg libmpfr-dev libnetcdf-dev libnlopt-dev libopenbabel-dev libpcre3-dev libpng12-dev libtiff5-dev libxml2-dev netcdf-bin openjdk-8-jre-headless openjdk-8-jdk-headless libglpk-dev libglpk-java python-dev python-pip

# Install Xorg environment (needed for compiling some Bioc packages)
RUN apt-get -y install xauth xinit xterm xvfb

# Rsbml needs libsbml == 5.10.2, so install that
#RUN apt-get -y install libsbml5-dev libsbml5-python libsbml5-perl libsbml5-java libsbml5-cil libsbml5-dbg
WORKDIR /usr/src
RUN wget -O libSBML-5.10.2-core-src.tar.gz 'http://downloads.sourceforge.net/project/sbml/libsbml/5.10.2/stable/libSBML-5.10.2-core-src.tar.gz?r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Fsbml%2Ffiles%2Flibsbml%2F5.10.2%2Fstable%2F' && tar xzvf libSBML-5.10.2-core-src.tar.gz ; cd libsbml-5.10.2 ; CXXFLAGS=-fPIC CFLAGS=-fPIC ./configure --prefix=/usr && make && make install && ldconfig
RUN pip install python-libsbml

# Install RStudio from their repository
RUN wget -O /tmp/rstudio.ver --no-check-certificate -q https://s3.amazonaws.com/rstudio-server/current.ver
RUN wget -O /tmp/rstudio-server-$(cat /tmp/rstudio.ver)-amd64.deb -q http://download2.rstudio.org/rstudio-server-$(cat /tmp/rstudio.ver)-amd64.deb
RUN dpkg -i /tmp/rstudio-server-$(cat /tmp/rstudio.ver)-amd64.deb
RUN rm /tmp/rstudio-server-$(cat /tmp/rstudio.ver)-amd64.deb



# Update java in R
RUN R CMD javareconf

# Install R packages
RUN for PACK in $PACK_R; do R -e "install.packages(\"$PACK\", repos='https://cran.rstudio.com/')"; done

# Install Bioconductor packages manually first
ADD installFromBiocViews.R /tmp/installFromBiocViews.R
RUN R -e "source('https://bioconductor.org/biocLite.R'); biocLite(\"BiocInstaller\", dep=TRUE, ask=FALSE)"
RUN for PACK in $PACK_BIOC; do R -e "library(BiocInstaller); biocLite(\"$PACK\", dep=TRUE, ask=FALSE)"; done

# Install Bioconductor "Metabolomics" flavour
#ADD https://raw.githubusercontent.com/phnmnl/bioc_docker/master/out/release_metabolomics/installFromBiocViews.R /tmp/installFromBiocViews.R
ADD https://raw.githubusercontent.com/phnmnl/bioc_docker/master/out/release_metabolomics/install.R /tmp/installFromBiocViews.R
RUN /usr/bin/xvfb-run R -f /tmp/installFromBiocViews.R

# Install github R packages from source
RUN for PACK in $PACK_GITHUB; do R -e "library('devtools'); install_github(\"$PACK\")"; done

# Install eigenfaces from source
RUN R -e "library('devtools'); library('pcaMethods'); install_github(\"vbonhomme/Momocs\"); library('Momocs'); install_github(\"vbonhomme/eigenfaces\")"

# Install BATMAN
RUN R -e "library('devtools'); install.packages('batman', repos='http://R-Forge.R-project.org')"

# Install BatchCorr
RUN R -e "devtools::install_git('https://gitlab.com/CarlBrunius/batchCorr.git')"

# Install ROOT + Bioconductor xps
# see http://bioconductor.org/packages/release/bioc/readmes/xps/README
# Prevent Debian Bug
RUN ln -s /usr/lib/gcc/x86_64-linux-gnu/5/libgfortranbegin.a /usr/lib/gcc/x86_64-linux-gnu/6/libgfortranbegin.a
ENV ROOT_VER="6.06.08"
RUN wget -O /usr/src/root-${ROOT_VER}.tar.gz https://root.cern.ch/download/root_v${ROOT_VER}.source.tar.gz
WORKDIR /usr/src
RUN tar -xvzf root-${ROOT_VER}.tar.gz
WORKDIR /usr/src/root-$ROOT_VER
RUN ./configure
RUN make
RUN bash -c 'source /usr/src/root-$ROOT_VER/bin/thisroot.sh && R -e "source(\"https://bioconductor.org/biocLite.R\"); biocLite(\"xps\")"'

# Install SIRIUS
RUN mkdir /usr/lib/sirius
WORKDIR /usr/lib/sirius
RUN wget -O /tmp/sirius.zip 'https://bio.informatik.uni-jena.de/artifactory/libs-releases-local/sirius_3_1_3_linux64.zip'
RUN unzip /tmp/sirius.zip

# Install mzml2isa
RUN pip install mzml2isa

# Update R packages
RUN R -e "update.packages(repos='https://cran.rstudio.com/', ask=F)"



# Configure RStudio server
ADD rserver.conf /etc/rstudio/rserver.conf
ADD rsession.conf /etc/rstudio/rsession.conf
RUN echo "#!/bin/sh" > /usr/sbin/rstudio-server.sh
RUN echo "/usr/lib/rstudio-server/bin/rserver --server-daemonize=0" >> /usr/sbin/rstudio-server.sh
RUN chmod +x /usr/sbin/rstudio-server.sh



# Infrastructure specific
RUN groupadd -g 9999 -f rstudio
RUN useradd -d /home/rstudio -m -g rstudio -u 9999 -s /bin/bash rstudio
RUN echo 'rstudio:docker' | chpasswd

RUN apt-get -y install ldap-utils libpam-ldapd libnss-ldapd libldap2-dev nslcd tcsh
WORKDIR /
ADD etc/ldap.conf /etc/ldap.conf
ADD etc/ldap /etc/ldap
ADD etc/pam.d /etc/pam.d
ADD etc/nsswitch.conf /etc/nsswitch.conf
ADD etc/nslcd.conf /etc/nslcd.conf
RUN chmod 660 /etc/nslcd.conf
ADD etc/ssl/certs/IPB* /etc/ssl/certs/
RUN update-rc.d nslcd enable
RUN mkdir /raid
RUN ln -s /home /raid/home



# Create RStudio start script
RUN echo "#!/bin/sh" > /usr/sbin/rstudio-server.sh
RUN echo "service nslcd start" >> /usr/sbin/rstudio-server.sh
RUN echo "sleep 10" >> /usr/sbin/rstudio-server.sh
RUN echo "/usr/lib/rstudio-server/bin/rserver --server-daemonize=0" >> /usr/sbin/rstudio-server.sh
RUN chmod +x /usr/sbin/rstudio-server.sh



# Clean up
RUN apt-get -y clean && apt-get -y autoremove && rm -rf /var/lib/{cache,log}/ /tmp/* /var/tmp/*



# expose port
EXPOSE 8080

# Define Entry point script
WORKDIR /
CMD ["/usr/sbin/rstudio-server.sh"]

