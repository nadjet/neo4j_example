// 1. We return all nodes and relation between them (only viable if you have view)
MATCH (n) RETURN n;

// 2. We find athletes
MATCH (n:Athlete) RETURN n;

// 3. We find events and their sport, returning the whole path = nodes with edges between them
MATCH p=()-[:HAS_SPORT]->() RETURN p;

// 4. We find female athletes: option 1
MATCH (n:Athlete{sex:"F"}) RETURN n;


// 5. We find female athletes: option 2
MATCH (n:Athlete) WHERE n.sex="F" RETURN n;

// 6. Counting nodes and renaming results
MATCH (n) RETURN count(n) AS how_many;

// 7. limit the results
MATCH (n:Athlete) RETURN n limit 2;

// 8. some condition on properties with conjunction
MATCH (n:Athlete) WHERE n.sex="F" AND n.height>180 RETURN n;


// 9. looking for a specific id
MATCH (n) WHERE id(n)=92 RETURN n;

// 10. negating existence + disjunction
MATCH (n:Athlete) WHERE NOT EXISTS(n.height) OR NOT EXISTS(n.weight) RETURN n;

// 11. Instead of negating existence, we can check if value is NULL
MATCH (n:Athlete) WHERE n.height is NULL RETURN n;

// 12. if no uniqueness constraint on property "name", then you can create the same even twice
CREATE (:Event {name:"Basketball Men's Basketball"});

// 13. we create unique contraint: we'll get a fail if we create a duplicate node as in 11 above.
CREATE CONSTRAINT ON (e:Event) ASSERT e.name is UNIQUE;

// 14. With "merge", we only create a node if it does not exist
MERGE (:Event {name:"Basketball Men's Basketball"});

// 15. !!!!Caution though: if we merge a relation between 2 nodes, if any of the info does not exist, all the nodes and relations will be created
// so that's ok
MERGE (:Event {name:"Basketball Men's Basketball"})-[:HAS_SPORT]->(:Sport)
// that creates nodes + relation, because the sports node does not exists ("Basket ball" is misspelt)
MERGE (:Event {name:"Basketball Men's Basketball"})-[:HAS_SPORT]->(:Sport{name:"Basket ball"})
// the solution is to be extra-careful, matching the nodes before merging the relation
MATCH (e:Event {name:"Basketball Men's Basketball"}),(s:Sport{name:"Basket ball"}) MERGE (e)-[:HAS_SPORT]->(s);

// 16. We add a new attribute, body mass index (bmi) which is the weight in kg divided by double the the height in meters
MATCH (a:Athlete) WHERE a.height is not NULL AND a.weight is not NULL SET a.bmi=toInt(a.weight/((a.height/100)*(a.height/100)));

// 17. We delete the attribute
MATCH (a:Athlete) REMOVE a.bmi;

// Now for the queries downwards we need to upload the full csv with bulk_loading.cyp (after deleting the db and replacing csv with full one in import folder)

// 18. Who is the tallest: embedded queries
MATCH (a:Athlete) WITH max(a.height) as max_height MATCH (b:Athlete) WITH b, max_height WHERE b.height=max_height RETURN b;

// 19. Number of athletes with gold medals
MATCH (a:Athlete)<-[:HAS_ATHLETE]-(n:Participation)-[:HAS_MEDAL]->(:Medal{type:"Gold"}) return count(distinct a);

// 20. Recursive paths: an athlete's sport
MATCH p=(:Athlete)-[*]-(:Sport) RETURN p LIMIT 1;

// 21. top 10 sports with most events + their listing
MATCH (s:Sport)<-[:HAS_SPORT]-(e:Event) return s.name as sport,COUNT(e) as num_events, collect(e.name) as events ORDER BY num_events DESC LIMIT 10


// 22. page rank: apply page range on all nodes and all properties: calculates page rank measure and assign it as a property called "pagerank" on nodes.
CALL algo.pageRank(null, null,
  {iterations:20, dampingFactor:0.85, write: true,writeProperty:"pagerank"})
YIELD nodes, iterations, loadMillis, computeMillis, writeMillis, dampingFactor, write, writeProperty

// so now we can look at sports with most incoming links: does not fully correlate with number of participations
MATCH (n:Sport)-[]-(p) RETURN n, count(p) as num_participations order by n.pagerank desc limit 10

// 23. to get available procedures
CALL dbms.procedures()
