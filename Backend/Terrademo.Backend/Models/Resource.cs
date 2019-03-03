using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

using Newtonsoft.Json;

namespace Terrademo.Backend.Models {

    public class Resource {

        public string Filename { get; set; }

        public string Author { get; set; }

        public string Title { get; set; }

        public string Description { get; set; }

        [JsonIgnore]
        public string Content { get; set; }

        public IEnumerable<string> Tags { get; set; }

        [JsonIgnore]
        public IEnumerable<string> Variables { get; set; }

        public Resource() {
            this.Tags = new List<string>();
        }
    }
}
