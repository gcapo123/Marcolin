import { LightningElement,wire,track,api } from 'lwc';
import Id from '@salesforce/user/Id';
import getUserInfo from '@salesforce/apex/MyProfileController.getUserInfo';
import errorMess from '@salesforce/label/c.MyProfile_ErrorMsg';
import marketing_label1 from '@salesforce/label/c.marketing_label1';
import marketing_label2 from '@salesforce/label/c.marketing_label2';
import marketing_label3 from '@salesforce/label/c.marketing_label3';
import marketing_label4 from '@salesforce/label/c.marketing_label4';
import save from '@salesforce/label/c.save';
import cancel from '@salesforce/label/c.cancel';

import userAvatar from '@salesforce/resourceUrl/userAvatar';

export default class MyProfile extends LightningElement {
    
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
    @api  labelChangeInfo = 'Edit'
    @api  labelChangePassword = 'Change Password'
    @api  labelChangeMarketing = 'Change Your Marketing Settings'
    @api  labelChangeMarketingText = 'Are you sure you want to change your marketing settings?'
    @api  labelChangeInfoTitle = 'Edit your User Details'
    @api  labelChangePasswordTitle = 'Change Your Password'
    @track marketing_label1=marketing_label1
    @track marketing_label2=marketing_label2
    @track marketing_label3=marketing_label3
    @track marketing_label4=marketing_label4
    @track userAvatar = userAvatar
    @track changeInfo = false
    @track changeMarketing = false
    @track changePassword = false

    userId = Id
    @track errormsg = null;
    @track save = save;
    @track cancel = cancel;
    @track user={'name':null,'username':null,'profilePic':null,'country':null,'phone':null,'email':null,'goodCredit':null, 'language':null, 'timezone':null,'VAT':null,'company':null}
    @track marketing = false;

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
            //this.user.language = info.language;
            //this.user.timezone = info.timezone;
            //this.user.VAT = info.VAT;
            this.user.company = info.company;
            //this.marketing = info.marketing == 'true'?true:false;
            this.errormsg = null;
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

    handleChangeMarketing(){
        this.changeMarketing = true;
    }

    saveChangeMarketing(){
        this.changeMarketing = false;
    }

    closeChangeMarketing(){
        this.changeMarketing = false;
        console.log(this.marketing)
        
    }


    


}