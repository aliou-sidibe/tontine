# Plan : Ma Tontine, suivi de tontine hors ligne

*Créé le 6 novembre 2026.*

**Objectif :** une appli Android hors ligne pour gérer une tontine : noter qui a payé, ce qui reste
dû, qui ramasse à quel tour, et ce que l'organisateur a avancé de sa poche.

**Identifiants techniques :** package Flutter `matontine`, identifiant Android
`ci.ibrahimplastique.matontine`. Ne jamais changer ce dernier après la première installation :
Android traiterait l'appli comme une autre application.

**Utilisateur :** l'organisateur de la tontine (le frère d'Aliou). Il fait la tournée chaque jour
pour encaisser les cotisations, puis remet la cagnotte au bénéficiaire du tour.

**Maquette validée :** [Ma Tontine — maquette](https://claude.ai/artifact/Ke5yYbUMEtzGqQ5SgH9htd),
8 écrans. **L'appli la respecte à la lettre** : textes, couleurs, polices, tailles, espacements,
ordre des éléments. Un écran absent de la maquette reprend exactement la même charte (voir
[Charte graphique](#charte-graphique-relevée-dans-la-maquette)).

## Besoins validés

- Téléphone Android, un seul appareil. Devise : FCFA. Montants entiers.
- Plusieurs tontines possibles, en cours ou terminées.
- Une tontine se définit par : un nom, un **nombre de places**, une **cotisation par place et par
  jour**, une **durée de tour en jours** et un **premier jour de cotisation**.
- **Tous les jours comptent**, dimanches et jours fériés compris.
- **Une place = un tour = une cagnotte.** Le nombre de tours est égal au nombre de places.
- Un membre peut avoir **une place, plusieurs places ou une demi-place** (toute quantité par pas
  de ½). Une demi-place cotise la moitié, et **deux demi-places ramassent ensemble au même tour**,
  la moitié de la cagnotte chacune.
- **Le bénéficiaire cotise aussi pendant son tour.**
- **Le ramassage a lieu le lendemain du dernier jour du tour** (tour 1 du 1er au 10 : ramassage le
  11).
- **Ordre des tours** : fixé à la main ou tiré au sort à la création.
- **Échange de tours** possible en cours de tontine, tant qu'aucun des deux tours n'a été ramassé.
  L'échange reste dans l'historique.
- **Retards le jour du ramassage** :
  - un autre membre est en retard : **l'organisateur complète de sa poche**. L'appli note ce
    qu'il a avancé et auprès de qui le récupérer ;
  - le bénéficiaire est lui-même en retard : **son retard est retenu sur sa cagnotte**, et il est
    remis à jour.
- **Ni commission, ni pénalité de retard.**
- **Paiements : espèces ou mobile money**, sans intégration d'API (simple mention).
- **Saisie d'un versement uniquement par appui long** sur le membre. Un appui simple ne fait rien
  (évite les erreurs). Le pavé s'ouvre pré-rempli avec la cotisation du jour.
- **Partage de l'état en PDF** sur WhatsApp.
- Compte local avec **code de secours** pour réinitialiser le mot de passe (repris d'IP Caisse).
- Sauvegarde chiffrée par export / import (reprise d'IP Caisse).
- Pas de publication sur le Play Store : APK envoyé par WhatsApp, Drive ou câble.

## Règles de calcul

Notations, pour une tontine : `C` cotisation d'une place par jour, `T` jours par tour, `N` places
(= tours), `J` jour courant (jour 1 = premier jour de cotisation).

| Grandeur | Formule | Exemple (20 places, 5 000 F, 10 jours) |
|---|---|---|
| Durée totale | `N × T` jours | 200 jours |
| Versement d'une place par tour | `C × T` | 50 000 F |
| Cagnotte d'un tour | `N × C × T` | 1 000 000 F |
| Jours du tour `t` | de `(t−1)×T + 1` à `t×T` | tour 4 : jours 31 à 40 |
| Ramassage du tour `t` | premier jour + `t×T` jours | tour 4 : jour 41, mar. 10 nov. 2026 |

**Cotisation d'un membre par jour :** `places × C`, ses places comptées en demi-places pour
rester en entiers (`demi-places × C ÷ 2`). Pour que la demi-place tombe juste, **la cotisation
d'une place est un multiple de 10 F**.

**Dû à ce jour :** `cotisation du membre × min(J, N×T)`, et 0 avant le premier jour.

**Versé :** somme de ses versements non annulés, plus les retenues faites sur ses cagnottes.

**Solde :** `versé − dû à ce jour`.
- Solde négatif : en retard ou à encaisser (voir l'écran Aujourd'hui).
- Solde positif : en avance.
- **« À jour jusqu'au jour X »** : `X = versé ÷ cotisation du membre` (division entière), plafonné
  au dernier jour.

**Affectation des versements :** un versement couvre toujours **les jours les plus anciens
d'abord**. Conséquence voulue : un membre en retard rembourse d'abord l'organisateur, qui avait
complété la cagnotte d'un tour déjà ramassé.

**Avancé par l'organisateur, à récupérer :** pour chaque membre,
`max(0, dû jusqu'à la fin du dernier tour ramassé − versé)`. Le total est affiché sur l'écran
Aujourd'hui avec les prénoms concernés.

**Remise de la cagnotte du tour `t`** (exemple de la maquette) :

| Ligne | Calcul | Exemple |
|---|---|---|
| Cagnotte du tour | `N × C × T` (moitié pour une demi-place) | 1 000 000 F |
| Versé par les membres | part des versements affectée aux jours du tour | 955 000 F |
| Tu complètes de ta poche | manque des **autres** membres sur ce tour | + 40 000 F |
| Retenue : retard du bénéficiaire | tout son retard jusqu'au dernier jour du tour | − 5 000 F |
| **À remettre** | cagnotte − retenue | **995 000 F** |

La retenue est enregistrée comme un versement du bénéficiaire (mode « retenue ») : il est remis
à jour. Si sa retenue couvre aussi d'anciens tours, cette part rembourse l'organisateur.

**Tour à deux demi-places :** deux remises de la moitié de la cagnotte (500 000 F chacune).
Chacune a sa propre retenue. Le complément de l'organisateur se partage par moitié.

**Tontine terminée :** quand tous les tours ont été remis.

## Modèle de données

Identifiants UUID. Montants en entiers. Dates de cotisation et de ramassage en jours
calendaires (sans heure). Historique en **ajout seul** : un versement ou une remise ne se modifie
ni ne se supprime, il s'annule par une contre-écriture (même principe qu'IP Caisse).

| Table | Contenu |
|---|---|
| `account` | Compte local (repris d'IP Caisse) : identifiant, empreintes du mot de passe et du code de secours, blocage. |
| `tontine` | nom, nombre de places, cotisation par place et par jour, jours par tour, premier jour, création. |
| `member` | tontine, nom, téléphone (facultatif), ordre d'affichage. |
| `slot` | une part de tour : tontine, numéro de tour, membre, demi-places (2 = place entière, 1 = demi-place). Un tour a une part entière ou deux demi-parts. |
| `payment` | tontine, membre, montant, mode (`cash`, `mobileMoney`, `withheld` pour une retenue), jour du versement, création. |
| `payment_cancellation` | versement annulé, motif, création. |
| `payout` | une remise : tontine, part (`slot`), jour, cagnotte, complément de l'organisateur, retenue, montant remis, mode, création. |
| `payout_cancellation` | remise annulée, motif, création. |
| `tour_swap` | échange : tontine, tour A, tour B, création. Les parts sont échangées dans la même transaction. |

## Écrans

Les 8 écrans de la maquette, plus ceux qu'elle ne montre pas, dessinés dans la même charte.

| # | Écran | Maquette | Points clés |
|---|---|---|---|
| 1 | **Aujourd'hui** | « Aujourd'hui » | En-tête « Jour J sur N×T » et date ; carte verte du tour en cours (bénéficiaire, date de ramassage, « dans N jours », barre « réunis / attendus à ce jour ») ; tuiles « Encaissé aujourd'hui » et « Avancé par toi » ; filtres « Tous », « À encaisser », « En retard » ; liste des membres ; « Appui long sur un membre pour enregistrer un versement » ; barre du bas. |
| 2 | **Versement** | « Versement (appui long) » | Feuille du bas : raccourcis « Le jour » et « Jour + retard », montant pré-rempli, « X sera à jour jusqu'au jour N », Espèces / Mobile money, date modifiable, pavé, « Annuler » et « Enregistrer X F ». |
| 3 | **Remise de la cagnotte** | « Remise de la cagnotte » | Calcul ligne par ligne, montant à remettre, mode, « Confirmer la remise de X F ». |
| 4 | **Fiche membre** | « Fiche membre » | Retard ou avance, total versé, son tour (bouton « Échanger »), historique des versements avec les annulations barrées, bouton Appeler. |
| 5 | **Mes tontines** | « Mes tontines » | En cours et terminées, « Nouvelle tontine », Sauvegarde, Mon compte. |
| 6 | **Nouvelle tontine · 1 Paramètres** | « Nouvelle tontine · paramètres » | Champs et carte « Calculé par l'appli ». |
| 7 | **Nouvelle tontine · 2 Membres** | *(hors maquette)* | Nom, téléphone, nombre de places par pas de ½ ; compteur « X places sur N ». |
| 8 | **Nouvelle tontine · 3 Ordre** | « Nouvelle tontine · ordre des tours » | « Qui ramasse quand ? », « Tirer au sort », contrôle « N places sur N · demi-places associées », glisser pour réordonner. |
| 9 | **Nouvelle tontine · 4 Récap** | *(hors maquette)* | Résumé et calendrier, bouton « Démarrer la tontine ». |
| 10 | **Tours (calendrier)** | « Calendrier des tours » | Remis / En cours / À venir, « Échanger deux tours », « Partager l'état (PDF) sur WhatsApp ». |
| 11 | Échange de tours | *(hors maquette)* | Choix des deux tours non ramassés, confirmation. |
| 12 | Connexion, création du compte, code de secours, mot de passe oublié | *(hors maquette)* | Repris d'IP Caisse, dans la charte. |
| 13 | Sauvegarde | *(hors maquette)* | Reprise d'IP Caisse, dans la charte. |
| 14 | Liste des membres (onglet Membres) | *(hors maquette)* | Lignes identiques à l'écran Aujourd'hui, ouvrant la fiche membre. |

**Navigation :** barre du bas à 4 onglets, **Aujourd'hui, Membres, Tours, Plus** (Plus ouvre
« Mes tontines »). L'appli s'ouvre sur l'écran Aujourd'hui de la dernière tontine consultée, ou sur
« Mes tontines » s'il n'y en a pas.

**Écran Aujourd'hui : état d'un membre** (badge à droite de la ligne) :

| État | Condition | Badge | Couleurs |
|---|---|---|---|
| En retard | solde < 0 et versé < dû jusqu'à hier | « Retard X F » (X = −solde) | `#FCEADB` / `#7A3A00` |
| À encaisser | solde < 0 et versé ≥ dû jusqu'à hier | « À encaisser X F » | `#EEF0EF` / `#3E4843` |
| Payé aujourd'hui | solde = 0 | « Payé aujourd'hui » (sinon « À jour » sans versement du jour) | `#E3F1E9` / `#17583C` |
| En avance | solde > 0 | « Avance X F » | `#E4ECF8` / `#1D4F91` |

**Sous-titre d'une ligne :** `N place(s)`, suivi dans cet ordre de la première information qui
s'applique :
1. « dont X F avancés par toi » ;
2. « à jour jusqu'au jour N » (en retard ou en avance) ;
3. « ramasse le <date> » (bénéficiaire du tour en cours) ;
4. « X F par jour » (si ce n'est pas exactement une place).

La liste suit l'ordre : en retard, à encaisser, payé, en avance. Filtres : « Tous » (membres),
« À encaisser » (solde < 0), « En retard ».

## Charte graphique relevée dans la maquette

Les valeurs sont celles de la maquette, en pixels logiques Flutter (1 px CSS = 1 dp).

**Couleurs**

| Rôle | Valeur |
|---|---|
| Fond d'écran | `#F5F7F6` |
| Surface (cartes, lignes, barre du bas) | `#FFFFFF` |
| Texte | `#17201B` |
| Texte secondaire | `#56615B` |
| Texte tertiaire (poignées) | `#8A948F` |
| Bordure de carte | `#E3E7E4` |
| Bordure de bouton ou de champ | `#DCE2DE` |
| Séparateur interne | `#EEF0EF` |
| Principal (vert) | `#1F6B4A` ; pâle `#E3F1E9` ; texte sur pâle `#17583C` |
| Retard / avance de l'organisateur | fond `#FCEADB`, texte `#7A3A00` |
| Neutre (à encaisser, à venir) | fond `#EEF0EF`, texte `#3E4843` |
| Avance d'un membre | fond `#E4ECF8`, texte `#1D4F91` |
| Fond d'un segment (Espèces / Mobile money) | `#EEF0EF` (feuille) ou `#E7EBE9` (écran) |
| Touches du pavé | `#F2F4F3` |
| Étape inactive | `#D6DCD8` |
| Voile derrière une feuille | `#5E6762` |
| Bouton filtre actif | fond `#17201B`, texte blanc |

**Polices** (embarquées, pas de téléchargement) : **Inter** 400, 500, 600 et 700 pour le texte,
**Space Grotesk** 500 et 700 pour les titres et les montants. Pas de Space Grotesk 600 en fichier
statique : le 600 du pavé s'affiche en 700.

**Tailles et rayons courants :** titres d'écran 26–28 Space Grotesk 700 ; montant de feuille 34 ;
texte de ligne 15/600 et sous-titre 12 ; boutons principaux 54 de haut, rayon 14 ; filtres 36 de
haut, rayon 18 ; cartes rayon 12–16 ; badges 12/600, rayon 8, marge 4×8 ; zones tactiles ≥ 44 ;
marges latérales 16, en-tête 20.

**Icônes :** traits fins (2 px, extrémités arrondies) comme dans la maquette, redessinées en
`CustomPainter` ou SVG quand Material n'a pas l'équivalent exact. Pas d'emoji.

## Décisions techniques

- **Technique :** Flutter 3.47, SQLite via `drift`, Riverpod 3. Mêmes choix et mêmes versions
  qu'IP Caisse.
- **Code en anglais** (identifiants, commentaires, logs) ; **textes affichés en français**.
- **Logique de calcul pure** (`lib/domain/`), sans Flutter ni base de données, entièrement couverte
  par des tests. Les écrans n'affichent que ce qu'elle calcule.
- **Dates :** jours calendaires locaux, l'heure du téléphone n'entre jamais dans un calcul de
  jour. Une date future de versement est refusée.
- **Reprise d'IP Caisse :** compte local, code de secours, session, sauvegarde chiffrée, enregistrement
  du fichier par le sélecteur Android, redémarrage après restauration. Le code est **copié et
  traduit**, pas partagé : les deux applis restent indépendantes.
- **Sauvegarde Android :** désactivée (`allowBackup="false"`).
- **Chaque écran de la maquette a un test de widget** qui vérifie ses textes clés avec les données
  de l'exemple (20 places, 5 000 F, 10 jours, début le 1er octobre 2026, jour 37).

## Sécurité du compte (reprise d'IP Caisse)

- Un compte, créé au premier lancement, stocké sur l'appareil.
- Mot de passe de 6 caractères minimum, conservé sous forme d'empreinte (PBKDF2-HMAC-SHA256, sel
  aléatoire).
- **Code de secours** affiché une seule fois à la création. Il permet de choisir un nouveau mot de
  passe ; un nouveau code est alors affiché. **Sans mot de passe ni code, l'accès est perdu.**
- Blocage après 5 échecs : 30 s, puis le double à chaque fois, jusqu'à 16 min.
- Session gardée 8 heures d'inactivité, puis mot de passe redemandé.
- Sauvegarde : fichier `.matontine` chiffré (AES-256-GCM, clé dérivée par PBKDF2) avec un mot de
  passe distinct, de 8 caractères minimum. Rappel si la dernière sauvegarde date de plus de 7
  jours.
- Limite : la base n'est pas chiffrée. Le compte protège l'accès par l'appli, pas contre une
  extraction des données d'un téléphone rooté.

## Étapes

Durées estimées pour un développeur seul. **Total : environ 3 à 5 semaines.**

| # | Étape | Contenu | C'est terminé quand… | Durée |
|---|---|---|---|---|
| 1 | Socle | Projet, polices, charte, base et migrations, calculs (`lib/domain/`) testés, compte local et code de secours, clé de signature, premier APK | L'APK s'installe, le compte se crée, et les calculs de l'exemple sont vérifiés par les tests | 2–3 j |
| 2 | Création de tontine | Écrans Paramètres, Membres, Ordre (tirage, demi-places), Récap ; Mes tontines | Ton frère crée la tontine de l'exemple et voit son calendrier | 3–4 j |
| 3 | Versements et Aujourd'hui | Écran Aujourd'hui, feuille de versement, annulation, onglet Membres, fiche membre | La tournée d'une journée se saisit vite, sans erreur | 4–5 j |
| 4 | Tours et remise | Calendrier, remise de la cagnotte, échange de tours | Une cagnotte remise apparaît dans l'historique avec la bonne retenue et le bon complément | 2–3 j |
| 5 | Partage | PDF de l'état (qui a payé, qui doit combien, prochains tours), partage WhatsApp | L'état part sur WhatsApp en deux appuis | 2–3 j |
| 6 | Sauvegarde | Export / import chiffré, rappel | Une restauration sur un **autre** téléphone retrouve tout | 1–2 j |
| 7 | Pilote | Une à deux semaines d'utilisation réelle, corrections | Plus de retour au cahier | 1–2 sem. |

**Étape 2 (6 novembre 2026) :** développée et testée. Sont faits : « Mes tontines » avec les
cartes de la maquette, et « Nouvelle tontine » en 4 écrans (Paramètres, Membres, Ordre avec
glisser et tirage au sort, Récap), enregistrés d'un bloc. Deux choix hors maquette :
- l'écran Ordre liste les 20 tours avec défilement ; la ligne « … et les tours 11 à 20 » de la
  maquette n'était qu'un raccourci d'affichage ;
- les demi-places sont associées dans l'ordre de saisie, et le tirage au sort les réassocie au
  hasard ; on ne choisit pas encore à la main qui partage le tour de qui.

**Avancement étape 1 :** presque terminée (6 novembre 2026). Sont faits et testés : le projet,
les polices embarquées, la charte, la base (schéma v1), les calculs de `lib/domain/` (vérifiés
avec les chiffres de la maquette), le compte local et son code de secours, l'écran « Mes
tontines » vide, et la configuration de signature. L'APK de debug compile. Restent : créer la
clé de signature, puis installer un premier APK de release sur le téléphone.

Ton frère ne doit pas dépendre de l'appli avant que la sauvegarde soit en place (étape 6).

## Distribution

- APK `arm64-v8a` signé : `flutter build apk --release --split-per-abi`, envoyé par WhatsApp, Drive
  ou câble. Android demande d'autoriser l'installation d'applis inconnues.
- Numéro de build (`+N` dans `pubspec.yaml`) augmenté à chaque version, jamais en arrière.
- Clé de signature (`.jks`) et son mot de passe hors du dépôt, avec au moins deux copies. Sans
  elle, impossible de mettre à jour l'appli sans la désinstaller.
- Faire une sauvegarde avant chaque mise à jour.

## Après la V1

- Rappels de retard par SMS ou WhatsApp (message pré-rempli), si ton frère le souhaite.
- Un même membre réutilisé d'une tontine à l'autre.
- Synchro ou multi-appareils, seulement si le besoin se confirme.

Tout ce qui n'est pas dans ce plan attend la fin du pilote.
