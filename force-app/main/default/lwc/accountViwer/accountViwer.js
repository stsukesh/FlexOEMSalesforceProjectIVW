import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';

// Import field references (Best practice)
import NAME_FIELD from '@salesforce/schema/Account.Name';

export default class AccountManager extends LightningElement {
    @api recordId;
    
    // CORRECT: Class properties do not use 'let' or 'const'
    accountName; 

    /**
     * @wire service to fetch the record data reactively.
     */
    @wire(getRecord, { recordId: '$recordId', fields: [NAME_FIELD] })
    wiredAccount({ error, data }) {
        if (data) {
            // Use 'let' for local variables inside a function as per your standard
            let nameFromSalesforce = data.fields.Name.value;
            
            // Use 'this.' to assign the value to the class property
            this.accountName = nameFromSalesforce;
        } else if (error) {
            console.error('Error loading account name:', error);
        }
    }

    // Dynamic label for the card header
    get cardTitle() {
        // Use 'this.' to read the class property
        return this.recordId ? `Editing: ${this.accountName}` : 'Create New Account';
    }

    get buttonLabel() {
        return this.recordId ? 'Update Account' : 'Create Account';
    }

    handleSuccess(event) {
        let action = this.recordId ? 'updated' : 'created';
        
        const toast = new ShowToastEvent({
            title: 'Success',
            message: `Account ${action} successfully.`,
            variant: 'success'
        });
        this.dispatchEvent(toast);
    }

    handleError(event) {
        const toast = new ShowToastEvent({
            title: 'Error saving record',
            message: event.detail.detail,
            variant: 'error'
        });
        this.dispatchEvent(toast);
    }
}