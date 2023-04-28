import sys

import flask
from flask import Flask, render_template, redirect, request, session
# from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import text
from conf.config import Config
from models.model_User import User
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
    #user = None  # из-за этого говна может не загружаться страница АУФ
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
                    #user_uuid = str(row[7:-4])
                    user_uuid = str(row)
                    session['active_user_uuid'] = user_uuid
                    #print(user_uuid, file=sys.stderr)
                    userlogin = User().create(user_uuid)
                    #print(userlogin.get_id(), file=sys.stderr) #- важная строчка!!!!!!!!!!!!!!
                    login_user(userlogin)
                    #print(session['active_user_uuid'], file=sys.stderr)
                    #next = flask.request.args.get('next')
                    return redirect("/profile")
    return render_template('auth.html')
    #return render_template('auth.html', user=user)


@app.route("/logout", methods=['GET'])
@login_required
def logout():
    logout_user()
    session.clear()
    return redirect("/")


@app.route("/reg", methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        login = request.form['login']
        password = request.form['password']
        password2 = request.form['password2']

    return render_template('register.html')


@app.route("/profile")
@login_required
def profile():
    #user = current_user()
    #user = user.get_id()
    if 'active_user_uuid' in session:
        active_user_uuid = session['active_user_uuid']
        #print(active_user_uuid, file=sys.stderr)
    return render_template('profile.html')


#@login_manager.unauthorized_handler
#def unauthorized():
#    return 'tekst'


app = create_app(Config)
app.run(host='0.0.0.0', port=80, debug=True, threaded=True)
