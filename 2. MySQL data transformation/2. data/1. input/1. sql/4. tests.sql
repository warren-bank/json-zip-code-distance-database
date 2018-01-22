USE `zipcode_spatial_relations`;

-- process a small subset of the input data
CALL geodist(1, 10);

-- output format: SQL table
CALL get_geodist(1, 10);

-- output format: JSON string
-- Array of Objects:
--   [{"dist": 100.0, "zip": "12345"}]
CALL get_geodist_json(1, 10);
