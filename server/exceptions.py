class ServerError(Exception):
    __code = -420

    def __init__(self, code):
        self.__code = code

    def getCode(self):
        return self.__code


class UserError(Exception):
    __code = -421

    def __init__(self, code):
        self.__code = code

    def getCode(self):
        return self.__code


errorCodes = {
    101: "Failed to connect to database",
    102: "Database disconnected",
    103: "Failed to commit into database",
    104: "Database execution failed",
    300: "Session Expired",
    301: "Invalid User",
    302: "User already exists",
    303: "Wrong OTP",
    304: "Wrong username or password",
    305: "Forbidden operation",
    306: "Unauthenticated",
    400: "Mail service error",
    401: "Unable to send mail",
    500: "Not enough balance",
    501: "Pot is locked"
}
