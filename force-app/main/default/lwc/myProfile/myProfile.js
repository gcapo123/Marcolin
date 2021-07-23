import { LightningElement,wire,track,api } from 'lwc';
import Id from '@salesforce/user/Id';
import getUserInfo from '@salesforce/apex/MyProfileController.getUserInfo';
import getLanguagePicklist from '@salesforce/apex/MyProfileController.getLanguagePicklist';
import getTimezonePicklist from '@salesforce/apex/MyProfileController.getTimezonePicklist';
import errorMess from '@salesforce/label/c.MyProfile_ErrorMsg';
import marketing_label1 from '@salesforce/label/c.marketing_label1';
import marketing_label2 from '@salesforce/label/c.marketing_label2';
import marketing_label3 from '@salesforce/label/c.marketing_label3';
import marketing_label4 from '@salesforce/label/c.marketing_label4';
import save from '@salesforce/label/c.save';
import cancel from '@salesforce/label/c.cancel';
import addContact from '@salesforce/apex/AddContactController.addContact';

import userAvatar from '@salesforce/resourceUrl/userAvatar';

export default class MyProfile extends LightningElement {
    
    userId = Id
    @api  labelName ='Name'
    @api  labelCountry ='Country'
    @api  labelUsername='Username'
    @api  labelCompany='Company'
    @api  labelPhone='Phone Number'
    @api  labelEmail='Email Address'
    @api  labelVat='VAT Code'
    @api  labelLanguage='Language'
    @api  labelTimezone='Timezone'
    @api  labelGoodCredit='Good Credit'
    @api  title = 'User Details'
    @api  titleLocale = 'Locale Settings'
    @api  labelChangeInfo = 'Edit'
    @api  labelAddContact = 'Add Contact'
    @api  labelChangePassword = 'Change Password'
    @api  labelChangeMarketing = 'Change Your Marketing Settings'
    @api  labelChangeMarketingText = 'Are you sure you want to change your marketing settings?'
    @api  labelChangeInfoTitle = 'Edit your User Details'
    @api  labelAddContactTitle = 'Add new contact'
    @api  labelChangePasswordTitle = 'Change Your Password'
    @track marketing_label1=marketing_label1
    @track marketing_label2=marketing_label2
    @track marketing_label3=marketing_label3
    @track marketing_label4=marketing_label4
    @track userAvatar = userAvatar
    @track AddContact = false
    @track changeInfo = false
    @track changeMarketing = false
    @track changePassword = false
    @track languagePicklist = []
    @track timezonePicklist = []
    @track chosenLanguage = null;
    @track chosenLanguageId = null;
    @track chosenTimezone = null;
    @track chosenTimezoneId = null;
    
    @track errormsg = null;
    @track save = save;
    @track cancel = cancel;
    @track contact = {'firstname': null, 'lastname':null, 'email':null, 'phone':null}
    @track user={'name':null,'username':null,'profilePic':null,'country':null,'phone':null,'email':null,'goodCredit':null, 'language':null,'languageId':null, 'timezone':null,'timezoneId':null,'VAT':null,'company':null, 'AccountId':null}
    @track marketing = false;
    @track checkMarketing = false;

    @wire(getUserInfo,{userId:'$userId'})
    wireGetUserInfo({error, data}) {
        if(data && data!=null){
            let info = JSON.parse(data);
            this.user.name = info.name;
            this.user.username = info.username;
            this.user.profilePic = info.profilePic;
            this.user.country = info.country;
            this.user.phone = info.phone;
            this.user.email = info.email;
            //this.user.goodCredit = info.goodCredit;
            this.user.language = info.language;
            this.user.languageId = info.languageId;
            this.user.timezone = info.timezone;
            this.user.timezoneId = info.timezoneId;
            //this.user.VAT = info.VAT;
            this.user.company = info.company;
            //this.marketing = info.marketing == 'true'?true:false;
            this.checkMarketing = this.marketing;
            this.errormsg = null;
            this.chosenTimezone = this.user.timezone;
            this.chosenTimezoneId = this.user.timezoneId;
            this.chosenLanguage = this.user.language;
            this.chosenLanguageId = this.user.languageId;
        }else{
            this.errormsg = errorMess;
        }
    }

    @wire(getLanguagePicklist)
    getUserLanguagePicklist({error,data}){
        if(data && data != null){
            let res = JSON.parse(data)
            for (const [key, value] of Object.entries(res)) {
                this.languagePicklist.push({value:key,label:value});
            }
           
        }else{
            this.errormsg = errorMess;
        }
    }

    @wire(getTimezonePicklist)
    getUserTimezonePicklist({error,data}){
        if(data && data != null){
            let res =JSON.parse(data);
            for (const [key, value] of Object.entries(res)) {
                this.timezonePicklist.push({value:key,label:value})
            }
            
           
        }else{
            this.errormsg = errorMess;
        }
    }

    get hasError(){
        return this.errormsg != null?true:false
    }

    get hasPicture(){
        return this.user.profilePic !=null && this.user.profilePic!=''?true:false
    }

    get langOptions(){
        let pickLang = this.languagePicklist.map(o=>{
            return {value:o.value,label:o.label}
        });
       
        return pickLang;
    }

    get timeOptions(){
        let pickTime = this.timezonePicklist.map(o=>{
            return {value:o.value,label:o.label}
        });
        
        return pickTime; 
    }

    updatefields(event){
        let field = event.target.name;
        console.log(field);
        if (field == 'FirstName') {
            this.contact.firstname=event.target.value;
        } 

        else if (field == 'LastName') {
            this.contact.lastname=event.target.value;
        } 

        else if (field == 'Email') {
            this.contact.email=event.target.value;
        } 

        else if (field == 'Phone') {
            this.contact.phone=event.target.value;
        } 
    }

    handleAddContact(){
        this.AddContact = true;
    }

    closeAddContact(){
        this.AddContact = false;
    }

    saveAddContact(){

        console.log(this.userId);
        console.log(this.contact);

        addContact({
            firstname:this.contact.firstname, 
            lastname:this.contact.lastname,
            email:this.contact.email,
            phone:this.contact.phone,
            userId:this.userId

        }).then((result)=>{
                
                    this.AddContact=false;
                
            }).catch((error)=>this.errormsg=error)
    }


    handleChangeInfo(){
        this.changeInfo = true;
    }

    closeChangeInfo(){
        this.changeInfo = false;
    }

    saveChangeInfo(){
        this.changeInfo = false;
    }

    handleChangePassword(){
        this.changePassword = true;
    }

    closeChangePassword(){
        this.changePassword = false;
    }

    saveChangePassword(){
        this.changePassword = false;
    }

    handleChangeMarketing(event){
        this.changeMarketing = true;
        this.marketing = event.target.checked;
    }

    saveChangeMarketing(){
        this.changeMarketing = false;
        this.marketing = this.checkMarketing;
        
    }

    closeChangeMarketing(){
        this.changeMarketing = false;
        this.checkMarketing = this.marketing;

        
    }

    handleChangeLanguage(event) {
        this.chosenLanguageId = event.detail.value;
        for(let el of this.languagePicklist){
            if(el.value == this.chosenLanguageId){
                this.chosenLanguage = el.label;
            }
        }
    }

    handleChangeTimezone(event) {
        this.chosenTimezoneId = event.detail.value;
        for(let el of this.timezonePicklist){
            if(el.value == this.chosenTimezoneId){
                this.chosenTimezone = el.label;
            }
        }
    }

    saveChangeLocale(){
        this.user.languageId = this.chosenLanguageId;
        this.user.language = this.chosenLanguage;
        this.user.timezoneId = this.chosenTimezoneId;
        this.user.timezone = this.chosenTimezone;
       
    }

    resetLocale(){
        console.log(this.user.timezoneId);
        console.log(this.user.languageId);
    }


    


}