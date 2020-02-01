/*
// tag::fabric-conf[]
# neo4j.conf
apoc.import.file.enabled=true

fabric.database.name=fosdem

fabric.graph.0.uri=neo4j://localhost:7687
fabric.graph.0.database=db1
fabric.graph.0.name=year2019

fabric.graph.1.uri=neo4j://localhost:7687
fabric.graph.1.database=db2
fabric.graph.1.name=year2020
// end::fabric-conf[]
*/


// tag::users[]
CREATE USER Michael SET PASSWORD 'secret' CHANGE NOT REQUIRED;
CREATE USER Sascha SET PASSWORD 'secret' CHANGE NOT REQUIRED;

CREATE ROLE organizer;
GRANT ROLE organizer TO Michael;

CREATE ROLE speaker;
GRANT ROLE speaker TO Sascha;
// end::users[]

// tag:privileges[]
GRANT ACCESS ON DATABASE fosdem TO speaker, organizer;

GRANT TRAVERSE ON GRAPH fosdem TO speaker, organizer;
GRANT READ {*} ON GRAPH fosdem TO speaker, organizer;
// equal to 
GRANT MATCH {*} ON GRAPH fosdem TO speaker, organizer;

DENY READ {email} ON GRAPH fosdem NODES Speaker TO speaker;

GRANT WRITE ON GRAPH fosdem TO organizer;
DENY  WRITE ON GRAPH * TO speaker;

GRANT CREATE NEW NODE LABEL ON DATABASE fosdem TO organizer;
GRANT CREATE NEW PROPERTY NAME ON DATABASE fosdem TO organizer;

// full power!
GRANT ALL DATABASE PRIVILEGES ON DATABASE * TO organizer;
// end:privileges[]


// tag::existential[]
MATCH (p:Person)
WHERE EXISTS {
	MATCH (p)-[:PRESENTS]->()
}
RETURN p as director;
// end:existential[]

// tag::subquery-union[]
call { 
  MATCH (e:Event) RETURN e.title as title
  UNION
  MATCH (k:Keynote) RETURN k.title as title
}
RETURN distinct name 
ORDER BY name DESC LIMIT 10;
// end:subquery-union[]


// show system graph
call apoc.systemdb.graph();

// FOSDEM Schedule https://fosdem.org/2020/schedule/xml
// put xml files into $NEO4J_HOME/import
// show content of file
CALL apoc.load.xmlSimple("file://fosdem-2019.xml") YIELD value ;

CALL apoc.load.xmlSimple("file://fosdem-2020.xml") YIELD value ;

:use db1
CALL apoc.load.xmlSimple("file://fosdem-2020.xml") YIELD value 
...

// todo example of iterating over files and loading them into different dbs with fabric

USE fosdem.year2020
CALL apoc.load.xmlSimple("file://fosdem-2020.xml") YIELD value 
UNWIND value._day AS _day
MERGE (d:Day {date:_day.date})

WITH * unwind _day._room AS _room
MERGE (r:Room {name:_room.name})

WITH *  unwind _room._event AS _event
MERGE (e:Event {id:_event.id}) 
MERGE (e)-[:IN_ROOM]->(r)
MERGE (e)-[:ON_DAY]->(d)
ON CREATE SET 
e.title    = _event._title._text,
e.start    = _event._start._text,
e.duration = _event._duration._text,
e.abstract = _event._abstract._text,
e.slug     = _event._slug._text

MERGE (t:Track {name:_event._track._text})
MERGE (e)-[:IN_TRACK]->(t)

WITH * UNWIND 
CASE apoc.meta.type(_event._persons._person) WHEN 'LIST' THEN _event._persons._person ELSE [_event._persons._person] END AS _person
WITH * WHERE NOT _person.id IS NULL
MERGE (p:Person {id:_person.id}) SET p.name = _person._text
MERGE (p)-[:PRESENTS]->(e);

MATCH (e:Event)-[:IN_TRACK]->(t:Track) where t.name = 'Keynotes' set e:Keynote;

MATCH p = (:Person)-[:PRESENTS]->(e:Event)-[:IN_TRACK]->(t:Track) 
WHERE t.name CONTAINS "Graph Systems" 
RETURN p;


call { 
  MATCH (e:Event) RETURN e.title as title
  UNION
  MATCH (k:Keynote) RETURN k.title as title
}
RETURN distinct name 
ORDER BY name DESC LIMIT 10;


UNWIND fosdem.graphIds() AS gid

CALL {
  USE fosdem.graph(gid)
  MATCH (:Event) return count(*) as c
}

RETURN sum(c);