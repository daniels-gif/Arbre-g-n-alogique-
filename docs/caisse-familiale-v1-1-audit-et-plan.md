# Caisse familiale — préparation v1.1 (sans modification de base de données)

Famille SOP Wandji & Kouamo Jacqueline  
Statut : **audit / conception uniquement — aucune mise en production autorisée**  
Date : 2026-11-14

## État actuel vérifié
- Source GitHub : `daniels-gif/Arbre-g-n-alogique-`, version de travail `test-pwa-installable-2026-11-14`.
- Portail existant : une interface HTML et JavaScript avec navigation familiale, vérification des accès par code et données familiales via des RPC.
- La rubrique `sopCaisse` est **une maquette statique** : « À configurer » pour les montants et boutons désactivés, sans gestion financière effective.
- Le calendrier `sopEvents` est déjà intégré au Salon familial. Conserver les six rubriques principales : Accueil, Arbre, Actus, Caisse, Souvenirs, Salon.
- L'enregistrement financier, les responsables habilités et les validations de la Caisse ne sont **pas** actuellement en place.
- Ne pas recopier les mots de passe, codes personnels ou justificatifs dans un fichier HTML statique ni dans des données de démonstration.

## Précautions avant développement
1. Conserver `main` et les données de production inchangées.
2. Utiliser uniquement `test-caisse-familiale-v11-2026-11-14` pour les prototypes et revues de code.
3. Soumettre un schéma de données et les politiques d'accès à autorisation **distincte** avant création/migration en base.
4. Tester sur des données de démonstration isolées, jamais avec de vrais versements ou justificatifs.
5. Exiger une autre autorisation avant publication officielle.

## Plan fonctionnel à proposer

### Accès et confidentialité
- Tout membre authentifié : lecture des caisses et objectifs, bilans collectifs, entrées/sorties **confirmées**, soldes, campagnes familiales ; gestion de ses propres déclarations et consultation privée de ses prêts, remboursements, échéances, rappels et relevés.
- Responsables habilités : gestion des caisses et objectifs, cotisations annuelles ou mensuelles, campagnes, vérification, sorties, prêts et rapprochements.
- Lecture collective des montants par membre **uniquement si les règles de la caisse le permettent**.
- Justificatifs, coordonnées financières, pièces et dossiers individuels restent inaccessibles aux autres membres.
- Enforcer les règles **au serveur et en base**, pas uniquement en cachant les boutons.

### Modèle de données à valider
- `caisses` : objectifs, règles de visibilité, responsables, statut et devise.
- `cotisations` et `campagnes_evenements` : montants attendus, échéances, visibilité et participants.
- `declarations` : membre, caisse, type, montant, devise, référence externe, état, justificatif protégé.
- `validations` : acteur, décision, horodatage, montant, motif éventuel, référence/justificatif.
- `ecritures_confirmees` : journal append-only, correction par écriture compensatrice.
- `prets` : capital, remise effective, 0 % d'intérêt, fréquence, premier paiement, nombre et minimum d'échéances, statut.
- `echeances_pret` et `remboursements` : calendrier, déclarations, confirmations, capital restant, retards, rééchelonnements approuvés.
- `rappels` : échéance, report, cible autorisée, état d'envoi.
- `rapprochements` : solde du portail versus fonds détenus à l'extérieur, responsable, date, écart et justification.
- `journal_audit` : événements de validation et corrections horodatées, non destructifs.

### Workflow obligatoire
- `déclaré` → `en_vérification` → `confirmé` ou `rejeté`.
- Deux validations **distinctes**, côté serveur, pour chaque prêt et chaque sortie.
- Une remise de fonds de prêt est une opération séparée dont la confirmation déclenche le calendrier de remboursement à partir de la date effective convenue.
- Les autres opérations ont une confirmation par responsable habilité.
- Une confirmation ne peut pas être effacée silencieusement ; les corrections sont tracées.
- Pas d'opération financière réelle, de collecte ni de versement dans le site.

### Échéances des prêts
- Aucun intérêt, aucun frais automatique et aucune pénalité de remboursement anticipé.
- Bimensuel : **deux dates contractuelles par mois** (non assimilé à toutes les deux semaines).
- Trimestriel : tous les trois mois à partir de la date contractuelle.
- Quadrimestriel : tous les quatre mois à partir de la date contractuelle.
- Calculer les échéances en respectant le montant minimal convenu et l'arrondi monétaire ; ajuster le dernier paiement au capital restant dû.
- Prévoir les mois sans jour équivalent, les dates contractuelles particulières et les rééchelonnements approuvés.
- Ne déduire du capital que les remboursements **confirmés**, pas les déclarations en attente.

### Interfaces
- Vue collective : caisses, objectifs, soldes et opérations confirmées, campagnes et bilans.
- Tableau « Mon espace » : mes cotisations, mes événements, déclarations, prêts, échéances, rappels, historique et relevés.
- Panneau « Gestion » visible seulement aux responsables habilités.
- Formulaires masqués par défaut, ouverts sur action explicite.
- Rapports personnels PDF ; rapports autorisés PDF et Excel.
- Statuts d'attente et de rejet lisibles ; aucun montant fictif affiché comme réel.

### Rappels
- Cotisations, campagnes, échéances de prêts et opérations en attente de validation.
- Respecter les dates contractuelles et reports approuvés ; ne pas envoyer de détail privé à un autre membre.

## Recette impérative avant autorisation de publication
1. Une personne non authentifiée ne voit aucune donnée financière privée.
2. Un membre A ne peut pas consulter les dossiers, justificatifs et prêts du membre B, même en appelant l'API directement.
3. Un membre ne peut confirmer sa propre opération sans habilitation appropriée.
4. Les sorties et prêts exigent deux approbations d'identités différentes.
5. Une opération rejetée ou seulement déclarée ne modifie jamais le solde confirmé.
6. Tests bimensuel / trimestriel / quadrimestriel, remboursements anticipés et rééchelonnements sans intérêt.
7. Correction d'une écriture : trace, auteur, date, référence ; aucune suppression silencieuse.
8. Test d'export de relevé strictement limité au membre authentifié.
9. Vérification des droits de gestion et de rapprochement.
10. Non-régression des six rubriques et du Salon / Agenda.
11. Vérification de la déconnexion après 30 minutes d'inactivité.
12. Autorisation de modification de base puis autorisation **séparée** pour la production.

## Décisions restant à approuver
- Personnes responsables et remplaçants ; règles de visibilité des contributions par membre.
- Devise(s), règles de cotisation et plafonds de prêts.
- Jours bimensuels par contrat, règles de dates de fin de mois, règles d'arrondi et de report.
- Canal des rappels, consentement et paramètres de confidentialité.
- Stockage sécurisé des justificatifs ; rétention et sauvegardes de la base.
