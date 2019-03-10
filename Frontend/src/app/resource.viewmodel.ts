import { Resource } from './shared/models';

export class ResourceViewModel {

    constructor(data: Resource) {
        this.resource = data;
    }

    public resource: Resource;
    public showCode: boolean = false;

    // This property used for determining whether the item is selected
    private _selected: boolean = false;

    public get selected(): boolean {
        return this._selected || this.resource.filename.startsWith('_');
    }

    public set selected(value: boolean) {
        this._selected = value || this.resource.filename.startsWith('_');
    }

    public get required(): boolean {
      return this.resource.filename.startsWith("_");
    }
}