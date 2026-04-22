from dotenv import load_dotenv
import os

load_dotenv()

ORACLE_USER = os.getenv("ORACLE_USER", "movieuser")
ORACLE_PASSWORD = os.getenv("ORACLE_PASSWORD", "moviepass")
ORACLE_DSN = os.getenv("ORACLE_DSN", "db:1521/FREEPDB1")
ORACLE_PWD = os.getenv("ORACLE_PWD", "PASSPASS")
MODEL_NAME = os.getenv("MODEL_NAME", "all-MiniLM-L6-v2")

FLASK_HOST = os.getenv("FLASK_HOST", "0.0.0.0")
FLASK_PORT = int(os.getenv("FLASK_PORT", "5005"))
FLASK_DEBUG = os.getenv("FLASK_DEBUG", "True").lower() == "true"