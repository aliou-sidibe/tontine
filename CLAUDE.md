# Ma Tontine

Appli Android hors ligne de suivi de tontine. Le plan, les règles de calcul et la charte sont dans
[docs/plan.md](docs/plan.md) : le lire avant toute tâche.

## Maquette : à respecter à la lettre

La maquette validée est la référence de chaque écran :
https://claude.ai/artifact/Ke5yYbUMEtzGqQ5SgH9htd (8 écrans).

- Avant de coder ou de modifier un écran de la maquette, **relire son fichier** (lecture de
  l'artefact, fichier `project/<Écran>.dc.html`) et reproduire **exactement** : textes,
  ponctuation, ordre des éléments, couleurs, polices, tailles, espacements, rayons.
- Couleurs et styles : uniquement ceux de `lib/common/theme.dart` (`AppColors`, `AppText`),
  relevés dans la maquette. Pas de couleur Material par défaut, pas de valeur approchée.
- Un écran absent de la maquette reprend la même charte (en-têtes, cartes, champs, boutons).
- Chaque écran de la maquette a un test de widget qui vérifie ses textes avec les données de
  l'exemple (`test/domain/maquette_example.dart`).
- Un écart à la maquette n'est permis que sur demande explicite ; le noter dans le plan.

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
