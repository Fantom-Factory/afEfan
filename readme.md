# efan v2.0.2
---

[![Written in: Fantom](http://img.shields.io/badge/written%20in-Fantom-lightgray.svg)](http://fantom-lang.org/)
[![pod: v2.0.2](http://img.shields.io/badge/pod-v2.0.2-yellow.svg)](http://eggbox.fantomfactory.org/pods/afEfan)
[![Licence: ISC](http://img.shields.io/badge/licence-ISC-blue.svg)](https://choosealicense.com/licenses/isc/)

## Overview

`efan` is a library for rendering Embedded Fantom (efan) templates.

Like `EJS` for Javascript, `ERB` for Ruby and `JSP` for Java, `efan` lets you embed snippets of Fantom code inside textual templates.

`efan` aims to hit the middle ground between programmatically rendering markup with [web::WebOutStream](http://fantom.org/doc/web/WebOutStream.html) and rendering logicless templates such as [Mustache](http://eggbox.fantomfactory.org/pods/mustache).

> **ALIEN-AID:** Create powerful re-usable components with [efanXtra](http://eggbox.fantomfactory.org/pods/afEfanXtra) and [IoC](http://eggbox.fantomfactory.org/pods/afIoc) !!!

> **ALIEN-AID:** If rendering HTML, use [Slim](http://eggbox.fantomfactory.org/pods/afSlim) !!! The concise and lightweight template syntax makes generating HTML easy!

## Install

Install `efan` with the Fantom Pod Manager ( [FPM](http://eggbox.fantomfactory.org/pods/afFpm) ):

    C:\> fpm install afEfan

Or install `efan` with [fanr](http://fantom.org/doc/docFanr/Tool.html#install):

    C:\> fanr install -r http://eggbox.fantomfactory.org/fanr/ afEfan

To use in a [Fantom](http://fantom-lang.org/) project, add a dependency to `build.fan`:

    depends = ["sys 1.0", ..., "afEfan 2.0"]

## Documentation

Full API & fandocs are available on the [Eggbox](http://eggbox.fantomfactory.org/pods/afEfan/) - the Fantom Pod Repository.

## Quick Start

1. Create a text file called `Example.fan`

        using afEfan
        
        class Example {
            Void main() {
                template := """<% ctx.times |i| { %>
                                  Ho!
                               <% } %>
                               Merry Christmas!"""
        
                text := Efan().render(template, 3)
        
                echo(text)  // --> Ho! Ho! Ho! Merry Christmas!
            }
        }


2. Run `Example.fan` as a Fantom script from the command line:

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

All whitespace in efan templates is preserved, except for when a line exists only to contain a code block (or similar). This has the effect of removing unwanted line breaks. For example:

```
Hey! It's
<% if (ctx.isXmas) { %>
  Christmas
<% } %>
Time!
```

is rendered as:

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

Efan().render(template, ctx)
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

Efan().render(template, ctx)
```

### Warning!

All classes not in `sys` (and that includes all classes in your application) need to be referenced by their fully qualified class name:

    <% concurrent::Actor.sleep(2sec) %>

Or imported with `<%? using %>` statements:

    <%? using concurrent %>
    <% Actor.sleep(2sec) %>

This is because compiled efan code resides in a newly constructed pod!

## View Helpers

Efan lets you provide view helpers for common tasks. View helpers are `classes` or `mixins` that your efan template will extend, giving your templates access to commonly used methods. Example, for escaping XML:

```
mixin XmlViewHelper {
    Str xml(Str str) {
        str.toXml()
    }
}
```

Set view helpers when calling efan:

```
Efan().render(template, ctx, [XmlViewHelper#])
```

Template usage would then be:

```
<p>
    Hello <%= xml(ctx.name) %>!
</p>
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

## How efan Works

Efan works by converting the efan template string in to Fantom source code. It then compiles this source code into a new Fantom class.  This new Fantom class extends any given `ViewHelpers` and has a hidden `render()` method. That is how code in the template is able to access the `ViewHelpers`.

Because types can not be *unloaded*, if you were compile 1000s of efan templates, it could be considered a memory leak.

Each invocation of `Efan.compileXXX()` creates a new Fantom type, so use it judiciously. Caching the returned [EfanMeta](http://eggbox.fantomfactory.org/pods/afEfan/api/EfanMeta) classes is highly recommended. Example:

```
efanStr  := "<% ctx.times |i| { %>Ho! <% } %>"
template := Efan().compile(efanStr, Int#)  // <-- cache this!

ho       := template.render(1)
hoho     := template.render(2)
hohoho   := template.render(3)
```

## IoC

When efan is added as a dependency to an IoC enabled application, such as [BedSheet](http://eggbox.fantomfactory.org/pods/afBedSheet) or [Reflux](http://eggbox.fantomfactory.org/pods/afReflux), then the following services are automatically made available to IoC:

- [Efan](http://eggbox.fantomfactory.org/pods/afEfan/api/Efan)
- [EfanCompiler](http://eggbox.fantomfactory.org/pods/afEfan/api/EfanCompiler)
- [EfanParser](http://eggbox.fantomfactory.org/pods/afEfan/api/EfanParser)

This makes use of the non-invasive module feature of IoC 3.

