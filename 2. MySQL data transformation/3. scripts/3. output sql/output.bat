@echo off

set sql_dir=%~dp0..\..\2. data\2. output\1. sql

set database_name=zipcode_spatial_relations
set table_name=zipcode_mapping

if exist "%sql_dir%" rmdir /Q /S "%sql_dir%"
mkdir "%sql_dir%"

mysqldump --user root --compact --no-create-info --order-by-primary --complete-insert --extended-insert --result-file="%sql_dir%\%table_name%.sql" --databases "%database_name%" --tables "%table_name%"

echo.
pause
