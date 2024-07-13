from fastapi import FastAPI, Request, Header, Depends
from starlette.responses import JSONResponse

import queryTemplates
from db import Mysql
from datetime import datetime, timezone
from utils import distribute, sqlFormat, tuplesToList
import hashlib
import jwt
import auth
import exceptions
import mail.gmail
import otp
import secrets
import dataModels

DATABASE_NAME = 'potshots'
USER_TABLENAME = 'users'
USER_SCHEMA = ['email', 'name', 'digest']
POTS_TABLENAME = 'pots'
POTS_SCHEMA = ['goal', 'target', 'targetDate', 'creationDate', 'owner']
SHARED_TABLENAME = 'shared'
SHARED_SCHEMA = ['pot', 'user']
TRANSACTIONS_TABLENAME = 'transactions'
TRANSACTIONS_SCHEMA = ['type', 'amount', 'paymentDate', 'pot']

app = FastAPI()
DATABASE = Mysql.MySqlDB(DATABASE_NAME, '127.0.0.1', 3306, secrets.DATABASE_USERNAME, secrets.DATABASE_PASSWORD)
DATABASE.init()
USERS = DATABASE.getTable(USER_TABLENAME)
POTS = DATABASE.getTable(POTS_TABLENAME)
SHARED = DATABASE.getTable(SHARED_TABLENAME)
TRANSACTIONS = DATABASE.getTable(TRANSACTIONS_TABLENAME)
myMail = mail.gmail.GmailHandler(secrets.GMAIL_CLIENT_ID, secrets.GMAIL_CLIENT_SECRET, secrets.GMAIL_REFRESH_TOKEN,
                                 secrets.GMAIL_API_KEY, secrets.GMAIL_ID)
mailFactory = myMail.getMailFactory()
otpFactory = otp.OtpSessionFactory()
jwtFactory = auth.JWTFactory(1296000, secrets.JWT_SECRET)

USERS.attachSchema(USER_SCHEMA)
POTS.attachSchema(POTS_SCHEMA)
SHARED.attachSchema(SHARED_SCHEMA)
TRANSACTIONS.attachSchema(TRANSACTIONS_SCHEMA)


async def authenticate(authorization: str = Header(None)):
    if authorization is None:
        raise exceptions.UserError(306)
    try:
        token = authorization.split(' ')[1]
        payload = jwtFactory.decodeToken(token)
        return payload['email']
    except jwt.ExpiredSignatureError:
        raise exceptions.UserError(300)
    except jwt.InvalidTokenError:
        raise exceptions.UserError(301)


async def authorize(authorization: str = Header(None)):
    user = await authenticate(authorization)
    potsOwned = POTS.get({'owner': user}, ['id'])
    potsOwned = map(lambda pot: pot[0], potsOwned)
    return list(potsOwned)


@app.middleware('http')
async def exceptionHandler(request: Request, call_next):
    try:
        return await call_next(request)
    except exceptions.ServerError as e:
        return JSONResponse(content={'error': e.getCode()}, status_code=500)
    except exceptions.UserError as e:
        return JSONResponse(content={'error': e.getCode()}, status_code=400)
    except Exception:
        return JSONResponse(content={'error': -1}, status_code=500)


@app.get("/")
async def root():
    return {"message": "Hello World"}


@app.post("/signup")
async def createUser(newUser: dataModels.NewUser):
    if USERS.get({'email': newUser.email}):
        raise exceptions.UserError(302)
    generatedOtp = otpFactory.create(newUser.email, newUser)
    welcomeMail = mailFactory.create(newUser.email, "Welcome to potshots!", generatedOtp)
    myMail.send(welcomeMail)
    return {"success": "OK"}


@app.post("/verify")
def verifyUser(otp: dataModels.Otp):
    otpSession = otpFactory.get(otp.email)
    if otpSession.getValue() != otp.value:
        return {"error": 303}
    userData = otpSession.getUserData()
    USERS.insert({'email': otp.email, 'name': userData.name,
                  'digest': hashlib.sha256(str(userData.password).encode()).hexdigest()})
    jwtToken = jwtFactory.generateToken({"email": otp.email})
    return {"token": jwtToken}


@app.post("/login")
def sendJWT(requestedUser: dataModels.User):
    if not USERS.get({'email': requestedUser.email}):
        raise exceptions.UserError(304)
    userDigest = USERS.get({'email': requestedUser.email}, ['digest'])[0][0]
    digest = hashlib.sha256(requestedUser.password.encode()).hexdigest()
    if digest == userDigest:
        jwtToken = jwtFactory.generateToken({"email": requestedUser.email})
        return {"token": jwtToken}
    else:
        raise exceptions.UserError(304)


@app.post("/pot")
def createPot(newPot: dataModels.NewPot, user: str = Depends(authenticate)):
    todaysDate = datetime.now(timezone.utc).strftime("%Y-%m-%d")
    newPot = newPot.dict()
    newPot['owner'] = user
    newPot['creationDate'] = todaysDate
    POTS.insert(newPot)
    return {"success": "OK"}


@app.get("/pot")
def getPots(user: str = Depends(authenticate)):
    sharedPots = SHARED.get({'user': user}, ['pot'])
    sharedPotList = ['-1']
    for i in sharedPots:
        sharedPotList.append(sqlFormat(i[0]))
    getAllPotsQuery = queryTemplates.GET_ALL_POTS.format(tableName=POTS_TABLENAME, owner=user,
                                                         idList=','.join(sharedPotList))
    potsData = DATABASE.execute(getAllPotsQuery)
    return {"pots": tuplesToList(potsData,
                                 ['id', 'goal', 'target', 'balance', 'targetDate', 'creationDate', 'owner', 'locked'])}


@app.post("/pot/lock")
def lockPot(pot: dataModels.PotId, permitted: list = Depends(authorize)):
    if pot.id in permitted:
        POTS.update({'locked': '0b1'}, {'id': pot.id})
        return {"success": "OK"}
    else:
        raise exceptions.UserError(305)


@app.post("/pot/unlock")
def unlockPot(pot: dataModels.PotId, permitted: list = Depends(authorize)):
    if pot.id in permitted:
        POTS.update({'locked': '0b0'}, {'id': pot.id})
        return {"success": "OK"}
    else:
        raise exceptions.UserError(305)


@app.post("/transaction/add")
def addAmount(newTransaction: dataModels.NewTransaction, user: str = Depends(authenticate)):
    todaysDate = datetime.now(timezone.utc)
    if len(newTransaction.pots) == 1:
        TRANSACTIONS.insert({
            'type': 'add',
            'amount': newTransaction.amount,
            'paymentDate': todaysDate.strftime('%Y-%m-%d %H:%M:%S'),
            'pot': newTransaction.pots[0]
        })
        return {"success": "OK"}
    pots = newTransaction.pots
    if not pots:
        ownedPots = POTS.get({'owner': user}, ['id'])
        sharedPots = SHARED.get({'user': user}, ['pot'])
        for i in ownedPots:
            pots.append(i[0])
        for i in sharedPots:
            pots.append(i[0])
    potData = POTS.get({'id': pots}, ['id', 'target', 'balance', 'targetDate'])
    potDataMatrix = {}
    for i in potData:
        targetDifference = i[1] - i[2]
        potDataMatrix[i[0]] = [targetDifference]
    distribution = distribute(newTransaction.amount, potDataMatrix, [1])
    for i in distribution.keys():
        TRANSACTIONS.insert({
            'type': 'add',
            'amount': distribution[i],
            'paymentDate': todaysDate.strftime('%Y-%m-%d %H:%M:%S'),
            'pot': i
        })
    return {"success": "OK"}


@app.post("/transaction/withdraw")
def withdraw(newTransaction: dataModels.NewTransaction, permitted: list = Depends(authorize)):
    if newTransaction.pots[0] not in permitted:
        raise exceptions.UserError(305)
    pot = POTS.get({'id': newTransaction.pots[0]}, ['balance', 'locked'])[0]
    if pot[1] == 1:
        raise exceptions.UserError(501)
    if newTransaction.amount > pot[0]:
        raise exceptions.UserError(500)
    TRANSACTIONS.insert({
        'type': 'withdraw',
        'amount': newTransaction.amount,
        'paymentDate': datetime.now(timezone.utc).strftime('%Y-%m-%d %H:%M:%S'),
        'pot': newTransaction.pots[0]
    })
    return {"success": "OK"}
