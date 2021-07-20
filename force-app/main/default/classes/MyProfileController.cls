public with sharing class MyProfileController {
    public MyProfileController() {

    }

    @AuraEnabled(cacheable = true)
    public static String getUserInfo(String userId){
        try {
            
            Map<String,String> result=new Map<String,String>();
            User u = [SELECT Name,Username,Email,AccountId,ContactId,FullPhotoUrl,LanguageLocaleKey,TimeZoneSidKey FROM User WHERE Id=:userId LIMIT 1];
            String labelLanguage = [SELECT toLabel(LanguageLocaleKey) FROM User WHERE Id =:userId].LanguageLocaleKey;
            String labelTimezone = [SELECT toLabel(TimeZoneSidKey) FROM User WHERE Id =:userId].TimeZoneSidKey;
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
            result.put('language',labelLanguage);
            result.put('languageId',u.LanguageLocaleKey);
            result.put('timezone',labelTimezone);
            result.put('timezoneId',u.TimeZoneSidKey);
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

    @AuraEnabled(cacheable = true)
    public static String getLanguagePicklist(){
        try {

            Map<String,String> picklistValuesList = new Map<String,String>();
            Schema.SObjectType convertToObj = Schema.getGlobalDescribe().get('User');
            Schema.DescribeSObjectResult res = convertToObj.getDescribe();
            Schema.DescribeFieldResult fieldResult;
            fieldResult = res.fields.getMap().get('LanguageLocaleKey').getDescribe();
            for(Schema.PicklistEntry lang: fieldResult.getPicklistValues()){
                picklistValuesList.put(lang.getValue(),lang.getLabel());
            }
            return JSON.serialize(picklistValuesList);
        } catch (Exception e) {
            return null;
        }
    }

    @AuraEnabled(cacheable = true)
    public static String getTimezonePicklist(){
        try {

            Map<String,String> picklistValuesList = new Map<String,String>();
            Schema.SObjectType convertToObj = Schema.getGlobalDescribe().get('User');
            Schema.DescribeSObjectResult res = convertToObj.getDescribe();
            Schema.DescribeFieldResult fieldResult;
            fieldResult = res.fields.getMap().get('TimeZoneSidKey').getDescribe();
            for(Schema.PicklistEntry timezone: fieldResult.getPicklistValues()){
                picklistValuesList.put(timezone.getValue(),timezone.getLabel());
            }
            return JSON.serialize(picklistValuesList);
        } catch (Exception e) {
            return null;
        }
    }


    
}
