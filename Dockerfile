FROM ubuntu:20.04
MAINTAINER ASCDC <asdc.sinica@gmail.com>

ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

ADD run.sh /script/run.sh

RUN chmod +x /script/*.sh && \
	sed -i -E 's/http:\/\/(.*\.)?(archive\.ubuntu\.com)/http:\/\/tw\.\2/g' /etc/apt/sources.list && \
	apt-get update && \
	echo "tzdata tzdata/Areas select Asia" | debconf-set-selections && \
	echo "tzdata tzdata/Zones/Asia select Taipei" | debconf-set-selections && \
	echo "locales locales/default_environment_locale select zh_TW.UTF-8" | debconf-set-selections && \
	echo "locales locales/locales_to_be_generated multiselect zh_TW.UTF-8 UTF-8" | debconf-set-selections && \
	apt-get -y install jq git wget curl vim apt-utils software-properties-common sudo tzdata locales language-pack-zh-hant language-pack-zh-hant-base apt-transport-https ca-certificates gnupg-agent build-essential pkg-config libmagickwand-dev gcc-multilib dkms make gcc g++ && \
	ln -fs /usr/share/zoneinfo/Asia/Taipei /etc/localtime && \
	dpkg-reconfigure --frontend noninteractive tzdata && \
	rm -f "/etc/locale.gen" && \
	dpkg-reconfigure --frontend noninteractive locales && \
	locale-gen en_US.UTF-8 && \
	export LANG=zh_TW.UTF-8 && \
	export LC_ALL=zh_TW.UTF-8 && \
	echo "export LANG=zh_TW.UTF-8" >> ~/.bashrc && \
	echo "export LC_ALL=zh_TW.UTF-8" >> ~/.bashrc && \
	echo "export TZ=Asia/Taipei" >> ~/.bashrc && \
	add-apt-repository -y ppa:ondrej/php && \
	add-apt-repository -y ppa:ondrej/apache2
RUN apt-get update && \
	apt-get -y upgrade && \
	apt-get install -y apache2 php8.0 php8.0-common php8.0-cli php8.0-opcache php-uploadprogress php-memcache php8.0-zip php8.0-mysql php8.0-phpdbg php8.0-gd php8.0-imap php8.0-ldap php8.0-pgsql php8.0-pspell php8.0-tidy php8.0-dev php8.0-intl php8.0-curl php8.0-xmlrpc php8.0-xsl php8.0-bz2 php8.0-mbstring imagemagick && \
	mkdir /tmp/imagick && \
	git clone https://github.com/Imagick/imagick /tmp/imagick && \
	cd /tmp/imagick && \
	phpize && \
	./configure && \
	make && \
	make install && \
	cd / && \
	rm -rf /tmp/* && \
	echo "extension=imagick.so" | tee /etc/php/8.0/mods-available/imagick.ini && \
	ln -sf /etc/php/8.0/mods-available/imagick.ini /etc/php/8.0/apache2/conf.d/20-imagick.ini && \
	ln -sf /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled/rewrite.load

EXPOSE 80
WORKDIR /var/www/html
ENTRYPOINT ["/script/run.sh"]
