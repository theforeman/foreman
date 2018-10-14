import React from 'react';
import PropTypes from 'prop-types';

import { parseDiff, Diff, markCharacterEdits } from 'react-diff-view';
import { formatLines, diffLines } from 'unidiff';
import 'react-diff-view/index.css';
import './diffview.scss';

const getDiff = (oldText, newText) => {
  const diffText = formatLines(diffLines(oldText, newText), { context: 3 });
  // these two lines are faked to mock git diff output
  const header = ['diff --git a/a b/b', 'index 0000000..1111111 100644'];
  return `${header.join('\n')}\n${diffText}`;
};

const DiffView = ({
  oldText,
  newText,
  viewType,
}) => {
  const markEdits = markCharacterEdits({ threshold: 30, markLongDistanceDiff: true });
  const gitDiff = getDiff(oldText, newText);
  const files = parseDiff(gitDiff);
  const hunk = files[0].hunks;

  return (
    hunk && <Diff hunks={hunk} markEdits={markEdits} viewType={viewType} />
  );
};

DiffView.propTypes = {
  oldText: PropTypes.string.isRequired,
  newText: PropTypes.string.isRequired,
  viewType: PropTypes.string.isRequired,
};

export default DiffView;
