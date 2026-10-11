import {
  IonContent,
  IonHeader,
  IonItem,
  IonLabel,
  IonPage,
  IonTitle,
  IonToolbar,
  useIonViewWillEnter,
} from '@ionic/react';
import { IonReactRouter } from '@ionic/react-router';
import type { FC } from 'react';
import React, { useState } from 'react';
import { useParams } from 'react-router';
import { Redirect, Route } from 'react-router-dom';

/* Core CSS required for Ionic components to work properly */
import '@ionic/react/css/core.css';

/* Basic CSS for apps built with Ionic */
import '@ionic/react/css/normalize.css';
import '@ionic/react/css/structure.css';
import '@ionic/react/css/typography.css';

/* Theme variables */
//TODO update if needed
import '../../theme/variables.css';

/* Component CSS */
import styles from './[FTName % pascalcase].module.css';

type [FTName % pascalcase]Props = {};

/**
 *
 * @returns data
 */
function getData(): Record<string, unknown> {
  return {};
}

const [FTName % pascalcase]: FC<[FTName % pascalcase]Props> = () => {
  const [loading, setLoading] = useState(false);
  const [data, setData] = useState<Record<string, unknown>>();

  //Param from the url
  const params = useParams<{ id: string }>();

  //Load data before Ionic view entering
  useIonViewWillEnter(() => {
    const obj: Record<string, unknown> = getData();
    setData(obj);
  });


  return (
    <IonPage>
      <IonHeader>
        <IonToolbar>
          <IonTitle>[FTName % sentencecase]</IonTitle>
        </IonToolbar>
      </IonHeader>
    
      <IonContent fullscreen className={styles.[FTName % pascalcase]}>
        {data ? (
          <>
            <IonItem>
              <IonLabel>{data}</IonLabel>
            </IonItem>
          </>
        ) : (
          <div>No data found</div>
        )}
      </IonContent>
    </IonPage>
  );
};

export default [FTName % pascalcase];
