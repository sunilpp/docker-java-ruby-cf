
FROM ubuntu:15.04

#================================================
# Customize sources for apt-get
#================================================
RUN  echo "deb http://archive.ubuntu.com/ubuntu vivid main universe\n" > /etc/apt/sources.list \
  && echo "deb http://archive.ubuntu.com/ubuntu vivid-updates main universe\n" >> /etc/apt/sources.list

RUN apt-get update -qqy \
  && apt-get -qqy --no-install-recommends install software-properties-common \
  && add-apt-repository -y ppa:git-core/ppa

#========================
# Miscellaneous packages
# iproute which is surprisingly not available in ubuntu:15.04 but is available in ubuntu:latest
# OpenJDK8
# rlwrap is for azure-cli
# groff is for aws-cli
# tree is convenient for troubleshooting builds
#========================
RUN apt-get update -qqy \
  && apt-get -qqy --no-install-recommends install \
    iproute \
    openssh-client ssh-askpass\
    ca-certificates \
    openjdk-8-jdk \
    tar zip unzip \
    wget curl \
    git \
    build-essential \
    less nano tree \
    python python-pip groff \
    rlwrap \
    bison \
    libffi-dev \
    libgdbm-dev \
    libgdbm3 \
    libncurses5-dev \
    libreadline6-dev \
    libssl-dev \
    libyaml-dev \
    zlib1g-dev \
  && rm -rf /var/lib/apt/lists/* \
  && sed -i 's/securerandom\.source=file:\/dev\/random/securerandom\.source=file:\/dev\/urandom/' ./usr/lib/jvm/java-8-openjdk-amd64/jre/lib/security/java.security

# workaround https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=775775
RUN [ -f "/etc/ssl/certs/java/cacerts" ] || /var/lib/dpkg/info/ca-certificates-java.postinst configure
#========================================
# Add normal user with passwordless sudo
#========================================
RUN useradd builder --shell /bin/bash --create-home \
  && usermod -a -G sudo builder \
  && echo 'ALL ALL = (ALL) NOPASSWD: ALL' >> /etc/sudoers \
  && echo 'builder:secret' | chpasswd


# use rbenv understandable version
ARG RUBY_VERSION
ENV RUBY_VERSION=${RUBY_VERSION:-2.3.0}

COPY scripts/package-setup.sh /
RUN /package-setup.sh $RUBY_VERSION
RUN rm -fv /package-setup.sh

COPY scripts/rbenv-setup.sh /
RUN bash /rbenv-setup.sh $RUBY_VERSION
RUN rm -fv /rbenv-setup.sh

COPY scripts/init.sh /init.sh
RUN chmod +x /init.sh
ENTRYPOINT ["/init.sh"]


#==========
# Maven
#==========
ENV MAVEN_VERSION 3.3.9

RUN curl -fsSL http://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar xzf - -C /usr/share \
  && mv /usr/share/apache-maven-$MAVEN_VERSION /usr/share/maven \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

ENV MAVEN_HOME /usr/share/maven



#====================================
# Cloud Foundry CLI
# https://github.com/cloudfoundry/cli
#====================================
RUN wget -O - "http://cli.run.pivotal.io/stable?release=linux64-binary&source=github" | tar -C /usr/local/bin -zxf -

# compatibility with CloudBees AWS CLI Plugin which expects pip to be installed as user
RUN mkdir -p /root/.local/bin/ \
  && ln -s /usr/bin/pip /root/.local/bin/pip \
  && chown -R builder:builder /root/.local

#====================================
# NODE JS
# See https://nodejs.org/en/download/package-manager/#debian-and-ubuntu-based-linux-distributions
#====================================
RUN curl -sL https://deb.nodesource.com/setup_4.x | bash \
    && apt-get install -y nodejs

#====================================
# BOWER, GRUNT, GULP
#====================================

RUN npm install --global grunt-cli@0.1.2 bower@1.7.9 gulp@3.9.1

#====================================
# install Rbenv,Ruby 
#====================================

# use rbenv understandable version




USER builder

# for dev purpose
# USER root


