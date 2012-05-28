
eq = strictEqual

root = null
el = null
model = null
view = null

QUnit.done = QUnit.testStart = ->
    root = $('#el')
    if root.length > 0
        root.remove()
    root = $('<div id="el"><div></div></div>').appendTo($('body'))
    el = root.find('div')
    model = new Backbone.Model()
    view = new Backbone.View({el: root, model: model})

module 'options'

test 'model from view', ->
    bindings =
        str:
            text: 'div'
    Bindem.on.call view, bindings
    model.set 'str', 'hello'

    eq el.text(), 'hello'

test 'model option', ->
    bindings =
        str:
            text: 'div'
    Bindem.on.call null, bindings, {root: root, model: model}
    model.set 'str', 'hello'

    eq el.text(), 'hello'

test 'initialize true', ->
    model.set 'str', 'hello'
    bindings =
        str:
            text: 'div'
    Bindem.on.call view, bindings, {initialize: true}

    eq el.text(), 'hello'

test 'object literal', ->
    bindings =
        str:
            text:
                selector: 'div'
    Bindem.on.call view, bindings
    model.set 'str', 'hello'

    eq el.text(), 'hello'

test 'array', ->
    root.html('<span></span><div></div>')
    bindings =
        str:
            text: [
                'span'
                selector: 'div'
            ]
    Bindem.on.call view, bindings
    model.set 'str', 'hello'

    eq root.find('span').text(), 'hello'
    eq root.find('div').text(), 'hello'

test 'event option', ->
    root.html('<input type="text">')
    el = root.find('input')
    bindings =
        str:
            value:
                selector: 'input',
                event: 'keyup'
    Bindem.on.call view, bindings
    model.set 'str', 'hello'

    eq el.val(), 'hello'

    el.val('hellox')

    eq model.get('str'), 'hello'

    el.trigger($.Event('keyup'))

    eq model.get('str'), 'hellox'

module 'bindings'

test 'text', ->
    # already tested in options module
    ok true

test 'html', ->
    bindings =
        str:
            html: 'div'
    Bindem.on.call view, bindings
    model.set 'str', 'hello <i>world</i>'

    ok el.html() == 'hello <i>world</i>' || el.html() == 'hello <I>world</I>'
    eq el.text(), 'hello world'

test 'css', ->
    bindings =
        attr:
            css:
                'hello': 'div'
    Bindem.on.call view, bindings
    model.set 'attr', true

    eq el.attr('class'), 'hello'

    model.set 'attr', false

    eq el.attr('class'), ''

test 'style', ->
    bindings =
        attr:
            style:
                'text-decoration': 'div'
    Bindem.on.call view, bindings
    model.set 'attr', 'underline'

    eq el.css('text-decoration'), 'underline'

    model.set 'attr', 'none'

    eq el.css('text-decoration'), 'none'

test 'attr', ->
    bindings =
        str:
            attr:
                title: 'div'
    Bindem.on.call view, bindings
    model.set 'str', 'hello'

    eq el.attr('title'), 'hello'

test 'visible', ->
    bindings =
        attr:
            visible: 'div'
    Bindem.on.call view, bindings
    model.set 'attr', false

    ok !el.is(':visible')

    model.set 'attr', true

    ok el.is(':visible')

test 'hidden', ->
    bindings =
        attr:
            hidden: 'div'
    Bindem.on.call view, bindings
    model.set 'attr', true

    ok !el.is(':visible')

    model.set 'attr', false

    ok el.is(':visible')

test 'enable', ->
    root.html('<input type="text">')
    el = root.find('input')
    bindings =
        attr:
            enable: 'input'
    Bindem.on.call view, bindings
    model.set 'attr', false

    ok el.is(':disabled')

    model.set 'attr', true

    ok !el.is(':disabled')

test 'disable', ->
    root.html('<input type="text">')
    el = root.find('input')
    bindings =
        attr:
            disable: 'input'
    Bindem.on.call view, bindings
    model.set 'attr', true

    ok el.is(':disabled')

    model.set 'attr', false

    ok !el.is(':disabled')

test 'value', ->
    root.html('<input type="text"><textarea></textarea>')
    input = root.find('input')
    textarea = root.find('textarea')
    bindings =
        attr:
            value: ['input', 'textarea']
    Bindem.on.call view, bindings
    model.set 'attr', 'hello'

    eq input.val(), 'hello'
    eq textarea.val(), 'hello'

    input.val('hi')
    input.trigger('change')

    eq textarea.val(), 'hi'
    eq model.get('attr'), 'hi'

    textarea.val('hola')
    textarea.trigger('change')

    eq input.val(), 'hola'
    eq model.get('attr'), 'hola'

test 'change', 6, ->
    root.html('<input type="text">')
    el = root.find('input')
    value = 'hello'
    bindings =
        attr:
            value: 'input'
            change: [((val) ->
                eq val, value),
                'onChange']
    view.onChange = (val) ->
        eq val, value
    Bindem.on.call view, bindings
    model.set 'attr', value

    eq el.val(), 'hello'

    value = 'hi'
    el.val('hi')
    el.trigger('change')

    eq model.get('attr'), 'hi'

test 'checked checkbox', ->
    root.html('<input type="checkbox">')
    el = root.find('input')
    bindings =
        attr:
            checked: 'input'
    Bindem.on.call view, bindings
    model.set 'attr', true

    ok el.is(':checked')

    model.set 'attr', false

    ok !el.is(':checked')

    el.attr('checked', true)
    el.click()

    ok model.get('attr')

    el.attr('checked', false)
    el.click()

    ok !model.get('attr')

test 'checked radio', ->
    root.html('''<label><input type="radio" value="Alpha" />Alpha</label>
                <label><input type="radio" value="Beta"  />Beta</label>
                <label><input type="radio" value="Gamma" />Gamma</label>''')
    bindings =
        attr:
            checked: 'input'
    Bindem.on.call view, bindings
    model.set 'attr', 'Alpha'

    ok root.find('[value=Alpha]').is(':checked')
    ok !root.find('[value=Beta]').is(':checked')
    ok !root.find('[value=Gamma]').is(':checked')

    root.find('[value=Beta]').attr('checked', true).click()

    eq model.get('attr'), 'Beta'

    ok !root.find('[value=Alpha]').is(':checked')
    ok root.find('[value=Beta]').is(':checked')
    ok !root.find('[value=Gamma]').is(':checked')

test 'checked radio multiple selectors', ->
    root.html('''<label><input type="radio" value="Alpha" />Alpha</label>
                <label><input type="radio" value="Beta"  />Beta</label>
                <label><input type="radio" value="Gamma" />Gamma</label>''')
    bindings =
        attr:
            checked: ['[value=Alpha]', {selector: '[value=Beta]'}, '[value=Gamma]']
    Bindem.on.call view, bindings
    model.set 'attr', 'Alpha'

    ok root.find('[value=Alpha]').is(':checked')
    ok !root.find('[value=Beta]').is(':checked')
    ok !root.find('[value=Gamma]').is(':checked')

    root.find('[value=Beta]').attr('checked', true).click()

    eq model.get('attr'), 'Beta'

    ok !root.find('[value=Alpha]').is(':checked')
    ok root.find('[value=Beta]').is(':checked')
    ok !root.find('[value=Gamma]').is(':checked')

test 'hasfocus', ->
    root.html('<input type="text">')
    el = root.find('input')
    bindings =
        attr:
            hasfocus: 'input'
    Bindem.on.call view, bindings
    model.set 'attr', false

    ok !el.is(':focus')

    model.set 'attr', true

    ok el.is(':focus')

    el.trigger('blur')

    ok !model.get('attr')

    el.trigger('focus')

    ok model.get('attr')

test 'uniqueName', ->
    root.html('<input type="text">')
    el = root.find('input')
    bindings =
        x:
            uniqueName: 'input'
    Bindem.on.call view, bindings

    ok el.attr('name').length > 0

test 'unbinding', 4, ->
    root.html('<input type="text">')
    el = root.find('input')
    fire = true
    bindings =
        attr:
            value: 'input'
            change: (val) ->
                ok fire
    model.set 'attr', 'hello'
    Bindem.on.call view, bindings, {initialize: true}

    eq el.val(), 'hello'
    fire = false

    Bindem.off.call view, bindings

    value = 'hi'
    el.val('hi')
    el.trigger('change')

    eq model.get('attr'), 'hello'

    model.set 'attr', 'hola'

    eq el.val(), 'hi'
