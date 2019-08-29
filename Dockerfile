FROM rocker/rstudio:3.6.1

MAINTAINER Kristian Peters <kpeters@ipb-halle.de>

LABEL Description="Full-blown RStudio Server metabolomics installation."



# Environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=":1"
ENV PATH="/usr/local/bin/:/usr/local/sbin:/usr/bin:/usr/sbin:/usr/X11R6/bin:/bin:/sbin"
ENV PKG_CONFIG_PATH="/usr/lib64/pkgconfig:/usr/lib/pkgconfig:/usr/local/lib64/pkgconfig:/usr/local/lib/pkgconfig"
ENV LD_LIBRARY_PATH="/usr/lib64:/usr/lib:/usr/local/lib64:/usr/local/lib"

# CRAN packages and Bioconductor are joined
ENV PACK_R="abind ade4 akima ape arm BH cba clValid corrplot cpca curl DBI dendextend devtools diverse doMC doSNOW eigenfaces extrafont FactoMineR FD flexclust geometry ggplot2 gplots hash Hmisc httr intCor jsonlite klaR kohonen languageR limma lme4 lmerTest magic Matrix matrixStats mda memoise metabolomics MetStaT mixOmics multcomp multisom picante plotly plotrix pryr pvclust qtlcharts R6 randomForest rcdk Rcpp rmarkdown RMySQL robustrao rsm rstudioapi RJSONIO RUnit squash sva tools vegan xlsx xcms CAMERA Rdisop mtbls2 pcaMethods Risa ade4 affxparser affy annotate AnnotationDbi ape aroma.affymetrix ArrayExpress arrayQuality ArrayTools Biobase biomaRt Biostrings BSgenome cummeRbund DESeq2 easyRNASeq edgeR gage gcrma geiger genefilter geneplotter genomeIntervals GenomicAlignments GenomicFeatures GenomicRanges ggbio ggplot2 ggtree gmapR GO.db GOstats GSEABase GSVA gtools hopach IRanges KEGG.db KEGGgraph KEGGprofile KEGGREST limma made4 oligo omicade4 pathview plgem RColorBrewer RCy3 RCytoscape ropls Rsamtools Rsubread rtracklayer ShortRead simpleaffy topGO VariantAnnotation VennDiagram WGCNA XMLRPC DEXSeq SRAdb HTqPCR ddCt ShortRead ChemmineR"
ENV PACK_GITHUB="lgatto/ProtGenerics sneumann/mzR lgatto/MSnbase sneumann/xcms rajarshi/cdkr/rinchi cbroeckl/RAMClustR c-ruttkies/MetFragR/metfRag dragua/xlsx glibiseller/IPO jcapelladesto/geoRge rstudio/rmarkdown sneumann/MetShot vbonhomme/Momocs vbonhomme/eigenfaces ramnathv/rCharts"
ENV PACK_URL="https://cran.r-project.org/src/contrib/Archive/GenABEL.data/GenABEL.data_1.0.0.tar.gz https://cran.r-project.org/src/contrib/Archive/GenABEL/GenABEL_1.8-0.tar.gz"



# Add cran R backport
RUN apt-get -y update
#RUN apt-get -y install apt-transport-https locales
#RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9
#RUN echo "deb https://cloud.r-project.org/bin/linux/ubuntu xenial-cran35/" >> /etc/apt/sources.list

# Update and upgrade
RUN apt-get -y update
RUN apt-get -y dist-upgrade

# Generate locales
#ENV LC_ALL="en_US.UTF-8"
#ENV LC_CTYPE="en_US.UTF-8"
#RUN locale-gen $LC_ALL
#RUN dpkg-reconfigure locales

# Install files needed for compilation
RUN apt-get -y install curl wget gdebi-core psmisc libapparmor1 sudo cmake ed freeglut3-dev g++ gcc git libcurl4-gnutls-dev gfortran libglu1-mesa-dev libgomp1 libmariadb-client-lgpl-dev mysql-common libssl-dev libxml2-dev libxpm-dev pkg-config python tk8.6-dev unzip xorg-dev software-properties-common bibtool texlive-full texlive-bibtex-extra texlive-lang-german texlive-lang-english texlive-latex-base texlive-latex-recommended gdb libbz2-dev libdigest-sha-perl libexpat1-dev libfftw3-dev libgl1-mesa-dev libglu1-mesa-dev libgmp3-dev libgsl0-dev libgsl0-dbg libgsl2 libgtk2.0-dev libgtk-3-dev liblzma-dev libmpfr4-dbg libmpfr-dev libnetcdf-dev libnlopt-dev libopenbabel-dev libpcre3-dev libpng-dev libtiff5-dev libxml2-dev netcdf-bin openjdk-8-jre-headless openjdk-8-jdk-headless libglpk-dev libglpk-java python-dev python-pip libudunits2-dev librsvg2-dev libgeos-dev xauth xinit xterm xvfb imagemagick

# Install ImageMagick separately
#RUN add-apt-repository -y ppa:opencpu/imagemagick
#RUN apt -y update
#RUN apt-get -y install imagemagick

# Rsbml needs libsbml == 5.10.2, so install that
RUN apt-get -y install libsbml5-dev libsbml5-python libsbml5-perl libsbml5-java libsbml5-cil
WORKDIR /usr/src
RUN wget -O libSBML-5.10.2-core-src.tar.gz 'http://downloads.sourceforge.net/project/sbml/libsbml/5.10.2/stable/libSBML-5.10.2-core-src.tar.gz?r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Fsbml%2Ffiles%2Flibsbml%2F5.10.2%2Fstable%2F' && tar xzvf libSBML-5.10.2-core-src.tar.gz ; cd libsbml-5.10.2 ; CXXFLAGS=-fPIC CFLAGS=-fPIC ./configure --prefix=/usr && make && make install && ldconfig
RUN pip install python-libsbml
RUN rm -rf /usr/src/ibsbml-5.10.2 && rm -f libSBML-5.10.2-core-src.tar.gz

# Install RStudio from their repository
#RUN wget -O /tmp/rstudio.ver --no-check-certificate -q https://s3.amazonaws.com/rstudio-server/current.ver
#RUN wget -O /tmp/rstudio-server-$(cat /tmp/rstudio.ver)-amd64.deb -q http://download2.rstudio.org/rstudio-server-$(cat /tmp/rstudio.ver)-amd64.deb
#RUN dpkg -i /tmp/rstudio-server-$(cat /tmp/rstudio.ver)-amd64.deb
#RUN rm /tmp/rstudio-server-$(cat /tmp/rstudio.ver)-amd64.deb



# Set repositories permanently
#RUN echo "utils::setRepositories(ind=1:5)" >> /etc/R/Rprofile.site

# Update java in R
RUN R CMD javareconf

# Install R packages
RUN for PACK in $PACK_R; do R -e "install.packages(\"$PACK\")"; done

# Install packages manually
RUN for PACK in $PACK_URL; do R -e "library('devtools'); install_url(\"$PACK\")"; done

# Install Bioconductor manually first
#ADD installFromBiocViews.R /tmp/installFromBiocViews.R
#RUN R -e "source('https://bioconductor.org/biocLite.R'); biocLite(\"BiocInstaller\", dep=TRUE, ask=FALSE)"
RUN R -e "if (!requireNamespace(\"BiocManager\", quietly = TRUE)) install.packages(\"BiocManager\")"
RUN for PACK in $PACK_BIOC; do R -e "BiocManager::install(\"$PACK\", dep=TRUE, ask=FALSE)"; done

# Install Bioconductor Proteomics / Metabolomics flavour
#ADD https://raw.githubusercontent.com/phnmnl/bioc_docker/master/out/release_metabolomics/installFromBiocViews.R /tmp/installFromBiocViews.R
#ADD https://raw.githubusercontent.com/phnmnl/bioc_docker/master/out/release_metabolomics/install.R /tmp/installFromBiocViews.R
#RUN /usr/bin/xvfb-run R -f /tmp/installFromBiocViews.R

# Bioconductor: ProtMetCore
ADD https://raw.githubusercontent.com/Bioconductor/bioc_docker/master/out/release_protmetcore/install.R /tmp/
ADD http://master.bioconductor.org/todays-date /tmp/
RUN R -f /tmp/install.R
RUN rm -f /tmp/install.R

# Bioconductor: Metabolomics
ADD https://raw.githubusercontent.com/Bioconductor/bioc_docker/master/out/release_metabolomics/install.R /tmp/
ADD http://master.bioconductor.org/todays-date /tmp/
RUN R CMD javareconf
ENV NETCDF_INCLUDE=/usr/include
ENV OPEN_BABEL_LIBDIR /usr/lib/openbabel/2.3.2/
ENV OPEN_BABEL_INCDIR /usr/include/openbabel-2.0/
RUN rm -f /tmp/install.R

# Install github R packages from source
RUN for PACK in $PACK_GITHUB; do R -e "library('devtools'); install_github(\"$PACK\")"; done

# Install eigenfaces from source
RUN R -e "library('devtools'); library('pcaMethods'); install_github(\"vbonhomme/Momocs\"); library('Momocs'); install_github(\"vbonhomme/eigenfaces\")"

# Install CAMERA 1.33.3
#RUN R -e 'library(devtools); install_github(repo="sneumann/CAMERA", ref="cbc9cdb2eba6438434c27fec5fa13c9e6fdda785")'

# Upgrade to  latest XCMS
RUN R -e 'library(devtools); install_github("https://github.com/lgatto/ProtGenerics"); install_github("https://github.com/sneumann/mzR"); install_github("https://github.com/lgatto/MSnbase"); library(devtools); install_github(repo="sneumann/xcms", ref="24471b789ff4486688f0ba2aa1ac3373d93f38b7")'

# Install BATMAN
RUN R -e "library('devtools'); install.packages('batman', repos='http://R-Forge.R-project.org')"

# Install BatchCorr
RUN R -e "devtools::install_git('https://gitlab.com/CarlBrunius/batchCorr.git')"

# Install ROOT + Bioconductor xps
# see http://bioconductor.org/packages/release/bioc/readmes/xps/README
# Prevent Debian Bug
#RUN ln -s /usr/lib/gcc/x86_64-linux-gnu/5/libgfortranbegin.a /usr/lib/gcc/x86_64-linux-gnu/6/libgfortranbegin.a
#ENV ROOT_VER="6.06.08"
#RUN wget -O /usr/src/root-${ROOT_VER}.tar.gz https://root.cern.ch/download/root_v${ROOT_VER}.source.tar.gz
#WORKDIR /usr/src
#RUN tar -xvzf root-${ROOT_VER}.tar.gz
#WORKDIR /usr/src/root-$ROOT_VER
#RUN ./configure
#RUN make
#RUN bash -c 'source /usr/src/root-$ROOT_VER/bin/thisroot.sh && R -e "source(\"https://bioconductor.org/biocLite.R\"); biocLite(\"xps\")"'

# Install SIRIUS
RUN mkdir /usr/lib/sirius
WORKDIR /tmp
RUN wget -O /tmp/sirius.zip 'https://bio.informatik.uni-jena.de/repository/dist-release-local/de/unijena/bioinf/ms/sirius/4.0/sirius-4.0-linux64-headless.zip'
RUN unzip /tmp/sirius.zip
RUN cp sirius*/lib/* /usr/lib/sirius/

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
#ADD etc/ldap.conf /etc/ldap.conf
#ADD etc/ldap /etc/ldap
ADD etc/pam.d /etc/pam.d
ADD etc/nsswitch.conf /etc/nsswitch.conf
ADD etc/nslcd.conf /etc/nslcd.conf
RUN chmod 660 /etc/nslcd.conf
#ADD etc/ssl/certs/IPB* /etc/ssl/certs/
RUN update-rc.d nslcd enable
RUN mkdir /raid
RUN ln -s /home /raid/home



# Create RStudio start script
#RUN echo "#!/bin/sh" > /usr/sbin/rstudio-server.sh
#RUN echo "service nslcd start" >> /usr/sbin/rstudio-server.sh
#RUN echo "sleep 10" >> /usr/sbin/rstudio-server.sh
#RUN echo "/usr/lib/rstudio-server/bin/rserver --server-daemonize=0" >> /usr/sbin/rstudio-server.sh
#RUN chmod +x /usr/sbin/rstudio-server.sh



# Clean up
RUN apt-get -y clean && apt-get -y autoremove && rm -rf /var/lib/{cache,log}/ /tmp/* /var/tmp/*



# expose port
EXPOSE 8080

# Define Entry point script
#WORKDIR /
#CMD ["/usr/sbin/rstudio-server.sh"]

