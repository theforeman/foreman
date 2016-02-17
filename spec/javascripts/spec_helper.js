// PhantomJS (Teaspoons default driver) doesn't have support for Function.prototype.bind, which has caused confusion.
// Use this polyfill to avoid the confusion.
//= require support/phantomjs-shims
//
// You can require your own javascript files here. By default this will include everything in application, however you
// may get better load performance if you require the specific files that are being used in the spec that tests them.
//= require application
//
// Teaspoon includes some support files, but you can use anything from your own support path too.
//= require support/jasmine-jquery-2.1.0
