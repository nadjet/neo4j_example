// Create graph from athletes csv
// csv download from kaggle: https://www.kaggle.com/heesoo37/120-years-of-olympic-history-athletes-and-results
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 1. athlete nodes: row id is the athlete's unique identifier
CREATE CONSTRAINT ON (a:Athlete) ASSERT a.id is UNIQUE;
USING PERIODIC COMMIT LOAD CSV WITH HEADERS FROM 'file:///athlete_events.csv' as row FIELDTERMINATOR ',' MERGE (:Athlete {id:toInt(row.ID), sex:row.Sex, name:row.Name,height:row.Height, weight:row.Weight});


///////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 2. game nodes
CREATE CONSTRAINT ON (g:Game) ASSERT g.name is UNIQUE;
USING PERIODIC COMMIT LOAD CSV WITH HEADERS FROM 'file:///athlete_events.csv' as row FIELDTERMINATOR ',' MERGE (:Game {name:row.Games,year:row.Year,season:row.Season});

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 3. event nodes
CREATE CONSTRAINT ON (e:Event) ASSERT e.name is UNIQUE;
USING PERIODIC COMMIT LOAD CSV WITH HEADERS FROM 'file:///athlete_events.csv' as row FIELDTERMINATOR ',' MERGE (:Event {name:row.Event});

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 4. sport nodes
CREATE CONSTRAINT ON (s:Sport) ASSERT s.name is UNIQUE;
USING PERIODIC COMMIT LOAD CSV WITH HEADERS FROM 'file:///athlete_events.csv' as row FIELDTERMINATOR ',' MERGE (:Sport {name:row.Sport});

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 5. relation between event and sport
USING PERIODIC COMMIT LOAD CSV WITH HEADERS FROM 'file:///athlete_events.csv' as row FIELDTERMINATOR ',' MATCH (s:Sport {name:row.Sport}),(e:Event {name:row.Event}) MERGE (e)-[:HAS_SPORT]->(s);

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 6. team nodes
CREATE CONSTRAINT ON (t:Team) ASSERT t.name is UNIQUE;
USING PERIODIC COMMIT LOAD CSV WITH HEADERS FROM 'file:///athlete_events.csv' as row FIELDTERMINATOR ',' MERGE (:Team {name:row.Team});


///////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 7. medal nodes
CREATE CONSTRAINT ON (m:Medal) ASSERT m.type is UNIQUE;
USING PERIODIC COMMIT LOAD CSV WITH HEADERS FROM 'file:///athlete_events.csv' as row FIELDTERMINATOR ',' MERGE (:Medal {type:row.Medal});


///////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 8. participation nodes to model relation between a game, an athlete, an optional medal, a team and an event
CREATE CONSTRAINT ON (p:Participation) ASSERT p.id is UNIQUE;
USING PERIODIC COMMIT LOAD CSV WITH HEADERS FROM 'file:///athlete_events.csv' as row FIELDTERMINATOR ',' CREATE (:Participation {athlete:toInt(row.ID), event:row.Event, game:row.Games, team:row.Team, medal:row.Medal, id:toInt(row.rowNumber)});


///////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 9. relations between participation and athlete, event, game, team, medal

// relation between participation and athlete - athlete's age at the time of the specific Gate is recorded on the relation between that Gate and the athlete
USING PERIODIC COMMIT LOAD CSV WITH HEADERS FROM 'file:///athlete_events.csv' as row FIELDTERMINATOR ',' MATCH (participation:Participation {id:toInt(row.rowNumber)}) , (a:Athlete {id:toInt(row.ID)}) MERGE (participation)-[:HAS_ATHLETE{age:row.Age}]->(a);

// relation between participation and event
USING PERIODIC COMMIT LOAD CSV WITH HEADERS FROM 'file:///athlete_events.csv' as row FIELDTERMINATOR ',' MATCH (participation:Participation {id:toInt(row.rowNumber)}) , (e:Event {name:row.Event}) MERGE (participation)-[:HAS_EVENT]->(e);

// relation between participation and game
USING PERIODIC COMMIT LOAD CSV WITH HEADERS FROM 'file:///athlete_events.csv' as row FIELDTERMINATOR ',' MATCH (participation:Participation {id:toInt(row.rowNumber)}) , (g:Game {name:row.Games}) MERGE (participation)-[:HAS_GAME{city:row.City}]->(g);

// relation between participation and team
USING PERIODIC COMMIT LOAD CSV WITH HEADERS FROM 'file:///athlete_events.csv' as row FIELDTERMINATOR ',' MATCH (participation:Participation {id:toInt(row.rowNumber)}) , (t:Team {name:row.Team}) MERGE (participation)-[:HAS_TEAM]->(t);

// relation between participation and medal
USING PERIODIC COMMIT LOAD CSV WITH HEADERS FROM 'file:///athlete_events.csv' as row FIELDTERMINATOR ',' MATCH (participation:Participation {id:toInt(row.rowNumber)}) , (m:Medal {type:row.Medal}) MERGE (participation)-[:HAS_MEDAL]->(m);

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 10. A bit of cleaning
MATCH (n:Athlete) WHERE n.height="NA" REMOVE n.height;
MATCH (n:Athlete) WHERE n.weight="NA" REMOVE n.weight;
MATCH (n:Athlete) WHERE n.weight="NA" REMOVE n.weight;
MATCH ()-[r:HAS_MEDAL]->(:Medal{type:"NA"}) DELETE r;
MATCH (m:Medal{type:"NA"}) DELETE m;
MATCH (n:Participation) WHERE n.medal="NA" REMOVE n.medal;