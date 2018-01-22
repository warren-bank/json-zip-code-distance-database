#!/usr/bin/env bash

max_distance='100'

json_dir='../../2. data/2. output/2. json'

database_name='zipcode_spatial_relations'
table_name='zipcode_spatial'

[ -d "$json_dir" ] && rm -rf "$json_dir"
mkdir -p "$json_dir"

get_zipcode () {
  zipcode=$(mysql -u root --batch --skip-column-names --database "$database_name" --execute "SELECT zipcode FROM ${table_name} WHERE id=${zipcode_id}")
  return 0
}

export_json () {
  output_file="${json_dir}/${zipcode}.json"
  mysql -u root --batch --skip-column-names --database "$database_name" --execute "CALL get_geodist_json(${zipcode_id}, ${max_distance})" >"$output_file"
  return 0
}

table_count=$(mysql -u root --batch --skip-column-names --database "$database_name" --execute "SELECT COUNT(*) FROM ${table_name}")

zipcode_id=1
while [ $zipcode_id -lt $table_count ]; do
  get_zipcode
  export_json

  let zipcode_id=zipcode_id+1
done
