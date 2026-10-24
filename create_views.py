#!/usr/bin/env python3
"""Create the joined market views defined in create_views.sql."""

import pathlib

import oracledb

DB_USER = "PMKT"
DB_PASSWORD = "1Chaise-chien-soucoupe"
DB_DSN = (
    "(DESCRIPTION=(ADDRESS=(PROTOCOL=TCPS)"
    "(HOST=adb.eu-frankfurt-1.oraclecloud.com)(PORT=1522))"
    "(CONNECT_DATA=(SERVER=DEDICATED)"
    "(SERVICE_NAME=gf75342b9701342_nrkx9a0bppxkie5b_tp.adb.oraclecloud.com)))"
)


def load_statements():
    sql = pathlib.Path(__file__).with_name("create_views.sql").read_text()
    statements = []
    for chunk in sql.split(";"):
        lines = [
            line for line in chunk.splitlines() if not line.strip().startswith("--")
        ]
        statement = "\n".join(lines).strip()
        if statement:
            statements.append(statement)
    return statements


def main():
    conn = oracledb.connect(user=DB_USER, password=DB_PASSWORD, dsn=DB_DSN)
    try:
        cur = conn.cursor()
        statements = load_statements()
        for statement in statements:
            cur.execute(statement)
        conn.commit()
        print(f"Created/refreshed {len(statements)} views.")
    finally:
        conn.close()


if __name__ == "__main__":
    main()
