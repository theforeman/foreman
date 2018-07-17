# Translations

All strings need to be translated. We use gettext's underscore `__()` function as you know it from our asset pipeline code.

Note that for the time being the underscore function is available in the global `window` object and translations are handled outside of our webpack-processed code and there's no need to import it. This is most likely subject to change in future.


## Interpolation

Make sure that the strings inside the underscore function don't contain any interpolated values.
Using interpolation would break the actual translation of the string in runtime. Use `sprintf` from `jed` instead.

**Example:**
```js
// Wrong:
let msg = __(`%{taskCount} tasks complete`)
```

```js
// Correct:
import { sprintf } from 'jed';
let msg = sprintf(__('%(taskCount)s tasks complete'), { taskCount })
```
