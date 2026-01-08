import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

/**
 * @name: CreateAccount
 * @author: Sukesh Subash
 * @description: Creates an account and redirects to the new record page.
 */
export default class CreateAccount extends NavigationMixin(LightningElement) {

    /**
     * @description: Handles the successful creation of the record and redirects to its record page.
     * @param event - Success event from lightning-record-edit-form containing detail.id
     */
    async handleSuccess(event) {
        const newId = event.detail.id;

        // Show success toast
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Account Created Successfully!',
                variant: 'success'
            })
        );
        await new Promise(resolve => setTimeout(resolve, 1000)); // Wait 1s

        // Close any open action panel/quick action if applicable
        // and then navigate to record page. Some containers (like
        // utility bar/quick actions) block navigation until closed.
        // We use a microtask to ensure toast processing completes first.
        Promise.resolve().then(() => {
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: newId,
                        objectApiName: 'Account',
                        actionName: 'view'
                    }
                });
        
        });
    }

    /**
     * @description: Handles errors during submission and shows an error toast.
     * @param event - Error event from lightning-record-edit-form
     */
    handleError(event) {
        const errorMessage = event?.detail?.detail || 'An unknown error occurred';
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error Creating Record',
                message: errorMessage,
                variant: 'error'
            })
        );
    }


    /**
     * @description: Resets the input fields (kept for potential reuse, not invoked post-navigation).
     */
    handleReset() {
        const inputFields = this.template.querySelectorAll('lightning-input-field');
        if (inputFields && inputFields.length > 0) {
            inputFields.forEach((field) => {
                field.reset();
            });
        }
    }
}