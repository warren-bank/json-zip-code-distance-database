USE `zipcode_spatial_relations`;

-- cleanup
-- -------------------------------------------------------------------

DROP PROCEDURE IF EXISTS `geodist`;
DROP PROCEDURE IF EXISTS `geodist_generator`;
DROP PROCEDURE IF EXISTS `get_geodist`;
DROP PROCEDURE IF EXISTS `get_geodist_json`;

-- initialize
-- -------------------------------------------------------------------

delimiter $$

-- @param {integer} zipcode_id - Value of foreign key: `zipcode_spatial.id`
-- @param {integer} dist       - Value of distance radius from `zipcode_id` within which to search for matching records. (unit = miles)
CREATE PROCEDURE `geodist` (IN zipcode_id int, IN dist int)
BEGIN
  declare mylon double;
  declare mylat double;
  declare lon1 float;
  declare lon2 float;
  declare lat1 float;
  declare lat2 float;

  -- get the original lon and lat for the `zipcode_id`
  SELECT
    longitude, latitude
  INTO
    mylon, mylat
  FROM
    zipcode_spatial
  WHERE
    id=zipcode_id
  LIMIT 1
  ;

  -- calculate lon and lat for the rectangle:
  set lon1 = mylon - (dist / ABS(COS(RADIANS(mylat))*69));
  set lon2 = mylon + (dist / ABS(COS(RADIANS(mylat))*69));
  set lat1 = mylat - (dist / 69);
  set lat2 = mylat + (dist / 69);

  -- store the results:
  INSERT IGNORE INTO `zipcode_mapping` (focal_id, proximate_id, distance)
    -- run the query:
    SELECT
      zipcode_id     as focal_id,
      destination.id as proximate_id,
      3956 * 2 * ASIN(SQRT( POWER(SIN((mylat - destination.latitude) * pi()/180 / 2), 2) + COS(mylat * pi()/180) *  COS(destination.latitude * pi()/180) * POWER(SIN((mylon - destination.longitude) * pi()/180 / 2), 2)  )) as distance
    FROM
      zipcode_spatial destination
    WHERE
          destination.id <> zipcode_id
      and destination.longitude between lon1 and lon2
      and destination.latitude  between lat1 and lat2
    HAVING
      distance < dist
  ;
END $$

-- @param {integer} dist       - Value of distance radius from `zipcode_id` within which to search for matching records. (unit = miles)
CREATE PROCEDURE `geodist_generator` (IN dist int)
BEGIN
  declare zipcode_id    int DEFAULT 1;
  declare zipcode_count int;

  -- zipcode id values are autoincrement in the range: 1 .. (count - 1)
  -- get count
  SELECT COUNT(*) as count INTO zipcode_count FROM zipcode_spatial;

  -- iterate over all primary key values:
  WHILE zipcode_id < zipcode_count DO
    CALL geodist(zipcode_id, dist);
    SET zipcode_id := zipcode_id + 1;
  END WHILE;
END $$

-- @param {integer} zipcode_id - Value of foreign key: `zipcode_spatial.id`
-- @param {integer} dist       - Value of distance radius from `zipcode_id` within which to search for matching records. (unit = miles)
CREATE PROCEDURE `get_geodist` (IN zipcode_id int, IN dist int)
BEGIN
  -- CALL geodist(zipcode_id, dist);

  SELECT
    zmap.distance, zips.zipcode
  FROM
    zipcode_mapping zmap,
    zipcode_spatial zips
  WHERE
        zmap.focal_id = zipcode_id
    and zmap.distance <= dist
    and zips.id = zmap.proximate_id
  ORDER BY
    zmap.distance
  ;
END $$

-- @param {integer} zipcode_id - Value of foreign key: `zipcode_spatial.id`
-- @param {integer} dist       - Value of distance radius from `zipcode_id` within which to search for matching records. (unit = miles)
CREATE PROCEDURE `get_geodist_json` (IN zipcode_id int, IN dist int)
BEGIN
  -- CALL geodist(zipcode_id, dist);

  -- https://dev.mysql.com/doc/refman/5.6/en/server-system-variables.html#sysvar_group_concat_max_len
  SET SESSION group_concat_max_len = 18446744073709551615;

  SELECT CONCAT('[', better_result, ']') AS best_result FROM
  (
    SELECT GROUP_CONCAT('{', my_json, '}' SEPARATOR ',') AS better_result FROM
    (
      SELECT 
        CONCAT
        (
          '"dist": ',      distance,      ', '
          '"zip": ' , '"', zipcode , '"'
        ) AS my_json
      FROM
      (
        SELECT
          zmap.distance, zips.zipcode
        FROM
          zipcode_mapping zmap,
          zipcode_spatial zips
        WHERE
              zmap.focal_id = zipcode_id
          and zmap.distance <= dist
          and zips.id = zmap.proximate_id
        ORDER BY
          zmap.distance
      ) AS raw_data
    ) AS more_json
  ) AS yet_more_json
  ;
END $$

delimiter ;
