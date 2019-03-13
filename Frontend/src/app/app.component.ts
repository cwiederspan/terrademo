import { Component, AfterViewChecked } from '@angular/core';
import { HighlightService } from './highlight.service';
import { ResourceService } from './resource.service';
import { ResourceViewModel } from './resource.viewmodel';

import { FileSaverService } from 'ngx-filesaver';

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
      private highlightService: HighlightService,
      private fileSaverService: FileSaverService
    ) {
    
      this.resourceService
        .getResources()
        .subscribe(data => this.resources = data.map(r => new ResourceViewModel(r)));

      this.highlightService.highlightAll();
    }

    public downloadFile() {

      const selectedResources = this.resources.filter(r => r.selected).map(r => r.resource);

      this.resourceService
        .submitResourceRequest(selectedResources)
        .subscribe(blob => {

          console.log("Component.Step 1");

          //Success
          console.log('start download:', blob);
          var blob = new Blob([blob], { type: "application/pdf" } );

          console.log("Component.Step 2");
          this.fileSaverService.save(blob, "terrademo.zip");
        });
    }

    ngAfterViewChecked() {
        this.highlightService.highlightAll();
    }
}
