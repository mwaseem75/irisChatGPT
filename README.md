**irisChatGPT** application leverages the functionality of one of the hottest python framework [LangChain](https://python.langchain.com/docs/get_started/introduction.html) built around Large Language Models (LLMs).
LangChain is a framework that enables quick and easy development of applications that make use of Large Language Models.
Application is built by using objectscript with the help of  [intersystems Embedded Python](https://docs.intersystems.com/irisforhealthlatest/csp/docbook/DocBook.UI.Page.cls?KEY=AFL_epython) functionality. It also contains [Streamlit](https://streamlit.io/) web application which is an open-source Python app framework to create beautiful web apps for data science and machine learning.

![image](https://github.com/mwaseem75/irisChatGPT/assets/18219467/e84ecde9-24a6-475e-b598-6a7f3abe1410)


## Streamlit Web Application Layout
![image](https://github.com/mwaseem75/irisChatGPT/assets/18219467/acfb914e-560f-4554-babb-1a65b1531a57)

## Features
* Built-in [Intersystems ObjectScript Reference](https://docs.intersystems.com/iris20231/csp/docbook/DocBook.UI.Page.cls?KEY=RCOS) ChatGPT
* Built-in [InterSystems Grand Prix Contest 2023](https://community.intersystems.com/post/intersystems-grand-prix-contest-2023) ChatGPT
* Answer questions over a Cache database by using SQLDatabaseChain
* Create your own chatGPT model by using PDF, work and text documents
* OpenAI ChatGPT
* Wikipedia Search
* Search on the internet by using DuckDuckGo (DDG) general search engine
* Generate Python code by using Python REPL LangChain functionality
* Streamlit Web application
  * Intersystems objectscript reference ChatGPT
  * Intersystems grand prix contest ChatGPT
  * Select and upload your own document for ChatGPT 
  * OpenAI ChatGPT

## How to Run

To start coding with this repo, you do the following:

1. Clone/git pull the repo into any local directory

```shell
git clone https://github.com/mwaseem75/irisChatGPT.git
```

2. Open the terminal in this directory and run:

```shell
docker-compose build
```

3. Run the IRIS container with your project:

```shell
docker-compose up -d
```

## Installation with ZPM
```
zpm "install irisChatGPT.ZPM"
```
## Getting Started 
#### Get OpenAI Key
Application requires OpenAI API Key, sign up for OpenAI API on [this page](https://platform.openai.com/account/api-keys). Once you signed up and logged in, click on Personal, and select View API keys in drop-down menu. Create and copy the API Key

![image](https://github.com/mwaseem75/irisChatGPT/assets/18219467/7e7c7880-b9ac-4a60-9ec9-289dd2375a73)


#### Connect to IRIS Terminal by using below command
```
docker-compose exec iris iris session iris
```
#### Create a new instance of dc.irisChatGPT class and use SetApiKey method to set OpenAI API Key 
![image](https://github.com/mwaseem75/irisChatGPT/assets/18219467/dd4303ca-6ff4-48a0-92c1-70a2ad18cdec)

#### Chat with [Intersystems objectscript reference](https://docs.intersystems.com/iris20231/csp/docbook/DocBook.UI.Page.cls?KEY=RCOS)

#### Chat with [InterSystems Grand Prix Contest 2023](https://community.intersystems.com/post/intersystems-grand-prix-contest-2023)
#### Answer questions over a Cache database by using SQLDatabaseChain
#### Create your own chatGPT model by using PDF, work and text documents
#### OpenAI ChatGPT
#### Wikipedia Search
#### Search on the internet by using DuckDuckGo (DDG) general search engine
#### Generate Python code by using Python REPL LangChain functionality

## Streamlit Web application
Navigate to [Streamlit Web Application](http://localhost:8501) or [CSP Web application](http://localhost:55037/csp/irisChatGPT/index.csp)
  #### Intersystems objectscript reference ChatGPT
  #### Intersystems grand prix contest ChatGPT
  #### Select and upload your own document for ChatGPT 
  #### OpenAI ChatGPT

## Thanks
