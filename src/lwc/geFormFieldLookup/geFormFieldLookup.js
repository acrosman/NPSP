import { LightningElement, api, wire, track } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import doSearch from '@salesforce/apex/GE_LookupController.doSearch';

const DELAY = 300;

export default class GeFormFieldLookup extends LightningElement {
    @api fieldApiName;
    @api objectApiName;
    @api displayValue = '';
    @api defaultValue;
    @api label;
    @api required;
    @api id; // unique identifier for this field, used mainly for accessibility


    @track options = [];
    @track value;
    @track targetObjectApiName;
    @track queryFields;
    @track showError = false;

    /**
     * Retrieve information about the object the lookup points to.
     */
    @wire(getObjectInfo, { objectApiName: '$targetObjectApiName' })
    wiredTargetObjectInfo(response) {
        if(response.data) {
            this.targetObjectInfo = response;
            this.queryFields = this.getQueryFields();
        }
    }

    @wire(getRecord, { recordId: '$defaultValue', fields: '$queryFields'})
    wiredGetRecord({error, data}) {
        if(data) {
            if(typeof this.value === 'undefined') {
                this.value = this.defaultValue;
                this.displayValue = data.fields.Name.value;
            }
        }
    }

    @api
    reportValidity() {
        const isValid = this.checkValidity();
        this.showError = !isValid;
    }

    @api
    checkValidity() {
        if(this.required) {
            return typeof this.value !== 'undefined' && this.value !== null && this.value !== '';
        }
        return true;
    }

    /**
     * Handle text input change, and retrieve lookup options.
     * @param event
     */
    handleChange(event) {
        window.clearTimeout(this.delayTimeout);
        this.displayValue = event.detail;
        if (this.displayValue && this.displayValue.length > 1) {
            this.delayTimeout = setTimeout(() => this.retrieveLookupOptions(this.displayValue, this.targetObjectApiName), DELAY);
        }
    }

    /**
     * Handle user selecting an option from the dropdown list.
     * @param event
     */
    handleSelect(event) {
        this.displayValue = event.detail.displayValue;
        this.value = event.detail.value;
        this.dispatchEvent(new CustomEvent('change', { detail: event.detail }));
    }

    @api
    set objectDescribeInfo(newVal) {
        this._objectDescribeInfo = newVal;
        if(typeof newVal !== 'undefined') {
            // needed for @wire reactive property
            this.targetObjectApiName = this.fieldInfo.referenceToInfos[0].apiName;
        }
    }

    getQueryFields() {
        const fields = ['Id', 'Name'];
        return fields.map(f => `${this.targetObjectApiName}.${f}`);
    }

    get objectDescribeInfo() {
        return this._objectDescribeInfo;
    }

    get fieldInfo() {
        if(this.objectDescribeInfo && this.objectDescribeInfo) {
            return this.objectDescribeInfo.fields[this.fieldApiName];
        }
    }

    get fieldLabel() {
        return this.fieldInfo ? this.fieldInfo.label : null;
    }

    /**
     * Gets the SObject icon for the object that we're looking up to.
     * @returns {string}
     */
    get targetObjectIconName() {
        if(this.targetObjectInfo && this.targetObjectInfo.data) {
            if(this.targetObjectInfo.data.themeInfo) {
                const {iconUrl} = this.targetObjectInfo.data.themeInfo;
                const re = /\/(standard|custom)\/([a-zA-Z]+)/;
                const result = re.exec(iconUrl);

                // explicitly handle only standard and custom icon sets
                if(result !== null) {
                    if (result[1] === 'standard') {
                        return 'standard:' + result[2];
                    } else if (result[1] === 'custom') {
                        return 'custom:' + result[2];
                    }
                }
            }
        }
    }

    /**
     * Async function for retrieving lookup options.
     * @param searchValue String to search for.
     * @param sObjectType Object type to search e.g. Account
     * @returns {Promise<void>}
     */
    retrieveLookupOptions = async (searchValue, sObjectType) => {
        this.options = await doSearch({searchValue, sObjectType});
    };

}