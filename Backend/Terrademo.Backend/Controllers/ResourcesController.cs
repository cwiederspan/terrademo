using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Hosting;
using Terrademo.Backend.Services;
using Terrademo.Backend.Models;
using System.Net;
using System.Text;

namespace Terrademo.Backend.Controllers {

    //[Route("api/[controller]")]
    [ApiController]
    public class ResourcesController : ControllerBase {

        private readonly IResourceService Service;

        public ResourcesController(
            IResourceService service  
        ) {

            this.Service = service;
        }

        // GET api/resources
        [HttpGet("api/resources")]
        public async Task<ActionResult<IEnumerable<Resource>>> GetAsync() {

            try {

                var resources = await this.Service.GetResourcesAsync();
                return this.Ok(resources);
            }
            catch (Exception ex) {
                return this.StatusCode((int)HttpStatusCode.InternalServerError, ex.Message);
            }
        }

        // POST api/resources
        [HttpPost("api/resources")]
        public async Task<IActionResult> PostAsync([FromBody] ResourceRequest request) {

            try {

                var data = await this.Service.BuildResourceFileAsync(request.Files);
                return this.File(data, "application/zip");
            }
            catch (Exception ex) {
                return this.StatusCode((int)HttpStatusCode.InternalServerError, ex.Message);
            }
        }

        // POST api/resources
        [HttpGet("api/resources/download")]
        public async Task<IActionResult> GetDownloadAsync(string data) {

            try {

                byte[] bytes = Convert.FromBase64String(data);
                string files = Encoding.UTF8.GetString(bytes);
                string[] filenames = files.Split(",");

                var zipdata = await this.Service.BuildResourceFileAsync(filenames);
                return this.File(zipdata, "application/zip");
            }
            catch (Exception ex) {
                return this.StatusCode((int)HttpStatusCode.InternalServerError, ex.Message);
            }
        }
    }
}
