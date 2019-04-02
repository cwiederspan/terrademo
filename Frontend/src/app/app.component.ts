import { Component, Inject, OnInit, AfterViewChecked } from '@angular/core';
import { DOCUMENT } from '@angular/common';
import { HighlightService } from './highlight.service';
import { ResourceService } from './resource.service';
import { ResourceViewModel } from './resource.viewmodel';

import { FileSaverService } from 'ngx-filesaver';
import { MatSlideToggle } from '@angular/material';

import { environment } from 'src/environments/environment';
import { AppInsightService } from './app-insights.service';

@Component({
    selector: 'app-root',
    templateUrl: './app.component.html',
    styleUrls: ['./app.component.less']
})
export class AppComponent implements OnInit, AfterViewChecked {

    title = 'Terrademo';

    public resources: ResourceViewModel[] = [];

    constructor(
      @Inject(DOCUMENT) private doc: any,
      private appInsightService: AppInsightService,
      private resourceService: ResourceService,
      private highlightService: HighlightService,
      private fileSaverService: FileSaverService
    ) {
    
      this.resourceService
        .getResources()
        .subscribe(data => this.resources = data.map(r => new ResourceViewModel(r)));

      this.highlightService.highlightAll();
    }

    ngOnInit(): void {

      this.setAppInsights();
      this.appInsightService.logEvent('Message', 'Application Loaded.');
    } 

    public filterByTag(tag: string, item: MatSlideToggle) {
      
      console.log(`Changing ${tag} to ${item.checked}...`);

      this.resources.forEach(vm => {
        if (vm.resource.tags.includes(tag) === true) {
          console.log("It working!!!");
          vm.visible = item.checked;
        }
      });
    }

    public downloadFile() {

      const selectedResources = this.resources.filter(r => r.selected).map(r => r.resource);

      this.resourceService
        .submitResourceRequest(selectedResources)
        .subscribe(blob => this.fileSaverService.save(blob, "terrademo.zip"));
    }

    ngAfterViewChecked() {
    this.highlightService.highlightAll();
    }

    
    private setAppInsights() {

    try {

      const s = this.doc.createElement('script');
      s.type = 'text/javascript';
      s.innerHTML = 'var appInsights=window.appInsights||function(a){ function b(a){c[a]=function(){var b=arguments;c.queue.push(function(){c[a].apply(c,b)})}}var c={config:a},d=document,e=window;setTimeout(function(){var b=d.createElement("script");b.src=a.url||"https://az416426.vo.msecnd.net/scripts/a/ai.0.js",d.getElementsByTagName("script")[0].parentNode.appendChild(b)});try{c.cookie=d.cookie}catch(a){}c.queue=[];for(var f=["Event","Exception","Metric","PageView","Trace","Dependency"];f.length;)b("track"+f.pop());if(b("setAuthenticatedUserContext"),b("clearAuthenticatedUserContext"),b("startTrackEvent"),b("stopTrackEvent"),b("startTrackPage"),b("stopTrackPage"),b("flush"),!a.disableExceptionTracking){f="onerror",b("_"+f);var g=e[f];e[f]=function(a,b,d,e,h){var i=g&&g(a,b,d,e,h);return!0!==i&&c["_"+f](a,b,d,e,h),i}}return c }({ instrumentationKey:' + environment.appInsightsKey + ' }); window.appInsights=appInsights,appInsights.queue&&0===appInsights.queue.length&&appInsights.trackPageView();';
      const head = this.doc.getElementsByTagName('head')[0];
        head.appendChild(s);
      }
      catch {

      }
    }
}
