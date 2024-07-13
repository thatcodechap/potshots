import mysql.connector
import exceptions
import queryTemplates
from db.Database import Database
from db.Table import Table
from utils import sqlFormat


def checkConnection(func):
    def wrapper(*args, **kwargs):
        if args[0].isConnected():
            return func(*args, **kwargs)
        else:
            raise exceptions.ServerError(102)

    return wrapper


class MySqlTable(Table):
    __database = None
    __tableName = None
    __schema = None

    def __init__(self, database, tableName):
        self.__database = database
        self.__tableName = tableName

    def insert(self, values):
        formattedValues = []
        for column in self.__schema:
            formattedValue = sqlFormat(values[column])
            formattedValues.append(formattedValue)
        tableName = self.__tableName + '({})'.format(','.join(self.__schema))
        query = queryTemplates.INSERT_INTO.format(tableName=tableName, values=','.join(formattedValues))
        self.__database.execute(query)

    def get(self, conditions, columns=['*']):
        conditionsInString = []
        for column in conditions.keys():
            condition = ''
            if type(conditions[column]) == list:
                valuesInString = []
                for value in conditions[column]:
                    valuesInString.append(sqlFormat(value))
                condition = column + ' IN ({})'.format(','.join(valuesInString))
            else:
                condition = column + '=' + sqlFormat(conditions[column])
            conditionsInString.append(condition)
        query = queryTemplates.SIMPLE_SELECT.format(tableName=self.__tableName, conditions=','.join(conditionsInString),
                                                    columns=','.join(columns))
        return self.__database.execute(query)

    def update(self, values, conditions):
        conditionsInString = []
        valuesInString = []
        for column in conditions.keys():
            condition = column + '=' + sqlFormat(conditions[column])
            conditionsInString.append(condition)
        for column in values.keys():
            value = column + '=' + sqlFormat(values[column])
            valuesInString.append(value)
        query = queryTemplates.UPDATE.format(tableName=self.__tableName, conditions=','.join(conditionsInString),
                                             values=','.join(valuesInString))
        return self.__database.execute(query)

    def attachSchema(self, schema):
        self.__schema = schema


class MySqlDB(Database):
    __user = None
    __password = None
    __host = None
    __port = None
    __database = None
    __connection = None
    __cursor = None

    def __init__(self, database, host='127.0.0.1', port=3306, user='root', password=''):
        self.__host = host
        self.__port = port
        self.__user = user
        self.__password = password
        self.__database = database

    def isConnected(self):
        return self.__connection.is_connected()

    @checkConnection
    def __commit(self):
        try:
            self.__connection.commit()
        except Exception as e:
            raise exceptions.ServerError(103)

    def init(self):
        try:
            self.__connection = mysql.connector.connect(user=self.__user,
                                                        password=self.__password,
                                                        host=self.__host, port=self.__port,
                                                        database=self.__database)
            self.__cursor = self.__connection.cursor()
        except mysql.connector.Error as e:
            raise exceptions.ServerError(101)

    @checkConnection
    def execute(self, query):
        try:
            self.__cursor.execute(query)
            result = self.__cursor.fetchall()
            self.__connection.commit()
            return result
        except Exception as e:
            raise exceptions.ServerError(104)

    def getTable(self, tableName):
        return MySqlTable(self, tableName)
