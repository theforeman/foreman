export const dataUrl = '/some/poll/url/with/UNIQUE-ID';
export const reportFileName = 'report.txt';

export const scheduleResponse = {
  data: {
    data_url: dataUrl,
  },
};

export const failResponseMock = () =>
  Promise.reject(new Error('Network Error'));

export const noContentResponse = {
  status: 204,
};

export const generatedReportResponse = {
  status: 200,
  headers: {
    'content-disposition': `attachment; filename="${reportFileName}"`,
    'content-type': 'text/plain',
  },
  data: 'report result',
};
