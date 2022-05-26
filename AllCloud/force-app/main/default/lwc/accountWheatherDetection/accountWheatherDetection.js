import {LightningElement, api, wire, track} from 'lwc';
import {getRecord} from 'lightning/uiRecordApi';
import getAccount from '@salesforce/apex/AccountDetail.getAccountDetail';
import ADDRESS from '@salesforce/schema/Account.BillingAddress';
import ACCOUNT_CURRENT_WEATHER from '@salesforce/schema/Account.Account_Current_Weather__c';

const accFields = [
	'Account.BillingAddress',
    'Account.Account_Current_Weather__c',
    'Account.BillingLatitude',
    'Account.BillingLongitude'
]

export default class AccountWheatherDetection extends LightningElement {
    @api recordId;
    @api objectApiName;
    @track response;
    @track weather;
    @track accCity;
    @track accCountry;
    @track accPostalcode;
    @track accState;
    @track accStreet;

    @wire(getRecord, { recordId: '$recordId', fields: [ADDRESS, ACCOUNT_CURRENT_WEATHER] })
    record;

    connectedCallback(){
        this.getWeatherDescription();
    }

    getWeatherDescription() {
        getAccount({ accId: this.recordId })
            .then(result => {	
                this.response = result;
                this.address = result.acc.BillingAddress;
                this.weather = result.acc.Account_Current_Weather__c;
                this.accCity = result.acc.BillingCity;
                this.accCountry = result.acc.BillingCountry;
                this.accPostalcode = result.acc.BillingPostalCode;
                this.saccState = result.acc.BillingState;
                this.accStreet = result.acc.BillingStreet;
                console.log('acc::' + this.response.message);
                console.log('this.accStreet::' + this.accStreet);
        });
    }
}