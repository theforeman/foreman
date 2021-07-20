/* eslint-disable jquery/no-class */
/* eslint-disable jquery/no-each */
/* eslint-disable jquery/no-ajax */
/* eslint-disable jquery/no-data */
/* eslint-disable jquery/no-parents */

import $ from 'jquery';
import { doesDocumentHasFocus } from '../react_app/common/document';
import { notify } from '../foreman_toast_notifications';
import { activateTooltips } from '../foreman_tools';
import { reloadPage } from '../foreman_navigation';
import { translate as __ } from '../react_app/common/I18n';
import './index.scss';

$(document).on('ContentLoad', () => {
  if (window.location.pathname === '/') {
    startGridster();
    autoRefresh();
  }
});

let refreshTimeout;

function autoRefresh() {
  const element = $('.auto-refresh');
  clearTimeout(refreshTimeout);

  if (element[0]) {
    refreshTimeout = setTimeout(() => {
      const autoRefreshIsOn = $('.auto-refresh').hasClass('on');
      const hasFocus = doesDocumentHasFocus();

      if (autoRefreshIsOn && hasFocus) {
        reloadPage();
      }
    }, 60000);
  }
}

export function startGridster() {
  $('.gridster>ul')
    .gridster({
      widget_margins: [10, 10],
      widget_base_dimensions: [94, 340],
      max_size_x: 12,
      min_cols: 12,
      max_cols: 12,
      autogenerate_stylesheet: false,
    })
    .data('gridster');
}

export function removeWidget(item) {
  const widget = $(item).parents('li.gs-w');
  const gridster = $('.gridster>ul')
    .gridster()
    .data('gridster');
  if (
    window.confirm(
      __('Are you sure you want to delete this widget from your dashboard?')
    )
  ) {
    $.ajax({
      type: 'DELETE',
      url: $(item).data('url'),
      success() {
        notify({
          message: __('Widget removed from dashboard.'),
          type: 'success',
        });
        gridster.remove_widget(widget);
      },
      error() {
        notify({
          message: __('Error removing widget from dashboard.'),
          type: 'error',
        });
      },
    });
  }
}

export function addWidget(name) {
  $.ajax({
    type: 'POST',
    url: 'widgets',
    data: { name },
    success() {
      notify({
        message: __('Widget added to dashboard.'),
        type: 'success',
      });
      reloadPage();
    },
    error() {
      notify({
        message: __('Error adding widget to dashboard.'),
        type: 'error',
      });
    },
    dataType: 'json',
  });
}

export function savePosition(path) {
  const positions = serializeGrid();
  $.ajax({
    type: 'POST',
    url: path,
    data: { widgets: positions },
    success() {
      notify({
        message: __('Widget positions successfully saved.'),
        type: 'success',
      });
    },
    error() {
      notify({
        message: __('Failed to save widget positions.'),
        type: 'error',
      });
    },
    dataType: 'json',
  });
}

function serializeGrid() {
  const result = {};
  $('.gridster>ul>li').each((i, widget) => {
    const $widget = $(widget);
    result[$widget.data('id')] = {
      col: $widget.data('col'),
      row: $widget.data('row'),
      sizex: $widget.data('sizex'),
      sizey: $widget.data('sizey'),
    };
  });

  return result;
}

export function widgetLoaded(widget) {
  // TODO: remove this once we no longer use legacy charts in the dashboard widgets.
  activateTooltips(widget);
}
