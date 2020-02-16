using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Terrademo.Backend.Models {

    public class ResourceRequest {

        public IList<string> Files { get; set; }

        public ResourceRequest() {
            this.Files = new List<string>();
        }
    }
}
