from pathlib import Path
import db_gen
import os


def start_module():
    DB_NAME = "eightone_params.db"

    db_gen.abs_dir = os.path.dirname(os.path.abspath(__file__))
    db_gen.db_dir = Path('dbs')
    db_gen.db_file = Path(db_gen.abs_dir / db_gen.db_dir / DB_NAME)
    db_gen.osname = DB_NAME.split("_")[0]

    while True:
        db_gen.filename = str(input("Enter the name for batch file: "))
        if os.path.exists(db_gen.filename + ".bat"):
            print("File exists. Enter another name...")
        else:
            db_gen.gen_decision()
            break
