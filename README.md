# Turnkey Continuous Delivery

## Requisiti Hardware e Software
Il seguente software deve essere installato sul proprio pc:
- [Vagrant](https://www.vagrantup.com/downloads.html)
- [Virtualbox](https://git-scm.com/downloads)
- [git](https://git-scm.com/downloads)

## Introduzione
Quando parlo di _Continuous Integration & Delivery_, molto spesso, mi trovo di fronte a persone che credono che basti avere un sistema di build automatico,
 oppure di fronte a persone che credono che per loro sia qualcosa di inaccessibile!
Un'idea diffusa è che gli strumenti necessari per praticarla sono complessi e richiedono parecchio studio e tempo per creare l'infrastruttura di base.

Purtroppo entrambe le posizioni sono estremamente lontane dalla realtà!

Con questo workshop vorrei mostrare una soluzione “chiavi in mano” per sperimentare le pratiche di Continuous Integration & Delivery in pochi minuti!
Dimostrando che la sfida non è dominare gli strumenti, ma cambiare noi stessi e il nostro modo di lavorare e approcciare questo argomento in modo differente.

Durante questo workshop creiamo l'infrastruttura di base che ci permette di fare **Continuous** e lavorememo a un semplice micro-servizio, rilasciato come _container docker_, che converte i codici colore dal formato **HEX** al formato **HSL** e viceversa.

## Infrastruttura
Iniziamo con dare un'indicazione di quale sia una infrastruttura tipica che ci permette di praticare _Continuous Integration_.

Parliamo di software, quindi i mattoncini che ci servono sono un sistema di **Source Code Management (SCM)**, un **repository per gli artefatti** e un **sistema automatizzato di build**.
Questi mattoncini li installermo e li configureremo su una VM che chiameremo _**Turnkey**_.

Abbiamo bisogno anche di alcuni ambienti separati per eseguire il nostro micro-servizio e per la precisione useremo un ambiente di _dev / test_ e uno di _pre-produzione / staging_.
Ognuno di questi ambienti corrisponde a una VM dedicata.

La nostra infrastruttura è costituita da 3 ambienti differenti che corrispondono 1:1 ad altrettante VMs e per la precisione:
- **turnkey**: VM per SCM, repository binari e sistema automatizzato di build
- **testing**: VM per effettuare i test del nostro micro-servizio
- **staging**: VM configurata in modo identico a quelle di produzione
 
## Strumenti Utilizzati
Possiamo distinguere gli strumenti utilizzati in 2 categorie, in base allo scopo per cui li usiamo:
- Strumenti per l'_Infrastruttura_:
  - Vagrant (provisioning e configurazione di VMs)
  - Virtualbox
  - Ansible (installazione e configurazione software)
- Strumenti per il _Codice_:
  - git e GitLab-CE (gestione codice sorgente)
  - docker-registry (repository binary)
  - Jenkins (strumento per effettuare build automatiche)
  - Ansible (installazione e configurazione software)

### Vagrant
Vagrant è un gestore di Macchine Virtuali (VMs).

#### Introduzione a Vagrant
Le caratteristiche principali di questo software sono:
- Software Libero: licenza MIT
- disaccoppiamento tra gestore delle VMs e gli _'hypervisors'_ tramite **'providers'**
- libreria pubblica di _'box'_ pronti all'uso (imamgini di VMs pronte all'uso)  
- possiblità di creare nuovi _'box'_ in modo semplice
- configurazione delle VMs di cui fare il 'provision' tramite file testuale

#### Vagrant in questo workshop
In questo workshop la nostra **infrastruttura** è composta da 3 ambienti differenti:
- ambiente con strumenti per lo sviluppo e CI/CD
- ambiente di testing
- ambiente di pre-produzione / staging

E' stata creata una VM per ogni ambiente al fine di mantenerli separati e isolati;
per avviare le VM basta lanciare un singolo comando!
 
```bash
cd vagrant
vagrant plugin install vagrant-vbguest
vagrant vbguest
vagrant up
```

Al termine dell'esecuzione del comando ``vagrant up`` avremo i nostri 3 ambienti avviati con installato tutto il necessario.
L'installazione del software e una parte della sua configurazione viene fatto in automatico tramite _'Ansible'_ (vedi il prossimo capitolo).

### Ansible
Ansible è un software che consente di automatizzare le procedure di installazione e configurazione dei sistemi _'unix-like'_ e _'Ms Windows'_ (dalla versione 1.7).

#### Introduzione ad Ansible
Le caratteristiche principali di questo software sono:
- Software Libero: licenza GNU GPL v3
- agent-less: sfrutta le connessioni **ssh**
- minimale
- estendibile mediante plugin
- sicuro (usa ssh e utenti unix)
- dichiarativo
- idempotente
- semplice da imparare (file basati su _yaml_)

Ansible si basa sui concetti di _'Inventory'_, _'Role'_ _'Task'_ e _'Playbook'_.
In questa breve introduzione non entreremo nei dettagli dei concetti elencati sopra, ma in modo semplice possiamo definirli come:
- **Inventory**: uno o più file che descrivono censiscono i singoli server (nodi) o gruppi di nodi da gestire e che definiscono varibili specifiche per quel nodo o gruppo
- **Role**: insieme di **task**, configurazioni e varibili specifiche che servono per installare o configurare un prodotto o servizio e.g. _'docker'_
- **Task**: raccolta di _'istruzioni'_ basilari che servono per installare o configurare ogni singola parte di un prodotto o servizi più complesso e.g. _'docker machine'_, _'docker compose'_, _'enable docker via tcp'_
- **Playbook**: è quello che effettivamente andiamo a leggere ed eseguire. Esso istruisce su come mappare **Inventory** e **Role**

#### Ansible in questo workshop
Viene sfruttato in 2 momenti distinti e con scopi differenti:
1. installazione e configurazione degli ambienti... le 3 VM avviate tramite Vagrant
2. deploy e configurazione del nostro micro-service

Nel primo caso viene lanciato automaticamente dal processo di provisioning di Vagrant;
 mentre, nel secondo caso verrà lanciato dalla nostra _'Build & Delivery Pipeline'_ 

### GitLab-CE
GitLab Community Edition (GitLab-CE) è una piattaforma web per la gestione del codice sorgente basata su **git**.

#### Introduzione a GitLab-CE
Le caratteristiche principali di questo software sono:
- Software Libero: licenza MIT
- gestione repository git
- gestione granulare dei permessi
- issue tracking
- code review tool
- host di documentazione web
- funzionalità per supportare CI/CD (build pipeline, gestione dei deploy)
- integrazione con Docker e Kubernetes
- repository per container docker
- integrazione con sistemi di monitoring
- _DevOps Ready and Friendly_ (lo dichiara _'GitLab Inc.'_)

#### GitLab-CE in questo workshop
GitLab-CE può fare tantissime cose, ma noi lo useremo solo per gestire il repository del codice sorgente.
Nella pratica, avremmo potuto usare git **"puro"**, senza alcuna sovrastruttura software per gestire i repository e i permessi e senza alcuna interfaccia web o funzionalità aggiuntiva.

La scelta di usare GitLab-CE non è stata fatta con leggerenzza...
**Continuous Integration** e **Continuous Delivery** NON possono e NON devono essere ridotte meramente a un sistema di **Build Automation**;
esse fanno parte delle **Pratiche eXtreme Programming** e della **Cultura DevOps** e GitLab-CE ha alcune funzionalità utili per supportarci su queste vie, andando altre alla strada del **"Continuous"**.
Si è scelto di usare e mostrarvi GitLab-CE semplicemente per fornirvi uno strumento utile per sperimentare altre pratiche e supportarvi nel vostro lavoro quotidiano.

La nostra istanza è avviata come container Docker. Sul repository ufficiale di docker sono presenti parecchie immagini, tra cui quella **"ufficiale"** di GitLab-CE.
Esso è raggiungibile a questo url: [http://192.168.50.91:8002/](http://192.168.50.91:8002/)

Una volta eseguito il primo accesso e creata la password per l'utente _'root'_ possiamo creare il repository per il nostro micro-servizio:
- Create a project:
  - Project name: _hex2hsl_
  - Visibility Level: _Public_

URL repository **hex2hsl**: [http://192.168.50.91:8002/root/hex2hsl.git](http://192.168.50.91:8002/root/hex2hsl.git)

### Jenkins
Jenkins, da molti, è considerato lo strumento indispensabile e per eccellenza per fare **"Continuous Integration"**, ma sarà vero?
Mi sono chiesto più volte cos'è e cosa realmente fa... scavando fino alla radici ho trovato questa risposta:

``Jenkins è un Job Scheduler & Executor``

Sì, semplicemente esegue e pianifica delle _attività_. Normalmente queste _attività_ sono le build delle nostre applciazioni, ma nessuno ci vieta di utilizzarlo per altri tipi scopi. 

#### Introduzione a Jenkins
Le caratteristiche principali di questo software sono:
- Software Libero: licenza MIT
- altamente configurabile
- flessibile e duttile
- estendibile con plugin
- gestione e provision integrata dei tool utilizzati nelle attività
- architettura master/slave

#### Jenkins in questo workshop
In questo workshop lo useremo per il suo scopo principale... esguire build automatiche e permetterci di fare Continuous Integration & Delivery.

Vediamo come cofiguralo partendo da zero applicando alcune buone pratiche per rendere il sistema scalabile, resiliente ed affidabile.
La nostra istanza è avviata come container Docker ed è raggiungibile a questo url: [http://192.168.50.91:8003/](http://192.168.50.91:8003/)

Prima di iniziare è necessario recuperare la password di default generata in fase di installazione, quindi eseguite in una console i seguenti comandi:
```bash
vagrant ssh turnkey
docker exec turnkey_jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

**Wizard iniziale:**
- password: vedi codice sopra
- Customize Jenkins: _Install Suggested Plugins_
- Create First Admin User: _Continue as admin_
- Instance Configuration: _http://192.168.50.91:8003/_

**Al primo accesso:**
- Manage Jenkins -> Configure Global Security: _Anyone can do anything_
- Manage Jenkins -> Mange Nodes:
    - New Node:
        - Node Name: _schiavo_
        - mettere la spunta su _Permanent Agent_
        - premere _ok_
    - Pagina successiva:
        - Remote root directory: _/data/jenkins/nodes/_
        - Host: _192.168.50.91_
        - Credentials -> Add -> Jenkins:
            - Kind: _SSH Username with private key_
            - Username: _vagrant_
            - Private Key: _enter directly_
            - Key: copia il contenuto del file _./ansible/ssh/id_rsa_
        - Host Key Verification Strategy: _Non verify Verification Strategy_
- Manage Jenkins -> Manage Plugins:
    - [NodeJS](https://plugins.jenkins.io/nodejs)
    - [xUnit](https://plugins.jenkins.io/xunit)
    - [Docker](https://plugins.jenkins.io/docker-plugin)
- Manage Jenkins -> Global Tool Configuration:
    - NodeJS:
        - Name: nodejs-8
        - Install automatically
        - Version: 8.12.0
    - Docker:
        - Name: docker-latest
        - Install automatically
        - Version: latest

___

Copyright &copy; 2018  Gianni Bombelli @ Intré S.r.l.

[![Image](https://i.creativecommons.org/l/by-sa/4.0/88x31.png)](https://creativecommons.org/licenses/by-sa/4.0/)

Except where otherwise noted, content on this documentation is licensed under a [Creative Commons Attribution-ShareAlike 4.0 International License](https://creativecommons.org/licenses/by-sa/4.0/).
