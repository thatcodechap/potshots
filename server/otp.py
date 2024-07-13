import random
import time
from threading import Thread


class OtpSession:
    __id = None
    __value = None
    __creationTime = None

    def __init__(self, id, value, userData):
        self.__id = id
        self.__value = value
        self.__creationTime = time.time()
        self.__purgerRunning = False
        self.__userData = userData

    def getCreationTime(self):
        return self.__creationTime

    def getValue(self):
        return self.__value

    def getUserData(self):
        return self.__userData


class OtpSessionFactory:
    __size = None
    __timeoutInSeconds = None
    __otps = None
    __purgerRunning = False

    def __init__(self, size=4, timeoutInSeconds=300):
        self.__size = size
        self.__timeoutInSeconds = timeoutInSeconds
        self.__otps = {}

    def create(self, id, userData):
        if self.exists(id):
            return self.__otps[id].getValue()
        otpValue = ''
        for i in range(self.__size):
            otpValue += str(random.randint(0, 9))
        otp = OtpSession(id, otpValue, userData)
        self.__otps[id] = otp
        return otpValue

    def exists(self, id):
        if id in self.__otps:
            return True
        return False

    def get(self, id):
        return self.__otps[id]

    def expired(self, id):
        if self.exists(id) and time.time() - self.__otps[id].getCreationTime() > self.__timeoutInSeconds:
            return True
        return False

    def startPurger(self):
        if self.__purgerRunning:
            return

        def loop():
            while True:
                for id in self.__otps.keys():
                    if self.expired(id):
                        del self.__otps[id]
                time.sleep(5)

        Thread(target=loop).start()
        self.__purgerRunning = True
