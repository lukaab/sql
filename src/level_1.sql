-- 1. Nombre de dossiers incomplets
SELECT COUNT(*) AS nb_dossiers_incomplets
FROM dossiers_client
WHERE statut = 'incomplet';

-- 2. Stations desservies par chaque ligne
SELECT l.nom AS ligne, s.nom AS stations
FROM arrets a
JOIN lignes l ON a.id_ligne = l.id
JOIN stations s ON a.id_station = s.id
ORDER BY l.nom, s.nom;

-- 3. Nombre de stations par moyen de transport
SELECT l.type AS moyen_transport, COUNT(DISTINCT a.id_station) AS nb_stations
FROM arrets a
JOIN lignes l ON a.id_ligne = l.id
GROUP BY l.type
ORDER BY nb_stations DESC;

-- 4. Abonnements expirant à la fin de janvier 2025
SELECT t.nom AS nom_tarification, COUNT(*) AS nb_abonnements
FROM abonnements a
JOIN tarifications t ON a.id_tarification = t.id
WHERE a.date_fin BETWEEN '2025-01-31 00:00:00' AND '2025-01-31 23:59:59'
GROUP BY t.nom
ORDER BY nb_abonnements ASC;

-- 5. Création de la vue des dossiers en validation
CREATE OR REPLACE VIEW dossiers_en_validation AS
SELECT *
FROM dossiers_client
WHERE statut = 'validation'
ORDER BY date_creation ASC;
