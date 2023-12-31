css = '''
<style>
.chat-message {
    padding: 1rem; border-radius: 0.5rem; margin-bottom: 1rem; display: flex
}
.chat-message.user {
    background-color: #f0f2f6
}
.chat-message.bot {
    background-color: #d7d7e3
}
.chat-message .avatar {
  width: 25px;
}
.chat-message .avatar img {
  max-width: 39px;
  max-height: 39px;
  border-radius: 50%;
  object-fit: cover;
}
.chat-message .message {
  width: 95%;
  padding: 0 1.5rem;
}
'''

bot_template = '''
<div class="chat-message bot">
    <div class="avatar">
        <img src="https://i.ibb.co/cN0nmSj/Screenshot-2023-05-28-at-02-37-21.png" style="max-height: 39px; max-width: 39px; border-radius: 50%; object-fit: cover;">
    </div>
    <div class="message">{{MSG}}</div>
</div>
'''

user_template = '''
<div class="chat-message user">
    <div class="avatar">
        <img src="https://icons.iconarchive.com/icons/gartoon-team/gartoon-misc/256/Dialog-Question-Mark-icon.png">
    </div>    
    <div class="message">{{MSG}}</div>
</div>
'''