
component extends="org.nabuage.etm.AbstractEntity" {
    public function init(){
        super.init("person_address");
        super.setIdentifier("person_address_id");
        super.setSelectNullIdentifierList("date_deleted");
        
        VARIABLES.columns.id = create(name="person_address_id", type="CF_SQL_NUMERIC");
        VARIABLES.columns.personId = create(name="person_id", type="CF_SQL_NUMERIC");
        VARIABLES.columns.addressId = create(name="address_id", type="CF_SQL_NUMERIC");
        VARIABLES.columns.dateAdded = create(name="date_added", type="CF_SQL_TIMESTAMP");
        VARIABLES.columns.dateDeleted = create(name="date_deleted", type="CF_SQL_TIMESTAMP");

        return this;
    }
}