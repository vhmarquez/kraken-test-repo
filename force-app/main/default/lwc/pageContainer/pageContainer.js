import { LightningElement, api } from 'lwc';

const PAGES = new Set(['one','two']);
const PAGE_MAPPING = {
    one: () => import("c/pageOne"),
    two: () => import("c/pageTwo"),
};

export default class PageContainer extends LightningElement {
    currentPage;

    _type = "one";

    @api
    get type(){
        return this._type;
    }

    set type(val){
        if(!PAGES.has(val)){
            console.warn(`Unknown page type: ${val}`);
        }

        this._type = val;
        PAGE_MAPPING[val]().then(({ default: CurrentPage }) => {
            this.currentPage = CurrentPage;
        });
    }

    switchPage(event){
        console.log(event.target.dataset.name);
        let value = event.target.dataset.name;
        switch(value){
            case 'one':
                this._type = "one";
                break;
            case 'page-two':
                this._type = "two";
                break;
            default:
                this._type = "one";
                break;
        }
    }
}