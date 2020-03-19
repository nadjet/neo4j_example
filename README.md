# Neo4j Graph Database for Olympic Athletes

This repository contains the input csv and Cypher queries to create and manipulate a graph database about olympic athletes in [Neo4j](https://neo4j.com/).

The original csv is a Kaggle Dataset available [here](https://www.kaggle.com/heesoo37/120-years-of-olympic-history-athletes-and-results), which was scraped from a sports enthusiasts website. The dataset is included in this present repository as (1) some irrelevant and/or duplicate rows were removed, (2) a row id is included as a column to be used a the unique property on the participation node (see below).

## Contents

1. `sample_creation.cyp` is a script that loads a small sample of the data with simplified relations, for illustration.

2. `queries.cyp` contains a series of queries to learn about Neo4j's query language Cypher. Most of them (up until and including query 17) can be performed on the sample graph database created with the script above. Queries illustrate the following: 
	- aggregation functions (e.g., count, collect), 
	- nodes identifiers,
	- adding and removing properties (with `SET` and `REMOVE`),  
	- recursive paths,
	- arithmetic operations,
	- the difference between `MERGE` and `CREATE`
	- the uniqueness constraint,
	- conjunction and disjunction operators,
	- negation and existence operators
	- `LIMIT` and `DISTINCT` keywords.
	- using the PageRank graph algorithm.
	
3. `deleting.cyp` contains some basic queries for deleting relations and nodes, as well as (in a comment) how to delete the entire graph database.

4. `bulk_loading.cyp` contains the sequence of queries to load the entire csv.

5. The zipped csv with the athletes' information.

## Data modeling

### Nodes

The following types of nodes are created: 

- **Athlete**: an athlete with their basic theoretically "immutable" information such as name, sex, height and weight.
- **Team**: e.g., "Denmark"
- **Game**: e.g., "Summer 1992"
- **Event**: e.g., "Sailing Women's Windsurfer"
- **Sport**: e.g.,"Sailing"
- **Medal**: with only 3 possible values: Gold, Silver and Bronze.
- **Participation**: see second paragraph below.

Searching information that is a property is more expensive than if it is a node. Also, for graph embeddings, what counts are nodes and edges, not properties. Therefore, for example, `Medal` is modelled as a node rather than a property.

The last type of node `Participation` represents the participation of an athlete in an event at a game for a team with an optional medal. This information is presented as relations to the appropriate nodes and also as properties.

A unique property constraint is created on team, game, event and sport's name property; medal type property; athlete identifier and participation identifier. Both athlete and participation identifiers come from the csv and are different from Neo4j's internal node identifier.

### Relations

The following relations are created:

- **HAS_SPORT**: from Event to Sport node, e.g., from "Sailing Women's Windsurfer" to "Sailing".
- **HAS_ATHLETE**, **HAS_GAME**, **HAS_TEAM** and **HAS_MEDAL**: from Participation to Athlete, Game, Team and Medal node. 

Some properties were assigned to relations. These are the age of the athlete on the **HAS_ATHLETE** relation, and the city on the **HAS_GAME** relation because a game can occur in different cities (thinking about it, this modelling is not optimal since the property is duplicated for every athlete's participation).


