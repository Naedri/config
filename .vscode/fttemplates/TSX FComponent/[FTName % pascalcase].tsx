import type { FC, ReactNode } from 'react';
import React from 'react';

import styles from './[FTName % pascalcase].module.css';

export interface [FTName % pascalcase]Props {
  disabled?: boolean;
  onClick?: (e?: Event) => void;
  defaultValue?: string;
  children?: ReactNode | undefined;
  type?: 'submit' | 'reset' | '[FTName % camelcase]';
}

const [FTName % pascalcase]: FC<[FTName % pascalcase]Props> = ({
  disabled = false,
  onClick,
  defaultValue = undefined,
  children,
  type = '[FTName % camelcase]',
}: [FTName % pascalcase]Props) => {
  return (
      <[FTName % camelcase] defaultValue={defaultValue} className={styles.[FTName % pascalcase]} disabled={disabled} onClick={onClick} type={type}>
          {children}
      </[FTName % camelcase]>
  );
}

export default [FTName % pascalcase];