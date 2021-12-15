
component extends="testbox.system.BaseSpec" {
    function beforeAll() {
        manager = createMock("org.nabuage.etm.EntityManager");
        manager.init("");

        queryService = getProperty(manager, "queryService", "VARIABLES");

        qService = new Query();
        prepareMock(qService);
        qService.setDatasource("nabotm");
        
    }

    function afterAll() {
        
    }

    function run() {
        scenario("Manager", function() {

            describe("addComma", function() {

                it("can add comma on non-empty string", function() {
                    var sql = "SELECT first_name";
    
                    makePublic(manager, "addComma");
                    
                    expect(manager.addComma(sql)).toBe(sql & ", ");
                });
    
                it("can return same string", function() {
                    var sql = "";
    
                    makePublic(manager, "addComma");
                    
                    expect(manager.addComma(sql)).toBe(sql);
                });

            });
            describe("addAnd", function() {

                it("can add AND on non-empty string", function() {
                    var sql = "WHERE first_name = ''";
    
                    makePublic(manager, "addAnd");
                    
                    expect(manager.addAnd(sql)).toBe(sql & " AND ");
                });
    
                it("can return same string", function() {
                    var sql = "";
    
                    makePublic(manager, "addAnd");
                    
                    expect(manager.addAnd(sql)).toBe(sql);
                });

            });

            describe("getGuid", function() {

                it("can return guid", function() {
                    var mockQuery = querySim("guid
                    1234567890qwertyuiopasdfghjklzxc");

                    var manager1 = createMock("org.nabuage.etm.EntityManager");
                    manager1.init("");                    
                    
                    manager1.$("getResult", mockQuery);
                    
                    expect(manager1.getGuid()).toBe("1234567890qwertyuiopasdfghjklzxc");
                });

            });

            describe("addParameter", function() {

                beforeEach(function() {
                    manager.clearParameters();
                });

                it("can add parameter", function() {                    
                    manager.addParameter("first_name", "first", "cf_sql_varchar");

                    expect(!queryService.getParams().isEmpty()).toBeTrue();
                    expect(queryService.getParams().len()).toBe(1);
                    
                });

                it("can add parameter 2 times", function() {
                    manager.addParameter("first_name", "first", "cf_sql_varchar");
                    manager.addParameter("first_name", "first", "cf_sql_varchar");

                    expect(!queryService.getParams().isEmpty()).toBeTrue();
                    expect(queryService.getParams().len()).toBe(2);
                    
                });

            });

            describe("clearParameters", function() {

                beforeEach(function() {
                    manager.addParameter("first_name", "first", "cf_sql_varchar");
                });

                it("can clear parameters", function() {
                    manager.clearParameters();

                    expect(queryService.getParams().isEmpty()).toBeTrue();
                    
                });

            });

            describe("addParameters", function() {

                beforeEach(function() {
                    manager.clearParameters();
                    makePublic(manager, "addParameters");
                });

                it("can add parameters", function() {     
                    var parameters = [
                        {
                            name: "first_name",
                            value: "first",
                            cfsqltype: "cf_sql_varchar"
                        },
                        {
                            name: "last_name",
                            value: "last",
                            cfsqltype: "cf_sql_varchar"
                        }
                    ];         
                    manager.addParameters(parameters);

                    expect(!queryService.getParams().isEmpty()).toBeTrue();
                    expect(queryService.getParams().len()).toBe(2);
                    expect(queryService.getParams()[1].null).toBeFalse();
                    expect(queryService.getParams()[1].list).toBeFalse();
                    
                });

                it("can add parameters, is null", function() {     
                    var parameters = [
                        {
                            name: "first_name",
                            value: "first",
                            cfsqltype: "cf_sql_varchar",
                            null: true
                        },
                        {
                            name: "last_name",
                            value: "last",
                            cfsqltype: "cf_sql_varchar",
                            null: true
                        }
                    ];         
                    manager.addParameters(parameters);

                    expect(!queryService.getParams().isEmpty()).toBeTrue();
                    expect(queryService.getParams().len()).toBe(2);
                    expect(queryService.getParams()[1].null).toBeTrue();
                    expect(queryService.getParams()[2].null).toBeTrue();
                    
                });

                it("can add parameters, is list", function() {     
                    var parameters = [
                        {
                            name: "first_name",
                            value: "first",
                            cfsqltype: "cf_sql_varchar",
                            list: true
                        },
                        {
                            name: "last_name",
                            value: "last",
                            cfsqltype: "cf_sql_varchar",
                            list: true
                        }
                    ];         
                    manager.addParameters(parameters);

                    expect(queryService.getParams().isEmpty()).toBeFalse();
                    expect(queryService.getParams().len()).toBe(2);
                    expect(queryService.getParams()[1].list).toBeTrue();
                    expect(queryService.getParams()[2].list).toBeTrue();
                    
                });

            });

            describe("execute", function() {
                it("can execute", function() {
                    var sql = "INSERT INTO PersonX(first_name, last_name) VALUES ('', '')"; 
                    var parameters = [
                        {
                            name: "first_name",
                            value: "first",
                            cfsqltype: "cf_sql_varchar",
                            list: true
                        },
                        {
                            name: "last_name",
                            value: "last",
                            cfsqltype: "cf_sql_varchar",
                            list: true
                        }
                    ];        
                    
                    qService.$("execute", createMock("result"));
                    manager.$property("queryService", "VARIABLES", qService);

                    manager.execute(sql, parameters);
                    
                    expect(qService.getParams().isEmpty()).toBeTrue();
                    
                });
            });

            describe("getResult", function() {
                // it("can get result", function() {
                //     var sql = "SELECT * FROM PERSONX"; 
                //     var parameters = [
                //         {
                //             name: "first_name",
                //             value: "first",
                //             cfsqltype: "cf_sql_varchar",
                //             list: true
                //         },
                //         {
                //             name: "last_name",
                //             value: "last",
                //             cfsqltype: "cf_sql_varchar",
                //             list: true
                //         }
                //     ];

                //     var mockQuery = querySim("first_name,last_name
                //     first|last");

                //     var manager1 = createMock("org.nabuage.etm.EntityManager");
                //     manager1.init("");

                //     var resultMock = createMock("result");
                //     resultMock.$("getResult", mockQuery);

                //     var queryServiceMock = new Query();
                //     prepareMock(queryServiceMock);
                //     queryServiceMock.setDatasource("nabotm");

                //     queryServiceMock.$("execute", resultMock);

                //     manager1.$property("queryService", "VARIABLES", queryServiceMock);

                //     expect(manager.getResult(sql, parameters)).toBe(mockQuery);
                    
                // });


                // it("can get result", function() {
                //     var sql = "SELECT * FROM PersonX"; 
                //     var parameters = [
                //         {
                //             name: "first_name",
                //             value: "first",
                //             cfsqltype: "cf_sql_varchar",
                //             list: true
                //         },
                //         {
                //             name: "last_name",
                //             value: "last",
                //             cfsqltype: "cf_sql_varchar",
                //             list: true
                //         }
                //     ];

                //     makePublic(manager, "queryService", "VARIABLES");

                //     queryServiceMock = manager.$property("queryService", "VARIABLES", createStub());
                //     queryServiceMock.$("execute");
                    
                //     manager.execute(sql, parameters);
                    
                //     expect(queryService.getParams().isEmpty()).toBeTrue();
                    
                // });
            });

            describe("load", function() {

                beforeEach(function() {
                    entity = new Entity();
                    mockQuery = querySim("entity_id,name,email
                    1|name|email@email.com");
                });

                it("can load entity or search by id", function() {
                    var sql = "SELECT entity_id, date_deleted, name, id, email FROM entity WHERE entity_id = :entity_id AND date_deleted IS NULL";
                    

                    manager.$("getResult", mockQuery);

                    manager.load(entity, 1);

                    expect(entity.getId()).toBe(1);
                    expect(entity.getName()).toBe("name");
                    expect(entity.getEmail()).toBe("email@email.com");
                    expect(manager.getGeneratedSQL()).toBe(sql);
                });
            });
            
            describe("getByEntity", function() {

                beforeEach(function() {
                    entity = new Entity();                    
                });

                it("can get entities by entity properties, search by name", function() {
                    var sql = "SELECT entity_id, date_deleted, name, id, email FROM entity WHERE date_deleted IS NULL AND name = :name";
                    var mockQuery = querySim("entity_id,name,email
                    1|name|email@email.com
                    2|name|email1@email.com");

                    entity.setName("name");

                    manager.$("getResult", mockQuery);

                    var entityArray = manager.getByEntity(entity);

                    expect(ArrayLen(entityArray)).toBe(2);
                    expect(manager.getGeneratedSQL()).toBe(sql);
                });

                it("can get entities by entity properties, search by id and name", function() {
                    var sql = "SELECT entity_id, date_deleted, name, id, email FROM entity WHERE entity_id = :entity_id AND date_deleted IS NULL AND name = :name";
                    var mockQuery = querySim("entity_id,name,email
                    1|name|email@email.com");

                    entity.setId(1);
                    entity.setName("name");

                    manager.$("getResult", mockQuery);

                    var entityArray = manager.getByEntity(entity);

                    expect(ArrayLen(entityArray)).toBe(1);
                    expect(manager.getGeneratedSQL()).toBe(sql);
                });
            });

            describe("loadByEntity", function() {

                beforeEach(function() {
                    entity = new Entity();                    
                });

                it("can get entity by entity properties, search by id", function() {
                    var sql = "SELECT entity_id, date_deleted, name, id, email FROM entity WHERE entity_id = :entity_id AND date_deleted IS NULL";
                    var mockQuery = querySim("entity_id,name,email
                    1|name|email@email.com");

                    entity.setId(1);

                    manager.$("getResult", mockQuery);

                    var entityArray = manager.getByEntity(entity);

                    expect(ArrayLen(entityArray)).toBe(1);
                    expect(entity.getId()).toBe(1);
                    expect(entity.getName()).toBe("name");
                    expect(entity.getEmail()).toBe("email@email.com");
                    expect(manager.getGeneratedSQL()).toBe(sql);
                });
            });

            describe("insert", function() {

                beforeEach(function() {
                    entity = new Entity();           
                });

                it("can insert entity, does not return identity", function() {
                    var sql = "INSERT INTO entity(name, email) VALUES(:name, :email)";
                    
                    entity.setName("name");
                    entity.setEmail("email@email.com");

                    manager.$("execute");

                    manager.insert(entity);

                    expect(entity.getId()).toBeNull();
                    expect(manager.getGeneratedSQL()).toBe(sql);
                });

                it("can insert entity, returns identity", function() {
                    var sql = "INSERT INTO entity(name, email) VALUES(:name, :email)";
                    var mockQuery = querySim("entity_id,name,email
                    1|name|email@email.com");

                    entity.setName("name");
                    entity.setEmail("email@email.com");


                    manager.$("execute");
                    manager.$("getResult", mockQuery);

                    manager.insert(entity, true);

                    expect(entity.getId()).toBe(1);
                    expect(manager.getGeneratedSQL()).toBe(sql);
                });
            });

            describe("update", function() {

                beforeEach(function() {
                    entity = new Entity();           
                });

                it("can update entity", function() {
                    var sql = "UPDATE entity SET name = :name, email = :email WHERE entity_id = :entity_id AND date_deleted IS NULL";
                    
                    entity.setId(1);
                    entity.setName("name");
                    entity.setEmail("email@email.com");

                    manager.$("execute");

                    manager.update(entity);

                    expect(manager.getGeneratedSQL()).toBe(sql);
                });
            });

            describe("flagAsDeleted", function() {

                beforeEach(function() {
                    entity = new Entity();           
                });

                it("can flag entity as deleted, single entity", function() {
                    var sql = "UPDATE entity SET date_deleted = :date_deleted_SET WHERE entity_id = :entity_id AND date_deleted IS NULL";
                    
                    manager.$("execute");

                    manager.flagAsDeleted(entity, [1]);

                    expect(manager.getGeneratedSQL()).toBe(sql);
                });

                it("can flag entity as deleted, multiple entities", function() {
                    var sql = "UPDATE entity SET date_deleted = :date_deleted_SET WHERE entity_id IN (:entity_id) AND date_deleted IS NULL";
                    
                    manager.$("execute");

                    manager.flagAsDeleted(entity, [1, 2]);

                    expect(manager.getGeneratedSQL()).toBe(sql);
                });
            });

            describe("updateEntityStringValue", function() {

                beforeEach(function() {
                    var mockQuery = querySim("entity_id,name,email
                    1|NULL|email@email.com");

                    entity = new Entity();                    

                    entity.loadRow(mockQuery);          
                });

                it("string value is updated", function() {
                    expect(manager.updateEntityStringValue("", entity.getName())).toBeTrue();
                });

                it("string value is not updated", function() {
                    entity.setName("");

                    expect(manager.updateEntityStringValue("", entity.getName())).toBeFalse();
                });
            });

            describe("updateEntityNumericValue", function() {

                beforeEach(function() {
                    var mockQuery = querySim("entity_id,name,email
                    1|NULL|email@email.com");

                    entity = new Entity();                    

                    entity.loadRow(mockQuery);          
                });

                it("numeric value is updated", function() {
                    expect(manager.updateEntityNumericValue(2, entity.getId())).toBeTrue();
                });

                it("numeric value is not updated", function() {

                    expect(manager.updateEntityNumericValue(1, entity.getId())).toBeFalse();
                });
            });

        });
        
    }
}