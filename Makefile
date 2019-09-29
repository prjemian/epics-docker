# build (or push) subdirectories

build ::
	make -C n1_os_only      $@
	make -C n2_epics_base   $@
	make -C n3_synApps      $@
	# make -C n4_areaDetector $@

push ::
	# make -C n1_os_only      $@
	make -C n2_epics_base   $@
	make -C n3_synApps      $@
	# make -C n4_areaDetector $@
