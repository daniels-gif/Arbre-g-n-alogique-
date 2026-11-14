# Profil de joueur — fiche familiale et âge 18 ans ou moins
Date : 2026-11-14. Branche : `test-espace-enfants-phase1-2026-11-14`.

## Règle demandée
- Accéder à l'espace éducatif sans recopier les noms de la famille.
- Un membre ayant déverrouillé sa fiche personnelle utilise son identité déjà validée.
- Le serveur récupère le prénom/nom, jour, mois et, si disponible, l'année de naissance de `batcha_people`.
- Si l'année est manquante, le joueur saisit **uniquement son année de naissance**.
- Admission uniquement à **18 ans ou moins**, âge calculé à la date de la partie.
- L'année déclarée n'est pas écrite dans la fiche ni enregistrée dans le navigateur. Son exactitude reste à confirmer par un responsable familial (pas de preuve automatique).
- Si le jour ou le mois manque, la participation reste bloquée jusqu'à correction autorisée de la fiche.
- Autorisation d'un parent ou tuteur demandée dans le formulaire pour les moins de 18 ans ; la confirmation est déclarative dans la version test.
- Pas d'enregistrement de scores partagés ni de publication enfant.

## Préparé
- `index.html` conserve brièvement l'identifiant et le jeton de la fiche réellement déverrouillée ; suppression à la déconnexion.
- `enfants.html` ne propose plus de nom libre ni de date complète.
- `kids-family-gate.js` lit la session et appelle `batcha_kids_game_eligibility`.
- La fonction SQL (lecture seule du côté de la fiche familiale) est proposée dans `supabase/migrations/20261114_kids_game_eligibility_draft.sql`.
- Aucun profil joueur supplémentaire n'est créé dans l'arbre.

## Activation et limites
La fonction SQL **a été activée** dans Supabase à la demande explicite de la famille. Vérifications effectuées : présence de la fonction, autorisations RPC, refus d'une session invalide et réponse d'une session familiale valide, sans exposer les informations personnelles dans le compte rendu. Aucun profil familial n'a été créé, édité ou supprimé. **La sauvegarde restaurable n'a toutefois pas été confirmée ; il reste une limite de protection du projet.** La validation de l'année déclarée et l'autorisation parentale ne sont pas prouvées par un simple formulaire.

## Contrôles
Syntaxe JS des fichiers `index.html`, `enfants.html`, `kids-family-gate.js` et `kids-extras.js` vérifiée.
Les tests de connexion réels, appareils mobiles et sauvegarde restaurable sont encore à effectuer.
Le site public n'a pas été modifié.
