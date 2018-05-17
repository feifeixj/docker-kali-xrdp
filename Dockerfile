FROM kalilinux/kali-linux-docker
MAINTAINER feifeixj 220150878@seu.edu.cn
RUN cp  /etc/apt/sources.list /etc/apt/sources.list.old
ADD sources.list /etc/apt/sources.list
RUN apt-get -yy update
RUN apt-get -yy upgrade
ENV BUILD_DEPS="git autoconf pkg-config libssl-dev libpam0g-dev \
    libx11-dev libxfixes-dev libxrandr-dev nasm xsltproc flex \
    bison libxml2-dev dpkg-dev libcap-dev"
RUN apt-get -yy install \ 
    sudo apt-utils software-properties-common vim wget net-tools iputils-ping traceroute ca-certificates \
     xauth supervisor uuid-runtime pulseaudio locales \
    pepperflashplugin-nonfree openssh-server \
    bwa samtools  zsh  ibus-kkc file  vcftools bedtools \
    supervisor  libxml2 mock gcc make python bash  \ 
    coreutils diffutils patch \
    $BUILD_DEPS

RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

RUN apt install -y xterm git synapse kali-linux-full kali-desktop-lxde
RUN apt install -y xfce4 xfce4-terminal xfce4-screenshooter xfce4-taskmanager \
    xfce4-clipman-plugin xfce4-cpugraph-plugin xfce4-netload-plugin \
    xfce4-xkb-plugin
#ENV DISPLAY=:1
#COPY startup.sh /startup.sh
#RUN chmod +x  /startup.sh


# Build xrdp
WORKDIR /tmp
RUN apt-get source pulseaudio
RUN apt-get build-dep -yy pulseaudio
WORKDIR /tmp/pulseaudio-8.0
#RUN dpkg-buildpackage -rfakeroot -uc -b
RUN apt install -y xrdp


# Configure
ADD bin /usr/bin
ADD etc /etc
RUN mkdir /var/run/dbus
RUN cp /etc/X11/xrdp/xorg.conf /etc/X11
RUN sed -i "s/xrdp\/xorg/xorg/g" /etc/xrdp/sesman.ini
RUN locale-gen en_US.UTF-8
RUN echo "xfce4-session" > /etc/skel/.Xclients
RUN cp -r /etc/ssh /ssh_orig
RUN rm -rf /etc/ssh/*
RUN rm -rf /etc/xrdp/rsakeys.ini /etc/xrdp/*.pem 

#Add user
RUN addgroup user
RUN useradd -m -s /bin/bash -g user user
RUN echo "user:user" | /usr/sbin/chpasswd
RUN echo "user    ALL=(ALL) ALL" >> /etc/sudoers


VOLUME ["/etc/ssh","/home"]
ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]
CMD ["supervisord"]
