import { selectGeneratingProps } from '../TemplateGeneratorSelectors';

const state = {
  templates: {
    polling: false,
    dataUrl: '/some/url',
    generatingError: 'there was an error',
    generatingErrorMessages: [{ error: { message: 'aha' } }],
  },
};

describe('TemplateGeneratorSelectors', () => {
  it('selects template properties', () => {
    expect(selectGeneratingProps(state)).toMatchSnapshot();
  });
});
