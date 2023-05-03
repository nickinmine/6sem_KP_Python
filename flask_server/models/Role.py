from conf.config import db


class Role(db.Model):
    __tablename__ = 'role'
    role_id = db.Column(db.Integer, primary_key=True)
    role_name = db.Column(db.Integer(), nullable=False)

    def __repr__(self):
        return f"{self.role_name}"
