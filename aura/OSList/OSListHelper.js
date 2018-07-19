({
    "getElements" : function(cmp, evt, Id, cmpToRender) {
        console.log("Id: " + Id);
        var action = cmp.get("c.OSElement");
        action.setParams({ omniscriptId : Id });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("OSElements: ");
                console.dir(response.getReturnValue());
                if ($A.util.isEmpty(response.getReturnValue()) == false) {
                    var elements = response.getReturnValue();
                    cmp.set("v." + cmpToRender, elements);
                    if (cmpToRender == "OSElementsTarget")
                        this.compareArrays(cmp, evt);
                    console.log("printing...");
                } else {
                    console.log("Empty Elements List");
                }
            }
            else if (state === "INCOMPLETE") {
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
    },
    "getTargetOrgVersion" : function(cmp, evt, name) {
        console.log("NameHelper: " + name);
        var action = cmp.get("c.OSListTargetOrg");
        action.setParams({ OSName : name });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("OSElements: ");
                console.dir(response.getReturnValue());
                if ($A.util.isEmpty(response.getReturnValue()) == false) {
                    //cmp.set("v." + cmpToRender, response.getReturnValue());
                    console.dir(response.getReturnValue());
                    console.log("printing...");
                } else {
                    console.log("Empty Elements List");
                }
            }
            else if (state === "INCOMPLETE") {
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
    },
    "compareArrays" : function(cmp, evt) {
        var origin = cmp.get("v.OSElementsOrigin");
        var target = cmp.get("v.OSElementsTarget");
        
        for (var i = 0 ; i < origin.length ; i++) {
            origin[i].doNotExist = "border:solid 2px #99ff33;";
            for (var j = 0 ; j < target.length ; j++) {
                if (origin[i].Name == target[j].Name) {
                    origin[i].doNotExist = "";
                    if (origin[i].vlocity_cmt__PropertySet__c != target[j].vlocity_cmt__PropertySet__c) {
                        origin[i].different = "border:solid 2px #ffff00;";
                        target[j].different = "border:solid 2px #ffff00;";
                        break;
                    } else {
                        
                    } //#99ff33 green #ff0000 red
                }
            }
        }
        
        for (var i = 0 ; i < target.length ; i++) {
            target[i].deleted = "border:solid 2px #ff0000;";
            for (var j = 0 ; j < origin.length ; j++) {
                if (target[i].Name == origin[j].Name) {
                    target[i].deleted = "";
                }
            }
        }
        
        /*var obj = {
                            "vlocity_cmt__Element__c" : {
                                "CreatedBy" : {"Name": null, "Id": null},
                                "CreatedById" : null,
                                "CreatedDate" : null,
                                "Id" : null,
                                "Name" : null,
                                "vlocity_cmt__Active__c" : false,
                                "vlocity_cmt__Level__c" : -1,
                                "vlocity_cmt__OmniScriptId__c" : null,
                                "vlocity_cmt__OmniScriptId__r" : null,
                                "vlocity_cmt__Order__c" : -1,
                                "vlocity_cmt__PropertySet__c" : "",
                                "vlocity_cmt__ReusableOmniScript__c" : false,
                                "vlocity_cmt__Type__c" : null
                            }
                        };
                        target.splice(i, 0, obj);*/
        console.dir(origin);
        cmp.set("v.OSElementsOrigin", origin);
    },
})