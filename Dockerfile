FROM docker-registry.phenomenal-h2020.eu/phnmnl/bioc_release_metabolomics

MAINTAINER Kristian Peters <kpeters@ipb-halle.de>

LABEL Description="Full-blown RStudio Server metabolomics installation."



# Environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=":1"
ENV PATH="/usr/local/bin/:/usr/local/sbin:/usr/bin:/usr/sbin:/usr/X11R6/bin:/bin:/sbin"
ENV PKG_CONFIG_PATH="/usr/lib64/pkgconfig:/usr/lib/pkgconfig:/usr/local/lib64/pkgconfig:/usr/local/lib/pkgconfig"
ENV LD_LIBRARY_PATH="/usr/lib64:/usr/lib:/usr/local/lib64:/usr/local/lib"

# R packages
ENV PACK_R="abind BH cba curl dendextend devtools doSNOW eigenfaces extrafont FactoMineR geometry ggplot2 gplots hash Hmisc httr jsonlite klaR kohonen magic Matrix matrixStats mda memoise MetStaT multcomp plotly plotrix pryr R6 rcdk Rcpp rmarkdown RMySQL rsm rstudioapi RJSONIO RUnit squash tools vegan xlsx"
ENV PACK_BIOC="xcms CAMERA Rdisop mtbls2 pcaMethods Risa ade4 affxparser affy annotate AnnotationDbi ape aroma.affymetrix ArrayExpress arrayQuality ArrayTools Biobase biomaRt Biostrings BSgenome cummeRbund DESeq2 easyRNASeq edgeR gage gcrma geiger genefilter geneplotter genomeIntervals GenomicAlignments GenomicFeatures GenomicRanges ggbio ggplot2 ggtree gmapR GO.db GOstats GSEABase GSVA gtools hopach IRanges KEGG.db KEGGgraph KEGGprofile KEGGREST limma made4 oligo omicade4 pathview plgem RColorBrewer RCy3 RCytoscape Rsamtools Rsubread rtracklayer ShortRead simpleaffy topGO VariantAnnotation VennDiagram WGCNA XMLRPC DEXSeq SRAdb HTqPCR ddCt ShortRead"
ENV PACK_GITHUB="cbroeckl/RAMClustR c-ruttkies/MetFragR/metfRag dragua/xlsx glibiseller/IPO jcapelladesto/geoRge rstudio/rmarkdown sneumann/MetShot vbonhomme/Momocs vbonhomme/eigenfaces ramnathv/rCharts"



# Update sources
RUN apt-get -y update

# Install dependencies
RUN apt-get -y install libxpm-dev libgfortran-5-dev libgfortran-6-dev

# Clean up
RUN apt-get -y clean && apt-get -y autoremove && rm -rf /var/lib/{cache,log}/ /tmp/* /var/tmp/*



# Update java in R
RUN R CMD javareconf

# Install R packages
RUN for PACK in $PACK_R; do R -e "install.packages(\"$PACK\", repos='https://cran.rstudio.com/')"; done

# Install Bioconductor packages
ADD installFromBiocViews.R /tmp/installFromBiocViews.R
RUN R -e "source('https://bioconductor.org/biocLite.R'); biocLite(\"BiocInstaller\", dep=TRUE, ask=FALSE)"
RUN for PACK in $PACK_BIOC; do R -e "library(BiocInstaller); biocLite(\"$PACK\", dep=TRUE, ask=FALSE)"; done

# Install other R packages from source
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

# Update R packages
RUN R -e "update.packages(repos='https://cran.rstudio.com/', ask=F)"

# Install SIRIUS
RUN mkdir /usr/lib/sirius
WORKDIR /usr/lib/sirius
RUN wget -O /tmp/sirius.zip 'https://bio.informatik.uni-jena.de/artifactory/libs-releases-local/sirius_3_1_3_linux64.zip'
RUN unzip /tmp/sirius.zip

# Install mzml2isa
RUN pip install mzml2isa


# Configure RStudio server
ADD rserver.conf /etc/rstudio/rserver.conf
ADD rsession.conf /etc/rstudio/rsession.conf
RUN echo "#!/bin/sh" > /usr/sbin/rstudio-server.sh
RUN echo "/usr/lib/rstudio-server/bin/rserver --server-daemonize=0" >> /usr/sbin/rstudio-server.sh
RUN chmod +x /usr/sbin/rstudio-server.sh



# Infrastructure specific
RUN groupadd -g 9999 -f rstudio
#RUN useradd -d /home/rstudio -m -g rstudio -u 9999 -s /bin/bash rstudio
#RUN echo 'rstudio:docker' | chpasswd
#USER root
#RUN umount /home/rstudio
#RUN rm -rf /home/rstudio

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

RUN echo "#!/bin/sh" > /usr/sbin/rstudio-server.sh
RUN echo "service nslcd start" >> /usr/sbin/rstudio-server.sh
RUN echo "sleep 10" >> /usr/sbin/rstudio-server.sh
RUN echo "/usr/lib/rstudio-server/bin/rserver --server-daemonize=0" >> /usr/sbin/rstudio-server.sh
RUN chmod +x /usr/sbin/rstudio-server.sh



# expose port
EXPOSE 8080

# Define Entry point script
WORKDIR /
CMD ["/usr/sbin/rstudio-server.sh"]

