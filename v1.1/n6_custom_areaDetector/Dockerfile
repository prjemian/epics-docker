FROM  prjemian/synapps-6.2-ad-3.10
LABEL version="1.1.0" \
      maintainer="prjemian <prjemian@gmail.com>"
      # lastupdate="2021-02-03" \
      # Description="see docs at https://github.com/prjemian/epics-docker/blob/master/n4_areaDetector/README.md"
USER  root
WORKDIR /home
RUN pwd && ls -lAFgh

# TODO: more

RUN bash /opt/copy_screens.sh ${SUPPORT} /opt/screens | tee -a copy_screens.log

COPY ioc_files/customize_ad.sh /opt
RUN /opt/customize_ad.sh 2>&1 | tee /opt/customize_ad.log
