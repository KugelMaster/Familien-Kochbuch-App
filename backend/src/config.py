from pathlib import Path

# Database
DB_USERNAME = "cookbook"
DB_PASSWORD = "mysecretpassword"
DB_DOMAIN = "127.0.0.1"
DB_PORT = "5432"
DB_NAME = "cookbook"

DATABASE_URL = (
    f"postgresql://{DB_USERNAME}:{DB_PASSWORD}@{DB_DOMAIN}:{DB_PORT}/{DB_NAME}"
)

# Images
RECIPE_IMAGE_DIR = Path("/var/family-cookbook-api/images/recipes")

# Authentication
SECRET_KEY = "05f4532846f802e60af143475b2143ac41d64b22bc225820b5e3e310bb363901"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60
