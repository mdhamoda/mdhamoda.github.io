import { LightningElement, api, wire, track } from 'lwc';
import getAvailableFlights from '@salesforce/apex/FlightService.getAvailableFlights';
import assignFlight from '@salesforce/apex/FlightService.assignFlight';
import cancelTrip from '@salesforce/apex/FlightService.cancelTrip';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { getRecord } from 'lightning/uiRecordApi';

export default class AvailableFlights extends LightningElement {
    @api recordId;
    @track flights = [];
    @track visibleFlights = [];
    wiredFlights;

    // 🔹 Keep full wired result for refresh
    wiredTrip;

    page = 1;
    pageSize = 9; // 3x3 grid
    totalPages = 0;

    @wire(getRecord, { recordId: '$recordId', fields: ['Trip__c.Status__c'] })
    wiredTripHandler(result) {
        this.wiredTrip = result;
    }

    // 🔹 Getter to always pull latest Status__c
    get status() {
        return this.wiredTrip?.data?.fields.Status__c?.value;
    }

    // 🔹 Reactive show/hide flights
    get showAvailableFlights() {
        return this.status !== 'Flight booked';
    }

    @wire(getAvailableFlights, { tripId: '$recordId' })
    wiredFlightsHandler(result) {
        this.wiredFlights = result;
        if (result.data) {
            this.flights = result.data;
            this.totalPages = Math.ceil(this.flights.length / this.pageSize);
            this.updateVisibleFlights();
        } else {
            this.flights = [];
            this.visibleFlights = [];
            this.totalPages = 0;
        }
    }

    updateVisibleFlights() {
        const start = (this.page - 1) * this.pageSize;
        const end = this.page * this.pageSize;
        this.visibleFlights = this.flights.slice(start, end);
    }

    handleNext() {
        if (this.page < this.totalPages) {
            this.page++;
            this.updateVisibleFlights();
        }
    }

    handlePrev() {
        if (this.page > 1) {
            this.page--;
            this.updateVisibleFlights();
        }
    }

    get isPrevDisabled() {
        return this.page === 1;
    }

    get isNextDisabled() {
        return this.page === this.totalPages || this.totalPages === 0;
    }

    handleSelect(event) {
        const flightId = event.target.dataset.id;
        assignFlight({ tripId: this.recordId, flightId })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Trip Booked Successfully',
                        variant: 'success'
                    })
                );
                refreshApex(this.wiredTrip);
                return refreshApex(this.wiredFlights);
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error',
                        mode: 'sticky'
                    })
                );
            });
    }

    handleCancelTrip() {
        cancelTrip({ tripId: this.recordId })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Trip Cancelled',
                        message: 'Flight and ticket have been freed. Trip reset to Flight search.',
                        variant: 'success'
                    })
                );
                refreshApex(this.wiredTrip);
                return refreshApex(this.wiredFlights);
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error cancelling trip',
                        message: error.body.message,
                        variant: 'error',
                        mode: 'sticky'
                    })
                );
            });
    }
}
