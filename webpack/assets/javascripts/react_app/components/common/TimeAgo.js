import React from 'react';
import Moment from 'react-moment';

export default ({ date }) => date && <Moment fromNow={true} parse="YYYY-MM-DD h:mm:s z" date={date} /> || <span>{__('N/A')}</span>;
