using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Hosting;
using Terrademo.Backend.Services;
using Terrademo.Backend.Models;
using System.Net;

namespace Terrademo.Backend.Controllers {
    
    [ApiController]
    public class HealthController : ControllerBase {

        // GET api/resources
        [HttpGet("")]
        public IActionResult Get() {

            return this.Ok("Service is healthy");
        }
    }
}
