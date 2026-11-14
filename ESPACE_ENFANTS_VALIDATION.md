# Espace Enfants — Phase 1 : état de validation

Date : 14 novembre 2026
Branche : `test-espace-enfants-phase1-2026-11-14`
Base : branche principale `main`.

## Implémenté (branche de test uniquement)

- Accès au sélecteur depuis l'accueil d'un adulte déjà connecté.
- Préparation de l'API `batcha_parent_children` : session adulte vérifiée côté serveur et enfants directs de génération 4. L'année de naissance inconnue n'est pas inventée.
- Passage à une page dédiée `enfants.html` sans conserver les scripts et écrans du portail adulte.
- Accueil personnalisé uniquement avec le prénom de l'enfant, conservé temporairement dans `sessionStorage`.
- Calcul mental : 4 niveaux, 8 questions, correction et score local.
- Memory : 4 paires à retrouver, score de progression local.
- Quiz des liens de parenté : 6 questions, correction et score local.
- Modules non sécurisés ou non développés (actualités enfant, vidéos, messages, langues maternelles) désactivés et signalés « Bientôt disponible ».
- Aucune publication, aucun paiement, aucune messagerie et aucun score personnel transmis depuis la page enfant.
- Contrôle syntaxique JavaScript effectué.

## Bloqueurs avant ouverture aux familles

1. **Sauvegarde vérifiée :** une sauvegarde indépendante et restaurable de la base familiale n'a pas encore été confirmée.
2. **RPC parent-enfant :** la migration SQL préparée dans `supabase/migrations/20261114_kids_parent_selection_draft.sql` n'a PAS été appliquée à Supabase ; vérifier sauvegarde et autorisations avant activation.
3. **Parenté et autorité parentale :** `parent_id` permet d'établir une relation généalogique directe, mais ne suffit pas pour certifier tous les droits parentaux ; définir les modalités d'approbation avant tout partage de contenu.
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
