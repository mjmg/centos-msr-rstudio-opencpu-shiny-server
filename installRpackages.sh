#!/bin/sh

# This installs R packages in CRAN
echo "Installing ggplot2 from CRAN"
Rscript -e "install.packages('ggplot2')"
echo "Installing rmarkdown from CRAN"
Rscript -e "install.packages('rmarkdown')"

# This installs R packages from github
echo "Installing hadley/dplyr from github"
Rscript -e "library(devtools); install_github('dplyr', 'hadley')"

# This installs opencpu webapps from github
echo "Installing appdemo, gitstats, tvscore and qitools/charts opencpu webapp"
Rscript -e "library(devtools); install_github('mjmg/appdemo')"
Rscript -e "library(devtools); install_github('mjmg/gitstats')"
Rscript -e "library(devtools); install_github('mjmg/tvscore')"
Rscript -e "library(devtools); install_github('qitools/charts')"


# This installs R packages under Bioconductor
echo "Installing Biobase from Bioconductor"
Rscript -e "source('https://bioconductor.org/biocLite.R'); biocLite('Biobase')"
echo "Installing EBImage from Bioconductor"
Rscript -e "source('https://bioconductor.org/biocLite.R'); biocLite('EBImage')"
echo "Installing BiocStyle from Bioconductor"
Rscript -e "source('https://bioconductor.org/biocLite.R'); biocLite('BiocStyle')"

