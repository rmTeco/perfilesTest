/**
 * An apex page controller that exposes the change password functionality
 */
public with sharing class ChangePasswordController {
    public String oldPassword {get; set;}
    public String newPassword {get; set;}
    public String verifyNewPassword {get; set;}        
    
    public PageReference changePassword() {
        if((Site.isPasswordExpired() || (!Site.isPasswordExpired() && String.isNotBlank(oldpassword))) && String.isNotBlank(verifyNewPassword) && String.isNotBlank(newPassword)){
            return Site.changePassword(newPassword, verifyNewPassword, oldpassword); 
        }
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Debe completar todos los campos.'));
        return null;
    }     
    
    public ChangePasswordController() {}
}