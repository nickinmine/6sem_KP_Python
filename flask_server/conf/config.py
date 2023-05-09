from flask_sqlalchemy import SQLAlchemy
db = SQLAlchemy()


class Config(object):
    SECRET_KEY = '14b10598580fa862670c5ce365839c3b14b10598580fa862670c5ce365839c3b'
    #SQLALCHEMY_DATABASE_URI = 'postgresql+psycopg2://postgres:root@postgres/python_coursework'
    SQLALCHEMY_DATABASE_URI = 'postgres://python_coursework_user:Zb6yd2D03kOvvy3S9IE3HeC50eqsPXiq@dpg-chd6dn2k728tp9f2audg-a/python_coursework'
    SQLALCHEMY_TRACK_MODIFICATIONS = False
