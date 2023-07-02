ARG IMAGE=intersystemsdc/iris-community
#ARG IMAGE=intersystemsdc/iris-community:preview
#ARG IMAGE=intersystemsdc/iris-community:latest
FROM $IMAGE

USER root   
        
WORKDIR /opt/irisbuild
RUN chown ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /opt/irisbuild
USER ${ISC_PACKAGE_MGRUSER}

COPY  python python
COPY  pdfdata pdfdata
COPY  src src
COPY module.xml module.xml
COPY iris.script iris.script
COPY requirements.txt requirements.txt

RUN iris start IRIS \
	&& iris session IRIS < iris.script \
    && iris stop IRIS quietly
	
RUN pip3 install -r requirements.txt
# unstructured tiktoken clickhouse-connect==0.5.22 sqlalchemy-iris
