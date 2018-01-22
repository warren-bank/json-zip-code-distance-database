@echo off
setlocal enabledelayedexpansion

set max_distance=100

set json_dir=%~dp0..\..\2. data\2. output\2. json

set database_name=zipcode_spatial_relations
set table_name=zipcode_spatial

if exist "%json_dir%" rmdir /Q /S "%json_dir%"
mkdir "%json_dir%"

set cmd=mysql -u root --batch --skip-column-names --database "%database_name%" --execute "SELECT COUNT(*) FROM %table_name%"
FOR /F "tokens=* delims=" %%c IN ('%cmd%') DO (
  set table_count=%%c
  set /a "table_count-=1"
)

FOR /L %%i IN (1,1,!table_count!) DO call :process_id "%%i"

goto done

:process_id
  set zipcode_id=%~1
  call :get_zipcode
  call :export_json
  goto :eof

:get_zipcode
  set cmd=mysql -u root --batch --skip-column-names --database "%database_name%" --execute "SELECT zipcode FROM %table_name% WHERE id=!zipcode_id!"
  FOR /F "tokens=* delims=" %%z IN ('%cmd%') DO set zipcode=%%z
  goto :eof

:export_json
  set output_file="%json_dir%\!zipcode!.json"
  mysql -u root --batch --skip-column-names --database "%database_name%" --execute "CALL get_geodist_json(!zipcode_id!, %max_distance%)" >!output_file!
  goto :eof

:done
endlocal
echo.
pause
