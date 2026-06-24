import {
  DIFF_MODAL_TOGGLE,
  DIFF_MODAL_CREATE,
  DIFF_MODAL_VIEWTYPE,
} from '../DiffModalConstants';
import { toggleModal, createDiff, changeViewType } from '../DiffModalActions';
import { diffModalMock } from '../DiffModal.fixtures';

describe('DiffModal actions', () => {
  describe('toggleModal', () => {
    it('returns toggle action', () => {
      expect(toggleModal()).toEqual({ type: DIFF_MODAL_TOGGLE });
    });
  });

  describe('createDiff', () => {
    it('dispatches create action with diff payload', async () => {
      const dispatch = jest.fn();

      await createDiff(diffModalMock.diff, diffModalMock.title)(dispatch);

      expect(dispatch).toHaveBeenCalledWith({
        type: DIFF_MODAL_CREATE,
        payload: {
          diff: diffModalMock.diff,
          title: diffModalMock.title,
          isOpen: true,
        },
      });
    });
  });

  describe('changeViewType', () => {
    it('dispatches view type action', async () => {
      const dispatch = jest.fn();

      await changeViewType('unified')(dispatch);

      expect(dispatch).toHaveBeenCalledWith({
        type: DIFF_MODAL_VIEWTYPE,
        payload: {
          diffViewType: 'unified',
        },
      });
    });
  });
});
