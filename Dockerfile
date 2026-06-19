ARG IMAGE=intersystemsdc/irishealth-community:latest
FROM $IMAGE as builder

WORKDIR /opt/irisbuild
RUN chown ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /opt/irisbuild
USER ${ISC_PACKAGE_MGRUSER}

COPY python python
COPY pdfdata pdfdata
COPY data/fhir fhirdata
COPY src src
COPY module.xml module.xml
COPY merge.cpf merge.cpf
COPY iris.script iris.script
COPY requirements.txt requirements.txt

RUN iris start IRIS && \
    iris merge IRIS merge.cpf && \    
    iris session IRIS < iris.script && \
    iris stop IRIS quietly || \
    (cat /usr/irissys/mgr/messages.log && exit 1)

# ---- final stage ----
FROM $IMAGE as final

ADD --chown=${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} \
    https://github.com/grongierisc/iris-docker-multi-stage-script/releases/latest/download/copy-data.py \
    /irisdev/app/copy-data.py





    RUN --mount=type=bind,source=/,target=/builder/root,from=builder \
    cp -f /builder/root/usr/irissys/iris.cpf /usr/irissys/iris.cpf && \
    python3 /irisdev/app/copy-data.py -c /usr/irissys/iris.cpf -d /builder/root/