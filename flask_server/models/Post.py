from conf.config import db


class Post(db.Model):
    __tablename__ = 'post'

    def __repr__(self):
        return f"{self.author_uuid}, {self.open_date}, {self.topic}, {self.paragraph}"
