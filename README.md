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
## Registered FHIR Servers
###### Connect to IRIS Terminal
```
docker-compose exec iris iris session iris
```
###### To list down registered server use ServerList() of dc.FhirClient class
```
do ##class(dc.FhirClient).ServerList()
```
![image](https://user-images.githubusercontent.com/18219467/170888825-7d655866-3a8b-4322-9b64-1ccf0b1ffbf4.png)

###### To Register New Server use RegisterServer() function of dc.FhirClient class
###### class(dc.FhirClient).RegsterServer("Server Name","Endpoint","ApiKey"[optional],"EndpointOAuth"[optional]
To Register New Server use RegisterServer class method
```
do ##class(dc.FhirClient).RegisterServer("INTERSYSTEMS FHIR Server","http://localhost:52773/csp/healthshare/samples/fhir/r4/"," "," ")
```
![image](https://user-images.githubusercontent.com/18219467/171025900-e973c396-52da-4e24-8083-c7f5f701919c.png)


###### To Activate server, call below method by passing server ID
```
do ##class(dc.FhirClient).SetFhirServer(2)
```
## Get Resources from the FHIR Servers
###### To Retrieve all the resouces for the current server use ListResources() method of dc.FhirClient class
```
do ##class(dc.FhirClient).ListResources()
```
![image](https://user-images.githubusercontent.com/18219467/170890855-891bf5eb-a724-4297-8bcb-821637a146f5.png)

###### In order to display number of recordes of any resources use CountResource() method by passing Resource of dc.FhirClient
###### Below command will get counter of Patient Resource against active FHIR Server
```
set count = ##class(dc.FhirClient).CountResource("Patient")
write count
```


###### To Retrieve all the created Resources along with their count just pass 1 to ListResource() function
```
do ##class(dc.FhirClient).ListResources(1)
```
![image](https://user-images.githubusercontent.com/18219467/170890718-1dacba2c-4d2d-4830-8606-be0542230afb.png)


## Get Resources information by providing resource from active server 
###### To get details of the resource use GetResource() by passing Resource of dc.FhirClient class
###### Currently list of following resources is available
* Patient
* Observation
* Procedure
* Immunization
* Encounter
* Organization
* Condition
* Practitioner

###### Below command will retrieve all the Patients from the active FHIR Server
```
do ##class(dc.FhirClient).GetResource("Patient")
```
![image](https://user-images.githubusercontent.com/18219467/170890728-7fb7d8a3-4c33-4084-8f54-6ca772b60a41.png)
###### Below command will retrieve all the Observations from the active FHIR Server
```
do ##class(dc.FhirClient).GetResource("Observation")
```
![image](https://user-images.githubusercontent.com/18219467/170890999-9548988e-40e7-49c1-ad7f-f95d45f62b50.png)

## Get Resources for particular patient from the FHIR Servers
###### Currently list of following resources against the patient is available
* Observation
* Procedure
* Immunization
* Encounter
* Organization
* Condition
* Practitioner
###### Below command will retrieve Observations detail against Patinet ID 1 from the active FHIR Server
```
do ##class(dc.FhirClient).GetPatientResources("Observation","1")
```
![image](https://user-images.githubusercontent.com/18219467/170956427-4b46797d-45ce-49af-996d-465a2239d73c.png)

###### Below command will retrieve detail of Encounters against Patinet ID 1 from the active FHIR Server
```
do ##class(dc.FhirClient).GetPatientResources("Encounter","1")
```
![image](https://user-images.githubusercontent.com/18219467/170956695-ec3a396a-580c-41dc-b9f1-d5465a4a3653.png)

## Search in Patient Resource
Patient Resource search parameter detaisl can be found [**here**](https://www.hl7.org/fhir/patient.html#search)
Below command will search agaisnt Patient Id 2395
```
do ##class(dc.FhirClient).GetResource("Patient","_id","2395")
```
![image](https://user-images.githubusercontent.com/18219467/171736498-64e21522-c270-44a4-9135-edb99062c8b6.png)

Below command will search Patient given Name and family Name contaning "Don"
```
do ##class(dc.FhirClient).GetResource("Patient","name","Don")
```
![image](https://user-images.githubusercontent.com/18219467/171736755-365dfcc5-8043-4a9f-9cb3-6d5e4fd1c04b.png)

Below command will search all the male patients
```
do ##class(dc.FhirClient).GetResource("Patient","gender","male")
```
![image](https://user-images.githubusercontent.com/18219467/171736915-63a21dd0-d448-426a-bf0f-4022e8c2d115.png)




## Create Patient Resource
###### below CreatePatient() function of dc.FhirClient can be use to Create Patient Resource
```
ClassMethod CreatePatient(givenName As %String, familyName As %String, birthDate As %String,gender As %String)
```
###### function requires giveName,failyName,birthDate and gender to create Patient Resource
###### below command will create Patient
```
do ##class(dc.FhirClient).CreatePatient("PatientGN","PatientFN","2000-06-01","male")
```
![image](https://user-images.githubusercontent.com/18219467/171737063-423401ef-0d59-4ce9-ac1d-af9f5c75c9b7.png)

Let's search the newly created resource by it's name
```
do ##class(dc.FhirClient).CreatePatient("PatientGN","PatientFN","2000-06-01","male)
```
![image](https://user-images.githubusercontent.com/18219467/171737199-eeef2391-24df-4b1f-a22a-9f75f6cd32fa.png)

Patient ID 8111 is created


## Create Patient Observation Resource
###### Let us create Observation against our newly created Patient Resource
###### below CreateObservatoin() function of dc.FhirClient can be use to Create Patient Observatoins
```
ClassMethod CreateObservation(patientId As %String, loincCode As %String, ObrCategory As %String, ObrValue As %Integer, ObrUOM As %String, effectiveDate As %String)
```
###### Parametres 
* patientId is the Id of Patient
* LioncCode is Lionc Code, Detail can be found [**here**](https://loinc.org/fhir/)
* ObrCategory is Observation Category, Detail can be found [**here**](https://www.hl7.org/fhir/valueset-observation-category.html)
* ObrValue is Observatoin Value
* ObrUOM is Observation Unit
* EffectiveDate

###### below command will create Patient Vital Sign Observation
```
do ##class(dc.FhirClient).CreateObservation("8111","8310-5","vital-signs",96.8,"degF","2022-01-22")
```
![image](https://user-images.githubusercontent.com/18219467/171738074-2a0dda54-6215-46b0-a3aa-6a2fcb27bb85.png)


Let's List down patient observations
```
do ##class(dc.FhirClient).GetPatientResources("Observation","8111")
```
![image](https://user-images.githubusercontent.com/18219467/172003634-3f8c9ef6-76c2-4af0-97ac-e4431750e2e1.png)


Observation ID 8114 is created




## View FHIR Server information from CSP Web application
Navigate to [http://localhost:55037/csp/fhirclient/index.csp](http://localhost:55037/csp/fhirclient/index.csp)
###### Index Page will show active server Patients,Observations,Practitioners and Encounters count along with Patient and Registered Servers details
![170881284-b18aebca-e6a2-4a6e-ad20-a537c13ff51c](https://user-images.githubusercontent.com/18219467/170974585-621ce757-7382-4b0e-8505-40b141ada4c3.png)

###### Index page will display FHIR Server List with active server selected. Select other server from the list to view details of selected server
![image](https://user-images.githubusercontent.com/18219467/170976217-70b63f48-981a-4b76-9f9a-282f5f86ff59.png)

###### Hover to Patient ID and select to get details of Patient Resources
![image](https://user-images.githubusercontent.com/18219467/170976661-290c9f44-e11b-4fec-9cdb-bccb069de4ed.png)

###### This page will display count of some of Patient Resources along with Patient Observations details
![170881340-a9cd0c77-bf24-4e8e-85f7-84e04b527b49](https://user-images.githubusercontent.com/18219467/170976982-66eeb068-248f-474f-ad8c-e39c8cd2faea.png)


## Other information
Template used in web application is from [Bootstrap 4 Admin Dashboard](https://github.com/themekita/Atlantis-Lite) and it is free to use to develop non-commercial applications.


## Thanks
