/*
* Bind'em - A light-weight javascript library providing Knockout-like two-way declarative data binding for Backbone.
*
* Copyright (C) 2012, Jakub Dundalek
* Released under the MIT license.
*
* Homepage:
*   http://dundalek.com/backbone-bindem/
*
* Source code:
*   http://github.com/dundalek/backbone-bindem
*
* Dependencies:
*   jQuery v1.7+
*   Backbone.js
*   Underscore.js
*/
(function (factory) {
    if (typeof define === 'function' && define.amd) {
        // AMD - register as an anonymous module
        define(['jquery', 'underscore'], factory);
    } else if (typeof exports !== 'undefined' && typeof require !== 'undefined') {
        // CommonJS - export everything
        var jQuery = require('jQuery'),
            _ = require('underscore');
        _.extend(exports, factory(jQuery, _));
    } else {
        // running in browser - plug in
        window.Bindem = factory(window.jQuery, window._);
    }
})(function($, _) {
    var Bindem = {
        _bind: function(binding, options, bindModel, bindView) {
            var self = this,
                accessor = binding.accessor,
                model = binding.model || options.model || self.model,
                els = binding.selector ? options.root.find(binding.selector) : options.root;

            els.each(function() {
                var el = $(this);

                if (typeof model === 'string') {
                    model = self[model];
                }

                if (typeof binding.accessor === 'string') {
                    accessor = function(el, val) {
                        return val === undefined ? el[binding.accessor]() : el[binding.accessor](val);
                    };
                }

                (bindModel || Bindem._bindModel).call(self, model, el, accessor, binding, options);
                (bindView || Bindem._bindView).call(self, model, el, accessor, binding, options);
            });
        },
        _bindModel: function(model, el, accessor, binding, options) {
            var self = this;
            if (model && options.attr) {
                function getModelVal() {
                    var val = model.get(options.attr);
                    return (typeof binding.m2v === 'function' ? binding.m2v(val) : val);
                }
                function handler() {
                    var modelVal = getModelVal();
                    var args = Array.prototype.slice.call(arguments);
                    args.unshift(undefined);
                    args.unshift(el);
                    var elementVal = accessor.apply(self, args);
                    if (modelVal !== elementVal) {
                        args[1] = modelVal;
                        accessor.apply(self, args);
                    }
                }
                if (options.initialize) {
                    accessor.call(self, el, getModelVal());
                }
                model.on('change:' + options.attr, handler, self);
                model.on('sync', handler, self);
            }
        },
        _bindView: function(model, el, accessor, binding, options) {
            var self = this;
            if (binding.event && options.attr) {
                el.on(binding.event + '.bindem', function() {
                    var args = Array.prototype.slice.call(arguments);
                    args.unshift(undefined);
                    args.unshift(el);
                    var elementVal = accessor.apply(self, args),
                        modelVal = model.get(options.attr);
                    elementVal = (typeof binding.v2m === 'function' ? binding.v2m(elementVal) : elementVal);
                    if (modelVal !== elementVal) {
                       model.set(options.attr, elementVal);
                    }
                });
            }
        },
        _loadBindings: function(bindings, options, callback) {
            options = options || {};
            var self = this;
            _.each(bindings || {}, function(bindings, attr) {
                _.each(bindings, function(obj, binding) {
                    if (!(obj instanceof Array)) {
                        obj = [obj];
                    }
                    _.each(obj, function(obj) {
                        if (typeof obj === 'string') {
                            obj = {selector: obj};
                        }
                        var o = _.extend({attr: attr}, options);
                        o.root = options.root ? $(options.root) : self.$el;
                        o.attr = attr;
                        var bindingObj = binding;
                        if (Bindem.bindings[binding]) {
                            bindingObj = Bindem.bindings[binding];
                        }
                        callback.call(self, bindingObj, obj, o);
                    });
                });
            });
        },
        on: function(bindings, options) {
            Bindem._loadBindings.call(this, bindings, options, function(bindingObj, obj, o) {
                var init = bindingObj.init || function(binding, options) {
                    Bindem._bind.call(this, _.extend({}, bindingObj, binding), options);
                };
                init.call(this, obj, o);
            });
        },
        off: function(bindings, options) {
            Bindem._loadBindings.call(this, bindings, options, function(bindingObj, obj, o) {
                var destroy = bindingObj.destroy || function(binding, options) {
                    binding = _.extend({}, bindingObj, binding);
                    var model = binding.model || options.model || this.model,
                        els = binding.selector ? options.root.find(binding.selector) : options.root;
                    if (binding.event) {
                        els.off(binding.event + '.bindem');
                    }
                    if (model) {
                        model.off('change:' + options.attr, null, this);
                    }
                };
                destroy.call(this, obj, o);
            });
        }
    };

    var bindings = {
        custom: {},
        value: {
            accessor: 'val',
            event: 'change' },
        html: {
            accessor: 'html' },
        text: {
            accessor: 'text' },
        visible: {
            accessor: function(el, val) {
                if (val === undefined) {
                    return el.is(':visible');
                } else {
                    el[val ? 'show' : 'hide']();
                }
            }},
        hidden: {
            accessor: function(el, val) {
                return !Bindem.bindings.visible.accessor(el, val === undefined ? val : !val);
            }},
        disable: {
            accessor: function(el, val) {
                if (val === undefined) {
                    return el.prop('disabled');
                } else {
                    el.prop('disabled', val);
                }
            }},
        enable: {
            accessor: function(el, val) {
                return !Bindem.bindings.disable.accessor(el, val === undefined ? val : !val);
            }},
        hasfocus: {
            event: 'focus blur',
            accessor: function(el, val, evt) {
                if (val === undefined) {
                    return evt.type === 'focus' ? true : (
                        evt.type === 'blur' ? false : el.is(':focus'));
                } else {
                    el[val ? 'focus' : 'blur']();
                }
            }}
    };

    _.each({
        css: function(prop, el, val) {
            if (val === undefined) {
                return el.hasClass(prop);
            } else {
                el[val ? 'addClass' : 'removeClass'](prop);
            }
        },
        style: function(prop, el, val) {
            if (val === undefined) {
                return el.css(prop);
            } else {
                el.css(prop, val);
            }
        },
        attr: function(prop, el, val) {
            if (val === undefined) {
                return el.attr(prop);
            } else {
                el.attr(prop, val);
            }
        }
    }, function(accessor, binding) {
        bindings[binding] = {
            init: function(binding, options) {
                var self = this;
                _.each(binding, function(selector, prop) {
                    var obj = (typeof selector === 'object') ? selector : {selector: selector};
                    obj.accessor = function(el, val) {
                        accessor.call(this, prop, el, val);
                    };
                    Bindem._bind.call(self, obj, options);
                });
            },
            accessor: accessor
        };
    });

    bindings.change = {
        init: function(binding, options) {
            if (binding.selector && typeof binding.selector === 'string') {
                binding = this[binding.selector];
            }
            Bindem._bind.call(this, {
                accessor: function(el, val) {
                    if (val !== undefined) {
                        binding.call(this, val);
                    }
                }}, options);
        }
    };

    bindings.checked = {
        init: function(binding, options) {
            Bindem._bind.call(this, _.extend({}, bindings.checked, binding), options, null,
                function() {
                    Bindem._bindView.apply(this, arguments);
                    // IE 6+7 won't allow radio buttons to be selected unless they have a name
                    var el = arguments[1];
                    if (el.is(':radio') && !el.attr('name')) {
                        bindings.uniqueName._assignUniqueName(null, el);
                    }
                });
        },
        event: 'click',
        accessor: function(el, val) {
            if (el.is('[type=radio]')) {
                if (val === undefined) {
                    return (el.prop('checked') ? '' : '_')+el.val();
                } else {
                    el.prop('checked', el.val() === val);
                }
            } else {
                if (val === undefined) {
                    return el.prop('checked');
                } else {
                    el.prop('checked', val);
                }
            }
        }
    };

    bindings.uniqueName = {
        init: function(binding, options) {
            Bindem._bind.call(this, binding, options, null,
                              bindings.uniqueName._assignUniqueName);
        },
        _assignUniqueName: function(model, el) {
            el.attr('name', 'bindem_unique_' + (++bindings.uniqueName._currentIndex));
        },
        _currentIndex: 0
    };

    Bindem.bindings = bindings;
    return Bindem;
});