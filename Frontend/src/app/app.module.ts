import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { HttpClientModule } from '@angular/common/http';

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';

import { BrowserAnimationsModule } from '@angular/platform-browser/animations';

import { FlexLayoutModule } from '@angular/flex-layout';
import { MatMenuModule, MatExpansionModule, MatIconModule, MatToolbarModule, MatTableModule, MatButtonModule, MatChipsModule, MatDialogModule, MAT_DIALOG_DEFAULT_OPTIONS, MatFormFieldModule, MatInputModule, MatCheckboxModule, MatDividerModule, MatSlideToggleModule, MatCardModule } from '@angular/material';
import { HighlightService } from './highlight.service';
import { ResourceService } from './resource.service';

import { FileSaverModule } from 'ngx-filesaver';

@NgModule({
  declarations: [
    AppComponent
  ],
  imports: [
    BrowserModule,
    AppRoutingModule,
    BrowserAnimationsModule,
    HttpClientModule,

    FlexLayoutModule,
    
    MatDialogModule,
    MatToolbarModule,
    MatMenuModule,
    MatIconModule,
    MatTableModule,
    MatButtonModule,
    MatCheckboxModule,
    MatChipsModule,
    MatInputModule,
    MatFormFieldModule,
    MatDividerModule,
    MatExpansionModule,
    MatSlideToggleModule,
    MatCardModule,

    FileSaverModule
  ],
  providers: [
    {provide: MAT_DIALOG_DEFAULT_OPTIONS, useValue: {hasBackdrop: false}},
    HighlightService,
    ResourceService
  ],
  bootstrap: [AppComponent]
})
export class AppModule { }
