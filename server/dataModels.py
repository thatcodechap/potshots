from pydantic import BaseModel


class NewPot(BaseModel):
    goal: str
    target: int
    targetDate: str


class NewUser(BaseModel):
    email: str
    name: str
    password: str



class Otp(BaseModel):
    email: str
    value: str


class User(BaseModel):
    email: str
    password: str


class PotId(BaseModel):
    id: int


class NewTransaction(BaseModel):
    amount: int
    pots: list
