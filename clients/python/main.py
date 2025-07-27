import os
from pathlib import Path
from sqlalchemy import create_engine

def main():
    engine = create_engine("hsqldb+jaydebeapi://SA:@hsqldb/default", echo=True)

    try:
        conn = engine.connect()
        version = engine.dialect._get_server_version_info(conn)
        assert isinstance(version,str) and len(version) > 0, 'Version string is missing.'
        print(f'\nSuccessfully connected!\nHSQLDB version: {version}\n')
        conn.close()
    except Exception as e:
        print(f'\n{repr(e)}\n{str(e)}\n')


if __name__ == "__main__":
    java_home = os.environ.get("JAVA_HOME")
    if not java_home:
        print("JAVA_HOME is not set. Please set it to run the Java client.")
        exit(1)
    java_home = Path(java_home).resolve()
    print(f"Using JAVA_HOME: {java_home}")

    # fine file like hsqldb-*.jar
    hsqldb_jar = next((java_home / "lib" / f for f in os.listdir(java_home / "lib") if f.startswith("hsqldb-") and f.endswith(".jar")), None)
    if not hsqldb_jar:
        print("hsqldb jar not found in JAVA_HOME/lib. Please ensure HSQLDB is installed.")
        exit(1)
    os.environ["CLASSPATH"] = str(hsqldb_jar.resolve())
    print(f"Found HSQLDB jar: {hsqldb_jar}")

    main()
