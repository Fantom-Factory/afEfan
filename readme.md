#efan v1.5.0
---
[![Written in: Fantom](http://img.shields.io/badge/written%20in-Fantom-lightgray.svg)](http://fantom.org/)
[![pod: v1.5.0](http://img.shields.io/badge/pod-v1.5.0-yellow.svg)](http://www.fantomfactory.org/pods/afEfan)
![Licence: MIT](http://img.shields.io/badge/licence-MIT-blue.svg)

## Overview

`efan` is a library for rendering Embedded Fantom (efan) templates.

Like `EJS` for Javascript, `ERB` for Ruby and `JSP` for Java, `efan` lets you embed snippets of Fantom code inside textual templates.

`efan` aims to hit the middle ground between programmatically rendering markup with [web::WebOutStream](http://fantom.org/doc/web/WebOutStream.html) and rendering logicless templates such as [Mustache](https://bitbucket.org/xored/mustache/).

> **ALIEN-AID:** Create powerful re-usable components with [efanXtra](http://pods.fantomfactory.org/pods/afEfanXtra) and [IoC](http://pods.fantomfactory.org/pods/afIoc) !!!

> **ALIEN-AID:** If rendering HTML, use [Slim](http://pods.fantomfactory.org/pods/afSlim) !!! The concise and lightweight template syntax makes generating HTML easy!

## Install

Install `efan` with the Fantom Repository Manager ( [fanr](http://fantom.org/doc/docFanr/Tool.html#install) ):

    C:\> fanr install -r http://pods.fantomfactory.org/fanr/ afEfan

To use in a [Fantom](http://fantom.org/) project, add a dependency to `build.fan`:

    depends = ["sys 1.0", ..., "afEfan 1.5"]

## Documentation

Full API & fandocs are available on the [Fantom Pod Repository](http://pods.fantomfactory.org/pods/afEfan/).

## Quick Start

1. Create a text file called `xmas.efan`

        <% ctx.times |i| { %>
           Ho!
        <% } %>
        Merry Christmas!


2. Create a text file called `Example.fan`

        using afEfan
        
        class Example {
            Void main() {
                template := `xmas.efan`.toFile.readAllStr
        
                text := Efan().renderFromFile(template, 3)  // --> Ho! Ho! Ho! Merry Christmas!
                echo(text)
            }
        }


3. Run `Example.fan` as a Fantom script from the command line:

        C:\> fan Example.fan
        Ho! Ho! Ho! Merry Christmas!



## Tags

Efan supports the following tags:

### Eval Tags

Any tag with the prefix `<%=` will evaluate the fantom expression and write it out as a Str.

    Hello, <%= "Emma".upper %>!

### Comment Tags

Any tag with the prefix `<%#` is a comment and will be left out of the resulting template.

    <%# This is just a comment %>

### Code Tags

Any tag with the prefix `<%` will be converted into Fantom code.

    <% echo("Hello!") %>

### Instruction Tags

The content of any tag with the prefix `<%?` is taken to be a Fantom `using` instruction.

    <%? using concurrent::Actor %>

### Escaping Tags

All efan tags can be escaped by adding an extra `%` character to the start and end tags. Example:

    This is how you <%%= escape %%> efan tags.

prints:

    This is how you <%= escape %> efan tags.

### Whitespace

All whitespace in efan templates is preserved, except for when a line exists only to contain a code block (or similar). This has the effect of removing unwanted line breaks. Consider:

```
Hey! It's
<% if (ctx.isXmas) { %>
  Christmas
<% } %>
Time!
```

would be rendered as

```
Hey! It's
  Christmas
Time!
```

and not:

```
Hey! It's

  Christmas

Time!
```

(Advanced users may turn this feature off in `EfanCompiler`.)

## Template Context

Each template render method takes an argument called `ctx` which you can reference in your template. `ctx` is typed to whatever Obj you pass in, so you don't need to cast it. Examples:

Using maps:

```
ctx := ["name":"Emma"]  // ctx is a map

template := "Hello <%= ctx["name"] %>!"

Efan().renderFromStr(template, ctx)
```

Using objs:

```
class Entity {
    Str name
    new make(Str name) { this.name = name }
}

...

template := "Hello <%= ctx.name %>!"
ctx      := Entity("Emma")  // ctx is an Entity

Efan().renderFromStr(template, ctx)
```

### Warning!

All classes not in `sys` (and that includes all classes in your application) need to be referenced by their fully qualified class name:

    <% concurrent::Actor.sleep(2sec) %>

Or imported with `<%? using %>` statements:

    <%? using concurrent %>
    <% Actor.sleep(2sec) %>

This is because compiled efan code resides in a newly constructed pod!

## View Helpers

Efan lets you provide view helpers for common tasks. View helpers are `mixins` that your efan template will extend, giving your templates access to commonly used methods. Example, for escaping XML:

```
mixin XmlViewHelper {
    Str xml(Str str) {
        str.toXml()
    }
}
```

Set view helpers when calling efan:

```
Efan().renderFromStr(template, ctx, [XmlViewHelper#])
```

Template usage would then be:

```
<p>
    Hello <%= xml(ctx.name) %>!
</p>
```

## Layout Pattern / Nesting Templates

Efan templates may be nested inside one another, effectively allowing you to componentise your templates. This is accomplished by passing body functions in to the efan `render()` method and calling `renderBody()` to invoke it.

This is best explained in an example. Here we will use the *layout pattern* to place some common HTML into a `layout.efan` file:

layout.efan:

```
<head>
    <title><%= ctx %></title>
</head>
<body>
    <%= renderBody() %>
</body>
```

index.efan:

```
<html>
<%= ctx.layout.render("Cranberry Whips") { %>
    ...my cool page content...
<% } %>
</html>
```

Code to run the above example:

Index.fan:

```
using afEfan

class Index {
    Str renderIndex() {
        index     := efan().compileFromFile(`index.efan` .toFile, EfanTemplate#)
        layout    := efan().compileFromFile(`layout.efan`.toFile, Str#)

        return index.render(layout)
    }
}
```

This produces an amalgamation of the two templates:

```
<html>
<head>
    <title>Cranberry Whips</title>
</head>
<body>
    ...my cool page content...
</body>
</html>
```

## Err Reporting

Efan compilation and runtime Errs report snippets of code showing which line in the `efan` template the error occurred. Example:

```
Efan Compilation Err:
  file:/projects/fantom/Efan/test/app/compilationErr.efan : Line 17
    - Unknown variable 'dude'

    12: Five space-worthy orbiters were built; two were destroyed in mission accidents. The Space...
    13: </textarea><br/>
    14:         <input id="submitButton" type="button" value="Submit">
    15:     </form>
    16:
==> 17: <% dude %>
    18: <script type="text/javascript">
    19:     <%# the host domain where the scanner is located %>
    20:
    21:     var plagueHost = "http://fan.home.com:8069";
    22:     console.debug(plagueHost);
```

This really helps you see where typos occurred.

## Templates

Efan works by dynamically generating Fantom source code and compiling it into a Fantom type. Because types can not be *unloaded*, if you were compile 1000s of efan templates, it could be considered a memory leak.

Each invocation of `Efan.compileXXX()` creates a new Fantom type, so use it judiciously. Caching the returned [EfanTemplate](http://pods.fantomfactory.org/pods/afEfan/api/EfanTemplate) classes is highly recommended. Example:

```
efanStr  := "<% ctx.times |i| { %>Ho! <% } %>"
template := Efan().compileFromStr(efanStr, Int#)  // <-- cache this template!

ho       := template.render(1)
hoho     := template.render(2)
hohoho   := template.render(3)
```

