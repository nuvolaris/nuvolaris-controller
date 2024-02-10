<!--
  ~ Licensed to the Apache Software Foundation (ASF) under one
  ~ or more contributor license agreements.  See the NOTICE file
  ~ distributed with this work for additional information
  ~ regarding copyright ownership.  The ASF licenses this file
  ~ to you under the Apache License, Version 2.0 (the
  ~ "License"); you may not use this file except in compliance
  ~ with the License.  You may obtain a copy of the License at
  ~
  ~   http://www.apache.org/licenses/LICENSE-2.0
  ~
  ~ Unless required by applicable law or agreed to in writing,
  ~ software distributed under the License is distributed on an
  ~ "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
  ~ KIND, either express or implied.  See the License for the
  ~ specific language governing permissions and limitations
  ~ under the License.
-->

# Implementazione di APISIX in Kubernetes con OpenWhisk Fork Nuvolaris

## Passo 1: Login nell'Ambiente Nuvolaris

Per iniziare a lavorare con APISIX e OpenWhisk all'interno del tuo ambiente Kubernetes, è essenziale accedere all'ambiente Nuvolaris. Questo passaggio garantisce che tutte le operazioni successive vengano eseguite nel contesto giusto e con le autorizzazioni appropriate.

### Preparazione

Assicurati di avere le seguenti informazioni a portata di mano prima di procedere:

- L'URL del tuo cluster Nuvolaris.
- Le credenziali di accesso, se richieste.

### Esecuzione del Comando di Login

Per effettuare il login, apri il terminale sul tuo computer o sulla console cloud, a seconda di dove intendi eseguire i comandi. Dopodiché, inserisci il seguente comando:

```bash
nuv -login http://<cluster nuvolaris>
```

Sostituisci `<cluster nuvolaris>` con l'URL effettivo del tuo cluster Nuvolaris. Ad esempio, se il tuo cluster si trova all'indirizzo `http://nuvolaris.example.com`, il comando diventa:

```bash
nuv -login http://nuvolaris.example.com
```

### Verifica del Login

Dopo aver eseguito il comando, dovresti ricevere una conferma che indica il successo del login. In caso di errore, controlla di aver inserito correttamente l'URL e di avere le autorizzazioni necessarie per accedere all'ambiente.

## Passo 2: Deploy dei File YAML

Dopo aver effettuato l'accesso all'ambiente Nuvolaris, il passo successivo è il deploy dei file YAML necessari per la configurazione di APISIX in Kubernetes. Ogni file YAML ha uno scopo specifico e richiede particolare attenzione durante il deploy.

### Preparazione dei File YAML

Assicurati di avere i seguenti file YAML pronti per il deploy:

1. **apisix_etcd.yaml**: Questo file configura il server etcd per APISIX. Verifica che le impostazioni corrispondano alla tua configurazione di etcd.
2. **dashboard_new.yaml**: Imposta il dashboard per APISIX. Questo file contiene impostazioni cruciali per l'interfaccia utente del dashboard.
3. **apisix-ingress-gateway.yaml**: Configura il gateway di ingresso per APISIX, che gestisce il traffico in entrata.

### Modifiche Specifiche ai File YAML

#### Modifiche al File `dashboard_new.yaml`

Prima di procedere con il deploy del `dashboard_new.yaml`, è importante apportare alcune modifiche specifiche:

- **Cambio delle Credenziali**: Cerca la sezione relativa alle credenziali utente nel file e sostituiscile con le tue. Ad esempio:

  ```yaml
  data:
    conf.yaml:
      users:
        - username: admin
          password: <tua_password>
        - username: nuvolaris
          password: <altra_password>
  ```

  Sostituisci `<tua_password>` e `<altra_password>` con le tue password personali.

#### Modifiche al File `apisix-ingress-gateway.yaml`

- **Cambio del Dominio**: Sostituisci tutte le occorrenze di `nuvolaris.dynamicsconsulting.it` con il tuo dominio effettivo.

### Deploy dei File YAML

Dopo aver apportato le modifiche necessarie, procedi con il deploy di ciascun file YAML utilizzando il comando:

```bash
kubectl apply -f <nome_del_file>.yaml
```

Esegui questo comando separatamente per ciascun file YAML, rispettando l'ordine sopra indicato.

### Verifica del Deploy

Una volta completato il deploy di ciascun file, è essenziale verificare che tutto sia stato configurato correttamente. Utilizza comandi come `kubectl get pods` e `kubectl get services` per controllare lo stato dei servizi e assicurati che non ci siano errori.

### Risoluzione dei Problemi

In caso di problemi durante il deploy, ecco alcune possibili soluzioni:

- **File YAML Mancante o Errato**: Assicurati che ogni file YAML sia corretto e presente nella directory di lavoro.
- **Errori Durante il Deploy**: Analizza i messaggi di errore per capire la natura del problema e apporta le correzioni necessarie ai file YAML.

## Passo 3: Connessione con l'Operatore Admin di APISIX

Dopo aver deployato i file YAML, il prossimo passo è stabilire una connessione con l'operatore admin di APISIX. Questa connessione è fondamentale per gestire e configurare APISIX dal tuo computer.

### Preparazione

Prima di procedere, assicurati che il servizio APISIX sia in esecuzione nel tuo ambiente Kubernetes. Puoi verificare ciò utilizzando il comando `kubectl get pods` e cercando i pod relativi ad APISIX.

### Stabilire la Connessione

Per connetterti all'operatore admin di APISIX, userai il comando `kubectl port-forward`. Questo comando crea un tunnel sicuro tra il tuo computer e il servizio APISIX in esecuzione in Kubernetes, permettendoti di interagire con l'operatore admin.

Esegui il seguente comando:

```bash
kubectl port-forward service/apisix-admin 9280:9280 -n nuvolaris
```

Questo comando inoltrerà la porta 9280 del servizio `apisix-admin` nel tuo ambiente Kubernetes alla porta 9280 del tuo computer locale.

### Verifica della Connessione

Una volta eseguito il comando, dovresti vedere un messaggio che indica che la connessione è stata stabilita. Per esempio:

```
Forwarding from 127.0.0.1:9280 -> 9280
Forwarding from [::1]:9280 -> 9280
```

Questo significa che ora puoi accedere all'operatore admin di APISIX tramite `http://localhost:9280` sul tuo browser o utilizzando comandi curl per le configurazioni API.

### Risoluzione dei Problemi

- **Connessione Non Riuscita**: Se incontri errori nel tentativo di stabilire la connessione, assicurati che il servizio `apisix-admin` sia in esecuzione e che tu abbia specificato il namespace corretto nel comando.
- **Porta Occupata**: Se la porta 9280 è già in uso sul tuo computer, puoi scegliere una porta alternativa modificando il comando, ad esempio `kubectl port-forward service/apisix-admin 9290:9280 -n nuvolaris` (inoltrerà la porta 9280 su Kubernetes alla porta 9290 sul tuo computer).

## Passo 4: Configurazione del Consumer per JWT-Auth in APISIX

Il quarto passo nel processo di implementazione di APISIX in Kubernetes con OpenWhisk Fork Nuvolaris è la configurazione del consumer per l'autenticazione JWT. Questa configurazione è essenziale per garantire che solo gli utenti autorizzati possano accedere alle tue API.

### Preparazione

Prima di procedere, assicurati che la connessione con l'operatore admin di APISIX sia attiva come stabilito nel Passo 3. Questo ti permetterà di inviare comandi all'operatore admin di APISIX.

### Aggiunta dell'Header di Autenticazione

Le chiamate verso l'operatore admin di APISIX devono essere autenticate utilizzando un token specifico. Troverai questo token (`x-api-key`) nel file `apisix_etcd.yaml` nella configurazione dell'operatore admin. Per questo esempio, useremo il valore `edd1c9f034335f136f87ad84b625c8f1`.

### Configurazione del Consumer

Il consumer in APISIX gestisce l'accesso e l'autenticazione degli utenti. Userai il comando curl per configurare un consumer che utilizzi JWT per l'autenticazione, includendo l'header `x-api-key`.

Esegui il seguente comando:

```bash
curl -X PUT http://localhost:9280/apisix/admin/consumers/ -H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1' -d '{
    "username": "nuvolaris",
    "plugins": {
        "jwt-auth": {
            "key": "nuvolaris",
            "secret": "nuvolaris123@"
        }
    }
}'
```

In questo esempio, stai configurando un consumer chiamato `nuvolaris` con un key/secreto per l'autenticazione JWT. Assicurati di sostituire `"nuvolaris"` e `"nuvolaris123@"` con il tuo username e la tua chiave segreta.

### Verifica della Configurazione

Dopo aver eseguito il comando, controlla la risposta per assicurarti che la configurazione sia stata accettata e applicata correttamente. In caso di errore, verifica la sintassi del comando e assicurati che la connessione con l'operatore admin di APISIX sia attiva.

### Risoluzione dei Problemi

- **Errore nella Risposta**: Se ricevi un messaggio di errore, controlla la sintassi del comando e le informazioni fornite.
- **Problemi di Connessione**: Assicurati che la tua connessione con l'operatore admin di APISIX sia ancora attiva e che il comando venga eseguito correttamente.

Con il consumer configurato, ora hai stabilito un livello di sicurezza per l'accesso alle tue API tramite JWT.

## Passo 5: Configurazione della Route di Autorizzazione JWT

Il quinto passo consiste nel configurare una route di autorizzazione JWT in APISIX. Questa configurazione permette di creare una route pubblica per richiedere il token bearer di JWT, che sarà poi utilizzato per autenticare le richieste alle API protette.

### Preparazione

Assicurati che la connessione con l'operatore admin di APISIX sia ancora attiva. Se necessario, ristabilisci la connessione come descritto nel Passo 3.

### Configurazione della Route

Userai un comando curl per configurare la route. Ricorda di includere l'header `x-api-key` per l'autenticazione con l'operatore admin di APISIX.

Esegui il seguente comando:

```bash
curl -X PUT http://localhost:9280/apisix/admin/routes/jas -H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1' -d '{
    "uri": "/AUTH/authorize",
    "name": "jwt-public-authorize",
    "plugins": {
        "public-api": {
            "uri": "/apisix/plugin/jwt/sign"
        }
    },
    "methods": [
        "GET"
    ]
}'
```

Questo comando configura una route all'URI `/AUTH/authorize` che permette di richiedere il token bearer di JWT. La route sarà accessibile pubblicamente.

### Verifica della Configurazione

Dopo aver eseguito il comando, verifica che la configurazione sia stata accettata senza errori. Potresti voler testare la route per assicurarti che funzioni come previsto.

### Risoluzione dei Problemi

- **Errore nella Risposta**: Se ricevi un errore, verifica che l'header `x-api-key` sia corretto e che la sintassi del comando curl sia corretta.
- **Problemi di Accesso alla Route**: Assicurati che la route sia configurata correttamente e che sia raggiungibile nel tuo ambiente Kubernetes.

Con la configurazione di questa route, hai ora un punto di accesso per ottenere token JWT necessari per accedere alle tue API protette.

## Passo 6: Configurazione di una Route di Demo con OpenWhisk ed APISIX

Il Passo 6 riguarda la configurazione di una route di demo per dimostrare l'integrazione tra OpenWhisk e APISIX. Questa configurazione illustra come creare e gestire una nuova API in Kubernetes utilizzando OpenWhisk e APISIX.

### Ottenimento dell'API Key di OpenWhisk

Il primo sottopunto è ottenere l'API Key di OpenWhisk, che ti permetterà di interagire con OpenWhisk tramite APISIX.

1. **Esegui il Comando per Ottenere l'API Key**: Apri il terminale e digita il seguente comando:

   ```bash
   nuv -wsk -i property get --auth
   ```

   Questo comando restituirà l'API Key necessaria per la successiva configurazione del plugin APISIX di OpenWhisk.

2. **Registra l'API Key Ottenuta**: Assicurati di annotare l'API Key ottenuta, poiché sarà utilizzata nei passaggi successivi per configurare la route in APISIX.

### Creazione dell'Azione OpenWhisk

Il secondo sottopunto implica la creazione di un'azione OpenWhisk che sarà poi esposta come API tramite APISIX.

1. **Sviluppa l'Azione `demoapi.js`**: Crea un file JavaScript denominato `demoapi.js`. Questo file dovrebbe contenere il codice necessario per eseguire l'azione desiderata. Ad esempio:

   ```javascript
   function main(params) {
       let method = params.method || 'unknown';
       let response = "Hello, " + method;
       if (params.body) {
           response += ". Body: " + JSON.stringify(params.body);
       }
       return { result: response };
   }

   ```

   Questo codice è un semplice esempio che restituisce un saluto e il metodo HTTP utilizzato nella richiesta.

2. **Prepara il File per il Deploy**: Dopo aver creato l'azione, prepara il file `manifest.yml` per il deploy dell'azione su OpenWhisk. Il file dovrebbe avere una struttura simile a questa:

   ```yaml
   packages:
     <NomePackage>:
       version: 1.0.0
       license: Apache-2.0
       inputs:
         DB_NAME: nuvolaris
         DB_USER: nuvolaris
         DB_PASSWORD: <PasswordDB>
         DB_HOST: nuvolaris-postgres
         DB_PORT: 5432
         API_KEY: <API_Key_OpenWhisk>
       actions:
         <NomeAzione>:
           function: demoapi.js
           runtime: nodejs:default
   ```

   Assicurati che il `manifest.yml` punti correttamente al file `demoapi.js` e specifica il runtime adeguato.

   Sostituisci <NomePackage>, <PasswordDB>, <API_Key_OpenWhisk>, <NomeAzione>, <PercorsoFileZip>, e <PercorsoClasseEsecuzione> con i valori appropriati. Questa configurazione permette di deployare l'azione su OpenWhisk.

3. **Deploy dell'Azione su OpenWhisk**: Utilizza il seguente comando per deployare l'azione su OpenWhisk:

   ```bash
   nuv -wsk project deploy
   ```

   Questo comando legge il file `manifest.yml` e deploya l'azione `demoapi` su OpenWhisk.

### Configurazione della Route in APISIX

Dopo aver deployato l'azione OpenWhisk, il passo successivo è configurare una route in APISIX per utilizzare questa azione. La configurazione della route include l'attivazione di tre plugin specifici: `jwt-auth`, `openwhisk`, e `body-transformer`.

1. **Preparazione per la Configurazione della Route**: Assicurati di essere connesso all'operatore admin di APISIX come descritto nei passaggi precedenti. Avrai bisogno di utilizzare l'API Key ottenuta in precedenza.

2. **Configurazione della Route con i Plugin**:

   - **jwt-auth**: Questo plugin garantisce che l'accesso all'API sia consentito solo agli utenti con un token JWT valido. Fornisce un livello di sicurezza aggiuntivo per la tua API.
   - **openwhisk**: Questo plugin permette di integrare l'azione OpenWhisk con la route APISIX. Configuralo con i dettagli dell'azione OpenWhisk che hai deployato.
   - **body-transformer**: Questo plugin consente di modificare il corpo della richiesta prima che raggiunga l'azione OpenWhisk. È utile per manipolare i dati in ingresso, nel caso specifico, aggiunge "method" con il Verbo chiamante.

3. **Esecuzione del Comando Curl per Configurare la Route**:

   ```bash
   curl -X PUT http://localhost:9280/apisix/admin/routes/<id_route> -d '{
       "uri": "/demoapi",
       "name": "demo-api",
       "plugins": {
           "jwt-auth": { "_meta": { "disable": false } },
           "openwhisk": {
               "api_host": "http://controller:3233",
               "service_token": "<API_KEY>",
               "namespace": "nuvolaris",
               "action": "<NomeAzioneDeployata>",
               "package": "<PackageAzioneDeployata>",
               "result": true,
               "ssl_verify": false,
               "timeout": 60000
           },
           "body-transformer": {
               "request": { "template": "{%\
                   local method = _ctx.var.method or 'unknown'\
                   local modified_body\
                   if _body and _body ~= '' then\
                       modified_body = _body:gsub('^%{', '{\"method\": \"' .. method .. '\", ')\
                   else\
                       modified_body = '{\"method\": \"' .. method .. '\"}'\
                   end\
                   %}\
                   {* modified_body *}" }
           }
       },
       "methods": [
           "GET", "PUT", "DELETE", "PATCH", "POST"
       ]
   }'

   ```

   Sostituisci <id_route>, <API_KEY>, <NomeAzioneDeployata>, <PackageAzioneDeployata> con i valori appropriati. L'embedded template Lua in body-transformer catturerà il metodo HTTP e lo passerà all'azione OpenWhisk.
   
4. **Verifica della Configurazione della Route**:

   Dopo aver eseguito il comando, verifica che la route sia stata configurata correttamente e che non ci siano errori. Puoi testare la route accedendo all'URL specificato (`https://tuodominio/gateway/demoapi`) e verificando che l'azione OpenWhisk risponda come previsto.

5. **Risoluzione dei Problemi**:

   - **Errore nella Risposta**: Se ricevi un messaggio di errore durante la configurazione della route, controlla la sintassi del comando curl e le informazioni fornite.
   - **Problemi di Accesso alla Route**: Assicurati che la route sia configurata correttamente e che sia raggiungibile nel tuo ambiente Kubernetes.

## Passo 7: Esempio d'Uso della Route di Demo

Il Passo 7 illustra come utilizzare la route di demo che hai configurato in APISIX con l'azione OpenWhisk `demoapi`. Questo esempio include la generazione di un token JWT sulla route di autenticazione e l'uso di questo token per effettuare una richiesta alla route di demo.

### Generazione del Token JWT

1. **Richiesta del Token JWT**: Per prima cosa, devi generare un token JWT utilizzando la route `/AUTH/authorize` che hai configurato in precedenza. Usa il seguente comando curl:

   ```bash
   curl -X GET http://<tuodominio>/gateway/AUTH/authorize
   ```

   Questo comando restituirà un token JWT che dovrai utilizzare per autenticare le tue richieste alla route di demo.

2. **Salva il Token JWT Ricevuto**: Copia il token JWT ricevuto e tienilo pronto per il passaggio successivo.

### Uso del Token JWT per Accedere alla Route di Demo

1. **Effettua una Richiesta alla Route di Demo**: Ora che hai il token JWT, puoi utilizzarlo per effettuare una richiesta autenticata alla route di demo. Usa il seguente comando curl, includendo il token JWT nell'header `Authorization`:

   ```bash
   curl -X GET http://<tuodominio>/gateway/demoapi -H 'Authorization: Bearer <token_jwt>'
   ```

   Sostituisci `<tuodominio>` con il tuo dominio e `<token_jwt>` con il token JWT che hai generato nel passaggio precedente.

2. **Verifica la Risposta**: Dopo aver eseguito il comando, dovresti ricevere una risposta dall'azione OpenWhisk `demoapi`. Questa risposta confermerà che la tua richiesta è stata elaborata correttamente.

### Risoluzione dei Problemi

- **Errore di Autenticazione**: Se ricevi un errore di autenticazione, assicurati che il token JWT sia corretto e valido.
- **Errore nella Risposta dalla Route di Demo**: Se la route di demo non risponde come previsto, verifica la configurazione della route in APISIX e assicurati che l'azione OpenWhisk sia configurata correttamente.

Questo esempio illustra come utilizzare una route protetta da JWT in APISIX, integrata con un'azione OpenWhisk, per creare un'API funzionale e sicura.
