# Espace Enfants — Phase 1 : état de validation

Date : 14 novembre 2026
Branche : `test-espace-enfants-phase1-2026-11-14`
Base : branche principale `main`.

## Implémenté (branche de test uniquement)

- Accès libre à la page de découverte Espace Enfants depuis l'accueil familial : la visite ne révèle pas de données personnelles d'enfant.
- Sélection d'un profil enfant pour jouer uniquement depuis une session familiale vérifiée.
- Préparation des API `batcha_kids_profiles`, `batcha_kids_session_start`, `batcha_kids_session_check`, `batcha_kids_session_end` : session de membre familial vérifiée côté serveur et jeton enfant temporaire.
- Éligibilité validée par requête non destructive : 11 profils enregistrés, incluant les 3 derniers enfants de SOP Wandji Verkys (rangs 4 à 6 de la troisième génération). Les autres profils éligibles appartiennent à la quatrième génération ; l'année de naissance inconnue n'est pas inventée.
- Passage à une page dédiée `enfants.html` sans conserver les scripts et écrans du portail adulte.
- Accueil personnalisé uniquement avec le prénom de l'enfant, conservé temporairement dans `sessionStorage`.
- Calcul mental : 4 niveaux, 8 questions, correction et score local.
- Memory : 4 paires à retrouver, score de progression local.
- Reconnaissance d’images : fruits et animaux en emoji, quiz local.
- Enigmes de logique : suites et questions courtes.
- Atelier créatif : dessin sur canvas, export local PNG, sans serveur.
- Cartes de fête : message prédéfini, prénom facultatif, export local en image.
- Quiz des liens de parenté : 6 questions, correction et score local.
- Modules non sécurisés ou non développés (actualités enfant, vidéos, messages, langues maternelles, club des cousins, partie en direct) désactivés et signalés « Bientôt disponible ».
- Aucune publication, aucun paiement, aucune messagerie et aucun score personnel transmis depuis la page enfant.
- Contrôle syntaxique JavaScript effectué.

## Bloqueurs avant ouverture aux familles

1. **Sauvegarde vérifiée :** une sauvegarde indépendante et restaurable de la base familiale n'a pas encore été confirmée.
2. **RPC de sélection et de session enfant :** la migration SQL préparée dans `supabase/migrations/20261114_kids_parent_selection_draft.sql` n'a PAS été appliquée à Supabase ; vérifier sauvegarde et autorisations avant activation. En l'absence d'activation, seuls l'accueil de découverte et les descriptions des jeux sont accessibles, sans ouverture d'un profil enfant.
3. **Droits des enfants :** la sélection des profils à des fins de jeux purement locaux est ouverte aux membres familiaux connectés. Cela ne constitue pas une autorisation de consulter ou de publier des informations privées au nom des enfants. Les publications, photos, messages et scores partagés exigent un contrôle parental et une modération côté serveur.
4. **Âges :** les enfants de quatrième génération n'ont pas tous une année de naissance enregistrée. Ne pas deviner l'âge ; adapter le niveau avec le parent tant que les données ne sont pas complétées.
5. **Contrôles réels :** tests parent valide, personne non autorisée, session expirée, retour adulte, Android, iPhone, tablette, clavier et lecteurs d'écran à effectuer.
6. **Hébergement :** aperçu Vercel READY observé ; l'accès effectif au fichier `enfants.html` n'a pas pu être testé depuis un navigateur non authentifié.
7. **Production :** aucun déploiement de production et aucune fusion dans `main` ; publication soumise à validation explicite.

## Guide de tests

- Connecter un profil adulte habilité, ouvrir le sélecteur et constater la liste de ses seuls enfants.
- Vérifier qu'un autre parent ne voit pas les mêmes profils.
- Sélectionner un enfant : ouverture de la page enfant, disparition de la session adulte.
- Tenter d'ouvrir la Caisse, les Projets ou les messages depuis la page enfant : aucun accès.
- Quitter l'univers enfant : retour à l'accueil et nouvelle vérification nécessaire pour l'espace adulte.
- Vérifier 8 calculs sur chaque niveau, les 4 paires du memory, les 6 liens de parenté.
- Tester liens directs sans sélection de profil et après expiration du contexte temporaire.
- Comparer l'arbre, la Caisse, les Projets, les Souvenirs et le Salon à la version principale.

Ce document est un contrôle de livraison de la phase 1, pas une validation de sécurité complète ni une preuve de sauvegarde/restauration.

## Étape suivante après les tests

La version contient des jeux **locaux** utilisables sans accès aux données confidentielles. Les fonctions communautaires pour enfants (actualités, messages, jeux asynchrones partagés, clubs, vidéothèque familiale) nécessitent un modèle d’autorisations parentales, une modération, un mécanisme de sauvegarde vérifié et des tests réels avant activation. Ne pas appeler cet état « point 13 intégralement terminé ».

## Correction demandée : accès à l'univers sans distinction générationnelle

Le bouton « Entrer dans l’Espace Enfants » est proposé à tous sur l'accueil de la branche test. Le sélecteur de jeu personnalisé est proposé aux membres connectés. Les trois derniers enfants de SOP Wandji Verkys figurent explicitement parmi les profils éligibles, malgré leur appartenance à la génération 3. La règle du seul rattachement direct au parent connecté est retirée pour les jeux locaux. Vérification du comportement réel requise après activation serveur.
