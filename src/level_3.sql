-- 1. Chiffre d'affaires des ventes de tickets par mois sur l'année 2024
SELECT TO_CHAR(date_achat, 'Month') AS mois, SUM(prix_unitaire_centimes) / 100 AS chiffre_affaires
FROM tickets
WHERE date_achat BETWEEN '2024-01-01' AND '2024-12-31'
GROUP BY mois, EXTRACT(MONTH FROM date_achat)
ORDER BY EXTRACT(MONTH FROM date_achat);

-- 2. Lignes de transport passant à Nation autour de 17h28 ± 4 minutes
SELECT l.nom AS ligne, h.horaire
FROM horaires h
JOIN arrets a ON h.id_arret = a.id
JOIN lignes l ON a.id_ligne = l.id
JOIN stations s ON a.id_station = s.id
WHERE s.nom = 'Nation'
AND h.horaire BETWEEN '17:24:00' AND '17:32:00'
ORDER BY h.horaire;

-- 3. Nombre moyen de validations par mois par type d'abonnement
SELECT t.nom AS abonnement, ROUND(AVG(nb_validations)) AS moy_validation
FROM (
    SELECT id_support, COUNT(*) AS nb_validations, DATE_TRUNC('month', date_heure_validation) AS mois
    FROM validations
    GROUP BY id_support, mois
) v
JOIN abonnements a ON v.id_support = a.id_support
JOIN tarifications t ON a.id_tarification = t.id
GROUP BY t.nom
ORDER BY moy_validation DESC, t.nom;

-- 4. Vue : moyenne des passages par jour de la semaine sur les 12 derniers mois
CREATE OR REPLACE VIEW moy_passagers_par_jour AS
SELECT TO_CHAR(date_heure_validation, 'Day') AS jour_semaine, ROUND(AVG(nb_passages)) AS moy_passagers
FROM (
    SELECT DATE_TRUNC('day', date_heure_validation) AS jour, COUNT(*) AS nb_passages
    FROM validations
    WHERE date_heure_validation >= CURRENT_DATE - INTERVAL '12 months'
    GROUP BY jour
) v
GROUP BY jour_semaine
ORDER BY jour_semaine;

-- 5. Vue : taux de remplissage moyen des lignes
CREATE OR REPLACE VIEW taux_remplissage_lignes AS
SELECT l.nom AS nom_ligne,
    ROUND(AVG(nb_passagers) / (nb_trains_par_jour * l.capacite_max) * 100, 2) AS taux_remplissage
FROM (
    SELECT id_ligne, COUNT(*) AS nb_passagers, DATE_TRUNC('day', date_heure_validation) AS jour
    FROM validations v
    JOIN arrets a ON v.id_station = a.id_station
    GROUP BY id_ligne, jour
) daily_passengers
JOIN lignes l ON daily_passengers.id_ligne = l.id
JOIN (
    SELECT id, 
        CASE WHEN type = 'metro' THEN 160 ELSE 64 END AS nb_trains_par_jour
    FROM lignes
) train_schedule ON l.id = train_schedule.id
GROUP BY l.nom, l.capacite_max, train_schedule.nb_trains_par_jour
ORDER BY taux_remplissage DESC;
