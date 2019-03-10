import { Component, AfterViewChecked } from '@angular/core';
import { HighlightService } from './highlight.service';
import { ResourceService } from './resource.service';
import { ResourceViewModel } from './resource.viewmodel';

@Component({
    selector: 'app-root',
    templateUrl: './app.component.html',
    styleUrls: ['./app.component.less']
})
export class AppComponent implements AfterViewChecked {

    title = 'Terrademo';

    public resources: ResourceViewModel[] = [];

    constructor(
      private resourceService: ResourceService,
      private highlightService: HighlightService
    ) {
    
      this.resourceService
        .getResources()
        .subscribe(data => this.resources = data.map(r => new ResourceViewModel(r)));

      this.highlightService.highlightAll();
    }

    ngAfterViewChecked() {
        this.highlightService.highlightAll();
    }
}
