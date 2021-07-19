global without sharing class LightningLoginFormController {

    public LightningLoginFormController() {
        
    }


    @AuraEnabled
    public static String login(String username, String password, String startUrl) {

        if(username == null || String.isEmpty(username)) {
            return Label.email_is_required;
        }

        if(!Pattern.matches('^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+$', username.toLowerCase())) {
            return Label.email_invalid;
        }

        if(password == null || String.isEmpty(password)) {
            return Label.password_required;
        }

        

        
        Savepoint sp = null;
        try {
            ApexPages.PageReference lgn = Site.login(username, password, startUrl);
            if(lgn == null ){ 
              //return null;
               ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info, '* You\'ve entered an incorrect username and/or password. Please re-enter your log-in information.'));
            }


           

            
            System.debug('Login is successful: ' + username);

            sp = Database.setSavepoint();
            /**
             * We recover the user's accountid and then we update the Status 
             */
            

            Id accountId = [SELECT AccountId FROM User WHERE Username = :username LIMIT 1].AccountId;
            System.debug('Username: ' + username + ', AcconutId: '+ accountId);
            Account accountToUpdate = [SELECT Id, Status__c FROM Account WHERE Id = :accountId LIMIT 1];
            accountToUpdate.Status__c = 'Active';
            update accountToUpdate;
            System.debug('Update completed - Username: ' + username + ', AcconutId: '+ accountId);

            System.debug('Id: ' + accountId + ', BuyerId: '+ accountId);
            buyerAccount buyerAccountoUpdate = [SELECT Id, BuyerStatus FROM buyerAccount WHERE BuyerId = :accountId LIMIT 1];
            buyerAccountoUpdate.BuyerStatus = 'Attivo';
            update buyerAccountoUpdate;
            System.debug('Update completed - Id: ' + accountId + ', BuyerId '+ accountId);

            
            aura.redirect(lgn);
            return null;
        }
        catch(System.DmlException e) {
            Database.rollback(sp);
            System.debug('DmlException caught: ' + e.getMessage());
            return 'Please contact system administrator';
        }
        catch (Exception ex) {
            System.debug('Error login - Username: ' + username);
            return ex.getMessage();            
        }
    }

    
    @AuraEnabled
    public static Boolean getIsUsernamePasswordEnabled() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getUsernamePasswordEnabled();
    }

    @AuraEnabled
    public static Boolean getIsSelfRegistrationEnabled() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getSelfRegistrationEnabled();
    }

    @AuraEnabled
    public static String getSelfRegistrationUrl() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        if (authConfig.getSelfRegistrationEnabled()) {
            return authConfig.getSelfRegistrationUrl();
        }
        return null;
    }

    @AuraEnabled
    public static String getForgotPasswordUrl() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getForgotPasswordUrl();
    }
    
    @TestVisible
    private static Auth.AuthConfiguration getAuthConfig(){
        Id networkId = Network.getNetworkId();
        Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(networkId,'');
        return authConfig;
    }

    @AuraEnabled
    global static String setExperienceId(String expId) {
        // Return null if there is no error, else it will return the error message 
        try {
            if (expId != null) {
                Site.setExperienceId(expId);
            }
            return null; 
        } catch (Exception ex) {
            return ex.getMessage();            
        }
    }
       
}