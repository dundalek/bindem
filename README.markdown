# Backbone Bind'em

A light-weight javascript library providing [Knockout](https://knockoutjs.com/)-like two-way declarative data binding for [Backbone](https://documentcloud.github.com/backbone/).

[Homepage](https://dundalek.com/bindem/)

Demos: [examples.html](https://dundalek.com/bindem/examples.html)

## Example code

```html
<div class='liveExample'>   
    <p>First name: <input class='firstName' /></p> 
    <p>Last name: <input class='lastName' /></p> 
    <h2>Hello, <span class='firstName'> </span> <span class='lastName'> </span>!</h2><br/>
    <label for="showInfo">Show info</label> <input type="checkbox" name="showInfo" />
    <span id='info'> </span>
</div>​
```

```javascript
var View = Backbone.View.extend({
    modelBindings: {
        firstName: {
            text: 'span.firstName',
            value: {
                selector: 'input.firstName',
                event: 'keyup' }},
        lastName: {
            text: 'span.lastName',
            value: {
                selector: 'input.lastName',
                event: 'keyup' }},
        info: {
            html: '#info' },
        showInfo: {
            checked: '[name=showInfo]',
            visible: '#info' }
    },
    initialize: function() {
        Bindem.on.call(this, this.modelBindings, {initialize: true});
    }
});

var personModel = new Backbone.Model({
    firstName: 'John',
    lastName: 'Smith',
    info: 'Try to write something in the <i>input fields</i> and see what happens.',
    showInfo: false
});

var view = new View({
    model: personModel,
    el: $('.liveExample')
});
```
