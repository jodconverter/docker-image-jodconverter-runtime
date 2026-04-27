build:
	docker build --target jre -t tsteidle/jodconverter-runtime:jre .
	docker build --target jdk -t tsteidle/jodconverter-runtime:jdk .
