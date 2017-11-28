//Check
MATCH (n:Entity) RETURN "Entities", COUNT(n);
MATCH (n:Type) RETURN "Types", COUNT(n);

//IF need be
//DROP INDEX ON :Type(lid);
//DROP INDEX ON :Type(name);
//DROP INDEX ON :Entity(lid);
//DROP INDEX ON :Entity(name);
//DROP INDEX ON :Entity(score);



/////
//
// Types
//
/////

CREATE CONSTRAINT ON (t:Type) ASSERT t.lid IS UNIQUE;
CALL db.awaitIndex(":Type(lid)", 60*60);
RETURN "Created Types t.lid IS UNIQUE";

CREATE INDEX ON :Type(name);
CALL db.awaitIndex(":Type(name)", 60*60);
RETURN "Created Types index :Type(name)";



/////
//
// Entities
//
/////


CREATE CONSTRAINT ON (e:Entity) ASSERT e.lid IS UNIQUE;
CALL db.awaitIndex(":Entity(lid)", 60*60);
RETURN "Created :Entity(lid) IS UNIQUE";

CREATE INDEX ON :Entity(name);
CALL db.awaitIndex(":Entity(name)", 60*60);
RETURN "Created Entities index :Entity(name)";

CREATE INDEX ON :Entity(score);
CALL db.awaitIndex(":Entity(score)", 60*60);
RETURN "Created Entities index :Entity(score)";


//The following crashes the system
//MATCH (n:Entity)
//SET n.llid = toInteger(n.lid);
//CREATE INDEX ON :Entity(llid);
//CALL db.awaitIndex(":Entity(llid)", 60*60);
//CREATE CONSTRAINT ON (e:Entity) ASSERT e.llid IS UNIQUE;


/////
//
// Relations: Meta-Model
// To be done
//
/////


CREATE CONSTRAINT ON (e:Relation) ASSERT e.labelId IS UNIQUE;
CALL db.awaitIndex(":Relation(labelId)", 60*60);
RETURN "Created :Relation(labelId) IS UNIQUE";

CREATE INDEX ON :Relation(name);
CALL db.awaitIndex(":Relation(name)", 60*60);
RETURN "Created Relations index :Relation(name)";

CREATE INDEX ON :Relation(code);
CALL db.awaitIndex(":Relation(code)", 60*60);
RETURN "Created Relations index :Relation(code)";

CREATE INDEX ON :Relation(domain);
CALL db.awaitIndex(":Relation(domain)", 60*60);
RETURN "Created Relations index :Relation(domain)";

/////
//
// Summary
//
/////


CALL db.constraints;
CALL db.indexes;



