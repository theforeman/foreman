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
		const { root } = compiler;
		compiler.hooks.compilation.tap("SimpleNamedModuleIdsPlugin", compilation => {
			compilation.hooks.optimizeModuleIds.tap("SimpleNamedModuleIdsPlugin", (modules) => {
				const chunkGraph = compilation.chunkGraph;
				const context = this.options.context
					? this.options.context
					: compiler.context;

        modules.forEach((module) => {
          var moduleId = chunkGraph.getModuleId(module);
          if (moduleId && moduleId.toString().includes('node_modules')) {
            chunkGraph.setModuleId(m, moduleId.slice(moduleId.indexOf('node_modules')));
          }
        });
			});
		});
	}
}

module.exports = SimpleNamedModulesPlugin;
