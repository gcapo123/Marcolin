public with sharing class MyProfileController {
    public MyProfileController() {

    }

    @AuraEnabled(cacheable = true)
    public static String getUserInfo(String userId){
        try {
            
            Map<String,String> result=new Map<String,String>();
            User u = [SELECT Name,Username,Email,AccountId,ContactId,FullPhotoUrl FROM User WHERE Id=:userId LIMIT 1];
            Contact c = [SELECT Phone,Email FROM Contact WHERE Id =:u.ContactId];
            Account a = [SELECT Name,BillingCountry FROM Account WHERE Id =:u.AccountId];
            result.put('name',u.Name);
            result.put('username',u.Username);
            //result.put('id',u.Id);
            result.put('email',u.Email);
            result.put('profilePic',u.FullPhotoUrl);
            result.put('phone',c.Phone);
            result.put('company',a.Name);
            result.put('country',a.BillingCountry);
            //result.put('marketing','true');
            if(c.Email != u.Email){
                c.Email = u.Email;
                update c;
            }
            return JSON.serialize(result);
            
        } catch (Exception e) {
            return null;
        }
    }
}
