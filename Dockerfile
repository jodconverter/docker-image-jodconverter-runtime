ARG TARGET_BASE_IMAGE=debian:bookworm

FROM eclipse-temurin:21-jdk-jammy as javabase
ENV JAVA_MODULES=java.base,java.compiler,java.datatransfer,java.desktop,java.instrument,java.logging,java.management,java.management.rmi,java.naming,java.net.http,java.prefs,java.rmi,java.scripting,java.se,java.security.jgss,java.security.sasl,java.smartcardio,java.sql,java.sql.rowset,java.transaction.xa,java.xml,java.xml.crypto,jdk.accessibility,jdk.charsets,jdk.crypto.cryptoki,jdk.crypto.ec,jdk.dynalink,jdk.httpserver,jdk.incubator.vector,jdk.internal.vm.ci,jdk.internal.vm.compiler,jdk.internal.vm.compiler.management,jdk.jdwp.agent,jdk.jfr,jdk.jsobject,jdk.localedata,jdk.management,jdk.management.agent,jdk.management.jfr,jdk.naming.dns,jdk.naming.rmi,jdk.net,jdk.nio.mapmode,jdk.sctp,jdk.security.auth,jdk.security.jgss,jdk.unsupported,jdk.xml.dom,jdk.zipfs

RUN $JAVA_HOME/bin/jlink \
    --add-modules $JAVA_MODULES \
    --strip-debug \
    --no-man-pages \
    --no-header-files \
    --compress=2 \
    --output /jre

############ JRE ############
ARG TARGET_BASE_IMAGE=debian:bookworm
FROM $TARGET_BASE_IMAGE as jre

ENV JAVA_HOME=/opt/java/openjdk
ENV PATH "${JAVA_HOME}/bin:${PATH}"
COPY --from=javabase /jre $JAVA_HOME

RUN apt-get update && apt-get -y install \
  apt-transport-https locales-all libpng16-16 libxinerama1 libgl1-mesa-glx libfontconfig1 libfreetype6 libxrender1 \
  libxcb-shm0 libxcb-render0 adduser cpio findutils gosu \
  # procps needed for us finding the libreoffice process, see https://github.com/sbraconnier/jodconverter/issues/127#issuecomment-463668183
  procps \
  && apt-get -y install libreoffice libreoffice-java-common --no-install-recommends \
  && useradd -m jodconverter \
  && rm -rf /var/lib/apt/lists/*

# We do not need a CMD nor ENTRYPOINT, since we are not going to run anything. This is just the libreoffice runtime for \
# running jodconverter - the app is packaged in a different repo
