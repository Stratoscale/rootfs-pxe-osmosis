ROOTFS = build/root
PIP_INSTALL_ARGUMENTS = -i http://pip-repo/simple/ --extra-index-url http://mirrors.stratoscale.com.s3-website-us-east-1.amazonaws.com/pip/simple

all: upseto_check rootfs
	echo "rootfs-clean-build built succesfully"

submit:
	sudo -E solvent submitproduct rootfs $(ROOTFS)

approve:
	sudo -E solvent approve --product=rootfs

clean:
	sudo rm -fr build

upseto_check:
	upseto checkRequirements; if [ $$? -ne 0 ]; then echo -e "\e[31m\e[1mWARNING: upseto checkRequirements failed! Did you forget to fulfill?\e[0m"; echo "Sleeping for 5 seconds"; sleep 5 ; fi

rootfs:
	$(MAKE) $(ROOTFS)

.PHONY: $(ROOTFS)
$(ROOTFS):
	 -sudo mv $(ROOTFS) $(ROOTFS).tmp
	 echo "Bringing source"
	 -mkdir $(@D)

	sudo -E solvent bring --repositoryBasename=rootfs-centos7-vanilla --product=rootfs --destination=$(ROOTFS).tmp

	echo "Installing CentOS RPMS"
	./chroot.sh $(ROOTFS).tmp yum install --assumeyes $(CENTOS_RPMS)

	echo "Installing EPEL RPMS"
	cp  epel-release-7-5.noarch.rpm $(ROOTFS).tmp/tmp/
	./chroot.sh $(ROOTFS).tmp yum install --assumeyes /tmp/epel-release-7-5.noarch.rpm
	./chroot.sh $(ROOTFS).tmp yum install --assumeyes $(EPEL_RPMS)

	echo "Removing requiretty"
	sudo sed -i -e 's/Defaults.*requiretty/#Defaults    requiretty/' $(ROOTFS).tmp/etc/sudoers

	echo "Installing python packages"
	./chroot.sh $(ROOTFS).tmp pip install $(PIP_INSTALL_ARGUMENTS) $(PYTHON_PACKAGES)

	echo "Installing NextGen DevStack"
	mkdir -p $(ROOTFS).tmp/tmp/devstack
	cp -a ../{upseto,solvent,osmosis,strato-pylint} $(ROOTFS).tmp/tmp/devstack
	./chroot.sh $(ROOTFS).tmp /bin/sh -c "cd /tmp/devstack/upseto && make install"
	./chroot.sh $(ROOTFS).tmp /bin/sh -c "cd /tmp/devstack/solvent && make install"
	./chroot.sh $(ROOTFS).tmp /bin/sh -c "cd /tmp/devstack/osmosis && make build && make install"
	./chroot.sh $(ROOTFS).tmp /bin/sh -c "cd /tmp/devstack/strato-pylint && make install"

	echo "Cleanup"
	sudo rm -fr /tmp/devstack

	sudo mv $(ROOTFS).tmp $(ROOTFS)


CENTOS_RPMS = \
	automake \
	babeltrace \
	boost-devel \
	createrepo \
	cscope \
	ctags \
	curl \
	doxygen \
	fuseiso \
	fontforge \
	gcc \
	gcc-c++ \
	git \
	httpd-tools \
	java-1.7.0-openjdk \
	kernel-debug-devel \
	kernel-devel \
	libcap \
	libvirt-python \
	lttng-tools \
	lttng-ust \
	lttng-ust-devel \
	make \
	ncurses-devel \
	nmap \
	openssl-devel \
	python-devel \
	python-dmidecode \
	python-matplotlib \
	python-netaddr \
	rpmdevtools \
	ruby \
	ruby-devel \
	rubygem-rake \
	spice-gtk-tools \
	tcpdump \
	udisks2 \
	unzip \
	vim-enhanced \
	wget \
	xmlrpc-c-devel \
	yum-utils \


EPEL_RPMS = \
	s3cmd \
	python-pip \
	ack \


PYTHON_PACKAGES = $(PIP_PACKAGES) $(PIP_PACKAGES_INDIRECT_DEPENDENCY)

PIP_PACKAGES =  \
	anyjson==0.3.3 \
	bunch==1.0.1 \
	bz2file==0.95 \
	coverage==3.7 \
	Django==1.6 \
	djangorestframework==2.3.10 \
	django-tagging==0.3.1 \
	Flask==0.10.1 \
	Flask-RESTful==0.2.8 \
	futures==2.1.5 \
	graphite-web==0.9.12 \
	ipdb==0.8 \
	Jinja2==2.7.1 \
	lcov_cobertura==1.4 \
	mock==1.0.1 \
	netifaces==0.10.4 \
	networkx==1.8.1 \
	paramiko==1.12.0 \
	pep8==1.5.7 \
	pip2pi==0.5.0 \
	pss==1.39 \
	psutil==1.2.1 \
	PyCPUID==0.4 \
	pyiface==0.0.1 \
	pylint==1.0.0 \
	python-cinderclient==1.0.7 \
	python-novaclient==2.15.0 \
	PyYAML==3.10 \
	pyzmq==14.0.1 \
	requests==2.1.0 \
	requests-toolbelt==0.2.0 \
	qpid-python==0.26 \
	selenium==2.38.1 \
	setuptools==11.3.1 \
	sh==1.09 \
	simplejson==3.3.1 \
	single==0.0.2 \
	stevedore==1.2.0 \
	taskflow==0.1.3 \
	tornado==3.1.1 \
	Twisted==13.2.0 \
	vncdotool==0.8.0 \
	whisper==0.9.12 \
	xmltodict==0.8.3 \
	pyftpdlib==1.4.0 \
	ftputil==3.2 \


PIP_PACKAGES_INDIRECT_DEPENDENCY =  \
	astroid==1.0.1 \
	argparse==1.3.0 \
	Babel==1.3 \
	docopt==0.6.2 \
	ecdsa==0.10 \
	ipython==2.1.0 \
	iso8601==0.1.8 \
	itsdangerous==0.23 \
	logilab-common==0.60.0 \
	MarkupSafe==0.18 \
	pbr==0.5.23 \
	pip==1.4.1 \
	pycrypto==2.6.1 \
	PIL==1.1.7 \
	prettytable==0.7.2 \
	pytz==2012d \
	six==1.9.0 \
	txAMQP==0.6.2 \
	Werkzeug==0.9.4 \
	wsgiref==0.1.2 \
	zope.interface==4.0.5 \
