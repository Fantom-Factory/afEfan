# afEfan

`efan` is a [Fantom](http://fantom.org/) library for rendering Embedded Fantom (efan) templates.

Much like `EJS` for Javascript, `ERB` for Ruby and `JSP` for Java, `efan` allows you to embed snippets of Fantom code inside textual templates.

`efan` aims to hit the middle ground between programmatically rendering markup with `web::WebOutStream` and using logicless templates with [Mustache](https://bitbucket.org/xored/mustache/).



## Install

Download from [status302](http://repo.status302.com/browse/afEfan).

Or install via fanr:

    $ fanr install -r http://repo.status302.com/fanr/ afEfan

To use in a project, add a dependency in your `build.fan`:

    depends = ["sys 1.0", ..., "afEfan 1+"]



## Documentation

Full API & fandocs are available on the [status302 repository](http://repo.status302.com/doc/afEfan/#overview).



## Quick Start

1). Create a text file called `xmas.efan`:

      <% ctx.times |i| { %>
        Ho!
      <% } %>
      Merry Christmas!

2). Create a text file called `Example.fan`:

    using afEfan

    class Example {
        Void main() {
            template := `xmas.efan`.toFile.readAllStr

            text := Efan().renderFromFile(template, 3)  // --> Ho! Ho! Ho! Merry Christmas!
            echo(text)
        }
    }

3). Run `Example.fan` as a Fantom script from the command line:

    C:\> fan Example.fan
    Ho! Ho! Ho! Merry Christmas!
