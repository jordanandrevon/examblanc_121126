# CycleNova — Épreuve blanche Data Analyst

Analyse des ventes, des retours et de la compétitivité prix de **CycleNova**, e-commerce fictif d'équipements de cyclisme. Le projet couvre les blocs BC01, BC02, BC03, BC04 et BC06 du référentiel RNCP38616 : SQL, statistiques, machine learning, gestion de projet IA et Business Intelligence.

**Auteur** : Jordan Andrevon — formation Data Analyst · Novembre 2026
**Données** : jeux synthétiques fournis par le formateur, sans aucune donnée personnelle réelle.

---

## Livrables

| Bloc | Partie | Livrable | Emplacement |
|---|---|---|---|
| BC01 | P1 — Présentation au responsable des opérations | Slides (8) | `PRESENTATIONS/BC01_P1_Presentation_CycleNova_Andrevon.pdf` |
| BC01 | P2 — Copie contrôlée des tables dans BigQuery | Script SQL + capture | `SQL/BC01_Partie2_CycleNova.sql`, `SQL/BC01_Partie2_controle_effectifs.png` |
| BC01 | P3 — Qualité des données et agrégations SQL | Notebook exécuté | `NOTEBOOKS/BC01_challenge_SQL.ipynb` |
| BC02 | P2 — EDA et test statistique | Notebook exécuté | `NOTEBOOKS/BC02_EDA_Statistiques.ipynb` |
| BC03 | P2 — Modèles et hyperparamètres | Notebook exécuté | `NOTEBOOKS/BC03_Machine_Learning.ipynb` |
| BC04 | P4 — Présentation au CTO | Slides (9) | `PRESENTATIONS/BC04_P4_Presentation_CTO_CycleNova_Andrevon.pdf` |
| BC04 | P5 — Vidéo (4 min 40) | Vidéo | Dans le dossier directement |
| BC06 | Dashboard Looker Studio | PDF + rapport en ligne | `DASHBOARD/BC06_Andrevon_Jordan.pdf` · [https://datastudio.google.com/reporting/b48d85bc-e40f-4b27-81f2-df8a460de428 |
| — | Réponses rédigées et QCM | Document du sujet complété | `SUJET/SUJET_Epreuve_Blanche_CycleNova.odt` |

---

## Structure du dépôt

```
├── README.md
├── DONNEES/          produits.csv, ventes.csv, prix_concurrents.csv
├── NOTEBOOKS/        BC01, BC02, BC03 (exécutés)
├── SQL/              script BigQuery
├── PRESENTATIONS/    BC01_P1 et BC04_P4 (PDF et HTML)
├── DASHBOARD/        export PDF du dashboard BC06
└── SUJET/            document du sujet complété
```

---

## Données

| Table | Une ligne = | Clé attendue | Lignes |
|---|---|---|---|
| `produits` | un produit du catalogue | `id_produit` | 65 |
| `ventes` | une vente d'un produit | `id_vente` | 3 005 |
| `prix_concurrents` | un relevé (produit, concurrent, date) | `id_produit`, `concurrent`, `date_releve` | 2 818 |

Période couverte : janvier 2025 → octobre 2026. 2025 sert à l'entraînement du modèle, 2026 au test final.

---

## Règles de nettoyage

Les mêmes règles sont appliquées dans tous les blocs : SQLite, pandas et la vue BigQuery `v_ventes_valides`.

| Anomalie | Lignes | Règle |
|---|---|---|
| `id_vente` dupliqué | 5 | une seule ligne conservée |
| Produit dupliqué au catalogue (`P0010`) | 1 | catalogue dédoublonné avant jointure |
| `id_produit` manquant ou inconnu (`P9999`) | 19 | exclusion |
| Quantité ≤ 0 | 7 | exclusion |
| Prix manquant ou ≤ 0 | 16 | exclusion |
| Remise hors [0 ; 1] | 8 | exclusion |
| `retour` manquant ou égal à 2 | 9 | conservée pour le CA, exclue du taux de retour |
| `canal` manquant | 8 | conservée, regroupée en « Inconnu » |

**Résultat : 2 950 ventes valides** (3 005 − 5 doublons − 50 lignes invalides, soit 1,8 % exclues).
Pour éviter de multiplier les lignes, l'historique des prix concurrents est réduit au **relevé le plus récent par produit et concurrent** avant toute comparaison.

---

## Résultats clés

**Indicateurs (BC01, contrôlés dans BigQuery et dans le dashboard)**
- CA brut (après remise, hors remboursement) : **238 742 €**
- Ventes valides : **2 950**
- Taux de retour : **16,8 %**, calculé sur 2 941 lignes à étiquette connue
- Retours les plus élevés : Textile (25,5 %) et Chaussures (23,3 %) ; canaux Application (19,4 %) et Marketplace (18,3 %)
- CA janvier–octobre : 121 161 € en 2025 contre 95 295 € en 2026 (**−21 %**)
- Prix catalogue face au dernier relevé (1er octobre 2026) : +0,3 % par rapport au concurrent A, +2,3 % par rapport au concurrent B

**Promotions (BC02)**
- Montant net moyen par ligne : 71,6 € avec code promo contre 85,1 € sans code. Différence significative (t de Welch, p ≈ 7 × 10⁻⁸ ; confirmée par Mann-Whitney).
- Avant remise, les paniers sont équivalents (p ≈ 0,79) : l'écart s'explique par la remise elle-même. Les données sont observationnelles, donc aucune causalité n'est établie.

**Prédiction des retours (BC03)**
- Variables utilisées, toutes connues au moment de la commande : quantité, prix, remise, code promo, mois, canal, catégorie. `date_retour`, `motif_retour` et les relevés de prix postérieurs sont exclus pour éviter les fuites.
- Modèles comparés : Dummy, régression logistique, Random Forest (Pipeline + ColumnTransformer, validation croisée sur 2025).
- Modèle retenu : Random Forest, `min_samples_leaf = 20`, choisi par GridSearchCV sur la ROC-AUC.
- Test 2026, évalué une seule fois : **ROC-AUC 0,59**, rappel 52 %, précision 22 %. Le signal est faible : le modèle sert d'aide à la décision, pas de décision automatique.

**Recommandation (BC04)** : lancer un outil de prévention des retours, sous forme d'un score de risque et d'actions préventives douces sur le Textile et les Chaussures. Le projet dure 12 semaines, pour un budget estimé à environ 23 000 € (hypothèses détaillées dans la présentation), avec un pilote A/B avant toute généralisation.

---

## Reproduire l'analyse

**Notebooks (Python 3)**
```bash
pip install pandas numpy matplotlib scipy scikit-learn jupyter
jupyter notebook NOTEBOOKS/
```
Les notebooks cherchent automatiquement les données dans `../DONNEES` : il ne faut pas modifier la structure des dossiers. Sur Google Colab, importe l'archive dans `/content`, puis exécute la première cellule.

**BigQuery (BC01 P2 et source du dashboard)**
1. Importer les 3 CSV dans un dataset `cyclenova_source` (région EU).
2. Créer le dataset `cyclenova_travail` dans la même région.
3. Exécuter `SQL/BC01_Partie2_CycleNova.sql`, qui copie les tables et contrôle les effectifs.
4. Le dashboard s'appuie sur la vue `cyclenova_travail.v_ventes_valides`, qui reprend les règles de nettoyage décrites plus haut.

---

## Limites

- Données synthétiques avec des anomalies volontaires. Les totaux portent sur les seules ventes valides : le CA des lignes exclues n'est pas estimé.
- Prix concurrents relevés une fois par mois, pour deux concurrents seulement. La comparaison porte sur le prix catalogue, pas sur le prix payé.
- Aucun identifiant client : impossible de vérifier l'indépendance des observations ou d'utiliser l'historique des clients.
- Tous les écarts observés sont descriptifs ou corrélationnels, aucun lien de causalité n'est démontré.
