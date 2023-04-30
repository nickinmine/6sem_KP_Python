import hashlib
import sys
import uuid

import flask
from flask import Flask, render_template, redirect, request, session
# from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import text
from conf.config import Config
from models.User import User
from flask_login import LoginManager, login_required, login_user, logout_user, current_user
#from sqlalchemy.orm import session, sessionmaker


db = SQLAlchemy()
app = Flask(__name__)
login_manager = LoginManager(app)
#Session = sessionmaker()


def create_app(config):
    # CORS(app)
    app.config.from_object(config)
    db.init_app(app)
    login_manager.init_app(app)
    # register_extensions(app)
    return app


def get_sql_connect():
    con = db.engine.connect()
    return con


@login_manager.user_loader
def load_user(user_uuid):
    #print('load_user', file=sys.stderr)
    return User.get(user_uuid)


@app.route("/test")
@login_required
def test():
    # users = db.session.execute(db.select(User.user_uuid)).scalars()
    con = get_sql_connect()
    # users = con.execute(text('select version()'))
    # users = db.session.query(User).all() #- теперь работает
    # users = db.session.query(User).all()
    # users = User.query.all() - не работает
    users = con.execute(text('select name, login, role_name from public."user" join role r on r.role_id = '
                             '"user".role_id'))
    return render_template('test.html', users=users)


@app.route("/", methods=['GET'])
@app.route("/index", methods=['GET'])
def indexpage():
    return render_template('index.html')


@app.route("/auth", methods=['GET', 'POST'])
def auth():
    if request.method == 'POST':
        login = request.form['login']
        password = request.form['password']
        #print(login, password, file=sys.stderr)
        if login and password:
            con = get_sql_connect()
            stmt = text("select user_uuid from public.user where login=:login and password=md5(:password) limit 1")
            #stmt = text(r"select user_uuid from public.user where login='root' and password='63a9f0ea7bb98050796b649e85481845' limit 1")
            user = con.execute(stmt, {'login': login, 'password': password}).fetchone()
            if user:
                for row in user:
                    user_uuid = str(row)
                    session['active_user_uuid'] = user_uuid
                    userlogin = User().create(user_uuid)
                    login_user(userlogin)
                    return redirect("/profile")
    if 'active_user_uuid' in session:
        return redirect("/profile")
    return render_template('auth.html')


@app.route("/logout", methods=['GET'])
@login_required
def logout():
    logout_user()
    session.clear()
    return redirect("/")


@app.route("/reg", methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        name = request.form['name']
        login = request.form['login']
        password = request.form['password']
        password2 = request.form['password2']
        if name and login and password:
            if password2 == password:
                #con = get_sql_connect()
                #stmt = text("insert into public.user (role_id, login, password, name) values (2, :login, md5(:password), :name)")
                #con.execute(stmt, {'login': login, 'password': password, 'name': name})
                password = hashlib.md5(password.encode())
                user = User(user_uuid=uuid.uuid4(), role_id=2, login=login, password=password.hexdigest(), name=name)
                db.session.add(user)
                db.session.commit()
                return redirect("/auth")
    return render_template('register.html')


@app.route("/profile")
@login_required
def profile():
    if 'active_user_uuid' in session:
        active_user_uuid = session['active_user_uuid']
        #print(active_user_uuid, file=sys.stderr)
    return render_template('profile.html')


#@login_manager.unauthorized_handler
#def unauthorized():
#    return 'tekst'


app = create_app(Config)
app.run(host='0.0.0.0', port=80, debug=True, threaded=True)