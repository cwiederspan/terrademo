using System;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.ApplicationInsights.Extensibility.PerfCounterCollector.QuickPulse;

using Terrademo.Backend.Services;
using Microsoft.Extensions.Hosting;

namespace Terrademo.Backend {

    public class Startup {

        public IConfiguration Configuration { get; }

        public Startup(IConfiguration configuration) {
            this.Configuration = configuration;
        }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services) {

            services.AddControllersWithViews();
            services.AddApplicationInsightsTelemetry();

            services.ConfigureTelemetryModule<QuickPulseTelemetryModule>((module, o) => module.AuthenticationApiKey = Configuration.GetValue<string>("ApplicationInsights:SecureApiKey"));

            // Add CORS support
            services.AddCors();

            var contentRoot = $"{this.Configuration.GetValue<string>(WebHostDefaults.ContentRootKey)}/Resources";
            services.AddTransient<Services.IResourceService>(sp => new ResourceService(contentRoot));
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IWebHostEnvironment env) {

            if (env.IsDevelopment()) {
                app.UseDeveloperExceptionPage();
            }

            // Setup the CORS support
            app.UseCors(builder => builder.AllowAnyOrigin().AllowAnyHeader().AllowAnyMethod());

            app.UseRouting();

            app.UseEndpoints(endpoints => {
                endpoints.MapControllerRoute(
                    name: "default",
                    pattern: "{controller=Home}/{action=Index}/{id?}");
            });
        }
    }
}
