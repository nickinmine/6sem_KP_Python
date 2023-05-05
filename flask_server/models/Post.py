from conf.config import db


class Post(db.Model):
    __tablename__ = 'post'
    post_id = db.Column(db.Integer, primary_key=True)
    author_uuid = db.Column(db.String(), db.ForeignKey('user.user_uuid'), nullable=False)
    theme_id = db.Column(db.Integer, db.ForeignKey('thread.theme_id'), nullable=False)
    paragraph = db.Column(db.String(), nullable=False)
    post_date = db.Column(db.DateTime, nullable=True)

    def __repr__(self):
        return f"{self.post_id}, {self.author_uuid}, {self.paragraph}"
