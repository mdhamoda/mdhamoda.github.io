import { LightningElement, api, wire, track } from 'lwc';
import getShipmentsByRegion from '@salesforce/apex/ShipmentRequestController.getShipmentsByRegion';
import updateShipments from '@salesforce/apex/ShipmentRequestController.updateShipments';
import dispatchShipments from '@salesforce/apex/CarrierDispatchService.dispatchShipments';
import { refreshApex } from '@salesforce/apex';
import { subscribe, unsubscribe, onError } from 'lightning/empApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { deleteRecord } from 'lightning/uiRecordApi';

const REGION_OPTS = [
    { label: 'EMEA', value: 'EMEA' }, 
    { label: 'APAC', value: 'APAC' },
    { label: 'AMER', value: 'AMER' }, 
    { label: 'All', value: 'All' }
];

export default class ShipmentDatatable extends LightningElement {
    @track shipments = [];
    @track modifiedShipments = [];
    @track selectedRegion = 'All';
    @track error;


    wiredShipmentsResult;
    subscription;
    intervalId;

    regionOptions = REGION_OPTS;

    // Modal related properties
    @track isModalOpen = false;
    @track isCreateModalOpen = false;
    @track selectedShipment = null;

    @wire(getShipmentsByRegion, { region: '$selectedRegion' })
    wiredShipments(result) {
        this.wiredShipmentsResult = result;
        if (result.data) {
            // Map shipments and add initial counter for live countdown
            this.shipments = result.data.map(record => ({
                ...record,
                shipmentInReview: record.Status__c === 'In Review',
                rowClassvalue: record.Status__c === 'In Review' ? 'row-yellow' :
                record.Status__c === 'Assigned to Agent' ? 'row-green' : '',
                counter: record.Status__c === 'In Review' && record.In_Review_Start_Time__c ? this.formatCountdown(record) : '',
                InReviewName: record.Status__c === 'In Review' && record.In_Review_Start_Time__c ? record.In_Review_User__r.Name : ''
            }));
            this.error = undefined;
            this.modifiedShipments = [];

            // Start or restart live countdown timer
            this.startCountdownTimer();
        } else if (result.error) {
            this.error = result.error.body ? result.error.body.message : 'Unknown error';
            this.shipments = [];
        }
    }

    openCreateModal() {
    this.isCreateModalOpen = true;
    }

    closeCreateModal() {
        this.isCreateModalOpen = false;
    }

    connectedCallback() {
        this.handleSubscribe();
        this.registerErrorListener();
        // Start timer just in case data was already loaded
        this.startCountdownTimer();
    }

    disconnectedCallback() {
        this.handleUnsubscribe();
        if (this.intervalId) {
            clearInterval(this.intervalId);
            this.intervalId = null;
        }
    }

    startCountdownTimer() {
        if (this.intervalId) {
            clearInterval(this.intervalId);
        }
        // Update countdown every second
        this.intervalId = setInterval(() => {
            if (this.shipments.length > 0) {
                this.shipments = this.shipments.map(record => {
                    if (record.Status__c === 'In Review' && record.In_Review_Start_Time__c) {
                        return {
                            ...record,
                            counter: this.formatCountdown(record)
                        };
                    }
                    return {
                        ...record,
                        counter: ''
                    };
                });
            }
        }, 1000);
    }

    handleRegionChange(event) {
        this.selectedRegion = event.detail.value;
    }

    handleSubscribe() {
        subscribe('/event/ShipmentRequestEvent__e', -1, () => {
            return refreshApex(this.wiredShipmentsResult);
        }).then(response => {
            this.subscription = response;
        });
    }

    handleUnsubscribe() {
        if (this.subscription) {
            unsubscribe(this.subscription, () => {});
            this.subscription = null;
        }
    }

    registerErrorListener() {
        onError(error => {
            this.showToast('Error', 'EMP API error: ' + JSON.stringify(error), 'error');
        });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

    // ========== Modal related handlers ==========

    handleRowClick(event) {
        const shipmentId = event.currentTarget.dataset.id;
        const shipment = this.shipments.find(s => s.Id === shipmentId);
        if (shipment) {
            const updatedStatus = shipment.Status__c === 'Assigned to Agent' ? 'In Review' : shipment.Status__c;
            if(updatedStatus === 'In Review') {
            this.selectedShipment = { ...shipment, Status__c: updatedStatus };
            const shipmentToUpdate = [{ Id: shipment.Id, Status__c: updatedStatus }];
            updateShipments({ shipmentsToUpdate: shipmentToUpdate })
                .then(() => {
                    this.showToast('Success', 'Status updated to In Review', 'success');
                    return refreshApex(this.wiredShipmentsResult);
                })
                .catch(error => {
                    this.showToast(
                        'Error',
                        error.body?.message || 'Failed to update status',
                        'error'
                    );
                }).finally(() => {
                    this.selectedShipment = { ...shipment, Status__c: updatedStatus };
                    this.isModalOpen = true;
                    });
            } else {
                this.selectedShipment = { ...shipment };
                this.isModalOpen = true;
            }
        }
    }

    handleFormSubmit(event) {
        event.preventDefault();
        const fields = event.detail.fields;
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    handleFormSuccess() {
        this.showToast('Success', 'Shipment updated successfully', 'success');
        this.isModalOpen = false;
        this.selectedShipment = null;
        refreshApex(this.wiredShipmentsResult);
    }

    handleError(event){
    console.error('Form Error Event:', JSON.stringify(event.detail, null, 2));

    const fieldErrors = event.detail?.output?.fieldErrors;
    const recordErrors = event.detail?.output?.errors;

    // Try to get a field-level error
    const firstFieldKey = fieldErrors && Object.keys(fieldErrors)[0];
    const firstFieldErrorMsg = fieldErrors?.[firstFieldKey]?.[0]?.message;

    // Try to get a record-level error
    const firstRecordErrorMsg = recordErrors?.[0]?.message;

    // Fallback to general error messages
    const generalErrorMsg = event.detail?.detail ?? event.detail?.message;

    // Coalesce the best available error message
    const errorMessage =
        firstFieldErrorMsg ??
        firstRecordErrorMsg ??
        generalErrorMsg ??
        'An unknown error occurred.';

    // Show toast
    this.showToast('Error', errorMessage, 'error');
    }

    closeModal() {
        this.isModalOpen = false;
        this.selectedShipment = null;
    }

    formatCountdown(record) {
        const startTimeStr = record.In_Review_Start_Time__c;
        const startTime = new Date(startTimeStr);
        if (isNaN(startTime)) return 'Invalid date';

        const now = new Date();
        const totalDuration = 5 * 60; // 5 minutes in seconds
        const elapsed = Math.floor((now - startTime) / 1000); // seconds elapsed since start

        const remaining = Math.max(0, totalDuration - elapsed);
        if (remaining === 0) return 'Expired';

        const minutes = Math.floor(remaining / 60);
        const seconds = remaining % 60;
        return `${minutes}:${seconds.toString().padStart(2, '0')}`;
    }

    handleDispatch(event) {
        const shipmentId = event.currentTarget.dataset.id;
        const shipment = this.shipments.find(s => s.Id === shipmentId);
        if (shipment.Status__c !== 'Ready for Dispatch') {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Review Shipment and update Ready for Dispatch before dispatching.',
                variant: 'error'
            }));
            return;
        }
        dispatchShipments({ shipmentRequestIds: [shipmentId] })
        .then(result => {
            this.dispatchEvent(new ShowToastEvent({
                title: shipment.Name + ' Dispatch ' + result.Status,
                message: result.Message,
                variant: result.Status === 'Success' ? 'success' : 'error',
                mode: result.Status === 'Success' ? 'dismissible' : 'sticky'
            }));
            // window.alert('Shipment Dispatching');
        })
        .catch(error => {
            console.error('Dispatch failed', error);
            this.dispatchEvent(new ShowToastEvent({
                title:  shipment.Name + ' Dispatch Failed',
                message: error.body?.message || error.message,
                variant: 'error'
            }));
        })
        .finally(() => {
            // Optionally refresh the shipments after dispatch
            refreshApex(this.wiredShipmentsResult);
        });
    }
    async handleDelete() {
        const recordId = this.selectedShipment?.Id;
        if (!this.selectedShipment || !this.selectedShipment.Id) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Shipment deleted successfully',
                    variant: 'success'
                })
            );
            return;
        }
        this.isModalOpen = false;
        this.selectedShipment = null;
        await deleteRecord(recordId)
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Shipment deleted successfully',
                    variant: 'success'
                })
            );
            refreshApex(this.wiredShipmentsResult);
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Delete failed',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        });
    }
}
