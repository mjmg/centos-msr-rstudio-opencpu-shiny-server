
FROM mjmg/centos-msr-base:latest

RUN \
  yum install -y epel-release && \
  yum install -y yum-utils \
                 rpmdevtools \
                 make \
                 httpd-devel \
                 libapreq2-devel \
                 libcurl-devel \
                 protobuf-devel \
                 openssl-devel \
                 libpng-devel \
                 libtiff-devel \
                 libjpeg-turbo-devel \
                 fftw-devel \
                 mesa-libGLU-devel \
                 ed \
                 netcdf-devel \
                 tk-devel \
                 git


#  wget http://dl.fedoraproject.org/pub/epel/7/SRPMS/l/libapreq2-2.13-11.el7.1.src.rpm && \
#  wget http://dl.fedoraproject.org/pub/epel/7/SRPMS/n/netcdf-4.3.3.1-5.el7.src.rpm && \
#  yum-builddep -y --nogpgcheck libapreq2-2.13-11.el7.1.src.rpm netcdf-4.3.3.1-5.el7.src.rpm

RUN \
  useradd -ms /bin/bash builder
  #chmod o+r rapache-1.2.7-2.1.src.rpm && \
  #chmod o+r opencpu-1.6.2-7.1.src.rpm
#  mv netcdf-4.3.3.1-5.el7.src.rpm /home/builder/ && \
#  mv libapreq2-2.13-11.el7.1.src.rpm /home/builder/

USER builder

RUN \
  rpmdev-setuptree

COPY \
  R-devel-fake.spec /tmp/R-devel-fake.spec

RUN \
  rpmbuild -bb /tmp/R-devel-fake.spec

#USER builder

#RUN \
#  cd ~ && \
#  rpm -ivh netcdf-4.3.3.1-5.el7.src.rpm && \
#  rpmbuild -ba ~/rpmbuild/SPECS/netcdf.spec

#RUN \
#  cd ~ && \
#  rpm -ivh libapreq2-2.13-11.el7.1.src.rpm && \
#  rpmbuild -ba ~/rpmbuild/SPECS/libapreq2.spec


USER root

RUN \
  #cd /home/builder/rpmbuild/RPMS/noarch/ && \
  rpm -ivh /home/builder/rpmbuild/RPMS/noarch/R-devel-fake*.rpm && \
  cd /home/builder/ && \
  wget http://download.opensuse.org/repositories/home:/jeroenooms:/opencpu-1.6/Fedora_23/src/rapache-1.2.7-2.1.src.rpm && \ 
  wget http://download.opensuse.org/repositories/home:/jeroenooms:/opencpu-1.6/Fedora_23/src/opencpu-1.6.2-7.1.src.rpm

RUN \
  yum-builddep -y --nogpgcheck rapache-1.2.7-2.1.src.rpm && \
  yum-builddep -y --nogpgcheck opencpu-1.6.2-7.1.src.rpm

USER builder

RUN \
  cd ~ && \
  rpm -ivh rapache-1.2.7-2.1.src.rpm && \
  rpmbuild -ba ~/rpmbuild/SPECS/rapache.spec

RUN \
  cd ~ && \
  rpm -ivh opencpu-1.6.2-7.1.src.rpm && \
  rpmbuild -ba ~/rpmbuild/SPECS/opencpu.spec 

RUN \
  cd ~ && \
  wget https://download2.rstudio.org/rstudio-server-rhel-1.0.44-x86_64.rpm && \
  wget https://download3.rstudio.org/centos5.9/x86_64/shiny-server-1.5.1.834-rh5-x86_64.rpm


USER root

RUN \
  yum reinstall -y glibc-common && \
  localedef --quiet -c -i en_US -f UTF-8 en_US.UTF-8


# Configure default locale
#RUN localectl set-locale LANG=en_US.UTF-8 && \
#    update-locale



ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

RUN \
  yum install -y MTA mod_ssl /usr/sbin/semanage && \
#  rpm -ivh netcdf*.rpm && \
#  rom -ivf libapreq*.rpm && \
  rpm -ivh /home/builder/rpmbuild/RPMS/x86_64/rapache-*.rpm && \
  rpm -ivh /home/builder/rpmbuild/RPMS/x86_64/opencpu-lib-*.rpm && \
  rpm -ivh /home/builder/rpmbuild/RPMS/x86_64/opencpu-server-*.rpm

RUN \
  yum install -y --nogpgcheck /home/builder/rstudio-server-rhel-1.0.44-x86_64.rpm 

RUN \
  #R -e \"install.packages('shiny', repos='https://cran.rstudio.com/')"
  echo "Installing shiny from CRAN" && \
  Rscript -e "install.packages('shiny')"


RUN \
  yum install -y --nogpgcheck /home/builder/shiny-server-1.5.1.834-rh5-x86_64.rpm
  
RUN mkdir -p /var/log/shiny-server \
	&& chown shiny:shiny /var/log/shiny-server \
	&& chown shiny:shiny -R /srv/shiny-server \
	&& chmod 777 -R /srv/shiny-server \
	&& chown shiny:shiny -R /opt/shiny-server/samples/sample-apps \
	&& chmod 777 -R /opt/shiny-server/samples/sample-apps 


# Cleanup
RUN \
  rm -rf /home/builder/* && \
  userdel builder && \
  yum autoremove -y

# Add default root password with password r00tpassw0rd
RUN \
  echo "root:r00tpassw0rd" | chpasswd  

# Add default rstudio user with pass rstudio
RUN \
  useradd rstudio && \
  echo "rstudio:rstudio" | chpasswd && \ 
  chmod -R +r /home/rstudio

# Apache ports
EXPOSE 80
EXPOSE 443
EXPOSE 8004
EXPOSE 9001
EXPOSE 3838

USER root

# Add supervisor conf files
ADD \
  rstudio-server.conf /etc/supervisor/conf.d/rstudio-server.conf
ADD \
  opencpu.conf /etc/supervisor/conf.d/opencpu.conf 
ADD \
  shiny-server.conf /etc/supervisor/conf.d/shiny-server.conf

# install additional packages
ADD \ 
  installRpackages.sh /usr/local/bin/installRpackages.sh
RUN \
  chmod +x /usr/local/bin/installRpackages.sh && \
  /usr/local/bin/installRpackages.sh
  
# Define default command.
#CMD ["/usr/bin/supervisord","-c","/etc/supervisor/supervisord.conf"]
CMD ["/usr/sbin/init"]
