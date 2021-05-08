FROM  prjemian/synapps-6.2
LABEL version="1.1.0" \
      maintainer="prjemian <prjemian@gmail.com>" \
      Description="source: https://github.com/prjemian/epics-docker/"
USER  root
WORKDIR /home
CMD bash
RUN pwd && ls -lAFgh

COPY ioc_files/general_purpose.db ${IOCXXX}/substitutions
COPY ioc_files/customize_xxx.sh /opt
RUN /opt/customize_xxx.sh && pwd
RUN bash /opt/copy_screens.sh ${SUPPORT} /opt/screens | tee -a /opt/copy_screens.log

# archive the template IOC, for making new XXX IOCs
WORKDIR ${SUPPORT}
RUN \
    pwd && ls -lAFgh && \
    tar czf /opt/$(basename ${XXX}).tar.gz $(basename ${XXX})
