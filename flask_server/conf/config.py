from flask_sqlalchemy import SQLAlchemy
db = SQLAlchemy()


class Config(object):
    DEBUG = True
    TESTING = True
    SECRET_KEY = '14b10598580fa862670c5ce365839c3b14b10598580fa862670c5ce365839c3b'
    SQLALCHEMY_DATABASE_URI = 'postgresql+psycopg2://postgres:root@postgres/python_coursework'
    SQLALCHEMY_TRACK_MODIFICATIONS = False
