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

            var files = Directory.EnumerateFiles(this.Root).ToList();
            var resources = await this.ProcessFilesAsync(files);
            return resources;
        }

        internal async Task<IEnumerable<Resource>> ProcessFilesAsync(IList<string> files) {

            var tasks = files.Select(async file => {

                var filename = Path.GetFileName(file);
                var content = await File.ReadAllTextAsync(file);

                var resource = new Resource() {
                    Filename = filename,
                    Author = this.ParseValue("Author", content),
                    Title = this.ParseValue("Title", content),
                    Description = this.ParseValue("Description", content),
                    Variables = this.ParseVariables(content)
                };

                return resource;
            });

            return await Task.WhenAll(tasks);
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

        internal IList<string> ParseVariables(string content) {
            
            var exp = @"\$\{var.(?<variable>\w+)\}";
            var matches = Regex.Matches(content, exp, RegexOptions.IgnoreCase | RegexOptions.Multiline);
            var variables = matches.SelectMany(m => m.Groups["variable"].Captures.Select(c => c.Value)).Distinct().ToList();

            return variables;
        }
    }
}
 