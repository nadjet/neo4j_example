// DELETE ALL: you must first delete the relations before the nodes

MATCH ()-[r]-() DELETE r;

MATCH (n) DELETE n;

// To delete everything including property names, delete db in data/databases and restart neo4j