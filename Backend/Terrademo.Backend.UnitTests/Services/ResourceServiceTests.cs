using System;
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
    }
}
