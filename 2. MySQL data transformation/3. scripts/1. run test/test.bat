@echo off

set sql_dir=%~dp0..\..\2. data\1. input\1. sql

mysql -u root <"%sql_dir%\1. schema.sql"
mysql -u root <"%sql_dir%\2. stored procedures.sql"
mysql -u root <"%sql_dir%\3. data.sql"
mysql -u root <"%sql_dir%\4. tests.sql"

echo.
pause
