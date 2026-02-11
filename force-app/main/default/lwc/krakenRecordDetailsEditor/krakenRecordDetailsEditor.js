import { LightningElement, api } from 'lwc';

export default class KrakenRecordDetailsEditor extends LightningElement {
    @api inputVariables;

    get labelFontSize() { return this.getInputValue('labelFontSize'); }
    get labelColor() { return this.getInputValue('labelColor'); }
    get valueFontSize() { return this.getInputValue('valueFontSize'); }
    get valueColor() { return this.getInputValue('valueColor'); }
    
    get sectionHeaderFontSize() { return this.getInputValue('sectionHeaderFontSize'); }
    get sectionHeaderColor() { return this.getInputValue('sectionHeaderColor'); }
    get sectionHeaderBackgroundColor() { return this.getInputValue('sectionHeaderBackgroundColor'); }
    
    get sectionHeaderPaddingTop() { return this.getInputValue('sectionHeaderPaddingTop'); }
    get sectionHeaderPaddingRight() { return this.getInputValue('sectionHeaderPaddingRight'); }
    get sectionHeaderPaddingBottom() { return this.getInputValue('sectionHeaderPaddingBottom'); }
    get sectionHeaderPaddingLeft() { return this.getInputValue('sectionHeaderPaddingLeft'); }

    getInputValue(name) {
        if (!this.inputVariables) return '';
        const param = this.inputVariables.find(p => p.name === name);
        return param && param.value ? param.value : '';
    }

    handleChange(event) {
        const name = event.target.name;
        const value = event.target.value;
        const type = event.target.type === 'color' ? 'String' : 'String'; // All mapped to String/Color in meta but passed as values

        const valueChangedEvent = new CustomEvent(
            'configuration_editor_input_value_changed', {
                bubbles: true,
                composed: true,
                cancelable: false,
                detail: {
                    name,
                    value,
                    valueType: type
                }
            }
        );
        this.dispatchEvent(valueChangedEvent);
    }
}