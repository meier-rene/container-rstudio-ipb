# Full-blown RStudio Server metabolomics installation

For the installation a rstudio container image derived from rocker/rstudio without
the VOLUME definition is required. VOLUME breaks user home dirs on IPB infrastructure.
```
git clone https://github.com/rocker-org/rocker-versioned.git
cd rocker-versioned/rstudio
sed '/VOLUME \/home\/rstudio\/kitematic/d' -i latest.Dockerfile
docker build -t rstudio -f latest.Dockerfile .
export VERSION=`cat latest.Dockerfile | head -n1 | sed 's/.*\([0-9].[0-9].[0-9]\)/\1/'`
docker tag rstudio rstudio:"$VERSION"
```

Then create container with:
```
docker build . -t rstudio-ipb 
docker run -d --restart=always -p 80:8787 -v "/vol:/vol" -v "/mnt/ifs:/mnt/ifs" -v "/home:/home" --name rstudio-ipb-run rstudio-ipb
```