// FAQ.swift
// Copyright (C) 2020 Presidenza del Consiglio dei Ministri.
// Please refer to the AUTHORS file for more information.
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Affero General Public License for more details.
// You should have received a copy of the GNU Affero General Public License
// along with this program. If not, see <https://www.gnu.org/licenses/>.

import Foundation

/// A struct representing an FAQ
public struct FAQ: Equatable, Codable {
  /// The title of the FAQ
  public let title: String

  /// The content of the FAQ
  public let content: String

  /// Creates a new FAQ
  public init(title: String, content: String) {
    self.title = title
    self.content = content
  }
}

// MARK: Italian default FAQs

// swiftlint:disable line_length

public extension FAQ {
  static let italianDefaultValues: [FAQ] = [
    .init(
      title: "Cos'è Immuni?",
      content: """
      Immuni è un'app creata per aiutarci a combattere le epidemie, a partire da quella del COVID-19:

       • L'app si propone di avvertire gli utenti potenzialmente contagiati il prima possibile, anche quando sono asintomatici.

       • Questi utenti possono poi isolarsi per evitare di contagiare altri. Questo minimizza la diffusione del virus e, allo stesso tempo, velocizza il ritorno a una vita normale per la maggior parte della popolazione.

       • Venendo informati tempestivamente, gli utenti possono anche contattare il proprio medico di medicina generale e ridurre così il rischio di complicanze.
      """
    ),
    .init(
      title: "Come funziona il sistema di notifiche di esposizione di Immuni?",
      content: """
      Il sistema di notifiche di esposizione di Immuni mira ad avvertire gli utenti quando sono stati esposti a un utente potenzialmente contagioso.

      Il sistema è basato sulla tecnologia Bluetooth Low Energy e non utilizza dati di geolocalizzazione di alcun genere, inclusi quelli del GPS. L'app non raccoglie e non è in grado di ottenere alcun dato identificativo dell'utente, quali nome, cognome, data di nascita, indirizzo, numero di telefono o indirizzo email. Immuni riesce quindi a determinare che un contatto fra due utenti è avvenuto, ma non chi siano effettivamente i due utenti o dove si siano incontrati.

      Di seguito, una spiegazione semplificata di come funziona il sistema. Consideriamo l'esempio di Alice e Marco, due ipotetici utenti.

      Una volta installata da Alice, l'app fa sì che il suo smartphone emetta continuativamente un segnale Bluetooth Low Energy che include un codice casuale. Lo stesso vale per Marco. Quando Alice si avvicina a Marco, gli smartphone dei due utenti registrano nella propria memoria il codice casuale dell'altro, tenendo quindi traccia di quel contatto. Registrano anche quanto è durato il contatto e a che distanza erano i due smartphone approssimativamente.

      I codici sono generati del tutto casualmente, senza contenere alcuna informazione sul dispositivo o l'utente. Inoltre, sono modificati diverse volte ogni ora, in modo da proteggere ulteriormente la privacy degli utenti.

      Supponiamo che, successivamente, Marco risulti positivo al SARS-CoV-2. Con l'aiuto di un operatore sanitario, Marco potrà caricare su un server delle chiavi crittografiche dalle quali è possibile derivare i suoi codici casuali.

      Per ogni utente, l'app scarica periodicamente dal server le nuove chiavi crittografiche inviate dagli utenti che sono risultati positivi al virus. L'app usa queste chiavi per derivare i loro codici casuali e controlla se qualcuno di quei codici corrisponde a quelli registrati nella memoria dello smartphone nei giorni precedenti. In questo caso, l'app di Alice troverà il codice casuale di Marco, verificherà se la durata e la distanza del contatto siano state tali da aver potuto causare un contagio e, se sì, avvertirà Alice.
      """
    ),
    .init(
      title: "L'app traccia i miei spostamenti?",
      content: """
      No. Il sistema di notifiche di esposizione di Immuni si basa sulla tecnologia Bluetooth Low Energy e non raccoglie dati di geolocalizzazione di alcun genere, inclusi quelli del GPS. Immuni non è in grado di sapere dove vai o chi incontri.
      """
    ),
    .init(
      title: "Come viene tutelata la mia privacy?",
      content: """
      Durante l'intero processo di design e sviluppo di immuni, abbiamo posto grande attenzione sulla tutela della tua privacy.

      Eccoti una lista di alcune delle misure con cui Immuni protegge i tuoi dati:

       • L'app non raccoglie alcun dato personale che consentirebbe di risalire alla tua identità. Per esempio, non ti chiede e non è in grado di ottenere il tuo nome, cognome, data di nascita, indirizzo, numero di telefono o indirizzo email.

       • L'app non raccoglie alcun dato di geolocalizzazione, inclusi i dati del GPS. I tuoi spostamenti non sono tracciati in alcun modo.

       • Il codice Bluetooth Low Energy trasmesso dall'app è generato in maniera casuale e non contiene alcuna informazione riguardo al tuo smartphone, né su di te. Inoltre, questo codice cambia svariate volte ogni ora, per tutelare ancora meglio la tua privacy.

       • I dati salvati sul tuo smartphone sono cifrati.

       • Le connessioni tra l'app e il server sono cifrate.

       • Tutti i dati, siano essi salvati sul dispositivo o sul server, saranno cancellati non appena non saranno più necessari e in ogni caso non oltre il 31 dicembre 2020.

       • È il Ministero della Salute il soggetto che raccoglie i tuoi dati. I dati verranno usati solo per contenere l'epidemia del COVID-19 o per la ricerca scientifica.

       • I dati sono salvati su server in Italia e gestiti da soggetti pubblici. 
      """
    ),
    .init(
      title: "Il codice è open source?",
      content: """
      Sì, il codice è open source e disponibile su GitHub. La licenza è la GNU Affero General Public License version 3.
      """
    ),
    .init(
      title: "Perché Immuni è importante?",
      content: """
      Tutti noi desideriamo ridurre la diffusione dell'epidemia, tornare al più presto a una vita normale e ridurre il rischio alla salute dei nostri cari.

      Immuni gioca un ruolo importante nella realizzazione di questi obiettivi. Grazie al sistema di notifiche di esposizione, l'app permette di avvertire rapidamente gli utenti che sono stati in prossimità di un utente contagioso, suggerendo l'isolamento e di contattare il proprio medico di medicina generale. Tutto questo è di cruciale importanza per minimizzare il numero di contagi e assicurarsi che gli utenti possano ricevere le giuste attenzioni mediche il prima possibile, minimizzando il rischio di complicanze.
      """
    ),
    .init(
      title: "È proprio necessario che tutti usino l'app? Cosa succede se non viene usata da un numero sufficiente di persone?",
      content: """
      Più persone usano Immuni, più l'app può essere efficace. Infatti, maggiore è la diffusione di Immuni, più sono i potenziali contagiati che l'app riesce ad avvertire e che possono quindi isolarsi, aiutando a contenere l'epidemia e ad accelerare il ritorno alla normalità.

      Tuttavia, anche se la diffusione di Immuni fosse limitata, l'app potrà comunque contribuire a rallentare l'epidemia, specialmente in combinazione alle altre misure implementate dal governo. Questo rallentamento, anche se minimo, ridurrà la pressione sul Servizio Sanitario Nazionale, permettendo a più pazienti di ricevere cure appropriate e potenzialmente salvando molte vite. Nel frattempo, la ricerca scientifica avanza verso un possibile vaccino.
      """
    ),
    .init(
      title: "Come posso controllare se sto usando l'app correttamente?",
      content: """
      Fare un uso scorretto dell'app rende Immuni molto meno efficace e aumenta il rischio per te, per i tuoi cari e per tutta la comunità.

      Per accertarti che tu stia usando l'app come previsto, basterà aprirla e controllare che nella sezione Home ci sia scritto “Servizio attivo”. In caso contrario, premi sul tasto “Riattiva Immuni” e segui le istruzioni per riportare l'app a funzionare correttamente.

      Qualche altro consiglio importante per assicurarti che Immuni possa essere efficace:

       • Quando esci di casa, porta sempre con te lo smartphone sul quale hai installato l'app.

       • Non disabilitare il Bluetooth (salvo quando stai dormendo, se lo desideri).

       • Non disinstallare l'app.

       • È di vitale importanza che, quando l'app ti manda una notifica, tu la legga, apra l'app e segua le indicazioni fornite. Per esempio, se l'app ti chiede di aggiornarla, per favore fallo. Se ti suggerisce di isolarti e di chiamare il tuo medico di medicina generale, è fondamentale che tu lo faccia immediatamente.
      """
    ),
    .init(
      title: "L'app fa diagnosi mediche o fornisce consigli medici?",
      content: """
      Immuni non fa e non può fare diagnosi. Sulla base dello storico della tua esposizione a utenti potenzialmente contagiosi, Immuni elabora alcune raccomandazioni su come è necessario comportarsi. Ma l'app non è un dispositivo medico e non può in alcun caso sostituire un medico.
      """
    ),
    .init(
      title: "Quali dispositivi e sistemi operativi sono supportati?",
      content: """
      Al momento, Immuni supporta gli smartphone con Bluetooth Low Energy e una versione di iOS pari o superiore alla 13.5 o di Android pari o superiore alla 6 (Marshmallow, API 23). Per gli smartphone Android, è anche richiesta una versione di Google Play Services pari o superiore alla 20.18.13.

      Se il tuo dispositivo lo consente, ti invitiamo ad aggiornare il sistema operativo a una versione che permetta l'uso di Immuni. Nel caso tu abbia uno smartphone Android, assicurati anche di aggiornare Google Play Services.

      Siamo consci dell'importanza di supportare il maggior numero di dispositivi possibile. I requisiti descritti sopra sono imposti dalle tecnologie per le notifiche di esposizione messe a disposizione da Apple e Google, che non sono disponibili per versioni precedenti di iOS, Android e Google Play Services.
      """
    ),
    .init(
      title: "Le istruzioni fornite dall'app sono attendibili?",
      content: """
      Le raccomandazioni fornite dall'app dipendono dalla durata della tua esposizione a utenti potenzialmente contagiosi e dalla distanza fra il tuo smartphone e quello di questi utenti durante l'esposizione.

      Si tratta di un numero limitato di informazioni, peraltro mai perfette, in quanto il segnale Bluetooth Low Energy è influenzato da vari fattori di disturbo. Quindi, la valutazione non sarà sempre impeccabile. Per esempio, se l'app ti raccomanda di isolarti, non significa che sicuramente hai il SARS-CoV-2. Significa piuttosto che, sulla base delle informazioni a disposizione dell'app, l'isolamento è la cosa più sicura da fare per te e per chi ti sta accanto.

      È quindi importante che tu segua le indicazioni fornite dall'app, per il bene tuo, dei tuoi cari e della comunità. Non esitare a consultare il tuo medico di medicina generale in caso l'app ti avverta di un possibile contagio.
      """
    ),
    .init(
      title: "Non ho uno smartphone compatibile con Immuni. Cosa posso fare?",
      content: """
      Senza uno smartphone compatibile, per il momento purtroppo non puoi usare Immuni.

      Siamo consci dell'importanza di consentire al maggior numero di persone possibile di usare Immuni. Comunicheremo prontamente eventuali novità in questo senso.
      """
    ),
    .init(
      title: "L'app scaricherà la batteria del mio smartphone?",
      content: """
      Non dovresti notare una differenza sostanziale nella durata della tua batteria. Immuni infatti usa il Bluetooth Low Energy, una tecnologia creata per essere particolarmente efficiente in termini di risparmio energetico.

      Tuttavia, anche se pensi che la batteria del tuo smartphone si sia scaricata un po' più velocemente del solito, per favore continua a usare l'app in modo corretto. Il tuo contributo è importante perché Immuni sia efficace nell'aiutarci a combattere l'epidemia e tornare al più presto a una vita normale.
      """
    ),
    .init(
      title: "Dove posso trovare Immuni?",
      content: """
      Puoi scaricare l'app dall'App Store (per iPhone) o da Google Play (per smartphone con sistema operativo Android). L'app non è disponibile su nessun altro canale di distribuzione.
      """
    ),
    .init(
      title: "I minori possono usare l'app?",
      content: """
      Devi avere almeno 14 anni per usare Immuni. Se hai almeno 14 anni ma meno di 18, per usare l'app devi avere il permesso di almeno uno dei tuoi genitori o di chi esercita la tua rappresentanza legale.
      """
    ),
    .init(
      title: "Posso accedere al mio profilo da dispositivi diversi?",
      content: """
      No. Con Immuni non crei un profilo come in tante altre app. Pertanto, se installi l'app su un nuovo dispositivo, non c'è modo per Immuni di riconoscere che sei sempre tu.
      """
    ),
    .init(
      title: "Immuni è gestito dal governo?",
      content: """
      Sì. Immuni è l'app di notifiche di esposizione del governo italiano, sviluppata dal Commissario Straordinario per l'Emergenza COVID-19 in collaborazione con il Ministero della Salute e il Ministero per l'Innovazione Tecnologica e la Digitalizzazione.

      Per Immuni, il governo italiano si avvale di una licenza perpetua e irrevocabile su tutto il codice, le grafiche, i testi e la documentazione concessa a titolo gratuito da Bending Spoons S.p.A.

      Sotto il coordinamento del Ministero della Salute e con il supporto del Dipartimento per l'Innovazione Tecnologica e la Digitalizzazione, lavorano al progetto le società a controllo pubblico SoGEI S.p.A. e PagoPA S.p.A. insieme a Bending Spoons S.p.A., che continua a fornire un servizio di documentazione, design e sviluppo software, sempre a titolo completamente gratuito e senza autorità decisionale o accesso ai dati degli utenti.
      """
    ),
    .init(
      title: "Bisogna pagare per usare Immuni?",
      content: """
      No. Immuni è un'app completamente gratuita.
      """
    ),
    .init(
      title: "Posso decidere di non usare l'app?",
      content: """
      Immuni è uno strumento importante nella lotta a questa terribile epidemia e ciascun utente ne aumenta l'efficacia complessiva. Per questo ti consigliamo vivamente di installare l'app, usarla correttamente e incoraggiare parenti e amici a fare lo stesso. Tuttavia, non sei obbligato a usarla. La decisione spetta soltanto a te.
      """
    ),
    .init(
      title: "Immuni dice che potrei essere a rischio, ma io mi sento bene. Cosa devo fare?",
      content: """
      Ti suggeriamo vivamente di seguire tutte le raccomandazioni di Immuni. Ci sono molte persone asintomatiche che hanno diffuso il virus senza rendersene conto. Uno dei punti di forza di Immuni è proprio la capacità di avvertire queste persone. Per favore, fai la tua parte seguendo le raccomandazioni, anche se pensi di non essere contagioso.
      """
    ),
    .init(
      title: "Sono stato in un luogo o con una persona che vorrei rimanessero privati. Immuni mette a repentaglio la mia privacy?",
      content: """
      No. Il sistema è basato sulla tecnologia Bluetooth Low Energy e non utilizza dati di geolocalizzazione di alcun genere, inclusi quelli del GPS. I codici che gli smartphone si scambiano sono generati in maniera casuale e cambiano svariate volte ogni ora. Di conseguenza, l'app non può determinare dove sia avvenuto un contatto né coloro che vi hanno preso parte. La tua privacy è tutelata.
      """
    ),
    .init(
      title: "Devo fare una registrazione con indirizzo email e password?",
      content: """
      No. L'app non raccoglie alcun dato personale che consentirebbe di risalire alla tua identità. Per esempio, non ti chiede e non è in grado di ottenere il tuo nome, cognome, data di nascita, indirizzo, numero di telefono o indirizzo email.
      """
    ),
    .init(
      title: "Devo tenere l'app aperta per farla funzionare correttamente? Posso usare altre app?",
      content: """
      Immuni funziona in background. L'importante è che il tuo smartphone sia acceso e che il Bluetooth sia attivo. Puoi anche chiudere l'app manualmente—fintanto che la tieni installata, non ci sono problemi. Puoi usare tranquillamente altre app, come fai di solito.
      """
    ),
    .init(
      title: "Il Bluetooth del mio smartphone deve essere sempre attivo?",
      content: """
      Il sistema di notifiche di esposizione si basa su Bluetooth Low Energy. È necessario, quindi, che il Bluetooth sia sempre attivo affinché il sistema possa rilevare i tuoi contatti con gli altri utenti. Resti ovviamente libero di attivare o disattivare il bluetooth quando preferisci.
      """
    ),
    .init(
      title: "Tengo spesso il mio smartphone in modalità aereo. Posso continuare a farlo?",
      content: """
      Sì, l'importante è che tu mantenga il Bluetooth attivo. In questo modo, Immuni continuerà a funzionare come previsto.
      """
    ),
    .init(
      title: "Quanto traffico dati consuma Immuni?",
      content: """
      Molto poco. Ogni giorno, l'app scarica le nuove chiavi crittografiche dei dispositivi degli utenti positivi al SARS-CoV-2 per controllare se sei stato esposto a loro ed eventualmente avvertirti. Puoi aspettarti che questa operazione consumi fino a qualche megabyte di traffico dati al giorno, più o meno come caricare una pagina di un sito con qualche foto.
      """
    ),
    .init(
      title: "L'app mi ha suggerito di fare un aggiornamento. Cosa succede se non lo faccio?",
      content: """
      Gli aggiornamenti sono volti a migliorare l'efficacia del sistema, anche correggendo potenziali difetti critici. Pertanto, è importante aggiornare Immuni quando è disponibile una nuova versione. Se l'aggiornamento è ritenuto necessario, l'app ti manderà una notifica. Tuttavia, la scelta se aggiornare o meno l'app sta a te.
      """
    ),
    .init(
      title: "Posso usare l'app senza connessione a Internet?",
      content: """
      Immuni non richiede una connessione a Internet continuativa. Tuttavia, l'app ha bisogno di connettersi di tanto in tanto (almeno una volta al giorno) per scaricare le informazioni necessarie a controllare se sei stato esposto a utenti potenzialmente contagiosi. Pertanto, assicurati che il tuo smartphone sia connesso a Internet almeno una volta al giorno.
      """
    ),
    .init(
      title: "Immuni condivide o vende i miei dati?",
      content: """
      I dati sono controllati dal Ministero della Salute. In nessun caso i tuoi dati verranno venduti o usati per qualsivoglia scopo commerciale, inclusa la profilazione a fini pubblicitari. Il progetto non ha alcun fine di lucro, ma nasce unicamente per aiutare a far fronte all'epidemia. Non è esclusa la condivisione di dati al fine di favorire la ricerca scientifica, ma solo previa completa anonimizzazione e aggregazione degli stessi.
      """
    ),
    .init(
      title: "Posso cambiare la lingua dell'app?",
      content: """
      Le lingue attualmente supportate dall'app sono l'italiano, l'inglese, il tedesco, il francese, lo spagnolo e il portoghese. L'app usa la stessa lingua che hai impostato sul tuo smartphone, se disponibile, altrimenti l'inglese. Perciò per cambiare la lingua dell'app dovrai cambiare la lingua del tuo dispositivo.
      """
    )
  ]
}

// MARK: English default FAQs

public extension FAQ {
  static let englishDefaultValues: [FAQ] = [
    .init(title: "[EN] Domanda", content: "[EN] Questa é una risposta")
  ]
}

// MARK: German default FAQs

public extension FAQ {
  static let germanDefaultValues: [FAQ] = [
    .init(title: "[DE] Domanda", content: "[DE] Questa é una risposta")
  ]
}
