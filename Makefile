PATH := $(HOME)/bin:$(PATH)

all: home php svn-load Twisted lxml ImageMagick ghostscript mysql

home:
	(cd $(HOME) && patch -p0) < patches/home

	mkdir -m 700 $(HOME)/.ssh
	cp authorized_keys $(HOME)/.ssh
	chmod 644 $(HOME)/.ssh/authorized_keys

openldap:
	wget ftp://ftp.openldap.org/pub/OpenLDAP/openldap-stable/openldap-stable-20090411.tgz
	tar xz < openldap-stable-20090411.tgz

	(cd openldap-2.4.16 && ./configure --prefix=$(HOME) --disable-slapd)

	$(MAKE) -C openldap-2.4.16
	$(MAKE) -C openldap-2.4.16 install

php: openldap
	wget http://php.net/distributions/php-5.3.0.tar.bz2
	tar xj < php-5.3.0.tar.bz2

	(cd php-5.3.0 && ./configure --enable-mbstring --with-ldap=$(HOME) --with-mysql --with-pdo-mysql --with-zlib)

	$(MAKE) -C php-5.3.0
	cp php-5.3.0/sapi/cli/php $(HOME)/bin

python:
	wget http://www.python.org/ftp/python/2.6.2/Python-2.6.2.tar.bz2
	tar xj < Python-2.6.2.tar.bz2

	(cd Python-2.6.2 && ./configure --prefix=$(HOME))

	$(MAKE) -C Python-2.6.2
	$(MAKE) -C Python-2.6.2 install

apr:
	wget http://mirror.csclub.uwaterloo.ca/apache/apr/apr-1.3.7.tar.gz
	tar xz < apr-1.3.7.tar.gz

	(cd apr-1.3.7 && ./configure --prefix=$(HOME))

	$(MAKE) -C apr-1.3.7
	$(MAKE) -C apr-1.3.7 install

apr-util: apr
	wget http://mirror.csclub.uwaterloo.ca/apache/apr/apr-util-1.3.8.tar.gz
	tar xz < apr-util-1.3.8.tar.gz

	(cd apr-util-1.3.8 && ./configure --prefix=$(HOME) --with-apr=$(HOME))

	$(MAKE) -C apr-util-1.3.8
	$(MAKE) -C apr-util-1.3.8 install

neon:
	wget http://webdav.org/neon/neon-0.28.5.tar.gz
	tar xz < neon-0.28.5.tar.gz

	(cd neon-0.28.5 && ./configure --prefix=$(HOME))

	$(MAKE) -C neon-0.28.5
	$(MAKE) -C neon-0.28.5 install

subversion: apr-util neon
	wget http://subversion.tigris.org/downloads/subversion-1.6.3.tar.bz2
	tar xj < subversion-1.6.3.tar.bz2

	wget http://www.sqlite.org/sqlite-amalgamation-3_6_16.zip
	unzip sqlite-amalgamation-3_6_16.zip -d subversion-1.6.3/sqlite-amalgamation

	(cd subversion-1.6.3 && ./configure --prefix=$(HOME) --with-apr=$(HOME) --with-apr-util=$(HOME))

	$(MAKE) -C subversion-1.6.3
	$(MAKE) -C subversion-1.6.3 install

	$(MAKE) -C subversion-1.6.3 swig-py
	$(MAKE) -C subversion-1.6.3 install-swig-py

	# Save username and password
	svn info http://example.com/svn/hosting --username administrator --password example

pysvn: python subversion
	wget http://pysvn.barrys-emacs.org/source_kits/pysvn-1.7.0.tar.gz
	tar xz < pysvn-1.7.0.tar.gz

	(cd pysvn-1.7.0/Source && python setup.py configure --svn-inc-dir=$(HOME)/include/subversion-1 --apr-inc-dir=$(HOME)/include/apr-1 --svn-lib-dir=$(HOME)/lib --apr-lib-dir=$(HOME)/lib)
	(cd pysvn-1.7.0/Source && patch -p0) < patches/pysvn

	$(MAKE) -C pysvn-1.7.0/Source
	mkdir -p $(HOME)/lib/python/pysvn
	cp pysvn-1.7.0/Source/pysvn/__init__.py pysvn-1.7.0/Source/pysvn/_pysvn_2_6.so $(HOME)/lib/python/pysvn

svn-load: pysvn
	cp svn-load $(HOME)/bin

zope.interface:
	wget http://www.zope.org/Products/ZopeInterface/3.3.0/zope.interface-3.3.0.tar.gz
	tar xz < zope.interface-3.3.0.tar.gz

	(cd zope.interface-3.3.0 && python setup.py install --home=~)

Twisted: zope.interface
	wget http://tmrc.mit.edu/mirror/twisted/Twisted/8.2/Twisted-8.2.0.tar.bz2#md5=c85f151999df3ecf04c49a781b4438d2
	tar xj < Twisted-8.2.0.tar.bz2

	(cd Twisted-8.2.0 && python setup.py install --home=~)

libxslt:
	wget ftp://xmlsoft.org/libxml2/libxslt-1.1.24.tar.gz
	tar xz < libxslt-1.1.24.tar.gz

	(cd libxslt-1.1.24 && ./configure --prefix=$(HOME))

	$(MAKE) -C libxslt-1.1.24
	$(MAKE) -C libxslt-1.1.24 install

lxml: python libxslt
	wget http://codespeak.net/lxml/lxml-2.2.2.tgz
	tar xz < lxml-2.2.2.tgz

	(cd lxml-2.2.2 && python setup.py build)

ImageMagick:
	wget ftp://ftp.imagemagick.org/pub/ImageMagick/ImageMagick.tar.gz
	tar xz < ImageMagick.tar.gz

	(cd ImageMagick-6.5.4-8 && ./configure --prefix=$(HOME) --without-perl)

	$(MAKE) -C ImageMagick-6.5.4-8
	$(MAKE) -C ImageMagick-6.5.4-8 install

ghostscript:
	wget http://ghostscript.com/releases/ghostscript-8.64.tar.bz2
	tar xj < ghostscript-8.64.tar.bz2

	(cd ghostscript-8.64 && ./configure --prefix=$(HOME))

	$(MAKE) -C ghostscript-8.64

mysql:
	wget http://mirror.csclub.uwaterloo.ca/mysql/Downloads/MySQL-5.1/mysql-5.1.36.tar.gz
	tar xz < mysql-5.1.36.tar.gz

	(cd mysql-5.1.36 && ./configure --prefix=$(HOME) --without-server)

	$(MAKE) -C mysql-5.1.36
	$(MAKE) -C mysql-5.1.36 install
