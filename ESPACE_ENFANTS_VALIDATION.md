# Profil enfant — Version simplifiée sans fonctionnalité de profil enfant

La demande familiale remplace le mécanisme de choix/connexion enfant :
le titre visible est **Profil enfant**, sans compte enfant séparé ni sélection dans l’arbre.

## Fonctionnement de cette version

- Tous les visiteurs du site peuvent ouvrir la rubrique **Profil enfant**.
- Jeux locaux accessibles sans connexion : calcul mental, mémoire, parenté, reconnaissance d’images, logique, dessin, cartes de fête.
- Aucun résultat nominatif, aucune photo et aucun message n’est envoyé au serveur depuis cette rubrique.
- Le sélecteur des générations 3–6, les jetons et les sessions enfants ont été retirés du frontend.
- Aucun schéma Supabase n’a besoin d’être activé pour ces jeux.
- Les modules de messages, actualités d’enfants, jeux à distance et publications sont toujours désactivés.
- Les profils, l’arbre, le Salon, la Caisse, les Projets et les autres sections adultes existantes demeurent présents dans le code.

## À ne pas activer

Le fichier SQL historique `supabase/migrations/20261114_kids_parent_selection_draft.sql` est **obsolète : NE PAS EXÉCUTER**. Il correspond à une conception abandonnée et n’est pas nécessaire à la rubrique simplifiée.

## Vérifications

- Contrôle de syntaxe JavaScript des trois fichiers : passé.
- Navigation réelle sur Android/iPhone et test complet des jeux : à effectuer dans l’aperçu.
- Production non modifiée : fusion ou publication conditionnée à la validation explicite.
