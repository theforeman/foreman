import React from 'react';
import PropTypes from 'prop-types';
import SearchModal from './SearchModal';
import { useForemanModal } from '../../../ForemanModal/ForemanModalHooks';
import { BOOKMARKS_MODAL } from '../../BookmarksConstants';
import { translate as __ } from '../../../../common/I18n';
import { noop } from '../../../../common/helpers';

const ConnectedSearchModal = props => {
  const { setModalClosed } = useForemanModal({
    id: BOOKMARKS_MODAL,
  });

  return <SearchModal setModalClosed={setModalClosed} {...props} />;
};

ConnectedSearchModal.propTypes = {
  controller: PropTypes.string.isRequired,
  url: PropTypes.string.isRequired,
  title: PropTypes.string,
  onEnter: PropTypes.func,
};

ConnectedSearchModal.defaultProps = {
  title: __('Create Bookmark'),
  onEnter: noop,
};

export default ConnectedSearchModal;
