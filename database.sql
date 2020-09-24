CREATE DATABASE authtodo;

\q
$ psql -U postgres -d authtodo
create extension if not exists "uuid-ossp";

\q
$ psql -U ylu -d authtodo
-- users
CREATE TABLE users(
  user_id UUID DEFAULT uuid_generate_v4(),
  user_name VARCHAR(255) NOT NULL,
  user_email VARCHAR(255) NOT NULL UNIQUE,
  user_password VARCHAR(255) NOT NULL,
  PRIMARY KEY(user_id)
);
-- todo
CREATE TABLE todos(
  todo_id SERIAL,
  user_id UUID,
  description VARCHAR(255) NOT NULL,
  PRIMARY KEY (todo_id),
  FOREIGN KEY (user_id) REFERENCES users(user_id)
);

--
authtodo=> select * from users;
 user_id | user_name | user_email | user_password
---------+-----------+------------+---------------
(0 rows)


authtodo=> select * from todos;
 todo_id | user_id | description
---------+---------+-------------
(0 rows)

-- clear the screen
authtodo=> \! cls

authtodo=> \d+ users
                                                    Table "public.users"
    Column     |          Type          | Collation | Nullable |      Default       | Storage  | Stats target | Descrip
tion
---------------+------------------------+-----------+----------+--------------------+----------+--------------+--------
-----
 user_id       | uuid                   |           | not null | uuid_generate_v4() | plain    |              |
 user_name     | character varying(255) |           | not null |                    | extended |              |
 user_email    | character varying(255) |           | not null |                    | extended |              |
 user_password | character varying(255) |           | not null |                    | extended |              |
Indexes:
    "users_pkey" PRIMARY KEY, btree (user_id)
    "users_user_email_key" UNIQUE CONSTRAINT, btree (user_email)
Referenced by:
    TABLE "todos" CONSTRAINT "todos_user_id_fkey" FOREIGN KEY (user_id) REFERENCES users(user_id)
Access method: heap

-----------+------------------------------------------------------------+-----------
authtodo=> \d+ todos
                                                             Table "public.todos"
   Column    |          Type          | Collation | Nullable |                Default                 | Storage  | Stat
s target | Description
-------------+------------------------+-----------+----------+----------------------------------------+----------+-----
---------+-------------
 todo_id     | integer                |           | not null | nextval('todos_todo_id_seq'::regclass) | plain    |
         |
 user_id     | uuid                   |           |          |                                        | plain    |
         |
 description | character varying(255) |           | not null |                                        | extended |
         |
Indexes:
    "todos_pkey" PRIMARY KEY, btree (todo_id)
Foreign-key constraints:
    "todos_user_id_fkey" FOREIGN KEY (user_id) REFERENCES users(user_id)
Access method: heap

authtodo=> drop table users;
ERROR:  cannot drop table users because other objects depend on it
DETAIL:  constraint todos_user_id_fkey on table todos depends on table users
HINT:  Use DROP ... CASCADE to drop the dependent objects too.
authtodo=>



INSERT INTO users (user_name, user_email, user_password)
VALUES ('test2', 'test2@test.com', 'test123');

authtodo=> \x on
Expanded display is on.
authtodo=> select * from users;
-[ RECORD 1 ]-+-------------------------------------
user_id       | 1bdfa4e2-c28e-4bbc-8920-9bba556a0e65
user_name     | test1
user_email    | test1@test.com
user_password | test123
-[ RECORD 2 ]-+-------------------------------------
user_id       | 7fc865da-8439-49bb-95b9-0d330bccd3d1
user_name     | test2
user_email    | test2@test.com
user_password | test123

--
INSERT INTO todos (user_id, description) 
VALUES ('1bdfa4e2-c28e-4bbc-8920-9bba556a0e65', 'need to go');

--
authtodo=> select * from users INNER JOIN todos ON users.user_id = todos.user_id;
-[ RECORD 1 ]-+-------------------------------------
user_id       | 1bdfa4e2-c28e-4bbc-8920-9bba556a0e65
user_name     | test1
user_email    | test1@test.com
user_password | test123
todo_id       | 1
user_id       | 1bdfa4e2-c28e-4bbc-8920-9bba556a0e65
description   | need to go

authtodo=> select * from users LEFT JOIN todos ON users.user_id = todos.user_id;
-[ RECORD 1 ]-+-------------------------------------
user_id       | 1bdfa4e2-c28e-4bbc-8920-9bba556a0e65
user_name     | test1
user_email    | test1@test.com
user_password | test123
todo_id       | 1
user_id       | 1bdfa4e2-c28e-4bbc-8920-9bba556a0e65
description   | need to go
-[ RECORD 2 ]-+-------------------------------------
user_id       | 7fc865da-8439-49bb-95b9-0d330bccd3d1
user_name     | test2
user_email    | test2@test.com
user_password | test123
todo_id       |
user_id       |
description   |

select * from users u LEFT JOIN todos t ON u.user_id = t.user_id where u.user_id = '7fc865da-8439-49bb-95b9-0d330bccd3d1';