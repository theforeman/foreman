/*
  Simple Named Modules Plugin
  Strips relative path up to node_modules/ from the module ID.
  This allows for consistent module IDs when building webpack bundles from
  differing base paths relative to the node_modules directory.

  Based on NamedModulesPlugin by Tobias Koppers @sokra, originally licensed under
  MIT License: http://www.opensource.org/licenses/mit-license.php
*/
"use strict";

class SimpleNamedModulesPlugin {
  constructor(options) {
    this.options = options || {};
  }

  apply(compiler) {
    compiler.plugin("compilation", (compilation) => {
      compilation.plugin("before-module-ids", (modules) => {
        modules.forEach((module) => {
          if(module.id === null && module.libIdent) {
            module.id = module.libIdent({
              context: this.options.context || compiler.options.context
            });
            if (module.id.includes('node_modules')) {
              module.id = module.id.slice(module.id.indexOf('node_modules'))
            }
          }
        });
      });
    });
  }
}

module.exports = SimpleNamedModulesPlugin;
