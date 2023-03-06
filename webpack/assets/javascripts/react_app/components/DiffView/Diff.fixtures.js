import { noop } from '../../common/helpers';

import { SPLIT, UNIFIED } from './DiffConsts.js';

export const patch = `
--- /etc/issue  2020-04-07 18:01:12.000000000 -0400
+++ /tmp/puppet-file20210218-2326-z6teom  2021-02-18 09:13:48.965177455 -0500
@@ -1,3 +1 @@
-\S
-Kernel \r on an \m
-
+fooo
\ No newline at end of file
`

export const diffMock = {
  oldText: 'hello friend',
  newText: 'hello there friend',
  viewType: SPLIT,
};

export const radioMock = {
  stateView: SPLIT,
  changeState: noop,
};

export const patchMock = {
  viewType: UNIFIED,
  patch,
};

export const fixtures = {
    'render DiffView w/oldText & newText': diffMock,
    'render DiffView w/Patch': patchMock,
  };

export const PF_SELECTED = 'pf-m-selected';

export const DIFF_SPLIT = 'diff-split';
export const DIFF_UNIFIED = 'diff-unified';
