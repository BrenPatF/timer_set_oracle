DEFINE LIB_USER=&1
DEFINE APP_USER=&2
@..\initspool drop_utils_users

PROMPT Drop &LIB_USER and &APP_USER
DROP USER &LIB_USER CASCADE
/
DROP USER &APP_USER CASCADE
/
PROMPT Drop directory input_dir
DROP DIRECTORY input_dir
/
@..\endspool
exit