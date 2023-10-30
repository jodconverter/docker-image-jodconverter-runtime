[![build-and-push](https://github.com/jodconverter/docker-image-jodconverter-runtime/actions/workflows/build.yml/badge.svg)](https://github.com/jodconverter/docker-image-jodconverter-runtime/actions/workflows/build.yml)

## Wat

Docker image to provide everything that is needed to run [JODconverter](https://github.com/jodconverter/jodconverter).
It includes LibreOffice and all needed libraries.

It does not include JODconverter as an app, see [JODconverter Example Apps](https://github.com/jodconverter/docker-image-jodconverter-examples)
for example projects build on top of this runtime, running JODconverter example apps.

## Builds info

- Official debian/bookworm with OpenJDK 17 Java (eclipse/temurin jlink based)
- LibreOffice is 7.4.+ right now

Hint: We cannot split [JODconverter](https://github.com/jodconverter/jodconverter) and LibreOffice into two separate images since for now, `JODconverter` has to be running on the same machine as LibreOffice.
The main reason behind this is, that [JODconverter](https://github.com/jodconverter/jodconverter) does manage the LibreOffice instances itself, starts and stop them. It does not just connect to it (and if, it uses a local socket)

## Credits

Credits to [LibreOffice](https://de.libreoffice.org/) for actually giving us the headless mode and the conversion options in the first place.

