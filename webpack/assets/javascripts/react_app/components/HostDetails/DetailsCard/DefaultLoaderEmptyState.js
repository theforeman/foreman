import React from 'react';
import { translate as __ } from '../../../common/I18n';
import './styles.scss';

const DefaultLoaderEmptyState = () => (
  <span className="disabled-text">{__('Not available')}</span>
);

export default DefaultLoaderEmptyState;
