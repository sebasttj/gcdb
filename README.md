gcdb
====

   A database for storing NFL game data, with support for importing from
   nfl.com's GameCenter

Authors
-------
   Josh Sebastian


About
-----

   Gcdb is a database which stores play-by-play information about NFL games. It
   records home and away team names, points scored per quarter, and
   play-by-play data. There is also a hierarchical categorization of play
   types.
   
   The idea is that you can use this data to answer questions that cannot
   generally be answered by on-line tools. See the "Examples" section for some
   ideas.
   
   Included is a script that can parse an nfl.com GameCenter JSON file and add
   its data to gcdb.

Installation
------------

   Gcdb requires a PostgreSQL database, and the ingest script requires
   Python 2 with the psycopg2, json, logging, and argparse modules. On many
   systems, the psycopg2 module is not included simply by installing Python; it
   must be specifically requested as a separate package.
   
   On a Debian-based system, you can install all reqiuired components like so:
   
    # apt-get install postgresql python python-psycopg2
   
   Once Postgres is installed, the simplest way to proceed is to set up a user
   account for yourself using auth ident, and give it with full control to a
   blank database called "gcdb". On a Debian-based system, that would look like
   this (run as yourself):
   
    $ sudo -u postgres createuser $USER
    $ sudo -u postgres createdb -O $USER gcdb
   
   Now that permissions are set up and we have a blank database, we can import
   the gcdb schema:
   
    $ psql -f gcdb-schema.sql gcdb
   
   Now, all that's left to do is import some data. Download a game from
   nfl.com, and ingest it.
   
    $ wget http://www.nfl.com/liveupdate/game-center/2012020500/2012020500_gtd.json
    $ ./gcdb-ingest-game 2012020500_gtd.json
   
   Voila!

Examples
--------

   So now you've got gcdb, and you have data in your database. What now? Well,
   how about we want to know whether run or pass was more successful on
   4th-and-3. Issue the following query:
   
    select actionid, action_yards - yards_to_go > 0, count(*)
    from drive_action
    where down = 4 and yards_to_go = 3
      and actionid in (10, 11, 14, 15, 16, 19, 20)
    group by actionid, action_yards - yards_to_go > 0
   
   (Those actionids represent, respectively, rush, rush for TD, incompletion,
   completion, completion for TD, interception, and sack. When the stat
   hierarchy is done, that query will be a lot more friendly.)
