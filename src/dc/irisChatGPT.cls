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

}
