import time
import jwt


class JWTFactory:
    __expiryTimeoutInSeconds = None
    __secret = None

    def __init__(self, expiryTimeoutInSeconds, secret):
        self.__expiryTimeoutInSeconds = expiryTimeoutInSeconds
        self.__secret = secret

    def generateToken(self, payload):
        payload['exp'] = int(time.time()) + self.__expiryTimeoutInSeconds
        return jwt.encode(payload, self.__secret, algorithm='HS256')

    def decodeToken(self, token):
        return jwt.decode(token, self.__secret, algorithms=['HS256'])

