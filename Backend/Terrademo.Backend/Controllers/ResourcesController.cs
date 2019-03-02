using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Hosting;
using Terrademo.Backend.Services;
using Terrademo.Backend.Models;

namespace Terrademo.Backend.Controllers {

    [Route("api/[controller]")]
    [ApiController]
    public class ResourcesController : ControllerBase {

        private readonly IResourceService Service;

        public ResourcesController(
            IResourceService service  
        ) {

            this.Service = service;
        }

        // GET api/resources
        [HttpGet]
        public async Task<ActionResult<IEnumerable<Resource>>> GetAsync() {

            var resources = await this.Service.GetResourcesAsync();

            return this.Ok(resources);
        }

        // POST api/resources
        [HttpPost]
        public void Post([FromBody] string value) {

        }
    }
}
