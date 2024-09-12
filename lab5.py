from dbtable import * import add_func

class StationTable(DbTable): '''
Это класс для таблиц '''
def table_name(self): '''
Это метод для названия таблицы '''
return self.dbconn.prefix + "stations"

def columns(self):
return {"id": ["serial", "PRIMARY KEY"],
"st_name": ["varchar(20)", "NOT NULL"], "tarrif_zone_id": ["integer", "NOT NULL"], "st_index": ["integer", "NOT NULL"]}

def table_constraint(self):
return ['CONTRAINT "Name" UNIQUE (st_name)']

def find_by_position(self, num):
sql = "SELECT * FROM " + self.table_name() sql += " ORDER BY "
sql += ", ".join(self.primary_key()) sql += " LIMIT 1 OFFSET %(offset)s" cur = self.dbconn.conn.cursor() cur.execute(sql, {"offset": num - 1}) return cur.fetchone()

def delete(self, val):
par_sql = f"DELETE FROM stations WHERE st_name = '{val[1]}';" cur = self.dbconn.conn.cursor()
cur.execute(par_sql) self.dbconn.conn.commit()

def insert(self): while True:
