import json
import sys
from random import random, randint

from flask_sqlalchemy import SQLAlchemy
from flask_sqlalchemy.model import Model
from sqlalchemy import Column, String, Integer
from sqlalchemy.ext.declarative import DeclarativeMeta

db = SQLAlchemy()


class User(db.Model):
    __tablename__ = 'user'
    user_uuid = Column(String(), nullable=False, primary_key=True)
    role_id = Column(Integer(), nullable=False)
    login = Column(String(), unique=True, nullable=False)
    #password = Column(String(), nullable=False)
    name = Column(String(), nullable=False)
    #avatar = Column(String())

    def __repr__(self):
        return f"{self.user_uuid}, {self.role_id}, {self.login}, {self.name}"

    def create(self, user_uuid):
        self.user_uuid = user_uuid
        #print(user_uuid, file=sys.stderr)
        return self

    def is_authenticated(self):
        return True

    def is_active(self):
        return True

    def is_anonymous(self):
        return False

    def get_id(self):
        return str(self.user_uuid)

    def get(self):
        return User()
