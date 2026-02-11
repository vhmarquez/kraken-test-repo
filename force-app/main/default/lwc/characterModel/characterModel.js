import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { getObjectInfos } from 'lightning/uiObjectInfoApi';
import MISSING_ITEM_URL from '@salesforce/resourceUrl/missing_item';

import CHARACTER_MODEL_OBJECT from '@salesforce/schema/Character_Model__c';
import GUILD_APPLICANT_OBJECT from '@salesforce/schema/Guild_Applicant__c';
import GUILD_MEMBER_OBJECT from '@salesforce/schema/Guild_Member__c';

let APPLICANT_GUILD_FIELDS = [];
let MEMBER_GUILD_FIELDS = [];
let GUILD_FIELDS = [];
let CHARACTER_MODEL_FIELDS = [];

export default class CharacterModel extends LightningElement {

    @api recordId;
    @api objectApiName;

    @track characterModelId;
    @track characterName;
    @track characterTitle;
    @track missingItemUrl = MISSING_ITEM_URL;

    @wire(getObjectInfos, { objectApiNames: [CHARACTER_MODEL_OBJECT, GUILD_APPLICANT_OBJECT, GUILD_MEMBER_OBJECT] })
    objectInfos({ error, data }) {
        if (data != null){
            let characterModelObject = data.results[0].result;
            let applicantObject = data.results[1].result;
            let memberObject = data.results[2].result;

            for(const field in characterModelObject.fields){
                CHARACTER_MODEL_FIELDS.push(characterModelObject.apiName + '.' + characterModelObject.fields[field].apiName)
            }

            for(const field in applicantObject.fields){
                APPLICANT_GUILD_FIELDS.push(applicantObject.apiName + '.' + applicantObject.fields[field].apiName)
            }

            for(const field in memberObject.fields){
                MEMBER_GUILD_FIELDS.push(memberObject.apiName + '.' + memberObject.fields[field].apiName)
            }

            if (this.objectApiName == applicantObject.apiName){
                GUILD_FIELDS = APPLICANT_GUILD_FIELDS;
            } else if (this.objectApiName == memberObject.apiName){
                GUILD_FIELDS = MEMBER_GUILD_FIELDS;
            }
        } else if (error){
            console.log(error);
        }
    };

    @wire(getRecord, { recordId: "$recordId", fields: GUILD_FIELDS })
    guild({ error, data }) {
        if (data != null) {
            this.characterModelId = data.fields.Character_Model__c.value;
            this.characterName = data.fields.Name.value;
            this.characterTitle = data.fields.Title__c.value;
        } else if (error) {
            console.log(error);
        }
    };

    @wire(getRecord, { recordId: "$characterModelId", fields: CHARACTER_MODEL_FIELDS})
    characterModel;

    get name() {
        return this.characterName;
    }

    get title() {
        return this.characterTitle;
    }

    get characterRender() {
        return this.characterModel.data.fields.Main_Raw__c.value;
    }

    get head() {
        return this.characterModel.data.fields.Head__c.value;
    }

    get neck() {
        return this.characterModel.data.fields.Neck__c.value;
    }

    get shoulders() {
        return this.characterModel.data.fields.Shoulders__c.value;
    }

    get chest() {
        return this.characterModel.data.fields.Chest__c.value;
    }

    get waist() {
        return this.characterModel.data.fields.Waist__c.value;
    }

    get legs() {
        return this.characterModel.data.fields.Legs__c.value;
    }

    get feet() {
        return this.characterModel.data.fields.Feet__c.value;
    }

    get wrist() {
        return this.characterModel.data.fields.Wrist__c.value;
    }

    get hands() {
        return this.characterModel.data.fields.Hands__c.value;
    }

    get finger() {
        return this.characterModel.data.fields.Finger__c.value;
    }

    get finger_2() {
        return this.characterModel.data.fields.Finger_2__c.value;
    }

    get trinket() {
        return this.characterModel.data.fields.Trinket_1__c.value;
    }

    get trinket_2() {
        return this.characterModel.data.fields.Trinket_2__c.value;
    }

    get back() {
        return this.characterModel.data.fields.Back__c.value;
    }

    get main_hand() {
        return this.characterModel.data.fields.Main_Hand__c.value;
    }

    get off_hand() {
        return this.characterModel.data.fields.Off_Hand__c.value;
    }

    get tabard() {
        return this.characterModel.data.fields.Tabard__c.value;
    }

}