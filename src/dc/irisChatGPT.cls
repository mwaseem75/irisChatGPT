Class dc.irisChatGPT Extends %RegisteredObject
{

// Create records in FHIRServer and initate Global Variable to hold current server ID 

ClassMethod SetApiKey(Key As %String) As %Integer
{
	Set ^ChatGPTKey(1) = Key
	Quit $$$OK
}

// Count Resource, Pass "ALL" in case of counting all the resources

ClassMethod IrisOpenAI(query As %String) As %String
{
	
    
	  try {
  		  //Importing python file 
          Set irisChatGPT = ##class(%SYS.Python).Import("irisChatGPT")
          
		} 
	  Catch err {
			return "Error While importing irisChatGPT file" 	
			  	
				}  
	  //invoking Method from python file
	  Set ans = irisChatGPT.irisOpneAI(query,$DATA(^$GLOBAL("^ActiveFhirServer")))
	  return ans
}

ClassMethod OpenAI(query) [ Language = python ]
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
	except Exception as e:  
		return e

	return qa.run(query)
}

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
	except Exception as e:
		return e
	return qa.run(query)
}

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
	except Exception as e:
		return e
	return qa.run(query)
}

ClassMethod test() [ Language = python ]
{
	import iris
	W = iris.cls("%SYSTEM.Util").ManagerDirectory()+'python/vectordb/contest'
	print(W)
}

}
