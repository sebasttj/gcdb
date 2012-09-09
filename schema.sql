--
-- PostgreSQL database dump
--

-- Dumped from database version 9.1.5
-- Dumped by pg_dump version 9.1.5
-- Started on 2012-09-09 09:29:10 CDT

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 173 (class 3079 OID 11677)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 1965 (class 0 OID 0)
-- Dependencies: 173
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_with_oids = false;

--
-- TOC entry 166 (class 1259 OID 16520)
-- Dependencies: 5
-- Name: action; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE action (
    statid character(100) NOT NULL,
    actionid integer NOT NULL
);


--
-- TOC entry 161 (class 1259 OID 16499)
-- Dependencies: 5
-- Name: drive; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE drive (
    gameid character(10) NOT NULL,
    driveid integer NOT NULL,
    pos_team character(3) NOT NULL
);


--
-- TOC entry 167 (class 1259 OID 16528)
-- Dependencies: 5
-- Name: game; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE game (
    gameid character varying(50) NOT NULL,
    home_team character(3) NOT NULL,
    away_team character(3) NOT NULL,
    season integer,
    week integer,
    when_played timestamp
);


--
-- TOC entry 162 (class 1259 OID 16502)
-- Dependencies: 5
-- Name: play; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE play (
    gameid character(10) NOT NULL,
    driveid integer NOT NULL,
    playid integer NOT NULL,
    down integer,
    yards_to_go integer,
    "time" integer NOT NULL,
    yardline integer,
    description character(2000)
);


--
-- TOC entry 163 (class 1259 OID 16508)
-- Dependencies: 5
-- Name: play_action; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE play_action (
    gameid character(10) NOT NULL,
    playid integer NOT NULL,
    playerid character(10),
    sequence integer NOT NULL,
    actionid integer NOT NULL,
    yards integer
);


--
-- TOC entry 164 (class 1259 OID 16511)
-- Dependencies: 5
-- Name: player; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE player (
    playerid character(10) NOT NULL,
    name character varying(100) NOT NULL
);


--
-- TOC entry 172 (class 1259 OID 16922)
-- Dependencies: 1930 5
-- Name: drive_action; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW drive_action AS
    SELECT gameid, game.season, game.week, game.home_team, game.away_team, play.driveid, play.playid, play."time", drive.pos_team, play.down, play.yards_to_go, play.description AS play_description, player.name AS player_name, play_action.actionid, play_action.yards AS action_yards, play_action.sequence FROM ((((game JOIN drive USING (gameid)) JOIN play USING (gameid, driveid)) JOIN play_action USING (gameid, playid)) JOIN player USING (playerid));


--
-- TOC entry 169 (class 1259 OID 16685)
-- Dependencies: 5
-- Name: quarter_score; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE quarter_score (
    gameid character(10) NOT NULL,
    quarter integer NOT NULL,
    team character(3) NOT NULL,
    points integer NOT NULL
);


--
-- TOC entry 170 (class 1259 OID 16695)
-- Dependencies: 1928 5
-- Name: game_score; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW game_score AS
    SELECT x.gameid, x.home_team, x.away_team, x.home_points, x.away_points, CASE WHEN (x.home_points > x.away_points) THEN x.home_team WHEN (x.home_points < x.away_points) THEN x.away_team ELSE 'tie'::bpchar END AS winning_team FROM (SELECT gameid, game.home_team, game.away_team, sum(h.points) AS home_points, sum(a.points) AS away_points FROM ((game JOIN quarter_score h USING (gameid)) JOIN quarter_score a USING (gameid, quarter)) WHERE ((h.team = game.home_team) AND (a.team = game.away_team)) GROUP BY gameid, game.home_team, game.away_team) x;


--
-- TOC entry 165 (class 1259 OID 16514)
-- Dependencies: 5
-- Name: stat; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE stat (
    statid character varying(200) NOT NULL,
    description character varying(1000),
    long_description character(2000)
);


--
-- TOC entry 168 (class 1259 OID 16531)
-- Dependencies: 5
-- Name: stat_hierarchy; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE stat_hierarchy (
    parent character(100) NOT NULL,
    child character(100) NOT NULL
);


--
-- TOC entry 171 (class 1259 OID 16700)
-- Dependencies: 1929 5
-- Name: stat_action; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW stat_action AS
    WITH RECURSIVE hier AS (SELECT action.statid, action.actionid FROM action UNION ALL SELECT n.parent, p.actionid FROM (stat_hierarchy n JOIN hier p ON ((n.child = p.statid)))) SELECT hier.statid, hier.actionid FROM hier;


--
-- TOC entry 1932 (class 2606 OID 16535)
-- Dependencies: 161 161 161 1960
-- Name: PK_DRIVE; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY drive
    ADD CONSTRAINT "PK_DRIVE" PRIMARY KEY (gameid, driveid);


--
-- TOC entry 1946 (class 2606 OID 16537)
-- Dependencies: 167 167 1960
-- Name: PK_GAME; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY game
    ADD CONSTRAINT "PK_GAME" PRIMARY KEY (gameid);


--
-- TOC entry 1935 (class 2606 OID 16539)
-- Dependencies: 162 162 162 1960
-- Name: PK_PLAY; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY play
    ADD CONSTRAINT "PK_PLAY" PRIMARY KEY (gameid, playid);


--
-- TOC entry 1940 (class 2606 OID 16541)
-- Dependencies: 164 164 1960
-- Name: PK_PLAYER; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY player
    ADD CONSTRAINT "PK_PLAYER" PRIMARY KEY (playerid);


--
-- TOC entry 1938 (class 2606 OID 16543)
-- Dependencies: 163 163 163 163 1960
-- Name: PK_PLAY_ACTION; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY play_action
    ADD CONSTRAINT "PK_PLAY_ACTION" PRIMARY KEY (gameid, playid, sequence);


--
-- TOC entry 1950 (class 2606 OID 16689)
-- Dependencies: 169 169 169 169 1960
-- Name: PK_QUARTER_SCORE; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY quarter_score
    ADD CONSTRAINT "PK_QUARTER_SCORE" PRIMARY KEY (gameid, quarter, team);


--
-- TOC entry 1942 (class 2606 OID 16545)
-- Dependencies: 165 165 1960
-- Name: PK_STAT; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY stat
    ADD CONSTRAINT "PK_STAT" PRIMARY KEY (statid);


--
-- TOC entry 1944 (class 2606 OID 16547)
-- Dependencies: 166 166 166 1960
-- Name: PK_STAT_ACTION; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY action
    ADD CONSTRAINT "PK_STAT_ACTION" PRIMARY KEY (statid, actionid);


--
-- TOC entry 1948 (class 2606 OID 16549)
-- Dependencies: 168 168 168 1960
-- Name: PK_STAT_HIER; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY stat_hierarchy
    ADD CONSTRAINT "PK_STAT_HIER" PRIMARY KEY (parent, child);


--
-- TOC entry 1936 (class 1259 OID 16550)
-- Dependencies: 163 1960
-- Name: IDX_PLAY_ACTION_ACTIONID; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_PLAY_ACTION_ACTIONID" ON play_action USING btree (actionid);


--
-- TOC entry 1933 (class 1259 OID 16551)
-- Dependencies: 162 1960
-- Name: IDX_PLAY_DOWN; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_PLAY_DOWN" ON play USING btree (down);


--
-- TOC entry 1951 (class 2606 OID 16552)
-- Dependencies: 161 167 1945 1960
-- Name: FK_DRIVE_GAME; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY drive
    ADD CONSTRAINT "FK_DRIVE_GAME" FOREIGN KEY (gameid) REFERENCES game(gameid);


--
-- TOC entry 1953 (class 2606 OID 16557)
-- Dependencies: 1934 162 162 163 163 1960
-- Name: FK_PLAY_ACTION_GAMEID_PLAYID; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY play_action
    ADD CONSTRAINT "FK_PLAY_ACTION_GAMEID_PLAYID" FOREIGN KEY (gameid, playid) REFERENCES play(gameid, playid);


--
-- TOC entry 1954 (class 2606 OID 16562)
-- Dependencies: 164 163 1939 1960
-- Name: FK_PLAY_ACTION_PLAYERID; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY play_action
    ADD CONSTRAINT "FK_PLAY_ACTION_PLAYERID" FOREIGN KEY (playerid) REFERENCES player(playerid);


--
-- TOC entry 1952 (class 2606 OID 16567)
-- Dependencies: 1931 162 162 161 161 1960
-- Name: FK_PLAY_GAME; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY play
    ADD CONSTRAINT "FK_PLAY_GAME" FOREIGN KEY (gameid, driveid) REFERENCES drive(gameid, driveid);


--
-- TOC entry 1958 (class 2606 OID 16690)
-- Dependencies: 1945 169 167 1960
-- Name: FK_QUARTER_SCORE_GAMEID; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY quarter_score
    ADD CONSTRAINT "FK_QUARTER_SCORE_GAMEID" FOREIGN KEY (gameid) REFERENCES game(gameid);


--
-- TOC entry 1955 (class 2606 OID 16572)
-- Dependencies: 1941 166 165 1960
-- Name: FK_STAT_ACTION_STATID; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY action
    ADD CONSTRAINT "FK_STAT_ACTION_STATID" FOREIGN KEY (statid) REFERENCES stat(statid);


--
-- TOC entry 1957 (class 2606 OID 24648)
-- Dependencies: 168 1941 165 1960
-- Name: FK_STAT_HIER_CHILD_STAT; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY stat_hierarchy
    ADD CONSTRAINT "FK_STAT_HIER_CHILD_STAT" FOREIGN KEY (child) REFERENCES stat(statid);


--
-- TOC entry 1956 (class 2606 OID 24643)
-- Dependencies: 168 1941 165 1960
-- Name: FK_STAT_HIER_PARENT_STAT; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY stat_hierarchy
    ADD CONSTRAINT "FK_STAT_HIER_PARENT_STAT" FOREIGN KEY (parent) REFERENCES stat(statid);


-- Completed on 2012-09-09 09:29:10 CDT

--
-- PostgreSQL database dump complete
--

