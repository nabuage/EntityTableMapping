
component extends="org.nabuage.etm.AbstractEntity" {
    public function init(){
        super.init("address");
        super.setIdentifier("address_id");
        super.setSelectNullIdentifierList("date_deleted");
        
        VARIABLES.columns.id = create(name="address_id", type="CF_SQL_NUMERIC");
        VARIABLES.columns.address = create(name="address", type="CF_SQL_VARCHAR");
        VARIABLES.columns.address2 = create(name="address2", type="CF_SQL_VARCHAR");
        VARIABLES.columns.state = create(name="state", type="CF_SQL_VARCHAR");
        VARIABLES.columns.postalCode = create(name="postal_code", type="CF_SQL_VARCHAR");
        VARIABLES.columns.country = create(name="country", type="CF_SQL_VARCHAR");
        VARIABLES.columns.dateAdded = create(name="date_added", type="CF_SQL_TIMESTAMP");
        VARIABLES.columns.dateModified = create(name="date_modified", type="CF_SQL_TIMESTAMP");
        VARIABLES.columns.dateDeleted = create(name="date_deleted", type="CF_SQL_TIMESTAMP");

        return this;
    }
}