import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { Button, Icon, Spinner } from 'patternfly-react';
import './auditspage.scss';
import { translate as __ } from '../../common/I18n';

import {
  getURIpage,
  getURIperPage,
  getURIsearch,
} from '../../components/Pagination/PaginationHelper';
import PageLayout from '../common/PageLayout/PageLayout';
import AuditsList from '../../components/AuditsList';
import Pagination from '../../components/Pagination/Pagination';
import DefaultEmptyState from '../../components/common/EmptyState';

class AuditsPage extends Component {
  componentDidMount() {
    const { fetchAudits } = this.props;
    fetchAudits({
      page: getURIpage() || 1,
      perPage: getURIperPage() || 20,
      searchQuery: getURIsearch(),
      historyPush: true,
      historyReplace: true,
    });

    window.onpopstate = e => {
      if (e.state) {
        fetchAudits({
          page: getURIpage() || 1,
          perPage: getURIperPage() || 20,
          searchQuery: getURIsearch(),
          historyPush: false, // don't push to history stack
        });
      }
    };
  }

  render() {
    const {
      data: { searchProps, docURL, searchable, perPageOptions },
      audits,
      page,
      perPage,
      itemCount,
      searchQuery,
      fetchAudits,
      showMessage,
      message,
    } = this.props;

    return (
      <PageLayout
        header={__('Audits')}
        searchable={searchable}
        searchProps={searchProps}
        onSearch={search =>
          fetchAudits({
            page: 1,
            searchQuery: search,
            perPage,
          })
        }
        toolbarButtons={
          <Button href={docURL} className="btn-docs">
            <Icon type="pf" name="help" />
            {__(' Documentation')}
          </Button>
        }
      >
        {showMessage ? (
          <DefaultEmptyState
            icon={message.type === 'error' ? 'error-circle-o' : 'add-circle-o'}
            header={
              message.type === 'error' ? __('Error') : __('No Audits Found')
            }
            description={message.text}
          />
        ) : (
          <React.Fragment>
            {audits.length === 0 ? (
              <div id="loading-audits">
                <Spinner size="lg" loading />
              </div>
            ) : (
              <React.Fragment>
                <div id="audit-list">
                  <AuditsList data={{ audits }} />
                </div>
                <div id="pagination">
                  <Pagination
                    data={{
                      itemCount,
                      viewType: 'table',
                      classNames: { pagination_classes: 'audits-pagination' },
                    }}
                    pagination={{ page, perPage, perPageOptions }}
                    onPageSet={newPage =>
                      fetchAudits({
                        page: newPage,
                        perPage,
                        searchQuery,
                      })
                    }
                    onPerPageSelect={newPerPage =>
                      fetchAudits({ page, perPage: newPerPage, searchQuery })
                    }
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
  data: PropTypes.shape({
    searchProps: PropTypes.shape({
      autocomplete: PropTypes.shape({
        results: PropTypes.array,
        searchQuery: PropTypes.string,
        url: PropTypes.string,
        useKeyShortcuts: PropTypes.bool,
      }),
      controller: PropTypes.string,
      bookmarks: PropTypes.shape({
        text: PropTypes.string,
        query: PropTypes.string,
      }),
    }),
    docURL: PropTypes.string,
    searchable: PropTypes.bool,
  }).isRequired,
  audits: PropTypes.array.isRequired,
  page: PropTypes.number.isRequired,
  perPage: PropTypes.number.isRequired,
  itemCount: PropTypes.number.isRequired,
  fetchAudits: PropTypes.func.isRequired,
  searchQuery: PropTypes.string.isRequired,
  showMessage: PropTypes.bool.isRequired,
  message: PropTypes.shape({
    type: PropTypes.string,
    text: PropTypes.string,
  }).isRequired,
};

export default AuditsPage;
