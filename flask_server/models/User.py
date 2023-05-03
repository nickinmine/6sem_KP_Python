from conf.config import db


class User(db.Model):
    __tablename__ = 'user'
    user_uuid = db.Column(db.String(), nullable=False, primary_key=True)
    role_id = db.Column(db.Integer(), db.ForeignKey('role.role_id'), nullable=False)
    login = db.Column(db.String(), unique=True, nullable=False)
    password = db.Column(db.String(), nullable=False)
    name = db.Column(db.String(), nullable=False)
    avatar = db.Column(db.String(), nullable=True)

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
