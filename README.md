[![build-and-push](https://github.com/EugenMayer/docker-image-jodconverter/actions/workflows/build.yml/badge.svg)](https://github.com/EugenMayer/docker-image-jodconverter/actions/workflows/build.yml)

## Wat

Docker image to provide everything that is needed to run [JODconverter](https://github.com/jodconverter/jodconverter).
It includes LibreOffice and all needed libraries.

It does not include jodconverter as an app, see [JODconverter Example Apps](https://github.com/EugenMayer/docker-image-jodconverter)
for example projects build on top of this runtime, running JODconverter example apps.

## Builds info

- Official OpenJDK 17 Java (bellsoft debian based)(since that is what we want with docker)
- LibreOffice is 6.1.5+ right now

Hint: We cannot split [JODconverter](https://github.com/jodconverter/jodconverter) and LibreOffice into two separate images since for now, `JODconverter` has to be running on the same machine as LibreOffice.
The main reason behind this is, that [JODconverter](https://github.com/sbraconnier/jodconverter) does manage the LibreOffice instances itself, starts and stop them. It does not just connect to it (and if, it uses a local socket)

## Credits

Credits to [LibreOffice](https://de.libreoffice.org/) for actually giving us the headless mode and the conversion options in the first place.

