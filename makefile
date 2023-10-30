build:
	docker build --target jre -t ghcr.io/jodconverter/jodconverter-runtime:jre .
	docker build --target jdk -t ghcr.io/jodconverter/jodconverter-runtime:jdk .

