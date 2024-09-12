from dbtable import *
import add_func
class StationTable(DbTable):
'''
Это класс для таблиц
'''
def table_name(self):
'''
Это метод для названия таблицы
'''
return self.dbconn.prefix + "stations"
def columns(self):
return {"id": ["serial", "PRIMARY KEY"],
"st_name": ["varchar(20)", "NOT NULL"],
"tarrif_zone_id": ["integer", "NOT NULL"],
"st_index": ["integer", "NOT NULL"]}
def table_constraint(self):
return ['CONTRAINT "Name" UNIQUE (st_name)']
def find_by_position(self, num):
sql = "SELECT * FROM " + self.table_name()
sql += " ORDER BY "
sql += ", ".join(self.primary_key())
sql += " LIMIT 1 OFFSET %(offset)s"
cur = self.dbconn.conn.cursor()
cur.execute(sql, {"offset": num - 1})
return cur.fetchone() 
def delete(self, val):
par_sql = f"DELETE FROM stations WHERE st_name = '{val[1]}';"
cur = self.dbconn.conn.cursor()
cur.execute(par_sql)
self.dbconn.conn.commit()
def insert(self):
while True:
st_name = input('Введите название добавляемой 
станции (enter - отмена): ').strip()
if len(st_name) > 20:
print('Недопустмая длина названия 
станции')
elif st_name == '':
return "1"
else:
break
tarrif_zone_id = add_func.validate_input('Введите номер
тарифной зоны: ', 0, 7)
if(tarrif_zone_id==-1):
return "1"
st_index = add_func.validate_input('Введите индекс
добавляемой станции: ', 0, 100)
if(st_index==-1):
return "1"
insert = [st_index, st_name, tarrif_zone_id]
self.insert_one(insert)
def update(self, old):
"""Функция для обновления станции
"""
print(f'''Выбрана станция для изменения: {old[1]}''')
cur = self.dbconn.conn.cursor()
while True:
data = input("Введите название (enter - отмена): 
").strip()
if(len(data.strip()) > 20):
data = input("Название слишком длинное! 
Введите название заново (enter - отмена):").strip()
elif(self.check_by_name(data.strip())):
data = input("Такое название уже существует. 
Введите новое (enter - отмена):").strip()
elif(data==''): return
else:
param_sql = f"UPDATE {self.table_name()} SET st_name = '{data}' WHERE 
st_name = '{old[1]}';"
cur.execute(param_sql)
self.dbconn.conn.commit()
return
def check_by_name(self, value): 
sql = f"SELECT * FROM {self.table_name()} WHERE st_name='{value}'"
cur = self.dbconn.conn.cursor() 
cur.execute(sql) 
result = cur.fetchone() 
cur.close() 
if result: 
return True
else: 
return False
def find_by_name(self, name):
cur = self.dbconn.conn.cursor()
param_query = f"SELECT id FROM Stations WHERE st_name = '{name}';"
# sql_sel = "SELECT id FROM " + self.table_name()
# sql_sel += " WHERE cath_name = " + "'" + name + "'" + ";"
cur.execute(param_query) 
ret = cur.fetchone()
return ret
def name_by_id(self, id):
cur = self.dbconn.conn.cursor()
query = "SELECT st_name FROM Stations WHERE id = %s;"
cur.execute(query, str(id))
return cur.fetchone()
def index_by_id(self,id):
cur = self.dbconn.conn.cursor()
query = f"SELECT st_index FROM Stations WHERE id = {id};"
cur.execute(query)
return cur.fetchone()
def example_insert(self):
self.insert_one([1, "Нахабино", 1])
self.insert_one([2, "Стрешнево", 2])
self.insert_one([2, "Царицыно", 2])
self.insert_one([3, "Яуза", 3])
self.insert_one([2, "Щукинская", 3])
self.insert_one([4, "Москва-Курская", 4])
self.insert_one([4, "Дмитровская", 4])
self.insert_one([4, "Остафьево", 4])
self.insert_one([4, "Подольск", 4])
return
from tables.station_table import *
from dbtable import *
import add_func
class RoutesTable(DbTable):
def table_name(self):
return self.dbconn.prefix + "routes"
def columns(self):
return {"id": ["serial", "PRIMARY KEY"],
"first_st_id": ["integer", "NOT NULL", "REFERENCES stations(id) ON DELETE 
CASCADE"],
"last_st_id": ["integer", "NOT NULL", "REFERENCES stations(id) ON DELETE 
CASCADE"]}
def primary_key(self):
return ['id'] 
'''def table_constraints(self):
return ["PRIMARY KEY(route_id)"]'''
def all_by_station_id(self, pid, t):
if(t == 1):
sql = f"""SELECT * FROM {self.table_name()} WHERE first_st_id = {str(pid)}
ORDER BY {", ".join(self.primary_key())};"""
else:
sql = f"""SELECT * FROM {self.table_name()} WHERE last_st_id = {str(pid)}
ORDER BY {", ".join(self.primary_key())};"""
cur = self.dbconn.conn.cursor()
cur.execute(sql)
return cur.fetchall() 
def delete(self, id):
par_sql = f"DELETE FROM routes WHERE id = {str(id)}"
cur = self.dbconn.conn.cursor()
cur.execute(par_sql)
self.dbconn.conn.commit()
def insert_route_one(self, max_index):
while True:
first_st_id = add_func.validate_input('Введите номер
добавляемой начальной станции (0 - для отмены): ', 0, 
max_index)
if(first_st_id == -1): return "1"
last_st_id = add_func.validate_input('Введите номер
добавляемой конечной станции (0 - для отмены): ', 0, 
max_index)
if(last_st_id == -1): return "1"
t1 = StationTable().index_by_id(first_st_id)
t2 = StationTable().index_by_id(last_st_id)
if t1>t2:
print('Нельзя добавить такой маршрут')
else:
insert = [first_st_id, last_st_id]
self.insert_one(insert)
return
def update(self, max_index):
while True:
t = add_func.validate_input('Изменить маршрут по:\
\n1 - начальной станции;\
\n2- конечной станции;\n(0 - отмена);\n', 0, 2)
if(t==1):
n1 = add_func.validate_input('Введите номер 
начальной станции, который вы хотите заменить (0 -
для отмены): ', 0, max_index)
if(n1 == -1): return "1"
n2 = add_func.validate_input('Введите номер, на 
который вы хотите поменять (0 - для отмены): ', 0, 
max_index)
if(n2 == -1): return "1"
if n1 != n2:
sql = f"""UPDATE {self.table_name()} SET first_st_id = '{n2}' WHERE 
first_st_id = '{n1}';"""
break
else:
print('Невозможно поменять на такой 
номер')
elif(t==2):
n1 = add_func.validate_input('Введите номер конечной 
станции, который вы хотите заменить (0 - для 
отмены): ', 0, max_index)
if(n1 == -1): return "1"
n2 = add_func.validate_input('Введите номер, на 
который вы хотите поменять (0 - для отмены): ', 0, 
max_index)
if(n2 == -1): return "1"
if n1 != n2:
sql = f"""UPDATE {self.table_name()} SET last_st_id = '{n2}' WHERE 
last_st_id = '{n1}';"""
# sql2 = f"""UPDATE stations SET id = '{n2}' WHERE id = '{n1}';"""
break
else:
print('Невозможно поменять на такой 
номер')
else:
return "1"
cur = self.dbconn.conn.cursor()
cur.execute(sql)
self.dbconn.conn.commit()
return
def example_insert(self):
self.insert_one([1,2])
self.insert_one([1,6])
self.insert_one([1,7])
self.insert_one([1,8])
self.insert_one([1,9])
self.insert_one([1,6])
return
