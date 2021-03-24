import { LightningElement,wire,track } from 'lwc';
import getContacts from '@salesforce/apex/ContactControllerV2.getContacts';
import FirstNameField from '@salesforce/schema/Contact.FirstName';
import LastNameField from '@salesforce/schema/Contact.LastName';
import LastSyncMessageField from '@salesforce/schema/Contact.LastSyncMessage__c';
import LastSyncDateField from '@salesforce/schema/Contact.LastSyncDate__c';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import AccountIndustryField from '@salesforce/schema/Contact.AccountIndustry__c';
import getFields from '@salesforce/apex/ContactControllerV2.getFields';
import getUserFieldsSelection from '@salesforce/apex/ContactControllerV2.getUserFieldsSelection';
import updateFieldSelection from '@salesforce/apex/ContactControllerV2.updateFieldSelection';
import sendToOtherOrg from '@salesforce/apex/ContactControllerV2.sendToOtherOrg';
export default class ContactListToSync extends LightningElement {
    columns = [
        {label: 'First Name',fieldName:FirstNameField.fieldApiName, type: 'text'},
        {label: 'Last Name',fieldName:LastNameField.fieldApiName, type: 'text'},
        {label: 'Account Industry',fieldName:AccountIndustryField.fieldApiName, type: 'text'}
    ];
    syncResultColumns = [
        {label: 'First Name', fieldName:FirstNameField.fieldApiName,type:'text'},
        {label: 'Last Name', fieldName:LastNameField.fieldApiName,type:'text'},
        {label: 'Error Message', fieldName:LastSyncMessageField.fieldApiName,type:'text'}
    ]
    firstName;
    lastName;
    industry;
    skip = 0;
    take= 10;
    isLoading = true;
    selectedContacts = [];
    contacts = [];
    haveMore = false;
    cantSync = true;
    showFieldSelectionModal = false;
    fields = [];
    maxRowSelection =20;
    selectedFields= [];
    syncResult = [];
    showSyncResult= false;
    connectedCallback(){
        this.loadContacts(true);
        // getFields({}).then(response=>{
        //     console.log(response)
        // }).catch(err=>{
        //     console.error(err)
        // });
    }
    loadContacts(override){
        this.isLoading = true;
        getContacts({
            skip:this.skip,
            take: this.take,
            firstNameFilter:this.firstName,
            lastNameFilter:this.lastName,
            industryFilter:this.industry
        }).then(response=>{
            //this.haveMore = response.HaveMore;
            if(override)
                this.contacts=response;
            else{
                let newContacts = [...this.contacts,...response];
                // for(let i =0;i<response.lenght;i++){
                //     const item = response[i];
                //     newContacts.push(item);
                // }
                this.contacts = newContacts;
            }
            this.isLoading = false;
        }).catch(error=>{
            console.error(error);
            this.isLoading = false;
        });
    }
    handleFilterChange(event){
        this[event.target.name] = event.target.value;
        this.skip = 0;
        this.loadContacts(true);
    }
    handleLoadMore(event){
        if(!this.isLoading){
            this.skip += this.take;
            this.loadContacts(false);
        }
    }
    handleSelectedRow(event){
        this.selectedContacts = [...event.detail.selectedRows];
        this.cantSync = this.selectedContacts == 0;
    }
    async handleSyncClick(){
        this.showFieldSelectionModal = true;
        try {
            let fields = await getFields({});
            let selectedFields = await getUserFieldsSelection({});

            let selectedValues = [];
            let options = [];
            Object.keys(fields).forEach(key=>{
                let finded = selectedFields.find(f=>f.Name.toLowerCase() === key.toLowerCase());
                if(finded)
                    selectedValues.push(key);
                options.push({value:key,label:fields[key]});
            });
            this.fields = options;
            this.selectedFields = selectedValues;
        } catch (error) {
            console.error(error);
        }
    }
    closeFieldSelectionModal(){
        this.showFieldSelectionModal = false;
    }
    handleFieldSelection(event){
        this.selectedFields = event.detail.value;
        updateFieldSelection({fields: this.selectedFields})
        .then(response=>{
            let event = new ShowToastEvent({
                title: 'Fields updated in database',
                variant: 'success'
            });
            this.dispatchEvent(event);
        }).catch(err=>{
            let event = new ShowToastEvent({
                title: 'An error has ocurred.',
                variant: 'error'
            });
            this.dispatchEvent(event);
            console.error(err);
        });
    }
    async handleConfirmSync(){
        this.showFieldSelectionModal = false;
        try {
            let ids = this.selectedContacts.map(sc=> sc.Id);
            let response = await sendToOtherOrg({contactsId:ids});
            if(response== null){
                let event = new ShowToastEvent({
                    title: 'An error has ocurred.',
                    variant: 'error'
                });
                this.dispatchEvent(event);
                console.error('Controller returns null');
                return;
            }
            console.log(response)
            this.syncResult = response;
            this.showSyncResult = true;
            let event = new ShowToastEvent({
                title: 'Contacts synced',
                variant: 'success'
            });
            this.dispatchEvent(event);
        } catch (error) {
            let event = new ShowToastEvent({
                title: 'An error has ocurred.',
                variant: 'error'
            });
            this.dispatchEvent(event);
            console.error(error);
        }
    }
    closeSyncModal(){
        this.showSyncResult = false;
    }
}