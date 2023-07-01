Class dc.irisChatGPT Extends %RegisteredObject
{

// Set API key by using global variable

ClassMethod SetApiKey(Key As %String) As %Integer
{
	Set ^ChatGPTKey(1) = Key
	Quit $$$OK
}

// usage of OpenAI by using chatGPT model gpt-3-turbo-0613

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
		entity_memory = ConversationEntityMemory(llm=llm, k=K )
		qa = ConversationChain(llm=llm,   prompt=ENTITY_MEMORY_CONVERSATION_TEMPLATE, memory=entity_memory)
		ret = '\n'+qa.run(query)+'\n'
	except Exception as e:  
		return e

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

	db = SQLDatabase.from_uri("iris://superuser:SYS@localhost:1972/USER") 

	llm = OpenAI(temperature=0, verbose=True)

	db_chain = SQLDatabaseChain(llm=llm, database=db, prompt=PROMPT, verbose=True) 

	return db_chain.run(query)
}

// Create your own chatGPT document by saving vector data locally, 

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
		fileType = "PDF"
	elif file_extension == '.docx' or file_extension=='.doc':
		fileType = "DOC"
	elif file_extension == '.txt':
		fileType = "TXT"
	else:
		fileType = "UNKOWN"

	if fileType == "UNKOWN":
		return "Please provide PDF,DOC or TXT file to ingest"
	elif fileType == "PDF":
		loader = PyPDFLoader(filePath)       
	elif fileType == "DOC":
		## Load and process the text
		loader = UnstructuredWordDocumentLoader(filePath)
	elif fileType == "TXT":
		loader = TextLoader(filePath)    
	
	try:
		documents = loader.load()
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
		return e

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
		qa = ConversationalRetrievalChain.from_llm(OpenAI(temperature=0), vectordb.as_retriever(), memory=memory)
		ret = '\n'+qa.run(query)+'\n'
	except Exception as e:
		return e
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
		return e
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
		qa = ConversationalRetrievalChain.from_llm(OpenAI(temperature=0), vectordb.as_retriever(), memory=memory)
		ret = '\n'+qa.run(query)+'\n'
	except Exception as e:
		return e
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
		return e
		
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
		return e
		
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
		return e
		
	return ret
}

}
