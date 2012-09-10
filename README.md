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
   the gcdb schema, and load the statistical metadata:
   
    $ psql -f schema.sql gcdb
    $ psql -f stat-data.sql gcdb
  
   Now, just tell gcdb to update itself based on the schedule info from nfl.com:

    $ ./ingest-game --update
 
   Voila!
   
   Note: Sometimes, nfl.com will give a "404: Not Found" error when requesting a
   JSON file, even though it exists. You'll see output like this:
   
    Processing game: 2011120412
    Processing game: 2011120406
    Could not read from file "http://www.nfl.com/liveupdate/game-center/2011120500/2011120500_gtd.json": HTTP Error 404: Not Found.
    Processing game: 2011120800
   
   If you see this, don't panic! After the program is done running, simply
   re-run `ingest-game --update`, and it will download the missing games' data.

Examples
--------

   So now you've got gcdb, and you have data in your database. What now? Well,
   how about we want to know whether run or pass was more successful on
   4th-and-3. Issue the following query:
   
    select statid, action_yards - yards_to_go > 0 madeit, count(*)
    from drive_action
    join stat_action using (actionid)
    where down = 4 and yards_to_go = 3
      and statid in ('rushing_att', 'passing_dropback')
    group by statid, action_yards - yards_to_go > 0
    order by 1, 2

   Or suppose you want to know what affect a week 1 win has on your overall
   record and chances of making the playoffs:
   
    with game_score as (
      select gameid, team, sum(points) points
      from quarter_score
      group by gameid, team
    ), team as (
      select distinct team from quarter_score
    ), victor as (
      select season, week, g.gameid, case when hs.points > vs.points then hs.team else vs.team end as victor
      from game g
      join game_score hs on g.gameid = hs.gameid and g.home_team = hs.team
      join game_score vs on g.gameid = vs.gameid and g.away_team = vs.team
      where season != 2012 and week between 1 and 17
    ), team_wins as (
      select season, victor team, count(*) wins
      from victor s
      group by season, victor
    ), x as (
      select t.season, t.team, t.wins, w1.victor is not null w1_win,
             max(pg.week) playoff
      from team_wins t
      left join victor w1 on t.season = w1.season
        and t.team = w1.victor and w1.week = 1
      left join game pg on t.season = pg.season and pg.week > 17
        and t.team in (pg.home_team, pg.away_team)
      group by t.season, t.team, t.wins, w1.victor
    )
    select w1_win, avg(wins), count(playoff)::float/count(*) playoff_chances
    from x
    group by w1_win   
