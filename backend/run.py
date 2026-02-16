import os
import sys

import uvicorn

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "src")))


if __name__ == "__main__":
    uvicorn.run("src.main:app", host="0.0.0.0", port=8000, reload=True)
