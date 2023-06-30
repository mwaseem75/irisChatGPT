#FROM python:3.9-slim
FROM python:3.11.2-bullseye AS builder

# For non community version
# COPY key/iris.key /usr/irissys/mgr/iris.key

# create dev directory
WORKDIR /opt/irisappS

# Copy source files to image
#COPY . /opt/irisappS
COPY streamlit streamlit
#COPY  Installer.cls .
#COPY /streamlit/app /opt/irisappS/app
#COPY /streamlit/requirements.txt /opt/irisapp5/app/requirements.txt
# create Python env
ENV SRC_PATH=/opt/irisappS
# Requirement for embedded python
RUN pip3 install -r ${SRC_PATH}/streamlit/app/requirements.txt
# Install Native API
# For now Native API wheel is not embedded in container
#add streamlit
#EXPOSE 8501

CMD streamlit run /opt/irisappS/streamlit/app/streamlitAPP.py