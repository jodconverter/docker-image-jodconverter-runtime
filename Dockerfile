ARG TARGET_BASE_IMAGE=debian:trixie

############ JRESOURCE ############
FROM amazoncorretto:25 as jvmsource
ENV JAVA_MODULES=java.base,java.compiler,java.datatransfer,java.desktop,java.instrument,java.logging,java.management,java.management.rmi,java.naming,java.net.http,java.prefs,java.rmi,java.scripting,java.se,java.security.jgss,java.security.sasl,java.smartcardio,java.sql,java.sql.rowset,java.transaction.xa,java.xml,java.xml.crypto,jdk.accessibility,jdk.charsets,jdk.crypto.cryptoki,jdk.crypto.ec,jdk.dynalink,jdk.httpserver,jdk.incubator.vector,jdk.internal.vm.ci,jdk.graal.compiler,jdk.graal.compiler.management,jdk.jdwp.agent,jdk.jfr,jdk.jsobject,jdk.localedata,jdk.management,jdk.management.agent,jdk.management.jfr,jdk.naming.dns,jdk.naming.rmi,jdk.net,jdk.nio.mapmode,jdk.sctp,jdk.security.auth,jdk.security.jgss,jdk.unsupported,jdk.xml.dom,jdk.zipfs

RUN dnf install -y binutils \
 # the jdk/jre is missing ca certificate on corretto, install those
 && dnf install -y ca-certificates \
 && update-ca-trust \
 && dnf clean all

RUN $JAVA_HOME/bin/jlink \
    --add-modules $JAVA_MODULES \
    --strip-debug \
    --no-man-pages \
    --no-header-files \
    --output /jre \
 # add the ca-certificates that we miss with corretto
 && rm -f /jre/lib/security/cacerts \
 && cp -L /etc/pki/java/cacerts /jre/lib/security/cacerts \
 && /jre/bin/keytool -list -cacerts -storepass changeit | head -2

############ JRE ############
ARG TARGET_BASE_IMAGE

FROM $TARGET_BASE_IMAGE as jre

ENV JAVA_HOME=/opt/java/openjdk
ENV PATH "${JAVA_HOME}/bin:${PATH}"

# expose our GOSU user
ENV NONPRIVUSER=jodconverter
ENV NONPRIVGROUP=jodconverter

# Set default characterset encoding to UTF-8
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

COPY --from=jvmsource /jre $JAVA_HOME

# using backports for libreoffice 26.x (trixie has 25.x)
RUN echo 'deb http://deb.debian.org/debian trixie-backports main' > /etc/apt/sources.list.d/backports.list \
  && echo 'deb http://deb.debian.org/debian trixie contrib' > /etc/apt/sources.list.d/contrib.list \
  && apt-get update && apt-get -y install \
  apt-transport-https locales-all libpng16-16 libxinerama1 glx-alternative-mesa libfontconfig1 libfreetype6 libxrender1 \
  libxcb-shm0 libxcb-render0 adduser cpio findutils gosu \
  # procps needed for us finding the libreoffice process, see https://github.com/sbraconnier/jodconverter/issues/127#issuecomment-463668183
  procps \
  # using backports for libreoffice 26.x (trixie has 25.x)
  && apt-get -y install -t trixie-backports libreoffice libreoffice-base libreoffice-common libreoffice-base-core \
  && groupadd $NONPRIVGROUP \
  && useradd -m $NONPRIVUSER -g $NONPRIVGROUP \
  && rm -rf /var/lib/apt/lists/*

# create font-cache for our gosu user
USER jodconverter
RUN fc-cache -fr
USER root

# We do not need a CMD nor ENTRYPOINT, since we are not going to run anything. This is just the libreoffice runtime for \
# running jodconverter - the app is packaged in a different repo

############ jdk ############

FROM jre as jdk
ENV JAVA_HOME=/opt/java/openjdk

COPY --from=jvmsource /usr/lib/jvm/java-25-amazon-corretto $JAVA_HOME
# add the ca-certificates that we miss with corretto
COPY --from=jvmsource /jre/lib/security/cacerts $JAVA_HOME/lib/security/cacerts
