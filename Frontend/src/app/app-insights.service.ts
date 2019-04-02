import { Injectable } from '@angular/core';
import { AppInsights } from 'applicationinsights-js';
// import * as decode from 'jwt-decode';
import { environment } from 'src/environments/environment';

@Injectable()
export class AppInsightService {

  private config: Microsoft.ApplicationInsights.IConfig = {
    instrumentationKey: environment.appInsightsKey
  };

  constructor() {

    if (!AppInsights.config) {

      AppInsights.downloadAndSetup(this.config);

      // If you want to log UserId in metrices
      // Logic to get logged in User
      //var user = User.GetUser();
      //AppInsights.setAuthenticatedUserContext(user);
    }
  }

  public logPageView(
    name?: string,
    url?: string,
    properties?: any,
    measurements?: any,
    duration?: number
  ) {
    AppInsights.trackPageView(name, url, properties, measurements, duration);
  }

  public logEvent(name: string, properties?: any, measurements?: any) {
    AppInsights.trackEvent(name, properties, measurements);
  }

  public logException(
    exception: Error,
    handledAt?: string,
    properties?: any,
    measurements?: any
  ) {
    AppInsights.trackException(exception, handledAt, properties, measurements);
  }

  public logTrace(message: string, properties?: any, severityLevel?: any) {
    AppInsights.trackTrace(message, properties, severityLevel);
  }
}