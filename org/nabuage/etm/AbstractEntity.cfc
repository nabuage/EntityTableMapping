
/**
*
* @file  
* @author  George Arellano
* @description
*
*/

component output="false" displayname="AbstractEntity"  {

    public function init(required string tableName) {
        VARIABLES.tableName = ARGUMENTS.tableName;
		VARIABLES.entity = StructNew();
		VARIABLES.entityStruct = StructNew();
        // column name of the primary key
		VARIABLES.identifier = "";
        // use in WHERE clause to SELECT the inserted record
		VARIABLES.selectIdentifierList = "";
        // use in WHERE clause as 'date_deleted IS NULL'. Gets appended on SELECT WHERE clause.
		VARIABLES.selectNullIdentifierList = "";
		VARIABLES.isLoadedFromRow = false;
		VARIABLES.assignEmptyValueForTheseTypes = "CF_SQL_VARCHAR,CF_SQL_LONGVARCHAR,CF_SQL_CHAR";

        // map object/entity properties to table columns
        VARIABLES.columns = StructNew();
        // default mapping. Needs to be overriden.
        VARIABLES.columns.id = create(name="id", type="CF_SQL_NUMERIC");

        return this;
    }

    public numeric function getId() {
        return get(VARIABLES.columns.id.name);
    }

    public void function setId(required numeric id) {
        set(VARIABLES.columns.id.name, ARGUMENTS.id);
    }

    public void function setIdentifier(required string name) {
        VARIABLES.identifier = ARGUMENTS.name;
    }

    public string function getIdentifier() {
        return VARIABLES.identifier;
    }

    public void function setSelectIdentifierList(required string names) {
        VARIABLES.selectIdentifierList = ARGUMENTS.names;
    }

    public string function getSelectIdentifierList() {
        return VARIABLES.selectIdentifierList;
    }

    public void function setSelectNullIdentifierList(required string names) {
        VARIABLES.selectNullIdentifierList = ARGUMENTS.names;
    }

    public string function getSelectNullIdentifierList() {
        return VARIABLES.selectNullIdentifierList;
    }

    public boolean function isLoadedFromRow() {
        return VARIABLES.isLoadedFromRow;
    }

    public struct function create(required string name, required string type, any defaultValue = "NULL") {
        var entityProperty = StructNew();

		entityProperty.name = ARGUMENTS.name;
		entityProperty.type = ARGUMENTS.type;
		entityProperty.defaultValue = ARGUMENTS.defaultValue;
		entityProperty.isSet = false;
		entityProperty.isUpdated = false;
		entityProperty.isNull = true;

		VARIABLES.entity[ARGUMENTS.name] = entityProperty;

		return VARIABLES.entity[ARGUMENTS.name];
    }

    public void function set(required string name, required any value) {
        if (VARIABLES.entity[ARGUMENTS.name].isSet) {
            VARIABLES.entity[ARGUMENTS.name].isUpdated = true;
        }
        
        VARIABLES.entity[ARGUMENTS.name].isSet = true;

        if (ARGUMENTS.value EQ "") {
            if (ListFindNoCase(VARIABLES.assignEmptyValueForTheseTypes, VARIABLES.entity[ARGUMENTS.name].type) GT 0) {
                VARIABLES.entity[ARGUMENTS.name].isNull = false;
				VARIABLES.entity[ARGUMENTS.name].value = ARGUMENTS.value;
            }
        }
        else {
            VARIABLES.entity[ARGUMENTS.name].isNull = false;
		 	VARIABLES.entity[ARGUMENTS.name].value = ARGUMENTS.value;
        }
    }

    public any function get(required string name) {
        if (StructKeyExists(VARIABLES.entity, ARGUMENTS.name)) {
            if (NOT VARIABLES.entity[ARGUMENTS.name].isNull) {
                return VARIABLES.entity[ARGUMENTS.name].value;
            }
        }
    }

    public void function setNull(required string name) {
        VARIABLES.entity[ARGUMENTS.name].isUpdated = true;        
        VARIABLES.entity[ARGUMENTS.name].isSet = true;
        VARIABLES.entity[ARGUMENTS.name].isNull = true;
        VARIABLES.entity[ARGUMENTS.name].value = "";
    }

    public boolean function isNull() {
        if (StructKeyExists(VARIABLES.entity, getIdentifier())) {
            return VARIABLES.entity[getIdentifier()].isNull;
        }
        else {
            return false;
        }
    }

    public struct function getProperties() {
        return VARIABLES.entity;
    }

    public string function getTableName() {
        return VARIABLES.tableName;
    }

    public void function reset() {
        var property = "";

        for (property in VARIABLES.entity) {
            if (VARIABLES.entity[property].isSet OR VARIABLES.entity[property].isUpdated) {
                VARIABLES.entity[property].isSet = false;
				VARIABLES.entity[property].isUpdated = false;
				VARIABLES.entity[property].isNull = true;
				StructDelete(VARIABLES.entity[property], "value");
            }
        }
    }

    public void function loadRow(required query resultSet, numeric index = 1) {
        var property = "";

        for (property in VARIABLES.entity) {
            if (StructKeyExists(ARGUMENTS.resultSet, property)) {
                set(property, ARGUMENTS.resultSet[property][ARGUMENTS.index]);
            }            
        }

        VARIABLES.isLoadedFromRow = true;
    }

    public struct function rawEntity(boolean useNULLString = true) {
        var property = "";
		var rawEntity = StructNew();
		var value = "";

        for (property in VARIABLES.entity) {
            if (VARIABLES.entity[property].isNull) {
                if (ARGUMENTS.useNULLString) {
                    value = "NULL";
                }
                else {
                    value = "";
                }
            }
            else {
                value = VARIABLES.entity[property].value;
            }
            rawEntity[property] = value;
        }

        return rawEntity;
    }

    public boolean function getBooleanValue(any sourceValue, boolean defaultValue = false) {
        if (NOT isNull(sourceValue)) {
            return sourceValue;
        }
        else {
            return defaultValue;
        }
    }

    public numeric function getNumericValue(any sourceValue, numeric defaultValue = 0) {
        if (NOT isNull(sourceValue)) {
            return sourceValue;
        }
        else {
            return defaultValue;
        }
    }

    public string function getStringValue(any sourceValue, string defaultValue = "") {
        if (NOT isNull(sourceValue)) {
            return ToString(sourceValue);
        }
        else {
            return defaultValue;
        }
    }
}
