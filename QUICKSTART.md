# Turnkey Continuous Delivery - Quickstart

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
La nostra infrastruttura è costituita da 3 ambienti differenti che corrispondono 1:1 ad altrettante VMs e per la precisione:
- **turnkley**: VM per SCM, repository binari e sistema automatizzato di build
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

E' stata creata una VM per ogni ambiente al fine di mantenerli separati e isolati;
per avviare le VM basta lanciare un singolo comando!
 
```bash
cd vagrant
vagrant plugin install vagrant-vbguest
vagrant up
```

### GitLab-CE
GitLab Community Edition (GitLab-CE) è una piattaforma web per la gestione del codice sorgente basata su **git**.

La nostra istanza è avviata come container Docker ed esso è raggiungibile a questo url: [http://192.168.50.91:8002/](http://192.168.50.91:8002/)

Una volta eseguito il primo accesso e creata la password per l'utente _'root'_ possiamo creare il repository per il nostro micro-servizio:
- Create a project:
  - Project name: _hex2hsl_
  - Visibility Level: _Public_

URL repository **hex2hsl**: [http://192.168.50.91:8002/root/hex2hsl.git](http://192.168.50.91:8002/root/hex2hsl.git)

### Jenkins
Jenkins, da molti, è considerato lo strumento indispensabile e per eccellenza per fare **"Continuous Integration"**, ma sarà vero?
Mi sono chiesto più volte cos'è e cosa realmente fa... scavando fino alla radici ho trovato questa risposta:

``Jenkins è un Job Scheduler & Executor``

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
