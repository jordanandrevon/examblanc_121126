-- BC01 Partie 2 : copie des trois tables de cyclenova_source vers cyclenova_travail

CREATE OR REPLACE TABLE `cyclenova-andrevon.cyclenova_travail.produits` AS
SELECT * FROM `cyclenova-andrevon.cyclenova_source.produits`;

CREATE OR REPLACE TABLE `cyclenova-andrevon.cyclenova_travail.ventes` AS
SELECT * FROM `cyclenova-andrevon.cyclenova_source.ventes`;

CREATE OR REPLACE TABLE `cyclenova-andrevon.cyclenova_travail.prix_concurrents` AS
SELECT * FROM `cyclenova-andrevon.cyclenova_source.prix_concurrents`;

-- BC01 Partie 2 : contrôle des effectifs, source et copie côte à côte

SELECT
  'produits' AS table_name,
  (SELECT COUNT(*) FROM `cyclenova-andrevon.cyclenova_source.produits`) AS n_source,
  (SELECT COUNT(*) FROM `cyclenova-andrevon.cyclenova_travail.produits`) AS n_travail,
  (SELECT COUNT(*) FROM `cyclenova-andrevon.cyclenova_source.produits`)
    = (SELECT COUNT(*) FROM `cyclenova-andrevon.cyclenova_travail.produits`) AS identique

UNION ALL

SELECT
  'ventes',
  (SELECT COUNT(*) FROM `cyclenova-andrevon.cyclenova_source.ventes`),
  (SELECT COUNT(*) FROM `cyclenova-andrevon.cyclenova_travail.ventes`),
  (SELECT COUNT(*) FROM `cyclenova-andrevon.cyclenova_source.ventes`)
    = (SELECT COUNT(*) FROM `cyclenova-andrevon.cyclenova_travail.ventes`)

UNION ALL

SELECT
  'prix_concurrents',
  (SELECT COUNT(*) FROM `cyclenova-andrevon.cyclenova_source.prix_concurrents`),
  (SELECT COUNT(*) FROM `cyclenova-andrevon.cyclenova_travail.prix_concurrents`),
  (SELECT COUNT(*) FROM `cyclenova-andrevon.cyclenova_source.prix_concurrents`)
    = (SELECT COUNT(*) FROM `cyclenova-andrevon.cyclenova_travail.prix_concurrents`);