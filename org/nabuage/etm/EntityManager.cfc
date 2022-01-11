
/**
*
* @file  
* @author  George Arellano
* @description
*
*/

component output="false" displayname="Manager"  {

    public function init(required string dsn){
        VARIABLES.dsn = ARGUMENTS.dsn;
        VARIABLES.queryService = new Query(dataSource=VARIABLES.dsn, name="queryService");

        VARIABLES.stringCFSqlType = "CF_SQL_VARCHAR";

        VARIABLES.generatedSQL = "";

        return this;
    }

    private string function addComma(required string clause) {
        if (ARGUMENTS.clause NEQ "") {
            return ARGUMENTS.clause & ", ";
        }
        else {
            return ARGUMENTS.clause;
        }
    }

    private string function addAnd(required string clause) {
        if (ARGUMENTS.clause NEQ "") {
            return ARGUMENTS.clause & " AND ";
        }
        else {
            return ARGUMENTS.clause;
        }
    }

    public string function getGuid() {
        return getResult("SELECT newid() AS guid").guid[1];
    }

    public void function clearParameters() {
        VARIABLES.queryService.clearParams();
    }

    public void function addParameter(required string name, required any value, required string sqlType, boolean isNull = false, boolean isList = false) {
        VARIABLES.queryService.addParam(name=ARGUMENTS.name, value=ARGUMENTS.value, cfsqltype=ARGUMENTS.sqlType, NULL=ARGUMENTS.isNull, list=ARGUMENTS.isList);
    }

    private void function addParameters(required array parameters) {
        var counter = 0;
        for (counter = 1; counter LTE ArrayLen(ARGUMENTS.parameters); counter = counter + 1) {
            VARIABLES.queryService.addParam(name=ARGUMENTS.parameters[counter].name, value=ARGUMENTS.parameters[counter].value, cfsqltype=ARGUMENTS.parameters[counter].cfsqltype, NULL=(StructKeyExists(ARGUMENTS.parameters[counter], "null") AND ARGUMENTS.parameters[counter].null), list=(StructKeyExists(ARGUMENTS.parameters[counter], "list") AND ARGUMENTS.parameters[counter].list));
        }
    }

    public void function execute(required string sql, required array parameters) {
        VARIABLES.queryService.clearParams();
        addParameters(ARGUMENTS.parameters);
        VARIABLES.queryService.execute(SQL=ARGUMENTS.sql);
        VARIABLES.queryService.clearParams();
    }

    public query function getResult(required string sql, array parameters = ArrayNew(1)) {
        var result = "";

        VARIABLES.queryService.clearParams();
        addParameters(ARGUMENTS.parameters);
        result = VARIABLES.queryService.execute(SQL=ARGUMENTS.sql).getResult();
        VARIABLES.queryService.clearParams();

        return result;
    }

    public void function load(required AbstractEntity entity, required numeric id) {
        var result = "";
        var sql = "";
        var selectSQL = "";
        var whereSQL = "";
        var properties = ARGUMENTS.entity.getProperties();
        var property = "";
        var parameters = ArrayNew(1);
        var counter = 0;

        VARIABLES.generatedSQL = "";

        for (property in properties) {
            //Build the SELECT statement.
            
            selectSQL = addComma(selectSQL) & properties[property].name;

            if (properties[property].name EQ ARGUMENTS.entity.getIdentifier()) {
                //Build the WHERE statement for the id.
                counter = counter + 1;
                parameters[counter] = StructNew();
                parameters[counter].name = properties[property].name;
                parameters[counter].value = ARGUMENTS.id;
                parameters[counter].cfsqltype = properties[property].type;

                whereSQL = addAnd(whereSQL) & properties[property].name & " = :" & properties[property].name;
            }
            else {
                if (ListFindNoCase(ARGUMENTS.entity.getSelectNullIdentifierList(), properties[property].name) GT 0) {
                    //Build the WHERE statement for the entity property where it needs to be NULL.
                    whereSQL = addAnd(whereSQL) & properties[property].name & " IS NULL ";
                }
            }
        }

        if (selectSQL NEQ "" AND whereSQL NEQ "") {
            sql = "SELECT " & selectSQL & " FROM " & ARGUMENTS.entity.getTableName() & " WHERE " & whereSQL;

            result = getResult(sql, parameters);            

            if (result.recordcount GT 0) {
                //Set the property value of the ARGUMENTS.entity.
                ARGUMENTS.entity.loadRow(result);
            }
        }

        VARIABLES.generatedSQL = sql;
    }

    public void function loadByEntity(required AbstractEntity entity) {
        var entities = getByEntity(ARGUMENTS.entity);
        
        if (ArrayLen(entities) GT 0) {
            ARGUMENTS.entity = entities[1];
        }        
    }

    public array function getByEntity(required AbstractEntity entity) {
        var entities = ArrayNew(1);
        var result = "";
        var sql = "";
        var selectSQL = "";
        var whereSQL = "";
        var properties = ARGUMENTS.entity.getProperties();
        var property = "";
        var objectName = "";
        var parameters = ArrayNew(1);
        var counter = 0;

        VARIABLES.generatedSQL = "";

        for (property in properties) {
            //Build the SELECT statement.
            
            selectSQL = addComma(selectSQL) & properties[property].name;

            if (properties[property].name EQ ARGUMENTS.entity.getIdentifier() AND NOT properties[property].isNull) {
                //Build the WHERE statement for the id.
                
                counter = counter + 1;
                parameters[counter] = StructNew();
                parameters[counter].name = properties[property].name;
                parameters[counter].value = properties[property].value;
                parameters[counter].cfsqltype = properties[property].type;
                
                whereSQL = addAnd(whereSQL) & properties[property].name & " = :" & properties[property].name;
            }
            else {
                //Only use the properties/values in the WHERE clause if it is in the select and NULL identifiers.
                //The rest will be ignored or not used even if it is explicityly set.

                if (ListFindNoCase(ARGUMENTS.entity.getSelectIdentifierList(), properties[property].name) GT 0) {
                    //Build the WHERE statement for the entity property.

                    if (NOT properties[property].isNull) {
                        
                        counter = counter + 1;
                        parameters[counter] = StructNew();
                        parameters[counter].name = properties[property].name;
                        parameters[counter].value = properties[property].value;
                        parameters[counter].cfsqltype = properties[property].type;

                        whereSQL = addAnd(whereSQL) & properties[property].name & " = :" & properties[property].name;
                    }
                }
                else {
                    if (ListFindNoCase(ARGUMENTS.entity.getSelectNullIdentifierList(), properties[property].name) GT 0) {
                        //Build the WHERE statement for the entity property where it needs to be NULL.
                        whereSQL = addAnd(whereSQL) & properties[property].name & " IS NULL";
                    }
                }
            }
            
        }

        if (selectSQL NEQ "" AND whereSQL NEQ "") {
            
            sql = "SELECT " & selectSQL & " FROM " & ARGUMENTS.entity.getTableName() & " WHERE " & whereSQL;

            result = getResult(sql, parameters); 

            if (result.recordcount GT 0) {

                for (counter = 1; counter LTE result.recordcount; counter = counter + 1) {

                    if (counter EQ 1) {
                        ARGUMENTS.entity.reset();
                        //Set the property value of the ARGUMENTS.entity.
                        ARGUMENTS.entity.loadRow(result);
                        entities[1] = ARGUMENTS.entity;
                    }
                    else {
                        objectName = GetMetaData(ARGUMENTS.entity).fullname;
                        entities[counter] = CreateObject("component", objectName).init();
                        entities[counter].loadRow(result, counter);
                    }
                    
                }
                
            }
        }

        VARIABLES.generatedSQL = sql;

        return entities;
    }

    public function insert(required AbstractEntity entity, boolean returnId = false) {
        var result = "";
        var sql = "";
        var insertSQL = "";
        var valuesSQL = "";
        var whereSQL = "";
        var properties = ARGUMENTS.entity.getProperties();
        var property = "";
        var selectIdentifiers = StructNew();
        var selectNullIdentifiers = StructNew();
        var selectIdentifier = "";
        var parameters = ArrayNew(1);
        var counter = 0;

        VARIABLES.generatedSQL = "";

        for (property in properties) {
            
            //Build the INSERT SQL
            
            if (NOT properties[property].isNull) {
                //Only include the property/value that is explicityly set (not empty) into the INSERT statement.
                insertSQL = addComma(insertSQL) & properties[property].name;                        
                
                if (ListFindNoCase(VARIABLES.stringCFSqlType, properties[property].type) GT 0 AND properties[property].value EQ "") {
                    //This is a workaround because empty space is being added by CF.
                    valuesSQL = addComma(valuesSQL) & " NULL";
                }
                else {
                    valuesSQL = addComma(valuesSQL) & ":" & properties[property].name;
                    
                    counter = counter + 1;
                    parameters[counter] = StructNew();
                    parameters[counter].name = properties[property].name;
                    parameters[counter].value = properties[property].value;
                    parameters[counter].cfsqltype = properties[property].type;
                }
                
            }

            //Find the identifiers that will be used to get the id of the inserted record.
            if (ARGUMENTS.returnId) {
                if (ListFindNoCase(ARGUMENTS.entity.getSelectIdentifierList(), properties[property].name) GT 0 AND NOT properties[property].isNull) {
                    selectIdentifiers[properties[property].name] = properties[property];
                }                    

                if (ListFindNoCase(ARGUMENTS.entity.getSelectNullIdentifierList(), properties[property].name) GT 0 AND properties[property].isNull) {
                    selectNullIdentifiers[properties[property].name] = properties[property];
                }
            }
            
        }

        if (insertSQL NEQ "" AND valuesSQL NEQ "") {
            sql = "INSERT INTO " & ARGUMENTS.entity.getTableName() & "(" & insertSQL & ") VALUES(" & valuesSQL & ")";
            
            execute(sql, parameters);
            VARIABLES.queryService.clearParams();

            VARIABLES.generatedSQL = sql;
            
            //Find the id of the inserted record.
            //Assign it to the identifier of the ARGUMENTS.entity.
            if (ARGUMENTS.returnId AND ARGUMENTS.entity.getIdentifier() NEQ "") {
                counter = 0;
                for (selectIdentifier in selectIdentifiers) {
                    //Use the select identifiers to find the inserted ARGUMENTS.entity.
                    if (selectIdentifiers[selectIdentifier].isNull) {
                        whereSQL = addAnd(whereSQL) & selectIdentifiers[selectIdentifier].name & " IS NULL";
                    }
                    else {
                        if (ListFindNoCase(VARIABLES.stringCFSqlType, selectIdentifiers[selectIdentifier].type) GT 0 AND selectIdentifiers[selectIdentifier].value EQ "") {
                            whereSQL = addAnd(whereSQL) & selectIdentifiers[selectIdentifier].name & " IS NULL";
                        }
                        else {
                            whereSQL = addAnd(whereSQL) & selectIdentifiers[selectIdentifier].name & " = :" & selectIdentifiers[selectIdentifier].name;
                            
                            counter = counter + 1;
                            parameters[counter] = StructNew();
                            parameters[counter].name = selectIdentifier;
                            parameters[counter].value = selectIdentifiers[selectIdentifier].value;
                            parameters[counter].cfsqltype = selectIdentifiers[selectIdentifier].type;
                        }                        
                    }                    
                }

                for (selectIdentifier in selectNullIdentifiers) {
                    //Use the select NULL identifiers to find the inserted ARGUMENTS.entity.
                    whereSQL = addAnd(whereSQL) & selectNullIdentifiers[selectIdentifier].name & " IS NULL ";
                }

                sql = "SELECT " & ARGUMENTS.entity.getIdentifier() & " FROM " & ARGUMENTS.entity.getTableName() & " WHERE " & whereSQL;

                result = getResult(sql, parameters);

                if (result.recordcount GT 0) {
                    ARGUMENTS.entity.setId(result[ARGUMENTS.entity.getIdentifier()][1]);
                }
            }
            
        }
        
    }

    public function update(required AbstractEntity entity) {
        var sql = "";
        var setSQL = "";
        var whereSQL = "";
        var properties = ARGUMENTS.entity.getProperties();
        var property = "";
        var addToWhere = "";
        var parameters = ArrayNew(1);
        var counter = 0;

        VARIABLES.generatedSQL = "";

        //Only use the table id in the WHERE clause of UPDATE statement.
        if (ARGUMENTS.entity.getIdentifier() NEQ "") {
            addToWhere = ListAppend(addToWhere, ARGUMENTS.entity.getIdentifier());
        }
        
        for (property in properties) {
            if (ListFindNoCase(addToWhere, properties[property].name) GT 0) {
                //Build the WHERE clause of the UPDATE statement.

                if (properties[property].name EQ ARGUMENTS.entity.getIdentifier()) {
                    whereSQL = addAnd(whereSQL) & properties[property].name & " = :" & properties[property].name;
                    
                    counter = counter + 1;
                    parameters[counter] = StructNew();
                    parameters[counter].name = properties[property].name;
                    parameters[counter].value = properties[property].value;
                    parameters[counter].cfsqltype = properties[property].type;
                }
            }
            else {
                //Only include the column to be updated if it is actually been updated within the ARGUMENTS.entity.
                if ((NOT ARGUMENTS.entity.isLoadedFromRow() AND properties[property].isSet) OR (ARGUMENTS.entity.isLoadedFromRow() AND properties[property].isUpdated)) {
                    //Build the SET clause of the UPDATE statement.
                    
                    if (properties[property].isNull) {
                        setSQL = addComma(setSQL) & properties[property].name & " = NULL ";
                    }
                    else {
                        if (ListFindNoCase(VARIABLES.stringCFSqlType, properties[property].type) GT 0 AND properties[property].value EQ "") {
                            //This is a workaround because empty space is being added by CF.
                            setSQL = addComma(setSQL) & properties[property].name & " = NULL";                                                       
                        }
                        else {
                            setSQL = addComma(setSQL) & properties[property].name & " = :" & properties[property].name;
                            
                            counter = counter + 1;
                            parameters[counter] = StructNew();
                            parameters[counter].name = properties[property].name;
                            parameters[counter].value = properties[property].value;
                            parameters[counter].cfsqltype = properties[property].type;
                        }                        
                    }

                }

                if (ListFindNoCase(ARGUMENTS.entity.getSelectNullIdentifierList(), properties[property].name) GT 0) {
                    //Add the NULL identifiers into the WHERE clause. This is normally the date_deleted.
                    whereSQL = addAnd(whereSQL) & properties[property].name & " IS NULL ";
                }
            }
        }

        if (setSQL NEQ "" AND whereSQL NEQ "") {
            sql = "UPDATE " & ARGUMENTS.entity.getTableName() & " SET " & setSQL & " WHERE " & whereSQL;
            
            execute(sql, parameters);
        }

        VARIABLES.generatedSQL = sql;
    }

    public function flagAsDeleted(required AbstractEntity entity, required array ids) {
        var sql = "";
        var setSQL = "";
        var whereSQL = "";
        var properties = ARGUMENTS.entity.getProperties();
        var property = "";
        var addToWhere = "";
        var dateDeleted = Now();
        var parameters = ArrayNew(1);
        var counter = 0;

        VARIABLES.generatedSQL = "";

        if (ARGUMENTS.entity.getIdentifier() NEQ "" AND ARGUMENTS.entity.getSelectNullIdentifierList() NEQ "" AND ArrayLen(ARGUMENTS.ids) GT 0) {
            
            //Only use the table id in the WHERE clause of UPDATE statement.
            if (ARGUMENTS.entity.getIdentifier() NEQ "") {
                addToWhere = ListAppend(addToWhere, ARGUMENTS.entity.getIdentifier());
            }
            if (ARGUMENTS.entity.getSelectNullIdentifierList() NEQ "") {
                addToWhere = ListAppend(addToWhere, ARGUMENTS.entity.getSelectNullIdentifierList());
            }
            
            for (property in properties) {
                if (ListFindNoCase(addToWhere, properties[property].name) GT 0) {
                    //Build the WHERE clause of the UPDATE statement.

                    if (properties[property].name EQ ARGUMENTS.entity.getIdentifier()) {
                        counter = counter + 1;
                        parameters[counter] = StructNew();
                        parameters[counter].name = properties[property].name;
                        parameters[counter].value = ArrayToList(ARGUMENTS.ids);
                        parameters[counter].cfsqltype = properties[property].type;

                        if (ArrayLen(ARGUMENTS.ids) GT 1) {
                            whereSQL = addAnd(whereSQL) & properties[property].name & " IN (:" & properties[property].name & ")";
                            
                            parameters[counter].list = true;
                        }
                        else {
                            whereSQL = addAnd(whereSQL) & properties[property].name & " = :" & properties[property].name;
                        }                        
                    }
                    else {
                        if (ListFindNoCase(ARGUMENTS.entity.getSelectNullIdentifierList(), properties[property].name) GT 0) {
                            whereSQL = addAnd(whereSQL) & properties[property].name & " IS NULL ";

                            if (ListFindNoCase("CF_SQL_TIMESTAMP", properties[property].type) GT 0) {
                                if (NOT properties[property].isNull) {
                                    dateDeleted = properties[property].value;
                                }
                                setSQL = addComma(setSQL) & properties[property].name & " = :" & properties[property].name & "_SET";                    
                                
                                counter = counter + 1;
                                parameters[counter] = StructNew();
                                parameters[counter].name = properties[property].name & "_SET";
                                parameters[counter].value = dateDeleted;
                                parameters[counter].cfsqltype = properties[property].type;
                            }                            
                        }                        
                    }
                }
            }

            if (setSQL NEQ "" AND whereSQL NEQ "") {
                sql = "UPDATE " & ARGUMENTS.entity.getTableName() & " SET " & setSQL & " WHERE " & whereSQL;
                
                execute(sql, parameters);
            }

            VARIABLES.generatedSQL = sql;
        }        
    }

    public boolean function updateEntityStringValue(required string source, required any destination) {
        if ((ARGUMENTS.source NEQ "" AND isNull(ARGUMENTS.destination)) OR (NOT isNull(ARGUMENTS.destination) AND ARGUMENTS.source NEQ ARGUMENTS.destination)) {
            return true;
        }
        else {
            return false;
        }
    }

    public boolean function updateEntityNumericValue(required numeric source, required any destination) {
        if ((ARGUMENTS.source GT -1 AND isNull(ARGUMENTS.destination)) OR (NOT isNull(ARGUMENTS.destination) AND ARGUMENTS.source NEQ ARGUMENTS.destination)) {
            return true;
        }
        else {
            return false;
        }
    }

    public string function getGeneratedSQL() {
        return Trim(VARIABLES.generatedSQL);
    }
}
