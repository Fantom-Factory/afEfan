# afEfan

afEfan is a [Fantom](http://fantom.org/) [afIoc](http://repo.status302.com/doc/afIoc/#overview) library for rendering Embedded Fantom (efan) templates.

Much like EJS for Javascript, ERB for Ruby and JSP for Java, EFAN allows you to embed snippets of Fantom code inside textual templates.

Efan hopes to hit the middle ground between programmatically rendering markup with `web::WebOutStream` and using logicless templates with [Mustache](https://bitbucket.org/xored/mustache/).



## Quick Start

xmas.efan:

    <% ctx.times |i| { %>
      Ho! 
    <% } %>
    Merry Christmas!


Fantom code:

    @Inject EfanTemplates efanTemplates

    ...

    // --> Ho! Ho! Ho! Merry Christmas!
    efanTemplates.renderFromFile(`xmas.fan`.toFile, 3)



## Documentation

Full API & fandocs are available on the [status302 repository](http://repo.status302.com/doc/afEfan/#overview).



## Install

Download from [status302](http://repo.status302.com/browse/afEfan).

Or install via fanr:

    $ fanr install -r http://repo.status302.com/fanr/ afEfan

