({
    handleevent: function(component, event, helper) {
        
        component.set('v.myBreadcrumbsC', event.getParam('myBreadcrumbs'));
        component.set('v.activeElementC', event.getParam('activeElement'));
	}
})