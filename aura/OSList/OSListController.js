({
	"doInit" : function(cmp) {
        var action = cmp.get("c.OSList");
        //action.setParams({ firstName : cmp.get("v.firstName") });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("OSNames: ");
                console.dir(response.getReturnValue());
                if ($A.util.isEmpty(response.getReturnValue()) == false) {
                    var omniscriptList = response.getReturnValue()
                	cmp.set("v.OSNames", omniscriptList);
                    
                    const nameSet = new Set();
                    for(var n in omniscriptList) {
                        nameSet.add(omniscriptList[n].Name);
                    }
                    let arr = Array.from(nameSet);
                    console.log('Set: ');
                    console.dir(arr);
                    cmp.set("v.OSNamesUnique", arr);
                } else {
                    console.log("Empty OS List");
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
    "getElements" : function(cmp) {
        
    },
    "selectedName" : function(cmp, evt) {
        cmp.set("v.OriginVersions", null);
        cmp.set("v.TargetVersions", null);
        cmp.set("v.OSElementsOrigin", null);
        cmp.set("v.OSElementsTarget", null);
        var name = cmp.find("Name").get("v.value");
        if (name != "none") {
            var names = cmp.get("v.OSNames");
            var versions = names.filter(function(names) {return names.Name == name});
            console.dir(versions);
            cmp.set("v.OriginVersions", versions);
            cmp.set("v.TargetVersions", versions);
        }
    },
    "selectedOrigin" : function(cmp, evt, helper) {
        var IdElement = cmp.find("origin").get("v.value");
        console.dir(name);
        if (name != "none") {
            var names = cmp.get("v.OSNames");
            var versions = names.filter(function(names) {return names.Id == IdElement});
            cmp.set("v.Origin", versions);
            console.log("Versions: ");
            console.dir(versions);
            helper.getElements(cmp, evt, versions[0].Id, "OSElementsOrigin");
        }
    },
    "selectedTarget" : function(cmp, evt, helper) {
        var IdElement = cmp.find("selectTargetOS").get("v.value");
        console.dir(name);
        if (name != "none") {
            var names = cmp.get("v.OSNames");
            var versions = names.filter(function(names) {return names.Id == IdElement});
            cmp.set("v.Target", versions);
            console.log("Versions: ");
            console.dir(versions);
            helper.getElements(cmp, evt, versions[0].Id, "OSElementsTarget");
        }
    },
})