import { LightningElement, api } from 'lwc';

export default class PageOne extends LightningElement {
    @api currentPage;

    switchPage() {

        this.dispatchEvent(
            new CustomEvent('switchpage', {
                detail: 'page-one'
            })
        );
    }
}