# Must be first — before any other imports
__import__('pysqlite3')
import sys
sys.modules['sqlite3'] = sys.modules.pop('pysqlite3')

import os

from langchain_openai import OpenAIEmbeddings, OpenAI, ChatOpenAI
from langchain_community.vectorstores import Chroma
from langchain.text_splitter import RecursiveCharacterTextSplitter

from langchain_community.document_loaders import (
    PyPDFLoader,
    UnstructuredWordDocumentLoader,
    TextLoader,
)

from langchain.memory import (
    ConversationEntityMemory,
    ConversationBufferMemory,
)

from langchain.chains.conversation.prompt import (
    ENTITY_MEMORY_CONVERSATION_TEMPLATE,
)

from langchain.chains import (
    ConversationChain,
    ConversationalRetrievalChain,
)

from langchain_community.utilities import SQLDatabase
from langchain_experimental.sql import SQLDatabaseChain

from langchain.prompts import PromptTemplate

MODEL = "gpt-3.5-turbo"
K = 10


def irisdb(query, apiKey):
    os.environ["OPENAI_API_KEY"] = apiKey

    _DEFAULT_TEMPLATE = """
Given an input question, first create a syntactically correct {dialect} query to run, then look at the results of the query and return the answer.

Use the following format:

Question: "Question here"
SQLQuery: "SQL Query to run"
SQLResult: "Result of the SQLQuery"
Answer: "Final answer here"

The SQL query should NOT end with semi-colon
Question: {input}
"""

    PROMPT = PromptTemplate(
        input_variables=["input", "dialect"],
        template=_DEFAULT_TEMPLATE,
    )

    db = SQLDatabase.from_uri(
        "iris://superuser:SYS@localhost:1972/USER"
    )

    llm = OpenAI(
        temperature=0,
        verbose=True,
    )

    db_chain = SQLDatabaseChain.from_llm(
        llm=llm,
        db=db,
        prompt=PROMPT,
        verbose=True,
    )

    return db_chain.invoke(query)["result"]


def ingest(path, apiKey, persist_directory="personal"):
    os.environ["OPENAI_API_KEY"] = apiKey

    embedding = OpenAIEmbeddings()

    fileType = getFileType(path)

    if fileType == "UNKNOWN":
        return "Please provide PDF, DOC or TXT file to ingest"

    elif fileType == "PDF":
        loader = PyPDFLoader(path)

    elif fileType == "DOC":
        loader = UnstructuredWordDocumentLoader(path)

    elif fileType == "TXT":
        loader = TextLoader(path)

    try:
        documents = loader.load()

        text_splitter = RecursiveCharacterTextSplitter(
            chunk_size=1000,
            chunk_overlap=0,
        )

        texts = text_splitter.split_documents(documents)

        Chroma.from_documents(
            documents=texts,
            embedding=embedding,
            persist_directory=persist_directory,
        )

        return "File uploaded successfully"

    except Exception as e:
        return str(e)


def docLoader(apiKey):
    os.environ["OPENAI_API_KEY"] = apiKey

    embedding = OpenAIEmbeddings()

    return Chroma(
        persist_directory="vectors",
        embedding_function=embedding,
    )


def contestLoader(apiKey):
    os.environ["OPENAI_API_KEY"] = apiKey

    embedding = OpenAIEmbeddings()

    return Chroma(
        persist_directory="contest",
        embedding_function=embedding,
    )


def irisdocs(query, apiKey):
    os.environ["OPENAI_API_KEY"] = apiKey

    embedding = OpenAIEmbeddings()

    try:
        vectordb = Chroma(
            persist_directory="vectors",
            embedding_function=embedding,
        )

        memory = ConversationBufferMemory(
            memory_key="chat_history",
            return_messages=True,
        )

        qa = ConversationalRetrievalChain.from_llm(
            OpenAI(temperature=0),
            vectordb.as_retriever(),
            memory=memory,
        )

        return qa.invoke({"question": query})["answer"]

    except Exception as e:
        return str(e)


def iriscontest(query, apiKey):
    os.environ["OPENAI_API_KEY"] = apiKey

    embedding = OpenAIEmbeddings()

    try:
        vectordb = Chroma(
            persist_directory="contest",
            embedding_function=embedding,
        )

        memory = ConversationBufferMemory(
            memory_key="chat_history",
            return_messages=True,
        )

        qa = ConversationalRetrievalChain.from_llm(
            OpenAI(temperature=0),
            vectordb.as_retriever(),
            memory=memory,
        )

        return qa.invoke({"question": query})["answer"]

    except Exception as e:
        return str(e)


def irislocal(query, apiKey, persist_directory="personal"):
    os.environ["OPENAI_API_KEY"] = apiKey

    embedding = OpenAIEmbeddings()

    try:
        vectordb = Chroma(
            persist_directory=persist_directory,
            embedding_function=embedding,
        )

        memory = ConversationBufferMemory(
            memory_key="chat_history",
            return_messages=True,
        )

        qa = ConversationalRetrievalChain.from_llm(
            OpenAI(temperature=0),
            vectordb.as_retriever(),
            memory=memory,
        )

        return qa.invoke({"question": query})["answer"]

    except Exception as e:
        return str(e)


def irisOpenAI(query, apiKey):
    os.environ["OPENAI_API_KEY"] = apiKey

    try:
        llm = ChatOpenAI(
            temperature=0,
            model_name=MODEL,
            openai_api_key=apiKey,
            verbose=False,
        )

        entity_memory = ConversationEntityMemory(
            llm=llm,
            k=K,
        )

        qa = ConversationChain(
            llm=llm,
            prompt=ENTITY_MEMORY_CONVERSATION_TEMPLATE,
            memory=entity_memory,
        )

        return qa.invoke(query)["response"]

    except Exception as e:
        return str(e)


def getFileType(filePath):
    _, file_extension = os.path.splitext(filePath)

    if file_extension == ".pdf":
        return "PDF"

    elif file_extension in (".docx", ".doc"):
        return "DOC"

    elif file_extension == ".txt":
        return "TXT"

    return "UNKNOWN"


def initdata():
    pass


print("Test")