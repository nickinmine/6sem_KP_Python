import hashlib
import modulefinder
import sys
import uuid

import flask
from flask import Flask, render_template, redirect, request, session
# from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import text
from conf.config import Config, db
from models.User import User
from models.Thread import Thread
from models.Role import Role
from models.Post import Post
from flask_login import LoginManager, login_required, login_user, logout_user, current_user
#from sqlalchemy.orm import session, sessionmaker


#db = SQLAlchemy()
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
    user = User.query.filter_by(user_uuid=user_uuid).first()
    #return User.get(user_uuid)
    return user


@app.route("/test")
@login_required
def test():
    # users = db.session.execute(db.select(User.user_uuid)).scalars()
    con = get_sql_connect()
    # users = con.execute(text('select version()'))
    # users = db.session.query(User).all() #- теперь работает
    # users = db.session.query(User).all()
    users = User.query.all() #- не работает
    #users = con.execute(text('select name, login, role_name from public."user" join role r on r.role_id = '
    #                         '"user".role_id'))
    return render_template('test.html', users=users)


@app.route("/", methods=['GET'])
@app.route("/index", methods=['GET'])
def indexpage():
    return render_template('index.html')


@app.route("/auth", methods=['GET', 'POST'])
def auth():
    # старая авторизация, возможно будет удалена
    #if request.method == 'POST':
    #    login = request.form['login']
    #    password = request.form['password']
    #    #print(login, password, file=sys.stderr)
    #    if login and password:
    #        con = get_sql_connect()
    #        stmt = text("select user_uuid from public.user where login=:login and password=md5(:password) limit 1")
    #        user = con.execute(stmt, {'login': login, 'password': password}).fetchone()
    #        if user:
    #            for row in user:
    #                user_uuid = str(row)
    #                session['active_user_uuid'] = user_uuid
    #                userlogin = User().create(user_uuid)
    #                login_user(userlogin)
    #                return redirect("/profile")
    if request.method == 'POST':
        login = request.form['login']
        password = hashlib.md5(request.form['password'].encode())
        if login and password:
            user = User.query.filter_by(login=login, password=password.hexdigest()).first()
            if user:
                session['active_user_uuid'] = user.user_uuid
                login_user(user)
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


@app.route("/user/<login>", methods=['GET'])
def user_page(login=None):
    user = User.query.filter_by(login=login).first()
    user_role = Role.query.filter_by(role_id=user.role_id).first()
    user.role_name = user_role.role_name
    user.thread_count = Thread.query.filter_by(author_uuid=user.user_uuid).count()
    user.post_count = Post.query.filter_by(author_uuid=user.user_uuid).count()
    return render_template('user_page.html', user=user)


@app.route("/profile", methods=['GET'])
@login_required
def profile():
    if 'active_user_uuid' in session:
        user_uuid = session['active_user_uuid']
        user = User.query.filter_by(user_uuid=user_uuid).first()
        user_role = Role.query.filter_by(role_id=user.role_id).first()
        user.role_name = user_role.role_name
        #con = get_sql_connect()
        #stmt = text('select name, login, role_name from public."user" join role r on r.role_id = '
        #            '"user".role_id where user_uuid=:user_uuid')
        #user = con.execute(stmt, {'user_uuid': user_uuid}).fetchone()
        return render_template('profile.html', user=user)
    return render_template('profile.html')


@app.route("/profile/name", methods=['POST'])
@login_required
def change_name():
    if request.method == 'POST':
        name = request.form['name']
        if 'active_user_uuid' in session:
            user_uuid = session['active_user_uuid']
            user = User.query.filter_by(user_uuid=user_uuid).first()
            if user:
                user.name = name
                db.session.commit()
    return redirect('/profile')


@app.route("/profile/password", methods=['POST'])
@login_required
def change_password():
    if request.method == 'POST':
        oldpassword = hashlib.md5(request.form['oldpassword'].encode())
        newpassword = hashlib.md5(request.form['newpassword'].encode())
        newpassword2 = hashlib.md5(request.form['newpassword2'].encode())
        if newpassword.hexdigest() == newpassword2.hexdigest():
            if 'active_user_uuid' in session:
                user_uuid = session['active_user_uuid']
                user = User.query.filter_by(user_uuid=user_uuid).first()
                if user.password == oldpassword.hexdigest():
                    user.password = newpassword.hexdigest()
                    db.session.commit()
    return redirect('/profile')


@app.route("/profile/avatar", methods=['POST'])
@login_required
def change_avatar():
    if request.method == 'POST':
        avatar_url = request.form['avatar']
        if 'active_user_uuid' in session:
            user_uuid = session['active_user_uuid']
            user = User.query.filter_by(user_uuid=user_uuid).first()
            if user:
                user.avatar = avatar_url
                db.session.commit()
    return redirect('/profile')


@app.route("/thread", methods=['GET'])
def thread_list():
    threads = Thread.query.order_by(Thread.open_date).all()
    if threads:
        for t in threads:
            #user = User.query.get(t.author_uuid)
            user = User.query.filter_by(user_uuid=t.author_uuid).first()
            if user:
                t.author_name = user.name
                t.author_login = user.login
            t.open_date = str(t.open_date)[0:-10]
            if t.close_date:
                t.close_date = str(t.close_date)[0:-10]
    return render_template('threads.html', threads=threads)


@app.route("/thread/<int:thread_id>", methods=['GET', 'PUT', 'DELETE'])
def thread_id(thread_id=0):
    return render_template('')


@app.route("/thread/add", methods=['GET', 'POST'])
@login_required
def thread_add():
    if request.method == 'POST':
        topic = request.form['topic']
        paragraph = request.form['paragraph']
        thread = Thread(author_uuid=session['active_user_uuid'], topic=topic, paragraph=paragraph, is_closed=False)
        db.session.add(thread)
        db.session.commit()
        return redirect('/thread/' + str(thread.theme_id))
    return render_template('thread_add.html')


#@login_manager.unauthorized_handler
#def unauthorized():
#    return 'tekst', 401


#@app.errorhandler(404)
#def page_not_found(error):
#    return render_template('page_not_found.html'), 404


app = create_app(Config)
app.run(host='0.0.0.0', port=80, debug=True, threaded=True)
