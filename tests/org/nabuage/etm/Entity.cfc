
component extends="org.nabuage.etm.AbstractEntity" {
    public function init(){
        super.init("entity");
        super.setIdentifier("entity_id");
        super.setSelectIdentifierList("name,email");
        super.setSelectNullIdentifierList("date_deleted");
        
        VARIABLES.columns = StructNew();
        VARIABLES.columns.id = create(name="entity_id", type="CF_SQL_NUMERIC");
        VARIABLES.columns.name = create(name="name", type="CF_SQL_VARCHAR");
        VARIABLES.columns.email = create(name="email", type="CF_SQL_VARCHAR");
        VARIABLES.columns.dateDeleted = create(name="date_deleted", type="CF_SQL_TIMESTAMP");

        return this;
    }

    public string function getName() {
        return get(VARIABLES.columns.name.name);
    }

    public void function setName(required string name) {
        set(VARIABLES.columns.name.name, ARGUMENTS.name);
    }

    public string function getEmail() {
        return get(VARIABLES.columns.email.name);
    }

    public void function setEmail(required string email) {
        set(VARIABLES.columns.email.name, ARGUMENTS.email);
    }
}