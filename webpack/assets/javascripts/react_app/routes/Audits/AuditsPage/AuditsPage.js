/* eslint-disable camelcase */
import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { Button, Icon, Spinner } from 'patternfly-react';
import './auditspage.scss';

import { translate as __ } from '../../../common/I18n';
import AuditsPageEmptyState from './AuditsPageEmptyState';
import PageLayout from '../../common/PageLayout/PageLayout';
import AuditsList from '../../../components/AuditsList';
import Pagination from '../../../components/Pagination/Pagination';
import { getParams } from '../../../components/Pagination/PaginationHelper';
import {
  AUDITS_DOC_URL,
  AUDITS_SEARCH_PROPS,
  AUDITS_PER_PAGE_OPTIONS,
} from './AuditsPageConstants';

class AuditsPage extends Component {
  componentDidMount() {
    document.title = __('Audits');
    const { audits, initializeAudits } = this.props;
    if (audits.length === 0) {
      const params = getParams();
      initializeAudits(params, true);
    }

    window.onpopstate = e => {
      if (e.state) {
        const popStateParams = getParams();
        initializeAudits(popStateParams);
      }
    };
  }

  componentWillUnmount() {
    window.onpopstate = () => {};
  }

  render() {
    const {
      audits,
      page,
      perPage,
      searchQuery,
      itemCount,
      showMessage,
      message,
      auditSearch,
      changePage,
      changePerPage,
      isLoading,
      isFetchingNext,
      isFetchingPrev,
    } = this.props;
    return (
      <PageLayout
        header={__('Audits')}
        searchable
        searchProps={AUDITS_SEARCH_PROPS}
        searchLoading={isLoading}
        searchQuery={searchQuery}
        onSearch={auditSearch}
        toolbarButtons={
          <Button href={AUDITS_DOC_URL} className="btn-docs">
            <Icon type="pf" name="help" />
            {__(' Documentation')}
          </Button>
        }
      >
        {showMessage ? (
          <AuditsPageEmptyState message={message} />
        ) : (
          <React.Fragment>
            {audits.length === 0 ? (
              <div id="loading-audits">
                <Spinner size="lg" loading />
              </div>
            ) : (
              <React.Fragment>
                <AuditsList audits={audits} />
                <div id="pagination">
                  <Pagination
                    data={{
                      itemCount,
                      viewType: 'table',
                      classNames: { pagination_classes: 'audits-pagination' },
                    }}
                    pagination={{
                      page,
                      perPage,
                      perPageOptions: AUDITS_PER_PAGE_OPTIONS,
                    }}
                    onPageSet={changePage}
                    onPerPageSelect={changePerPage}
                    disableNext={isFetchingNext}
                    disablePrev={isFetchingPrev}
                  />
                </div>
              </React.Fragment>
            )}
          </React.Fragment>
        )}
      </PageLayout>
    );
  }
}

AuditsPage.propTypes = {
  audits: PropTypes.array.isRequired,
  page: PropTypes.number.isRequired,
  perPage: PropTypes.number.isRequired,
  searchQuery: PropTypes.string.isRequired,
  itemCount: PropTypes.number.isRequired,
  initializeAudits: PropTypes.func.isRequired,
  showMessage: PropTypes.bool.isRequired,
  auditSearch: PropTypes.func.isRequired,
  changePage: PropTypes.func.isRequired,
  changePerPage: PropTypes.func.isRequired,
  isLoading: PropTypes.bool.isRequired,
  isFetchingNext: PropTypes.bool.isRequired,
  isFetchingPrev: PropTypes.bool.isRequired,
  message: PropTypes.shape({
    type: PropTypes.string,
    text: PropTypes.string,
  }).isRequired,
};

export default AuditsPage;
