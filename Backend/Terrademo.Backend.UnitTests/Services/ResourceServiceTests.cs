using System;
using System.Linq;
using System.Collections.Generic;
using Xunit;

namespace Terrademo.Backend.Services {

    public class ResourceServiceTests {

        [Theory]
        [InlineData("Author", "Sample Creator", "#Author: Sample Creator")]
        [InlineData("Author", "Sample Creator", "#Author: Sample Creator  ")]
        [InlineData("Author", "Sample Creator", "# Author: Sample Creator  ")]
        [InlineData("Author", "Sample Creator", "# Author : Sample Creator")]
        [InlineData("Author", "Sample Creator", "# Author: Sample Creator\r\nSome More Stuff Goes Here")]
        [InlineData("Author", "Sample Creator", "# AUTHOR: Sample Creator")]
        [InlineData("Author", "Sample Creator", "# author: Sample Creator")]
        [InlineData("Author", null, "# Author:")]
        [InlineData("Author", null, "#XXX: Sample Creator")]
        public void ParseValue_FromValidValues_ReturnsCorrectLabel(string label, string expected, string content) {

            var sut = new ResourceService("NOT_USED");
            var actual = sut.ParseValue(label, content);
            Assert.Equal(expected, actual);
        }

        [Theory]
        [InlineData("location = \"${not_a_variable}\"", new string[0])]
        [InlineData("location = \"${var.location}\"", new string[] { "location" })]
        [InlineData("  location = \"${var.location}\"  ", new string[] { "location" })]
        [InlineData("location = \"${var.resource_name}\"", new string[] { "resource_name" })]
        [InlineData("location = \"${var.resource}-${var.location}\"", new string[] { "location", "resource" })]
        [InlineData("location = \"${var.resource}\" \r\n resource = \"${var.location}\"", new string[] { "location", "resource" })]
        public void ParseVariables_FromValidValues_ReturnsCorrectListOfVariables(string content, IList<string> expected) {

            var sut = new ResourceService("NOT_USED");
            var actuals = sut.ParseVariables(content);

            var results1 = expected
                .Select(value => !actuals.Contains(value) ? $"Actual values are missing expected value '{value}'" : null)
                .ToList();

            var results2 = actuals
                .Select(value => !expected.Contains(value) ? $"Actual value '{value}' was not in expected results" : null)
                .ToList();

            var results = results1.Concat(results2).Where(x => !String.IsNullOrEmpty(x)).Distinct().ToList();

            Assert.True(results.Count == 0, String.Join("\r\n", results));
        }

        [Theory]
        [InlineData(null, "")]
        [InlineData(new string[0], "")]
        [InlineData(new string[] { "location" }, "location = \"\"\n")]
        [InlineData(new string[] { "location", "location" }, "location = \"\"\n")]
        [InlineData(new string[] { "resource_group", "location" }, "location       = \"\"\nresource_group = \"\"\n")]
        public void BuildVariableContent_FromValidValues_ReturnsCorrectContent(IList<string> variables, string expected) {

            var sut = new ResourceService("NOT_USED");
            var actual = sut.BuildVariableContent(variables);
            Assert.Equal(expected, actual);
        }

        [Theory]
        [InlineData(null, new string[0])]
        [InlineData("", new string[0])]
        [InlineData("Infrastructure", new string[] { "Infrastructure" })]
        [InlineData(" Infrastructure ", new string[] { "Infrastructure" })]
        [InlineData("Infrastructure, Apps", new string[] { "Apps", "Infrastructure" })]
        [InlineData(" Infrastructure , Apps ", new string[] { "Apps", "Infrastructure" })]
        public void ParseTags_FromValidValues_ReturnsCorrectListOfTags(string content, IList<string> expected) {

            var sut = new ResourceService("NOT_USED");
            var actuals = sut.ParseTags(content);

            var results1 = expected
                .Select(value => !actuals.Contains(value) ? $"Actual values are missing expected tag '{value}'" : null)
                .ToList();

            var results2 = actuals
                .Select(value => !expected.Contains(value) ? $"Actual tag '{value}' was not in expected results" : null)
                .ToList();

            var results = results1.Concat(results2).Where(x => !String.IsNullOrEmpty(x)).Distinct().ToList();

            Assert.True(results.Count == 0, String.Join("\r\n", results));
        }
    }
}
