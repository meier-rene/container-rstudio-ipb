# Full-blown RStudio Server metabolomics installation

To install create a rstudio container image derived from rocker/rstudio without
the VOLUME definition. This breaks user home dirs on IPB infrastructure.

Then create container with:
```
docker build . -t rstudio-ipb 
docker run -d --restart=always -p 80:8787 -v "/vol:/vol" -v "/mnt/ifs:/mnt/ifs" -v "/home:/home" --name rstudio-ipb-run rstudio-ipb
```