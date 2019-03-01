using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using Terrademo.Backend.Models;

[assembly: System.Runtime.CompilerServices.InternalsVisibleTo("Terrademo.Backend.UnitTests")]
namespace Terrademo.Backend.Services {

    public interface IResourceService {

        Task<IEnumerable<Resource>> GetResourcesAsync();
    }
    
    public class ResourceService : IResourceService {

        private readonly string Root;

        public ResourceService(string root) {
            this.Root = root;
        }

        public async Task<IEnumerable<Resource>> GetResourcesAsync() {

            var tasks = Directory.EnumerateFiles(this.Root).Select(async file => {

                var content = await File.ReadAllTextAsync(file);

                return this.ParseResource(content);
            });

            return await Task.WhenAll(tasks);
        }

        internal Resource ParseResource(string content) {

            return new Resource() {
                Author = this.ParseValue("Author", content),
                Title = this.ParseValue("Title", content),
                Description = this.ParseValue("Description", content)
            };
        }

        internal string ParseValue(string label, string content) {

            string result = null;

            var exp = $@"[#]\s*({label})\s*[:](?<value>.*)(\r|\n|$)";
            var matches = Regex.Match(content, exp, RegexOptions.IgnoreCase);

            if (String.IsNullOrWhiteSpace(matches.Groups["value"]?.Value) == false) {
                result = matches.Groups["value"].Value.Trim();
            }

            return result;
        }
    }
}
