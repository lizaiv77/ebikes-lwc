import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class LoginPage extends LightningElement {
    username = '';
    password = '';

    handleUsernameChange(event) {
        this.username = event.target.value;
    }

    handlePasswordChange(event) {
        this.password = event.target.value;
    }

    handleSubmit() {
        if (!this.username || !this.password) {
            this.showToast(
                'Error',
                'Please enter both username and password',
                'error'
            );
            return;
        }

        // TODO: Add login logic here
        this.showToast(
            'Success',
            `Login submitted for user: ${this.username}`,
            'success'
        );

        // Clear fields after submission
        this.username = '';
        this.password = '';
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }
}
