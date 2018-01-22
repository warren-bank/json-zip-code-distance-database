#!/usr/bin/env bash

sql_dir='../../2. data/2. output/1. sql'

database_name='zipcode_spatial_relations'
table_name='zipcode_mapping'

[ -d "$sql_dir" ] && rm -rf "$sql_dir"
mkdir -p "$sql_dir"

mysqldump --user root --compact --no-create-info --order-by-primary --complete-insert --extended-insert --result-file="${sql_dir}/${table_name}.sql" --databases "$database_name" --tables "$table_name"
