import { shallow } from 'enzyme';
import * as React from 'react';

import [FTName % pascalcase] from './[FTName % pascalcase]';

describe(' [FTName % sentencecase] specs', () => {
  it('should render as expected when passing required properties', () => {
    // Arrange
    const props = {
      name: 'test name',
      label: 'test label',
      value: 'test value',
      onChange: () => {},
    };

    // Act
    const component = shallow(< [FTName % pascalcase] {...props} />);

    // Assert
    expect(component).toMatchSnapshot();
  });
});
