FROM  prjemian/synapps-6.2-ad-3.10
LABEL version="1.1.0" \
      maintainer="prjemian <prjemian@gmail.com>" \
      Description="source: https://github.com/prjemian/epics-docker/"
USER  root
WORKDIR /home
CMD  bash
RUN pwd && ls -lAFgh

COPY ioc_files/customize_ad.sh /opt
RUN /opt/customize_ad.sh 2>&1 | tee /opt/customize_ad.log

RUN bash /opt/copy_screens.sh ${SUPPORT} /opt/screens | tee -a /opt/copy_screens.log
COPY \
      sim_cam_image.ui \
      start_caQtDM_adsim \
      /opt/iocSimDetector/
COPY \
      url_cam_image.ui \
      start_caQtDM_adurl \
      /opt/iocURLDriver/
RUN bash /opt/modify_adl_in_ui_files.sh  /opt/screens/ui
