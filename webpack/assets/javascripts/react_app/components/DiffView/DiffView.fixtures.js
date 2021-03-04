import { noop } from '../../common/helpers';

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
  viewType: 'split',
};

export const radioMock = {
  stateView: 'split',
  changeState: noop,
};

export const patchMock = {
  viewType: 'unified',
  patch,
};
