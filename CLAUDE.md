# Ma Tontine

Appli Android hors ligne de suivi de tontine. Le plan, les règles de calcul et la charte sont dans
[docs/plan.md](docs/plan.md) : le lire avant toute tâche.

## Maquette : à respecter à la lettre

La maquette validée est la référence de chaque écran :
https://claude.ai/artifact/Ke5yYbUMEtzGqQ5SgH9htd (8 écrans), complétée par la maquette des
jours sautés : https://claude.ai/artifact/2ReCrN8RcBdE9jgmAcUrZx (6 écrans).

- Avant de coder ou de modifier un écran de la maquette, **relire son fichier** (lecture de
  l'artefact, fichier `project/<Écran>.dc.html`) et reproduire **exactement** : textes,
  ponctuation, ordre des éléments, couleurs, polices, tailles, espacements, rayons.
- Couleurs et styles : uniquement ceux de `lib/common/theme.dart` (`AppColors`, `AppText`),
  relevés dans la maquette. Pas de couleur Material par défaut, pas de valeur approchée.
- Un écran absent de la maquette reprend la même charte (en-têtes, cartes, champs, boutons).
- Chaque écran de la maquette a un test de widget qui vérifie ses textes avec les données de
  l'exemple (`test/domain/maquette_example.dart`).
- Un écart à la maquette n'est permis que sur demande explicite ; le noter dans le plan.

## Interactions : skill `apple-design`

Le skill `apple-design` (global, `~/.claude/skills/apple-design`) guide le **comportement** de
l'interface ; la maquette reste la référence de l'**apparence** (en cas de conflit, la maquette
gagne : pas d'espacement de lettres, de flou ou de transparence qu'elle n'a pas). Ses exemples
sont pour le web ; en Flutter :

- Retour au toucher immédiat (au `onTapDown`, pas au relâché) ; pas de délai artificiel.
- Glisser 1:1 sous le doigt (réordonner les tours, feuilles du bas) ; feuilles fermables en les
  tirant vers le bas, en gardant la vitesse du geste.
- Animations en ressort et interruptibles (`SpringSimulation`, amortissement 1.0 par défaut) ;
  un élément sort par où il est entré.
- Retour haptique seulement sur les moments qui comptent : versement enregistré (appui long),
  cagnotte remise, élément déposé après un glisser, erreur.
- Respecter `MediaQuery.disableAnimations` (réduire les animations) : fondu court au lieu d'un
  mouvement.

## Code

- Code en anglais, textes affichés en français.
- Calculs dans `lib/domain/` uniquement (purs, sans Flutter ni base), couverts par des tests.
  Les écrans ne recalculent rien.
- Historique en ajout seul : un versement ou une remise s'annule par une contre-écriture,
  jamais par modification ou suppression.
- Code repris d'IP Caisse (`../ipc-project`) : copié et traduit, logique inchangée. Le signaler
  en tête de fichier (« Ported from IP Caisse »).
- Schéma de base modifié : augmenter `schemaVersion`, lancer
  `dart run drift_dev make-migrations`, écrire l'étape et son test.

## Vérifier

```bash
dart run build_runner build --delete-conflicting-outputs   # si tables modifiées
dart format .
flutter analyze
flutter test
```
