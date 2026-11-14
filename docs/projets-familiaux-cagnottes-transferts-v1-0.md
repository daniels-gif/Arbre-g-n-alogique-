# Cahier des charges — Projets familiaux, cagnottes et transferts

**Famille SOP Wandji & Kouamo Jacqueline**  
**Version 1.0 — extension du portail familial**  
**Statut : conception / prototype uniquement. Aucune modification de base de données ni publication de production autorisées.**  
Date de préparation : 14 novembre 2026.

## 1. Objectif et invariants

- Ajouter la rubrique principale **Projets familiaux**, reliée à **Caisse familiale**, sans supprimer ni modifier les fonctions des rubriques existantes.
- Proposer, approuver, financer, suivre et clôturer des projets collectifs ; gérer cagnottes, promesses, cotisations, contributions aux événements, prêts à **0 %**, remboursements, aides, dépenses, transferts déclarés, validations, rappels et rapports.
- **Aucun argent ne transite par le portail.** Tous les transferts ont lieu hors du site vers un destinataire habilité.
- Les montants promis ou simplement déclarés ne modifient jamais les soldes confirmés.
- Séparer totalement les données personnelles (prêts, justificatifs, références privées) des chiffres collectifs autorisés.
- Préparer une éventuelle intégration de prestataire de paiement dans une **phase ultérieure distincte**, sur nouvelle autorisation.

## 2. Résultat de l'audit du portail

- Source existante : `daniels-gif/Arbre-g-n-alogique-`, projet Vercel `arbre-genealogique-batcha`.
- **Production (`main`) : six rubriques** — Accueil, Arbre, Actualités, Agenda, Souvenirs, Salon.
- **Branche de préparation de la Caisse v1.1 : six rubriques principales** — Accueil, Arbre, Actualités, Caisse, Souvenirs, Salon. Agenda a été déplacé dans le Salon familial.
- **Aucune rubrique Projets familiaux existante** dans cette branche.
- **Point à valider** : la demande parle de « huitième onglet », mais avec les **six rubriques principales actuelles**, l'ajout de Projets ferait **sept onglets**. Ne pas inventer/supprimer un huitième onglet ; garder intactes les six rubriques et soumettre le comptage à validation lors de la maquette.
- La Caisse familiale actuelle reste une **maquette statique**, sans registre financier, véritable contrôle de rôles ou workflow de validation.
- Projet séparé de préparation : `test-projets-familiaux-v1-2026-11-14`, issu de `test-caisse-familiale-v11-2026-11-14`.

## 3. Rubrique Projets familiaux — proposition d'interface

Sous-rubriques demandées :
1. Tous les projets.
2. Proposer un projet.
3. Cagnottes.
4. Mes contributions.
5. Suivi des réalisations.
6. Projets terminés.
7. Rapports.

**Principes d'ergonomie :** cartes sobres, densité raisonnable, filtres simples et formulaires entièrement masqués jusqu'au clic sur « Proposer » ou « Contribuer ». Aucun montant de démonstration présenté comme une donnée réelle. Les écrans personnels et collectifs restent visuellement séparés.

Un projet doit contenir : titre, description/objectifs, catégorie, responsable proposé, budget prévisionnel, objectif de cagnotte, dates de début/cible, documents/devis/photos, bénéficiaires éventuels et modalités de contribution.

**États :** Brouillon → Soumis → En examen → Approuvé → En cours → Terminé ; Suspendu / Refusé / Annulé avec justification. Les transitions exigent les permissions appropriées et une trace d'audit.

## 4. Cagnottes et montants

Une cagnotte ponctuelle ou permanente peut être ouverte **uniquement après autorisation selon la gouvernance familiale** et rattachement à un projet approuvé, sauf règle familiale spécifique validée ultérieurement.

Afficher : objectif, contributions confirmées, reste à collecter, dépenses confirmées, solde disponible, nombre de contributeurs, date cible, progression.

Distinguer explicitement :
- **Promesse** : engagement du membre, sans versement confirmé.
- **Déclaration** : membre indique avoir payé à l'extérieur du site, en attente de vérification.
- **Confirmation** : fonds réellement vérifiés/reçus et écriture comptabilisée.
- **Rejet / informations requises / anomalie** : pas d'impact sur le solde.

## 5. Coordonnées de transfert et parcours manuel

Les destinataires de chaque caisse ou cagnotte sont configurés par administrateurs habilités : identité, moyen accepté, identifiant/numéro, devise, instructions et intervalle de validité. Leur publication ou changement requiert vérification et approbation ; **aucune modification par un membre ordinaire**.

Pour contribuer :
1. Ouvrir caisse/cagnotte et cliquer sur « Contribuer ».
2. Saisir le montant, consulter les coordonnées approuvées.
3. Faire le transfert **hors du portail**, puis revenir.
4. Déclarer montant/date/référence et, facultativement, justificatif privé.
5. Afficher « En attente de confirmation ».
6. Le responsable de réception vérifie **les fonds reçus**, pas seulement une capture d'écran.
7. Le validateur autorisé confirme, rejette avec motif, demande un complément ou signale un doublon.

Un transfert ne doit jamais compter deux fois. Chaque opération reçoit un **identifiant unique**, une référence de transfert normalisée/contrôlée, un lien à sa caisse/projet/prêt et une piste d'audit des changements.

Types à distinguer : contribution cagnotte, cotisation caisse, contribution événement, remboursement prêt, remise prêt, aide, dépense projet, transfert inter-caisses. Les transferts entre caisses doivent produire des écritures reliées équilibrées, sans créer de fonds artificiels.

## 6. Prêts et remboursements

Règles du cahier Caisse v1.1 à conserver :
- **0 % d'intérêt**, aucun frais ou pénalité automatique.
- **Bimensuel** = deux échéances par mois selon les deux jours prévus au contrat ; **trimestriel** = tous les 3 mois ; **quadrimestriel** = tous les 4 mois.
- Montant du capital, premier paiement, minimum convenu, nombre d'échéances, calendrier, restants dus et rééchelonnements approuvés ; remboursements anticipés possibles.
- Les conditions du contrat sont approuvées **avant la remise**.
- La date de remise effective des fonds sert au calcul contractuel.
- Remises, prêts et sorties sensibles : **double validation par deux personnes habilitées distinctes**.
- Un remboursement déclaré ne diminue **jamais** le capital restant dû tant que sa réception n'est pas confirmée.

Parcours remboursement : Mes prêts → Rembourser → coordonnées approuvées → transfert extérieur → déclaration/référence → vérification → confirmation → mise à jour du capital et historique.

La remise d'un prêt ou d'une aide est enregistrée par le gestionnaire (bénéficiaire, montant, date, moyen, référence, justificatif facultatif), peut faire l'objet d'un accusé de réception et est confirmée selon les droits.

## 7. Profils et contrôles d'accès

- **Membre** : lecture collective autorisée, projets, déclarations, demandes, prêts et documents propres.
- **Gestionnaire** : préparation, vérification et rapprochement externe.
- **Validateur** : décisions et confirmations selon permissions.
- **Administrateur** : paramétrage des caisses, projets, destinataires et habilitations.
- Les appels directs aux API doivent appliquer ces permissions **côté serveur**, non uniquement dans l'interface.
- Un lien privé de validation doit mener à l'authentification et revérifier les habilitations ; il **n'autorise jamais à confirmer seul**.
- Les justificatifs et coordonnées sensibles doivent être protégés (pas dans HTML ou URLs publiques), avec accès limité et journalisé.
- Transactions confirmées immuables ; corrections par écritures compensatrices traçables et journaux append-only.

## 8. Tableau personnel, réunions, rappels et documents

**Mon espace** : mes caisses, cotisations dues/confirmées/en attente ; projets suivis, promesses, cagnottes, prêts, échéances, remboursements, rappels et documents imprimables.

**Réunions annuelles** : ordre du jour, propositions, votes, décisions de financement, bilans, prêts, procès-verbaux et résolutions ; lier les décisions financières à leur délibération et à la validation autorisée.

**Rappels** : échéances de cotisation/contribution/prêt, déclarations, décisions, changements de destinataire ; tenir compte des reports approuvés, du statut confirmé et de la confidentialité des messages.

**Exports PDF / Excel autorisés** : relevés individuels, reçus de contribution confirmée, cagnottes, journal des mouvements, prêts et échéanciers, bilans mensuels/annuels, clôture de projet, validations. Afficher dates, montants, références, états, responsables concernés. Un reçu n'atteste que l'**enregistrement et la confirmation interne**, pas un encaissement par le portail.

## 9. Architecture fonctionnelle proposée (à approuver, non créée)

Séparation logique recommandée :
- profils familiaux & rôles ;
- projets, bénéficiaires et documents ;
- cagnottes, caisses, objectifs et campagnes ;
- promesses, déclarations de transfert, destinations de réception ;
- vérifications, approbations et registre financier confirmé ;
- prêts, remises effectives, échéanciers et remboursements ;
- aides, dépenses et transferts entre caisses ;
- notifications, justificatifs protégés, audits ;
- décisions de réunion et rapports.

Les opérations, confirmations et écritures doivent partager des identifiants stables, des règles d'idempotence, un contrôle transactionnel des doublons et des soldes cohérents. Revoir la configuration réelle de Supabase et l'autorisation en base avant toute migration.

## 10. Phases autorisées

1. **Maquettes uniquement** : écrans et parcours avec données explicitement fictives.
2. Projets, propositions, approbations, suivi et cagnottes, après validation de sécurité et du schéma.
3. Transferts manuels : déclaration, vérification, confirmation et rapprochement.
4. Prêts, remboursements, contrats, échéanciers et rappels.
5. Rapports, tableaux personnels et exports.
6. **Paiements intégrés** : exclusivement après prestataire, conformité, tests et nouvelle autorisation explicite.

## 11. Critères de recette

Vérifier avec différents profils de démonstration : proposer/consulter un projet, cagnotte et promesse, déclarer un transfert, suivre son statut, recevoir confirmation après vérification, consulter son suivi privé, demander un prêt, consulter les échéances, déclarer/faire confirmer un remboursement, télécharger un relevé.

Vérifier aussi :
- refus de lecture de justificatifs/identifiants/prêts d'autrui, y compris via API directe ;
- double approbation par **deux identités différentes**, et non deux clics d'un même compte ;
- référence de transfert dupliquée et appels répétés sans double comptabilisation ;
- promesse et déclaration sans impact sur solde confirmé ;
- rejet et correction horodatés, aucun effacement silencieux ;
- actualisation des remboursements seulement à confirmation ;
- contrats à 0 %, trois fréquences, dates limites, reports, remboursement anticipé ;
- rattachement des décisions aux procès-verbaux ;
- exports PDF/Excel filtrés par permissions ;
- aucune détention, transfert ni paiement par le portail ;
- non-régression des six rubriques et de la session de 30 minutes.

## 12. Verrous d'autorisation

**Ne pas** :
- modifier `main` ni Vercel production ;
- migrer ou modifier une table ou un stockage de production ;
- activer des flux de paiement, des coordonnées de réception, des notifications financières ou des transferts ;
- traiter des données financières réelles pour le prototype.

Exiger successivement :
1. validation de la maquette et des règles (dont nombre exact d'onglets et destinataires) ;
2. autorisation spécifique de modification de la base et du modèle d'accès ;
3. recette sécurité et double validation ;
4. autorisation **distincte** avant publication en production ;
5. autorisation supplémentaire avant toute connexion d'un prestataire de paiement.
