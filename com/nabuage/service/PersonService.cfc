
component displayname="PersonService" {
    public function init(required string dsn) {
        VARIABLES.manager = new org.nabuage.etm.EntityManager(ARGUMENTS.dsn);
        return this;
    }

    public com.entity.Person getPersonById(required numeric id) {
        var person = new com.nabuage.entity.Person();

        VARIABLES.manager.load(person, ARGUMENT.id);

        if (person.isNull()) {
            throw(message = "Record is not found.");
        }

        return person;
    }

    public numeric function create(required string firstName, required string lastName, required string gender) {
        var person = new com.nabuage.entity.Person();
        person.setFirstName(ARGUMENTS.firstName);
        person.setLastName(ARGUMENTS.lastName);
        person.setGender(ARGUMENTS.gender);
        person.setDateAdded(Now());

        VARIABLES.manager.insert(person, true);

        return person.getId();
    }

    public void function update(required numeric id, required string firstName, required string lastName, required string gender) {
        var person = getPersonById(ARGUMENTS.id);

        person.setFirstName(ARGUMENTS.firstName);
        person.setLastName(ARGUMENTS.lastName);
        person.setGender(ARGUMENTS.gender);
        person.setDateModified(Now());

        VARIABLES.manager.update(person);
    }

    public void function delete(required numeric id) {
        var person = new com.nabuage.entity.Person();

        VARIABLES.flagAsDeleted(person, [ARGUMENTS.id]);
    }

    public array searchPerson(required string firstName, required string lastName, required string gender) {
        var person = new com.nabuage.entity.Person();
        
        if (Trim(ARGUMENTS.firstName) != "") {
            person.setFirstName(ARGUMENTS.firstName);
        }
        if (Trim(ARGUMENTS.lastName) != "") {
            person.setLastName(ARGUMENTS.lastName);
        }
        if (Trim(ARGUMENTS.gender) != "") {
            person.setGender(ARGUMENTS.gender);
        }

        return VARIABLES.getByEntity(person);
    }

    
}