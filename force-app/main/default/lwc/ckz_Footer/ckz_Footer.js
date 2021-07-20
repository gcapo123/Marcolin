import { LightningElement, api,track } from "lwc";
import { loadStyle } from "lightning/platformResourceLoader";
import logo from '@salesforce/contentAssetUrl/logoMarcolinDark';
import fontawesome_pro_581_web from "@salesforce/resourceUrl/fontawesome_pro_581_web";

export default class Ckz_Footer_lwc extends LightningElement {
  @api showImage = false;
  @api imgUrl = "";
  @api imgHeight = "";
  @api backgroundColor;
  @api textColor;
  @track logo =logo;
  @api ctaText;

  @api colOneHeading='Chi Siamo';
  @api colOneLinkOneText;
  @api colOneLinkOneURL;
  @api colOneLinkTwoText;
  @api colOneLinkTwoURL;
  @api colOneLinkThreeText;
  @api colOneLinkThreeURL;
  @api colOneLinkFourText;
  @api colOneLinkFourURL;
  @api colOneLinkFiveText;
  @api colOneLinkFiveURL;
  @api showFiveLinksColOne=false;

  @api showSecondColumn=false;
  @api colTwoHeading;
  @api colTwoLinkOneText;
  @api colTwoLinkOneURL;
  @api colTwoLinkTwoText;
  @api colTwoLinkTwoURL;
  @api colTwoLinkThreeText;
  @api colTwoLinkThreeURL;
  @api colTwoLinkFourText;
  @api colTwoLinkFourURL;
  @api colTwoLinkFiveText;
  @api colTwoLinkFiveURL;
  @api showFiveLinksColTwo=false;

  @api colThreeHeading='Contatti';
  @api colThreeLinkOneText='Contatti';
  @api colThreeLinkOneURL;
  @api colThreeLinkTwoText='Privacy Policy';
  @api colThreeLinkTwoURL;
  @api colThreeLinkThreeText='Terms & Conditions';
  @api colThreeLinkThreeURL;
  @api colThreeLinkFourText='Sales Terms & Conditions';
  @api colThreeLinkFourURL;
  @api colThreeLinkFiveText;
  @api colThreeLinkFiveURL;
  @api showFiveLinksColThree=false;

  @api socialFacebook;
  @api socialFacebookLink = 'EptaSpA/';
  @api socialTwitter;
  @api socialTwitterLink;
  @api socialLinkedin;
  @api socialLinkedinLink;
  @api socialInstagram;
  @api socialInstagramLink;
  @api socialYoutube;
  @api socialYoutubeLink;

  @api showExpCloudLogo;
  @track nColumnsClassStyle;

  baseUrl='';

  connectedCallback() {
    this.baseUrl = window.location.href.split('/s/')[0]+'/s';
    loadStyle(this, fontawesome_pro_581_web + "/css/all.css");
    this.nColumnsClassStyle = this.showSecondColumn?'slds-col slds-size_1-of-3':'slds-col slds-size_1-of-2';
  }

  get footerStyles() {
    return `background-color:${this.backgroundColor};color:${this.textColor};`;
  }

  get imageStyles() {
    return `height:${this.imgHeight}; `;
  }

  get facebookLink() {
    return 'https://www.facebook.com/'+this.socialFacebookLink;
  }

  get twitterLink() {
    return `https://twitter.com/${this.socialTwitterLink}`;
  }

  get linkedinLink() {
    return `https://www.linkedin.com/company/${this.socialLinkedinLink}`;
  }

  get instagramLink() {
    return `https://www.instagram.com/${this.socialInstagramLink}`;
  }

  get youtubeLink() {
    return `https://www.youtube.com/channel/${this.socialYoutubeLink}`;
  }

  get contacts(){
    return this.baseUrl+"/contacts";
  }

  get privacy(){
    return this.baseUrl+"/privacy-policy";
  }

  get conditions(){
    //window.location.href = "../apex/EPTA_TermsAndConditions";
    return this.baseUrl+"/terms-and-conditions";
  }

  get conditionsSales(){
    return this.baseUrl+"/sales-terms-and-conditions";
  }

  get hasCta(){
    return this.ctaText==''?false:true;
  }
}