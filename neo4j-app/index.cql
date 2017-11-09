
CREATE INDEX ON :Type(lid);
CREATE INDEX ON :Type(name);
// CREATE CONSTRAINT ON (t:Type) ASSERT t.lid IS UNIQUE;

CALL db.awaitIndex(":Type(name)");
CALL db.awaitIndex(":Type(lid)");

CREATE INDEX ON :Entity(lid);
CREATE INDEX ON :Entity(name);
//CREATE CONSTRAINT ON (e:Entity) ASSERT e.lid IS UNIQUE;

CALL db.awaitIndex(":Entity(name)");
CALL db.awaitIndex(":Entity(lid)");
