function load_dynamic_javascripts(html) {
  function waitForAllLoaded() {
    // Wait for all plugins js modules to be loaded before loading the javascript content
    return new Promise(function(resolve) {
      // window.allPluginsLoaded is set to {} when plugins are starting to load
      // if there are no plugins window.allPluginsLoaded is never defined
      if (window.allPluginsLoaded === undefined || Object.values(window.allPluginsLoaded).every(Boolean)) {
        resolve();
      } else {
        function handleLoad() {
          if (window.allPluginsLoaded === undefined || Object.values(window.allPluginsLoaded).every(Boolean)) {
            resolve();
            // Remove the event listener
            document.removeEventListener('loadPlugin', handleLoad);
          }
        }
        document.addEventListener('loadPlugin', handleLoad);
      }
    });
  }
  waitForAllLoaded().then(async function() {
    // parse html string
    var template = document.createElement('template');
    template.innerHTML = html;
    var doc = new DOMParser().parseFromString(html, 'text/html');
    var copyChildren = [...doc.head.children];
    const loadScript = async scripts => {
      if (scripts.length === 0) {
        // All scripts are loaded
        window.allJsLoaded = true;
        const loadJS = new Event('loadJS');
        document.dispatchEvent(loadJS);
        return;
      }
      const script = scripts.shift();
      if (script.src) {
        // if script is just a link, add it to the head
        const scriptTag = document.createElement('script');
        scriptTag.src = script.src;
        scriptTag.onload = function() {
          // To load the next script only after the current one is loaded
          loadScript(scripts);
        };
        document.head.appendChild(scriptTag);
      } else {
        // if the script is a script tag, evaluate it and load the next one
        await eval(script.innerHTML);
        loadScript(scripts);
      }
    };
    loadScript(copyChildren);
  });
}
