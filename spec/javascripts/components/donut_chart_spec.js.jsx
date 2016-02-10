describe('DonutChart', function () {
  beforeEach(function() {
    mockColumns = [['a', 35], ['b', 15]]
  });

  it('renders a div with the passed id', function() {
    const donut_element = React.createElement(
      DonutChart,
      {columns: mockColumns, id: 'test_chart'}
    );
    shallowRenderer.render(donut_element);
    const component = shallowRenderer.getRenderOutput();
    expect(component.props.children.props.id).toEqual('test_chart')
  });

  it('computes the maximum percentage from the column variables', function() {
    expect(DonutChart.prototype.maxPercentage(mockColumns)).toEqual(70);
  });

  it('computes the label for the maximum percentage', function() {
    expect(DonutChart.prototype.maxLabel(mockColumns)).toEqual('a');
  });
});
