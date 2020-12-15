import React from 'react';
import PropTypes from 'prop-types';

import { parseDiff, Diff } from 'react-diff-view';
import { formatLines, diffLines } from 'unidiff';
import './diffview.scss';

const getDiff = (oldText, newText) => {
  const diffText = formatLines(diffLines(oldText, newText), { context: 3 });
  // these two lines are faked to mock git diff output
  const header = ['diff --git a/a b/b', 'index 0000000..1111111 100644'];
  return `${header.join('\n')}\n${diffText}`;
};

const DiffView = ({ oldText, newText, viewType, patch }) => {
  // old,new Text
  if (patch === '') {
    const gitDiff = getDiff(oldText, newText);
    const files = parseDiff(gitDiff);
    const { hunks, type } = files[0];
    return hunks && <Diff hunks={hunks} viewType={viewType} diffType={type} />;
  }
  // Patch
  const files = parseDiff(
    patch
      .split('\n')
      .slice(1)
      .join('\n')
  );
  // eslint-disable-next-line react/prop-types
  const renderFile = ({ oldRevision, newRevision, type, hunks }) => (
    <Diff
      key={`${oldRevision}-${newRevision}`}
      viewType={viewType}
      diffType={type}
      hunks={hunks}
    />
  );

  return <div>{files.map(renderFile)}</div>;
};

DiffView.propTypes = {
  // None are required because only one can be used at a time: (old + new || patch)
  oldText: PropTypes.string,
  newText: PropTypes.string,
  viewType: PropTypes.string.isRequired,
  patch: PropTypes.string,
};

DiffView.defaultProps = {
  oldText: '',
  newText: '',
  patch: '',
};

export default DiffView;
