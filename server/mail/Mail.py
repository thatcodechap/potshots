import base64
from email.mime.text import MIMEText


class TextMail:
    __body = None
    __mail = None

    def __init__(self, sender, recipient, subject, text):
        self.__mail = MIMEText(text)
        self.__mail['to'] = recipient
        self.__mail['from'] = sender
        self.__mail['subject'] = subject

    def getEncoded(self):
        return base64.urlsafe_b64encode(self.__mail.as_bytes()).decode()


class TextMailFactory:
    __sender = None

    def __init__(self, sender):
        self.__sender = sender

    def create(self, to, subject, text):
        return TextMail(self.__sender, to, subject, text)
