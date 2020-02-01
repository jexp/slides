CALL apoc.load.xmlSimple("file://fosdem-2019.xml") YIELD value ;

CALL apoc.load.xmlSimple("file://fosdem-2020.xml") YIELD value ;

:use db2
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

match (e:Event)-[:IN_TRACK]->(t:Track) where t.name = 'Keynotes' set e:Keynote


MATCH p = (:Person)-[:PRESENTS]->(e:Event)-[:IN_TRACK]->(t:Track) 
WHERE t.name CONTAINS "Graph Systems" 
RETURN p;



MATCH p = (:Person)-[:PRESENTS]->(e:Event)-[:IN_TRACK]->(t:Track) 
WHERE t.name contains "Graph Systems" 
RETURN p LIMIT 25



unwind fosdem.graphIds() as gid

call {
use fosdem.graph(gid)
MATCH (:Event) return count(*) as c
}

return sum(c)