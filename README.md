### [json-zip-code-distance-database](https://github.com/warren-bank/json-zip-code-distance-database)

#### Background:

* I had a fun/funny idea last night for a SPA.. to be continued
* This idea requires the availability of JSON data that maps each zip code to an Array of other zip codes, sorted in ascending order by distance
* It would want to lazy load one Array at a time, as needed, via XHR
* Consequently, the data should be organized one Array per JSON file
* Each JSON file should follow the naming convention: `${5-digit zip code}.json`

#### Methodology:

* searched google for a dataset of US zip codes that included geographic Lon/Lat coordinates
  * found a CSV dataset @ [federalgovernmentzipcodes.us](http://federalgovernmentzipcodes.us/free-zipcode-database-Primary.csv)
* wrote a database schema
* wrote some regex to transform the CSV into a SQL file containing a series of INSERT statements
* wrote some stored procedures for MySQL to process this data
  * iterate each row
    * search for other zip codes having a distance within a desired range
      * distance is calculated using the Lon/Lat pairs of the two (respective) zip codes
      * some optimization is done to prevent performing this calculation on zip codes that are too far away
        * they fall outside of a bounding rectangle
    * save each resulting zip code and its distance into another table
      * many-to-many mapping
      * this cache will grow quite large
* wrote some stored procedures for MySQL to query the many-to-many mapping table
  * the most important one returns JSON
    * input:
      * `id` of zip code
      * `radius` of distance (unit: miles)
    * output:
      * JSON
        * Array of Objects
          * `[{"dist": 2.50, "zip": "90210"}]`
* wrote some shell scripts
  * load the schema, data, and stored procedures into MySQL
  * populate the many-to-many mapping table in MySQL
  * export the many-to-many mapping table into a SQL file containing a series of INSERT statements
  * export the many-to-many mapping table into a large collection of small JSON data files

#### Where is the data?

* the `master` branch of the repo uses `.gitignore` to prevent inclusion of the exported data files
  * both SQL and JSON
* the `gh-pages` branch of the repo includes only the JSON data files
  * Github Pages are served with the CORS response HTTP header: `Access-Control-Allow-Origin: *`
    * the JSON data files can be requested and used by any SPA, via XHR
  * the filename of each JSON data file follows the naming convention: `${5-digit zip code}.json`
    * example: [90210](https://warren-bank.github.io/json-zip-code-distance-database/90210.json)
* the [releases](https://github.com/warren-bank/json-zip-code-distance-database/releases) page includes 7-zip compressed archives of both sets of exported data
  * v1.0.0
    * [SQL](https://github.com/warren-bank/json-zip-code-distance-database/releases/download/v1.0.0/MySQL-data-output.sql.7z)
      * compressed:
        * size: `34 MB`
      * uncompressed:
        * size: `358 MB`
        * files: `1`
    * [JSON](https://github.com/warren-bank/json-zip-code-distance-database/releases/download/v1.0.0/MySQL-data-output.json.7z)
      * compressed:
        * size: `35 MB`
      * uncompressed:
        * size: `559 MB`
        * files: `31,923`

#### What can I do with this?

* MySQL:
  * the CSV data table and the stored procedure that scans it for zip codes that are within a certain distance from a particular zip code can be used in production to dynamically perform this query
    * the many-to-many mapping table that was used to hold a cache of the entire pre-calculated dataset can be removed
    * a temporary table could replace it, and hold the query results until they are utilized.. then destroyed

* JSON:
  * the structure and small size of the data files are perfect for consumption by client-side SPAs
    * user enters a zip code into a form field
    * script requests JSON file that corresponds to this zip code value
    * script filters the Array to retain only the zip codes that are located within a desired distance of the input location
    * for each zip code in the result set:
      * obtain additional data that is app-specific
    * update the Redux store
    * update the React component tree
  * the aggregate size of the data set is rather large
    * during development:
      * hosting locally is a major hassle
      * accessing the data from Github Pages means that no local copy is needed

#### Similar Projects:

* [the National Bureau of Economic Research: ZIP Code Distance Database](http://www.nber.org/data/zip-code-distance-database.html)
  * I just found this dataset, and I'm pretty much laughing at myself that I effectively duplicated their entire project
    * The dataset that I generated uses a 100 mile radius
      * This distance range can be easily configured
      * If it were to be increased by an order of magnitude, then the database schema would need to be adjusted to allow for longer decimal values
    * Several datasets are available from the _NBER_
      * including [one](http://www.nber.org/distance/2016/gaz/zcta5/gaz2016zcta5distance100miles.csv.zip) that uses a 100 mile radius
        * _to do_: I'd like to compare our results

#### Legal:

* copyright: [Warren Bank](https://github.com/warren-bank)
* license: [GPL-2.0](https://www.gnu.org/licenses/old-licenses/gpl-2.0.txt)
