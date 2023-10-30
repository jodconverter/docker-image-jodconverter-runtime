ARG TARGET_BASE_IMAGE=debian:bookworm
ARG JAVA_VERSION=17

############ JRESOURCE ############
FROM eclipse-temurin:${JAVA_VERSION}-jdk-jammy as jresource
ENV JAVA_MODULES=java.base,java.compiler,java.datatransfer,java.desktop,java.instrument,java.logging,java.management,java.management.rmi,java.naming,java.net.http,java.prefs,java.rmi,java.scripting,java.se,java.security.jgss,java.security.sasl,java.smartcardio,java.sql,java.sql.rowset,java.transaction.xa,java.xml,java.xml.crypto,jdk.accessibility,jdk.charsets,jdk.crypto.cryptoki,jdk.crypto.ec,jdk.dynalink,jdk.httpserver,jdk.incubator.vector,jdk.internal.vm.ci,jdk.internal.vm.compiler,jdk.internal.vm.compiler.management,jdk.jdwp.agent,jdk.jfr,jdk.jsobject,jdk.localedata,jdk.management,jdk.management.agent,jdk.management.jfr,jdk.naming.dns,jdk.naming.rmi,jdk.net,jdk.nio.mapmode,jdk.sctp,jdk.security.auth,jdk.security.jgss,jdk.unsupported,jdk.xml.dom,jdk.zipfs

RUN $JAVA_HOME/bin/jlink \
    --add-modules $JAVA_MODULES \
    --strip-debug \
    --no-man-pages \
    --no-header-files \
    --compress=2 \
    --output /jre

############ JRE ############
ARG TARGET_BASE_IMAGE

FROM $TARGET_BASE_IMAGE as jre

ARG JAVA_VERSION

ENV JAVA_HOME=/opt/java/openjdk
ENV PATH "${JAVA_HOME}/bin:${PATH}"

# expose our GOSU user
ENV NONPRIVUSER=jodconverter
ENV NONPRIVGROUP=jodconverter

COPY --from=jresource /jre $JAVA_HOME

RUN apt-get update && apt-get -y install \
  apt-transport-https locales-all libpng16-16 libxinerama1 libgl1-mesa-glx libfontconfig1 libfreetype6 libxrender1 \
  libxcb-shm0 libxcb-render0 adduser cpio findutils gosu \
  # procps needed for us finding the libreoffice process, see https://github.com/sbraconnier/jodconverter/issues/127#issuecomment-463668183
  procps \
  && apt-get -y install libreoffice libreoffice-java-common --no-install-recommends \
  && useradd -m $NONPRIVUSER -g $NONPRIVGROUP \
  && rm -rf /var/lib/apt/lists/*

# We do not need a CMD nor ENTRYPOINT, since we are not going to run anything. This is just the libreoffice runtime for \
# running jodconverter - the app is packaged in a different repo

############ jdk ############

FROM jre as jdk
ARG JAVA_VERSION

# unset old JAVA_HOME (matches JRE) since we use a JDK here
ENV JAVA_HOME ""

# see https://adoptium.net/installation/linux/
RUN unset JAVA_HOME \
    && apt update && apt install -y wget apt-transport-https \
    && mkdir -p /etc/apt/keyrings \
    && wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | tee /etc/apt/keyrings/adoptium.asc \
    && echo "deb [signed-by=/etc/apt/keyrings/adoptium.asc] https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | tee /etc/apt/sources.list.d/adoptium.list \
    && apt update \
    && apt install -y temurin-${JAVA_VERSION}-jdk \
    && apt autoclean -y && apt clean -y \
    # rm jdk
    && rm -fr /opt/java/openjdk

