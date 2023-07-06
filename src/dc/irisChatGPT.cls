Class dc.irisChatGPT Extends %RegisteredObject
{

// Set API key by using global variable

ClassMethod SetAPIKey(Key As %String) As %Integer
{
	Set ^ChatGPTKey(1) = Key
	Quit $$$OK
}

// Set API key by using global variable

ClassMethod SetFHIRUrl(URL As %String) As %Integer
{
	Set ^ChatGPTFHIRUrl(1) = URL
	Quit $$$OK
}

// ChatGPT with OPENAI

ClassMethod openAI(query) [ Language = python ]
{
	from langchain.chat_models import ChatOpenAI
	from langchain.chains.conversation.memory import ConversationEntityMemory
	from langchain.chains import ConversationChain
	from langchain.chains.conversation.prompt import ENTITY_MEMORY_CONVERSATION_TEMPLATE
	import os,iris

	MODEL = "gpt-3.5-turbo-0613"
	K = 10
	#Get Api key
	apiKeyRef = iris.gref("^ChatGPTKey")
	try:
		apiKey = apiKeyRef.get([1])
	except:
		return "Please define ApiKey by calling SetApiKey(key) method"

	os.environ['OPENAI_API_KEY'] = apiKey

	#llm
	try:
		llm = ChatOpenAI(temperature=0,openai_api_key=apiKey, model_name=MODEL, verbose=False) 
		#Conversational memory is how a chatbot can respond to multiple queries
		entity_memory = ConversationEntityMemory(llm=llm, k=K )
		qa = ConversationChain(llm=llm,   prompt=ENTITY_MEMORY_CONVERSATION_TEMPLATE, memory=entity_memory)
		ret = '\n'+qa.run(query)+'\n'
	except Exception as e:  
		print(e)

	return ret
}

// Answer questions over a Cache database by using SQLDatabaseChain

ClassMethod irisDB(query) [ Language = python ]
{
	from langchain.llms import OpenAI
	from langchain import  SQLDatabase, SQLDatabaseChain
	from langchain.prompts.prompt import PromptTemplate
	import os,iris
	
	#Get Api key
	apiKeyRef = iris.gref("^ChatGPTKey")
	try:
		apiKey = apiKeyRef.get([1])
	except:
		return "Please define ApiKey by calling SetApiKey(key) method"

	os.environ['OPENAI_API_KEY'] = apiKey
	
	_DEFAULT_TEMPLATE = """Given an input question, first create a syntactically correct {dialect} query to run, then look at the results of the query and return the answer.

	Use the following format:

	Question: "Question here"
	SQLQuery: "SQL Query to run"
	SQLResult: "Result of the SQLQuery"
	Answer: "Final answer here"

	The SQL query should NOT end with semi-colon
	Question: {input}"""

	PROMPT = PromptTemplate(
	    input_variables=["input", "dialect"], template=_DEFAULT_TEMPLATE
	)
	#Cache connection parameters, Modify accoringly 
	db = SQLDatabase.from_uri("iris://superuser:SYS@localhost:1972/USER") 

	llm = OpenAI(temperature=0, verbose=True)

	db_chain = SQLDatabaseChain(llm=llm, database=db, prompt=PROMPT, verbose=True) 

	return db_chain.run(query)
}

// Create your own chatGPT document by saving vector data locally

ClassMethod ingest(filePath) [ Language = python ]
{
	from langchain.vectorstores import Chroma
	from langchain.embeddings import OpenAIEmbeddings
	from langchain.text_splitter import RecursiveCharacterTextSplitter
	from langchain.document_loaders import PyPDFLoader,UnstructuredWordDocumentLoader,TextLoader
	
	import os,iris
	#Get Api key
	apiKeyRef = iris.gref("^ChatGPTKey")
	try:
		apiKey = apiKeyRef.get([1])
	except:
		return "Please define ApiKey by calling SetApiKey(key) method"
	
	os.environ['OPENAI_API_KEY'] = apiKey
	embedding = OpenAIEmbeddings()
	#add mgr directory path to the file
	filePath = iris.cls("%SYSTEM.Util").ManagerDirectory()+'pdfdata/'+filePath
	filename, file_extension = os.path.splitext(filePath)
	if file_extension == '.pdf':
	    loader = PyPDFLoader(filePath)       
	elif file_extension == '.docx' or file_extension=='.doc':
	    loader = UnstructuredWordDocumentLoader(filePath)
	elif file_extension == '.txt':
	    loader = TextLoader(filePath)    
	else:
	    return "Please provide PDF,DOC or TXT file to ingest"
	
	try:
		documents = loader.load()
		#In order to split the document we need to import RecursiveCharacterTextSplitter from Langchain framework  
		text_splitter = RecursiveCharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
		texts = text_splitter.split_documents(documents)
		# Embed and store the texts
		# Supplying a persist_directory will store the embeddings on disk
		persist_directory = iris.cls("%SYSTEM.Util").ManagerDirectory()+'python/vectordb/personal'
		vectordb = Chroma.from_documents(documents=texts, embedding=embedding, persist_directory=persist_directory)
		#save document locally
		vectordb.persist()
		vectordb = None
	except Exception as e:
		print(e)

	return "File uploaded successfully"
}

// Intersystem Objectscript Reference chatGPT

ClassMethod irisDocs(query) [ Language = python ]
{
	from langchain.vectorstores import Chroma
	from langchain.embeddings import OpenAIEmbeddings
	from langchain.llms import OpenAI
	from langchain.memory import ConversationBufferMemory
	from langchain.chains import ConversationalRetrievalChain
	import iris

	import os,iris
	#Get Api key
	apiKeyRef = iris.gref("^ChatGPTKey")
	try:
		apiKey = apiKeyRef.get([1])
	except:
		return "Please define ApiKey by calling SetApiKey(key) method"

	os.environ['OPENAI_API_KEY'] = apiKey
	embedding = OpenAIEmbeddings()
	persist_directory = iris.cls("%SYSTEM.Util").ManagerDirectory()+'python/vectordb/vectors'
	## Now we can load the persisted database from disk, and use it as normal. 
	try:
		vectordb = Chroma(persist_directory=persist_directory, embedding_function=embedding)
		memory = ConversationBufferMemory(memory_key="chat_history", return_messages=True)
		#The ConversationalRetrievalChain is a conversational AI model that is designed to retrieve relevant responses based on user queries
		qa = ConversationalRetrievalChain.from_llm(OpenAI(temperature=0), vectordb.as_retriever(), memory=memory)
		ret = '\n'+qa.run(query)+'\n'
	except Exception as e:
		print(e)
	return ret
}

// InterSystems Grand Prix Contest 2023 chatGPT

ClassMethod irisContest(query) [ Language = python ]
{
	from langchain.vectorstores import Chroma
	from langchain.embeddings import OpenAIEmbeddings
	from langchain.llms import OpenAI
	from langchain.memory import ConversationBufferMemory
	from langchain.chains import ConversationalRetrievalChain

	import os,iris
	#Get Api key
	apiKeyRef = iris.gref("^ChatGPTKey")
	try:
		apiKey = apiKeyRef.get([1])
	except:
		return "Please define ApiKey by calling SetApiKey(key) method"

	os.environ['OPENAI_API_KEY'] = apiKey
	embedding = OpenAIEmbeddings()
	persist_directory = iris.cls("%SYSTEM.Util").ManagerDirectory()+'python/vectordb/contest'
	
	## Now we can load the persisted database from disk, and use it as normal. 
	try:
		vectordb = Chroma(persist_directory=persist_directory, embedding_function=embedding)
		memory = ConversationBufferMemory(memory_key="chat_history", return_messages=True)
		qa = ConversationalRetrievalChain.from_llm(OpenAI(temperature=0), vectordb.as_retriever(), memory=memory)
		ret = '\n'+qa.run(query)+'\n'
	except Exception as e:
		print(e)
	return ret
}

// answer question about Personal chatGPT

ClassMethod personalGPT(query) [ Language = python ]
{
	from langchain.vectorstores import Chroma
	from langchain.embeddings import OpenAIEmbeddings
	from langchain.llms import OpenAI
	from langchain.memory import ConversationBufferMemory
	from langchain.chains import ConversationalRetrievalChain

	import os,iris
	#Get Api key
	apiKeyRef = iris.gref("^ChatGPTKey")
	try:
		apiKey = apiKeyRef.get([1])
	except:
		return "Please define ApiKey by calling SetApiKey(key) method"

	os.environ['OPENAI_API_KEY'] = apiKey
	embedding = OpenAIEmbeddings()
	persist_directory = iris.cls("%SYSTEM.Util").ManagerDirectory()+'python/vectordb/personal'
	
	## Now we can load the persisted database from disk, and use it as normal. 
	try:
		vectordb = Chroma(persist_directory=persist_directory, embedding_function=embedding)
		memory = ConversationBufferMemory(memory_key="chat_history", return_messages=True)
		#The ConversationalRetrievalChain is a conversational AI model that is designed to retrieve relevant responses based on user queries
		qa = ConversationalRetrievalChain.from_llm(OpenAI(temperature=0), vectordb.as_retriever(), memory=memory)
		ret = '\n'+qa.run(query)+'\n'
	except Exception as e:
		print(e)
	return ret
}

// wikiPedia search

ClassMethod wikiPedia(query) [ Language = python ]
{
	from langchain.utilities import WikipediaAPIWrapper
	import os,iris
	
	#Get Api key
	apiKeyRef = iris.gref("^ChatGPTKey")
	try:
		apiKey = apiKeyRef.get([1])
	except:
		return "Please define ApiKey by calling SetApiKey(key) method"

	os.environ['OPENAI_API_KEY'] = apiKey
		
	try:
		wikipedia = WikipediaAPIWrapper()
		ret = '\n'+wikipedia.run(query)+'\n'
	except Exception as e:
		print(e)
		
	return ret
}

// search on internet by using DuckDuckGo (DDG) general search engine

ClassMethod duckDuckGo(query) [ Language = python ]
{
	from langchain.tools import DuckDuckGoSearchRun
	import os,iris
	
	#Get Api key
	apiKeyRef = iris.gref("^ChatGPTKey")
	try:
		apiKey = apiKeyRef.get([1])
	except:
		return "Please define ApiKey by calling SetApiKey(key) method"

	os.environ['OPENAI_API_KEY'] = apiKey
		
	try:
		search = DuckDuckGoSearchRun()
		ret = '\n'+search.run(query)+'\n'
	except Exception as e:
		print(e)
		
	return ret
}

// REPL stands for Read Evaluate Print Loop,  Python REPL LangChain used to generate python code

ClassMethod pythonREPL(query) [ Language = python ]
{
	from langchain.agents.agent_toolkits import create_python_agent
	from langchain.tools.python.tool import PythonREPLTool
	from langchain.llms.openai import OpenAI
	import os,iris
	
	#Get Api key
	apiKeyRef = iris.gref("^ChatGPTKey")
	try:
		apiKey = apiKeyRef.get([1])
	except:
		return "Please define ApiKey by calling SetApiKey(key) method"

	os.environ['OPENAI_API_KEY'] = apiKey
	llm = OpenAI(temperature=0, max_tokens=1000)
		
	try:
		agent_exec = create_python_agent(
    	llm=llm,
    	tool=PythonREPLTool(),
    	verbose=True,
		)
		ret = agent_exec.run(query)
	except Exception as e:
		print(e)
		
	return ret
}

// CHATGpt with FHIR, Patients and Observations

ClassMethod irisFHIR(query) [ Language = python ]
{
	from fhirpy import SyncFHIRClient
	from langchain.agents import create_pandas_dataframe_agent
	from langchain.llms.openai import OpenAI
	from fhirpy import SyncFHIRClient
	import os,iris
	import pandas as pd

	contentType = "application/fhir+json"

	#Get FHIR Server End point
	FHIRurl = iris.gref("^ChatGPTFHIRUrl")
	try:
	    url = FHIRurl.get([1])
	except:
	    return "Please define FHIR End point by calling SetFHIRUrl(url) method"
	    
	#Add / at the end of endpoint if not added
	if url[-1]!="/":
	    url=url+"/"
	    	
	#Get all patients
	client = SyncFHIRClient(url = url, extra_headers={"Content-Type":contentType,"x-api-key":""})

	#Get Api key
	apiKeyRef = iris.gref("^ChatGPTKey")
	try:
	    apiKey = apiKeyRef.get([1])
	except:
	    return "Please define ApiKey by calling SetApiKey(key) method"

	os.environ['OPENAI_API_KEY'] = apiKey
	#Get Patient data and convert to panda dataframe
	data = ""
	try:
	    data = client.resources("Patient").fetch()           
	except Exception as e:
	    print(e)
	
	header = ["Patient ID","Patient Family Name","Patient Given Name","Patient DOB","Patient Gender"]
	rows = []
	for rowval in data:
	        row = [rowval.get('id'),rowval.get_by_path('name.0.family'),rowval.get_by_path('name.0.given.0'),rowval.get_by_path('birthDate'),rowval.get_by_path('gender')]
	        rows.append(row)    
	patients = pd.DataFrame(rows,columns=header)

	#Get Observation data and convert to panda dataframe
	data = ""
	try:
	    data = client.resources("Observation").fetch()           
	except Exception as e:
	    print(e)

	header = ["Observation ID","Observation Category","Observation Code","Observation Value","Observation UOM","Observation Date","Patient ID"]        
	rows = []
	for rowval in data:
	        row = [rowval.get('id'),rowval.get_by_path('category.0.coding.0.code'),rowval.get_by_path('code.coding.0.code'),
	            rowval.get_by_path('valueQuantity.value'),rowval.get_by_path('valueQuantity.code'),rowval.get_by_path('effectiveDateTime'),rowval.get_by_path('subject.reference')]
	        rows.append(row)    
	observations = pd.DataFrame(rows,columns=header)
	#Get Procedures
	data = ""
	try:
	    data = client.resources("Procedure").fetch()           
	except Exception as e:
	    print(e)

	header = ["Procedure ID","Procedure Code","Procedure Details","Procedure StartDate","Procedure EndDate","Procedure Status","Patient ID"]  
	rows = []
	for rowval in data:
	        row =  [rowval.get('id'),
                rowval.get_by_path('code.coding.0.code'),
                rowval.get_by_path('code.coding.0.display'),
                rowval.get_by_path('performedPeriod.start'),
                rowval.get_by_path('performedPeriod.end'),
                rowval.get_by_path('status'),
                rowval.get_by_path('subject.reference')           
                ]
	        rows.append(row)    
	procedures = pd.DataFrame(rows,columns=header)
	#Get Immunization
	data = ""
	try:
	    data = client.resources("Immunization").fetch()           
	except Exception as e:
	    print(e)

	header = ["Immunization ID","VaccineCode","Immunization Details","Immunization Date","Encounter","Immunization Status","Patient ID"]
	rows = []
	for rowval in data:
	        row =  [rowval.get('id'),
                rowval.get_by_path('vaccineCode.coding.0.code'),
                rowval.get_by_path('vaccineCode.coding.0.display'),
                rowval.get('occurrenceDateTime'),
                rowval.get_by_path('encounter.reference'),
                rowval.get_by_path('status'),
                rowval.get_by_path('patient.reference')     
                ]
	        rows.append(row)    
	Immunizations = pd.DataFrame(rows,columns=header)
	#Getting Encounter Details
	data = ""
	try:
	    data = client.resources("Encounter").fetch()           
	except Exception as e:
	    print(e)

	header = ["Encounter ID","Encounter Class","Encounter StartDate","Encounter EndDate","Encounter Provider","Encounter Status","Patient ID"]   
	rows = []
	for rowval in data:
	        row =  [rowval.get('id'),
                rowval.get_by_path('class.code'),
                rowval.get_by_path('period.start'),
                rowval.get_by_path('period.end'),
                rowval.get_by_path('serviceProvider.reference'),
                rowval.get_by_path('status'),
                rowval.get_by_path('subject.reference')] 
	        rows.append(row)    
	Encounters = pd.DataFrame(rows,columns=header)
	#Getting Encounter Details
	data = ""
	try:
	    data = client.resources("Condition").fetch()           
	except Exception as e:
	    print(e)

	header = ["ID","Code","Details","ClinicalStatus","VerificationStatus","Patient ID"]    
	rows = []
	for rowval in data:
	        row =  [rowval.get('id'),
                rowval.get_by_path('code.coding.0.code'),
                rowval.get_by_path('code.coding.0.display'),
                rowval.get_by_path('clinicalStatus.coding.0.code'),           
                rowval.get_by_path('verificationStatus.coding.0.code'),    
                rowval.get_by_path('subject.reference')] 
	        rows.append(row)    
	Conditions = pd.DataFrame(rows,columns=header)
	#Getting Practitioner Details
	data = ""
	try:
	    data = client.resources("Practitioner").fetch()           
	except Exception as e:
	    print(e)

	header = ["Practitioner ID","Practitioner Name","Practitioner Gender","Practitioner Contact"]       
	rows = []
	for rowval in data:
	        row =   [rowval.get('id'),
                rowval.get_by_path('name.0.prefix.0')+' '+rowval.get_by_path('name.0.family')+' '+rowval.get_by_path('name.0.given.0'),
                rowval.get('gender'),rowval.get_by_path('telecom.0.value')]
	        rows.append(row)    
	Practitioners = pd.DataFrame(rows,columns=header)
	########################################################################        
	try:
		agent = create_pandas_dataframe_agent(OpenAI(temperature=0), [patients, observations,procedures,Immunizations,Encounters,Conditions,Practitioners], verbose=True)
	except Exception as e:
	    print(e)
	return '\n'+agent.run(query)+'\n'
}

}
