FROM frolvlad/alpine-glibc:alpine-3.4

MAINTAINER rajat.vig@gmail.com

ENV JAVA_HOME /usr/local/java
ENV JRE ${JAVA_HOME}/jre
ENV JAVA_OPTS=-Djava.awt.headless=true PATH=${PATH}:${JRE}/bin:${JAVA_HOME}/bin

WORKDIR /tmp

RUN \
  echo ipv6 >> /etc/modules && \
  apk add --no-cache ca-certificates wget && \
  sed -i -e 's#:/bin/[^:].*$#:/sbin/nologin#' /etc/passwd && \
  checksum="516d999293be394116fdcecc64feaf49" && \
  url="http://cdn.azul.com/zulu-pre/bin/zulu9.0.0.7-ea-jdk9.0.0-linux_x64.tar.gz" && \
  referer="http://zulu.org/download/" && \
  wget --referer "${referer}" "${url}" && \
  md5=$(md5sum *.tar.gz | cut -f1 -d' ') && \
  if [ ${checksum} != ${md5} ]; then \
    echo "[FATAL] File md5 ${md5} doesn't match published checksum ${checksum}. Exiting." >&2 && \
    exit 1; \
  fi && \
  tar -xzf *.tar.gz && \
  rm *.tar.gz && \
  mkdir -p $(dirname ${JAVA_HOME}) && \
  mv * ${JAVA_HOME} && \
  cd .. && \
  rmdir ${OLDPWD} && \
  cd ${JAVA_HOME} && \
  rm -rf *.zip demo man sample && \
  for ff in ${JAVA_HOME}/bin/*; do f=$(basename $ff); if [ -e ${JRE}/bin/$f ]; then ln -snf ${JRE}/bin/$f $ff; fi; done && \
  apk del ca-certificates openssl wget  && \
  rm -rf /tmp/* /var/cache/apk/* && \
  java -version

WORKDIR /root
