import { LightningElement, api } from 'lwc';

export default class PageTwo extends LightningElement {
    @api currentPage;

    switchPage() {

        this.dispatchEvent(
            new CustomEvent('switchpage', {
                detail: 'page-two'
            })
        );
    }
}