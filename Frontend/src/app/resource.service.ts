import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, of } from 'rxjs';
import { catchError, tap } from 'rxjs/operators';

import { Resource } from './shared/models';
import { environment } from '../environments/environment';

@Injectable({ providedIn: 'root' })
export class ResourceService {

    private baseUrl: string;

    constructor(
        private http: HttpClient
    ) {
        
        this.baseUrl = `${environment.backendUrl}/api/resources`;
    }

    /** GET heroes from the server */
    public getResources(): Observable<Resource[]> {

        const url = `${this.baseUrl}`;

        console.log(`ResourceService.getResources with URL '${url}'...`);

        return this.http.get<Resource[]>(url)
            .pipe(
                tap(r => this.log(`fetched resources`)),
                tap(r => r.sort((a, b) => a.filename.localeCompare(b.filename))),
                catchError(this.handleError('getResources', []))
            );
    }

    /**
     * Handle Http operation that failed.
     * Let the app continue.
     * @param operation - name of the operation that failed
     * @param result - optional value to return as the observable result
     */
    private handleError<T>(operation = 'operation', result?: T) {

        return (error: any): Observable<T> => {

            // TODO: send the error to remote logging infrastructure
            console.error(error); // log to console instead

            // TODO: better job of transforming error for user consumption
            this.log(`${operation} failed: ${error.message}`);

            // Let the app keep running by returning an empty result.
            return of(result as T);
        };
    }

    /** Log a HeroService message with the MessageService */
    private log(message: string) {
        console.log('ResourceService: ' + message);
    }
}
