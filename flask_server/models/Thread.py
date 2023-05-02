from conf.config import db


class Thread(db.Model):
    __tablename__ = 'thread'
    theme_id = db.Column(db.Integer, primary_key=True)
    author_uuid = db.Column(db.String(), nullable=False)
    topic = db.Column(db.Integer(), nullable=False)
    paragraph = db.Column(db.String(), nullable=True)
    is_closed = db.Column(db.String(), nullable=False)
    open_date = db.Column(db.DateTime, nullable=True)
    close_date = db.Column(db.DateTime, nullable=True)

    def __repr__(self):
        return f"{self.theme_id}, {self.author_uuid}, {self.open_date}, {self.topic}, {self.paragraph}"
