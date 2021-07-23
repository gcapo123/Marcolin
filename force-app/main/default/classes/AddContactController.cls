public without sharing class AddContactController {
    public AddContactController() {

    }

    @AuraEnabled
    public static boolean addContact(String firstname ,String lastname, String email, String phone, String userId) {
        

        try {
        
            User u = [SELECT AccountId, LanguageLocaleKey, LocaleSidKey, TimeZoneSidKey FROM User WHERE Id = :userId LIMIT 1];
            String accountId = u.AccountId;
            System.debug('AccountId: '+ AccountId);
            Account accountToUpdate = [SELECT Id FROM Account WHERE Id = :accountId LIMIT 1];

            Contact contactToInsert = new Contact (FirstName=firstname, LastName=lastname, Email=email, Phone=phone, AccountId=accountId);
            insert contactToInsert;

            User userToInsert = new User (Username=email, Email=email, FirstName=firstname, LastName=lastname, ContactId=contactToInsert.Id);
            userToInsert.ProfileId= [Select Id from Profile where name = 'Customer Community Plus User' LIMIT 1].id;

            String nickname = ((userToInsert.firstName != null && userToInsert.firstName.length() > 0) ? userToInsert.firstname.substring(0,1) : '' ) + userToInsert.lastName.substring(0,1);
            nickname += String.valueOf(Crypto.getRandomInteger()).substring(1,7);
            userToInsert.put('CommunityNickname', nickname);
            userToInsert.put('Alias', nickname);
            userToInsert.put('EmailEncodingKey', 'UTF-8');
            userToInsert.put('TimeZoneSidKey', u.TimeZoneSidKey);
            userToInsert.put('LanguageLocaleKey', u.LanguageLocaleKey);
            userToInsert.put('LocaleSidKey', u.LocaleSidKey);
            

            insert userToInsert;
            //String newUserId = Site.createPortalUser(userToInsert, accountId, null, true);
           
            PermissionSetAssignmentMethod(userToInsert.Id);

            return true;

        } catch (Exception e) {
            return false;
        }
    }

    @Future

    public static void PermissionSetAssignmentMethod(String userId){

        

        String PermissionSetId = [Select Id from PermissionSet where Name = 'Commerce_User' LIMIT 1].id;

            

        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = PermissionSetId, AssigneeId = userId);

        insert psa;

    }

}



    
