FROM python:3.10
RUN pip install --upgrade pip
RUN pip install Flask
RUN pip install Flask-SQLAlchemy
RUN pip install Flask-Login
RUN pip install psycopg2
RUN pip install waitress
WORKDIR /usr/src/app
COPY . /usr/src/app
CMD ["python", "app.py"]