import os
from dotenv import load_dotenv
from flask import Flask
from pymongo import MongoClient

load_dotenv

mongo_address = os.getenv("MONGO_ADDRESS")
client = MongoClient(mongo_address)
db = client.tccSaves

app = Flask(__name__)


import tcc-api.main