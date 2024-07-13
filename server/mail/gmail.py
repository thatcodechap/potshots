import json
import exceptions
from urllib import request, parse
from mail.Mail import TextMailFactory

TOKEN_ENDPOINT = 'https://oauth2.googleapis.com/token'
API_ENDPOINT = 'https://gmail.googleapis.com/gmail/v1/users/me/messages/send'


class GmailHandler:
    __clientId = None
    __clientSecret = None
    __refreshToken = None
    __apiToken = None
    __emailId = None

    def __init__(self, clientId, clientSecret, refreshToken, apiToken, emailId):
        self.__clientId = clientId
        self.__clientSecret = clientSecret
        self.__refreshToken = refreshToken
        self.__apiToken = apiToken
        self.__emailId = emailId

    def __getAccessToken(self):
        try:
            headers = {
                'Content-Type': 'application/x-www-form-urlencoded'
            }
            payload = parse.urlencode({
                'client_id': self.__clientId,
                'client_secret': self.__clientSecret,
                'refresh_token': self.__refreshToken,
                'grant_type': 'refresh_token'
            }).encode()
            tokenRequest = request.Request(url=TOKEN_ENDPOINT, method='POST', data=payload,
                                           headers=headers)
            response = request.urlopen(tokenRequest).read().decode('utf-8')
            response = json.loads(response)
            return response['access_token']
        except Exception as e:
            raise exceptions.ServerError(400)

    def send(self, mail):
        try:
            url = API_ENDPOINT + '?key='+self.__apiToken
            accessToken = self.__getAccessToken()
            headers = {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer ' + accessToken
            }
            payload = json.dumps({"raw": mail.getEncoded()}).encode()
            sendRequest = request.Request(url=url, headers=headers, data=payload, method='POST')
            request.urlopen(sendRequest)
        except Exception as e:
            raise exceptions.ServerError(401)

    def getMailFactory(self):
        return TextMailFactory(self.__emailId)
