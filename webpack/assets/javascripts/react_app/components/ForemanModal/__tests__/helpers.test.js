import React from 'react';
import ForemanModal from '../';
import { extractModalNodes } from '../helpers';

const headerNode = <ForemanModal.Header />;
const footerNode = <ForemanModal.Footer />;
const modalChildren = [headerNode, <p>hi</p>, footerNode];

describe('ForemanModal helpers', () => {
  describe('extractModalNodes', () => {
    it('returns an object with these three keys', () => {
      const result = extractModalNodes([]);
      expect(new Set(Object.keys(result))).toEqual(
        new Set(['headerChild', 'footerChild', 'otherChildren'])
      );
    });
    it('does not include header in otherChildren', () => {
      const result = extractModalNodes(modalChildren).otherChildren;
      expect(result.find(el => el.type === ForemanModal.Header)).toEqual(
        undefined
      );
    });
    it('does not include footer in otherChildren', () => {
      const result = extractModalNodes(modalChildren).otherChildren;
      expect(result.find(el => el.type === ForemanModal.Footer)).toEqual(
        undefined
      );
    });
    it('includes all nodes somewhere in the returned object', () => {
      const result = Object.values(extractModalNodes(modalChildren)); // array of arrays
      const expectedLength = modalChildren.length;
      let actualLength = 0;
      for (let i = 0; i < result.length; i++) {
        // result[i] can be an array of React elements or a single element
        if (Array.isArray(result[i])) {
          actualLength += result[i].length;
        } else {
          actualLength++;
        }
      }
      expect(actualLength).toEqual(expectedLength);
    });
  });
});
