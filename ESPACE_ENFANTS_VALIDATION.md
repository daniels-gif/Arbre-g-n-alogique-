# Profil enfant — version test des jeux, éligibilité 18 ans et moins

## Modifications confirmées

- Les phrases « accessibles sans compte enfant » et « Tes activités ne demandent ni achat, ni photo, ni messagerie » ont été retirées de l'entête.
- L’accès aux activités nécessite de créer un **profil de joueur temporaire** avec prénom ou pseudonyme et date de naissance.
- Vérification locale de l’éligibilité : **18 ans ou moins**. Les âges 19 ans et plus sont refusés.
- Pour les moins de 18 ans, le formulaire exige une confirmation parentale.
- La date de naissance est utilisée uniquement pour calculer l'âge, puis effacée du formulaire et **non enregistrée**.
- Seul le pseudonyme est conservé temporairement dans l’onglet via sessionStorage, avec une durée de vie de 6 heures.
- Les jeux locaux existants restent disponibles après création du profil : calcul mental, mémoire, parenté, images, logique, dessin et cartes.
- Le menu de changement de joueur efface le profil temporaire et renouvelle la page.
- Aucune base Supabase modifiée, aucune session enfant reliée à l'arbre et aucun accès adulte accordé par ce profil.

## Avertissements avant une version définitive

- La vérification d’âge est **côté navigateur uniquement** et ne représente pas une vérification d'identité inviolable.
- Aucune reconnaissance du lien de parenté avec les fiches de l'arbre.
- Pas de scores persistants partagés, classements inter-appareils, médias d'enfants, publications ni messagerie.
- Pour rendre l'éligibilité fiable côté serveur, il faudra une base et un contrôle d'accès adapté, avec sauvegardes et tests.
- Cette version ne touche pas à la production. Vérifier les jeux sur un téléphone réel avant publication.

## Contrôle de code

Syntaxe JavaScript vérifiée dans index.html, enfants.html et kids-extras.js.
