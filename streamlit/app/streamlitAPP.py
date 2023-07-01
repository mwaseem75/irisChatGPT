#streamlit application
import streamlit as st
import irisChatGPT
from pypdf import PdfReader
from langchain.text_splitter import CharacterTextSplitter
from langchain.embeddings import OpenAIEmbeddings
from langchain.vectorstores import FAISS
from langchain.chat_models import ChatOpenAI
from langchain.memory import ConversationBufferMemory
from langchain.chains import ConversationalRetrievalChain
from htmlTemplates import css, bot_template, user_template
import os


def get_pdf_text(pdf_docs):
    text = ""
    for pdf in pdf_docs:
        pdf_reader = PdfReader(pdf)
        for page in pdf_reader.pages:
            text += page.extract_text()
    return text


def get_text_chunks(text):
    text_splitter = CharacterTextSplitter(separator="\n",chunk_size=1000,chunk_overlap=200,length_function=len)
    chunks = text_splitter.split_text(text)
    return chunks


def get_vectorstore(text_chunks):
    embeddings = OpenAIEmbeddings()
    vectorstore = FAISS.from_texts(texts=text_chunks, embedding=embeddings)
    return vectorstore


def get_conversation_chain(vectorstore):
    llm = ChatOpenAI()
    memory = ConversationBufferMemory(memory_key='chat_history', return_messages=True)
    conversation_chain = ConversationalRetrievalChain.from_llm(
        llm=llm, retriever=vectorstore.as_retriever(), memory=memory )
    return conversation_chain


def handle_userinput(user_question):
    if st.session_state['rb'] == 'Intersystems Objectscript Reference':
        response = st.session_state.conversation_isdoc({'question': user_question})
        st.session_state.chat_history_isdoc = response['chat_history']

        qst = []; ans = []
        for i, message in reversed(list(enumerate(st.session_state.chat_history_isdoc))):
            if i % 2 == 0:
                qst.append(message.content)    
            else:
                ans.append(message.content)

        with st.expander("Conversation", expanded=True):        
            for i in range(len(qst)):
                st.write(user_template.replace(
                    "{{MSG}}",qst[i]), unsafe_allow_html=True)
                st.write(bot_template.replace(
                    "{{MSG}}", ans[i]), unsafe_allow_html=True)
    

    if st.session_state['rb'] == 'InterSystems Grand Prix Contest':
        response = st.session_state.conversation_iscontest({'question': user_question})
        st.session_state.chat_history_iscontest = response['chat_history']

        qst = []; ans = []
        for i, message in reversed(list(enumerate(st.session_state.chat_history_iscontest))):
            if i % 2 == 0:
                qst.append(message.content)    
            else:
                ans.append(message.content)

        with st.expander("Conversation", expanded=True):        
            for i in range(len(qst)):
                st.write(user_template.replace(
                    "{{MSG}}",qst[i]), unsafe_allow_html=True)
                st.write(bot_template.replace(
                    "{{MSG}}", ans[i]), unsafe_allow_html=True)


    #open AL
    if st.session_state['rb'] == 'OpenAI':
        #response = irisChatGPT.irisOpenAI(user_question,st.session_state["OPENAI_API_KEY"])
        response = irisChatGPT.irisdb(user_question,st.session_state["OPENAI_API_KEY"])
        qst = []; ans = []
        st.write(user_template.replace(
        "{{MSG}}",user_question), unsafe_allow_html=True)
        st.write(bot_template.replace(
        "{{MSG}}", response), unsafe_allow_html=True)

    #Intersystems documentation
    if st.session_state['rb'] == 'Personal ChatGPT':
        response = st.session_state.conversation({'question': user_question})
        st.session_state.chat_history = response['chat_history']

        qst = []; ans = []
        for i, message in reversed(list(enumerate(st.session_state.chat_history))):
            if i % 2 == 0:
                qst.append(message.content)    
            else:
                ans.append(message.content)
                            
        with st.expander("Conversation", expanded=True):        
            for i in range(len(qst)):
                st.write(user_template.replace(
                    "{{MSG}}",qst[i]), unsafe_allow_html=True)
                st.write(bot_template.replace(
                    "{{MSG}}", ans[i]), unsafe_allow_html=True)

                

def init_doc():
    #get data with the help of chromadb      
    # create conversation chain
    vectorstore = irisChatGPT.docLoader(st.session_state["OPENAI_API_KEY"])
    st.session_state.conversation_isdoc = get_conversation_chain(vectorstore)
    vectorstore = irisChatGPT.contestLoader(st.session_state["OPENAI_API_KEY"])
    st.session_state.conversation_iscontest = get_conversation_chain(vectorstore)
    st.session_state["INIT"] = 1
            
def main():
    st.session_state["OPENAI_API_KEY"] = '' 
    st.session_state["INIT"] = 0  
    st.set_page_config(page_title="iris ChatGPT", layout='wide', page_icon="🦜")
    st.write(css, unsafe_allow_html=True)    
    #initilize session state variables   
    if "conversation" not in st.session_state:
        st.session_state.conversation = None
    if "chat_history" not in st.session_state:
        st.session_state.chat_history = None


    st.sidebar.markdown(
        "## How to use\n"
        "1. Enter your [OpenAI API key](https://platform.openai.com/account/api-keys) below🔑\n"  # noqa: E501
        "2. Select option from below📄\n"
        "3. Ask a question about the document💬\n"
    )
    api_key_input = st.sidebar.text_input(
        "OpenAI API Key",
        type="password",
        placeholder="Paste your OpenAI API key here (sk-...)",
        help="You can get your API key from https://platform.openai.com/account/api-keys.",  # noqa: E501
        value=st.session_state.get("OPENAI_API_KEY", ""),
    )

    if api_key_input:
        st.session_state["OPENAI_API_KEY"] = api_key_input
        os.environ['OPENAI_API_KEY']  = api_key_input
        #if st.session_state["INIT"] != 1:
        init_doc()
      
    st.sidebar.markdown("---")

    rb = st.sidebar.radio(
    "## Select ChatGPT option",
    ('Intersystems Objectscript Reference', 'InterSystems Grand Prix Contest',
    'Personal ChatGPT','OpenAI'))
   
    #init selection variable
    st.session_state['rb'] = rb
    if rb == 'Intersystems Objectscript Reference':
        #st.header("🦜🔗Intersystems Objectscript Reference ChatGPT:")
        user_question = st.text_input("Ask a question about [Intersystems ObjectScript Reference](https://docs.intersystems.com/iris20231/csp/docbook/DocBook.UI.Page.cls?KEY=RCOS) :")
    elif rb == 'InterSystems Grand Prix Contest':
        #st.header("🦜🔗InterSystems Grand Prix Contest ChatGPT:")
        user_question = st.text_input("Ask a question about [InterSystems Grand Prix Contest 2023](https://community.intersystems.com/post/intersystems-grand-prix-contest-2023) :")
    elif rb == 'Personal ChatGPT':
        st.header("🦜🔗Personal ChatGPT :books:")
        user_question = st.text_input("Ask a question about Personal ChatGPT PDF:")
    else:
        st.header("🦜🔗OpenAI ChatGPT:")
        user_question = st.text_input("Ask any question:")
        
    #handle user input
    if user_question:
        if not st.session_state["OPENAI_API_KEY"].startswith('sk-'):
            st.warning('Please enter your OpenAI API key!', icon='⚠')
        else:
            handle_userinput(user_question)

    if rb == 'Personal ChatGPT':
        with st.sidebar:
            st.markdown("---")
            st.subheader("Your documents")
            pdf_docs = st.file_uploader(
                "Upload your PDFs here and click on 'Process'", accept_multiple_files=True)
            if st.button("Process"):
                with st.spinner("Processing"):
                    # get pdf text
                    raw_text = get_pdf_text(pdf_docs)

                    # get the text chunks
                    text_chunks = get_text_chunks(raw_text)

                    # create vector store
                    vectorstore = get_vectorstore(text_chunks)

                    # create conversation chain
                    st.session_state.conversation = get_conversation_chain(vectorstore)
    else:
        with st.sidebar:
            st.markdown("---")  

if __name__ == '__main__':
    main()