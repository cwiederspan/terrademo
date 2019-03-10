using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using Terrademo.Backend.Models;
using System.IO.Compression;

[assembly: System.Runtime.CompilerServices.InternalsVisibleTo("Terrademo.Backend.UnitTests")]
namespace Terrademo.Backend.Services {

    public interface IResourceService {

        Task<IEnumerable<Resource>> GetResourcesAsync();

        Task<byte[]> BuildResourceFileAsync(IList<string> files);
    }
    
    public class ResourceService : IResourceService {

        private readonly string Root;

        public ResourceService(string root) {
            this.Root = root;
        }

        public async Task<IEnumerable<Resource>> GetResourcesAsync() {

            var files = Directory.EnumerateFiles(this.Root)?.ToList();

            if (files is null || files.Count == 0) {
                throw new FileNotFoundException($"Unable to find files in location '{this.Root}'.");
            }

            var resources = await this.ParseFilesAsync(files);
            return resources;
        }

        public async Task<byte[]> BuildResourceFileAsync(IList<string> files) {

            var data = new byte[0];
            var variables = new List<string>();

            using (var memoryStream = new MemoryStream()) {

                using (var archive = new ZipArchive(memoryStream, ZipArchiveMode.Create, true)) {

                    var tasks = files.Select(async filename => {

                        var filepath = Path.Combine(this.Root, filename);
                        var resource = await this.ParseFileAsync(filepath);

                        var file = archive.CreateEntry(filename);

                        using (var entryStream = file.Open())
                        using (var sw = new StreamWriter(entryStream)) {
                            sw.Write(resource.Content);
                        }

                        variables.AddRange(resource.Variables);
                    });

                    // Wait for all of the tasks to complete
                    await Task.WhenAll(tasks);

                    // Get the content for the variables file
                    var varContent = this.BuildVariableContent(variables);

                    // Don't create the variables file if it's just going to be empty
                    if (String.IsNullOrWhiteSpace(varContent) == false) {

                        // Add and write out a variables file
                        var varFile = archive.CreateEntry("terraform.tfvars");

                        using (var entryStream = varFile.Open())
                        using (var sw = new StreamWriter(entryStream)) {
                            sw.Write(varContent);
                        }
                    }
                }

                data = memoryStream.ToArray();
            }

            return data;
        }

        internal async Task<IEnumerable<Resource>> ParseFilesAsync(IList<string> files) {

            var tasks = files.Select(async file => await this.ParseFileAsync(file));

            return await Task.WhenAll(tasks);
        }

        internal async Task<Resource> ParseFileAsync(string filepath) {

            var filename = Path.GetFileName(filepath);
            var content = await File.ReadAllTextAsync(filepath);

            var resource = new Resource() {
                Filename = filename,
                Author = this.ParseValue("Author", content),
                Title = this.ParseValue("Title", content),
                Description = this.ParseValue("Description", content),
                Content = content.Trim(),
                Variables = this.ParseVariables(content)
            };

            return resource;
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

        internal string BuildVariableContent(IList<string> variables) {

            // Make sure the list is not null
            var content = "";
            variables = variables ?? new List<string>();

            var uniqueVars = variables.Distinct().ToList();

            if (uniqueVars.Count > 0) {

                var maxLen = uniqueVars.Max(v => v.Length);

                var varLines = uniqueVars
                    .Select(v => string.Format($"{v.PadRight(maxLen, ' ')} = \"\"\n", v))
                    .OrderBy(v => v)
                    .ToList();

                content = String.Concat(varLines);
            }

            return content;
        }
    }
}
 