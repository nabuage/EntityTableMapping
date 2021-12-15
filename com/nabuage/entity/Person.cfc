component extends="org.nabuage.etm.AbstractEntity" {
    public function init(){
        // set person table name
        super.init("person");

        // set unique identifier of person table
        super.setIdentifier("person_id");

        // use in WHERE clause to SELECT the inserted record
        super.setSelectIdentifierList("first_name,last_name,gender,date_added");

        // use in WHERE clause as 'date_deleted IS NULL'
        super.setSelectNullIdentifierList("date_deleted");
        
        // override the default mapping
        VARIABLES.columns.id = create(name="person_id", type="CF_SQL_NUMERIC");

        // additional mapping
        VARIABLES.columns.id = create(name="person_id", type="CF_SQL_NUMERIC");
        VARIABLES.columns.firstName = create(name="first_name", type="CF_SQL_VARCHAR");
        VARIABLES.columns.lastName = create(name="last_name", type="CF_SQL_VARCHAR");
        VARIABLES.columns.gender = create(name="gender", type="CF_SQL_VARCHAR");
        VARIABLES.columns.dateAdded = create(name="date_added", type="CF_SQL_TIMESTAMP");
        VARIABLES.columns.dateModified = create(name="date_modified", type="CF_SQL_TIMESTAMP");
        VARIABLES.columns.dateDeleted = create(name="date_deleted", type="CF_SQL_TIMESTAMP");

        return this;
    }    

    public string function getFirstName() {
        return get(VARIABLES.columns.firstName.name);
    }

    public void function setFirstName(required string firstName) {
        set(VARIABLES.columns.firstName.name, ARGUMENTS.firstName);
    }

    public string function getLastName() {
        return get(VARIABLES.columns.lastName.name);
    }

    public void function setLastName(required string lastName) {
        set(VARIABLES.columns.lastName.name, ARGUMENTS.lastName);
    }

    public string function getGender() {
        return get(VARIABLES.columns.gender.name);
    }

    public void function setGender(required string gender) {
        set(VARIABLES.columns.gender.name, ARGUMENTS.gender);
    }

    public date function getDateAdded() {
        return get(VARIABLES.columns.dateAdded.name);
    }

    public void function setDateAdded(required date dateAdded) {
        set(VARIABLES.columns.dateAdded.name, ARGUMENTS.dateAdded);
    }

    public date function getDateModified() {
        return get(VARIABLES.columns.dateModified.name);
    }

    public void function setDateModified(required date dateModified) {
        set(VARIABLES.columns.dateModified.name, ARGUMENTS.dateModified);
    }

    public date function getDateDeleted() {
        return get(VARIABLES.columns.dateDeleted.name);
    }

    public void function setDateDeleted(required date dateDeleted) {
        set(VARIABLES.columns.dateDeleted.name, ARGUMENTS.dateDeleted);
    }
}