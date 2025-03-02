-- 1. Pourcentage des passagers avec abonnement vs tickets
SELECT 
    ROUND((COUNT(DISTINCT CASE WHEN a.id IS NOT NULL THEN s.id END) * 100.0) / COUNT(DISTINCT s.id), 2) AS part_abonnement,
    ROUND((COUNT(DISTINCT CASE WHEN t.id IS NOT NULL THEN s.id END) * 100.0) / COUNT(DISTINCT s.id), 2) AS part_ticket
FROM supports s
LEFT JOIN abonnements a ON s.id = a.id_support
LEFT JOIN tickets t ON s.id = t.id_support;

-- 2. Nombre de nouveaux abonnements par mois en 2024
SELECT TO_CHAR(date_debut, 'Month') AS mois, COUNT(*) AS nb_nvx_abo
FROM abonnements
WHERE date_debut BETWEEN '2024-01-01' AND '2024-12-31'
AND id_support NOT IN (
    SELECT DISTINCT id_support FROM abonnements WHERE date_debut < '2024-01-01'
)
GROUP BY mois, EXTRACT(MONTH FROM date_debut)
ORDER BY EXTRACT(MONTH FROM date_debut);

-- 3. Montant total économisé par les abonnés s'ils avaient acheté des tickets
SELECT 
    ROUND(SUM(
        (v_count * t.prix_centimes / 100.0) - a_montant
    ), 2) AS montant_economise_euros
FROM (
    SELECT a.id, COUNT(v.id) AS v_count, SUM(t.prix_centimes / 100.0) AS a_montant
    FROM abonnements a
    JOIN validations v ON a.id_support = v.id_support
    JOIN tarifications t ON a.id_tarification = t.id
    GROUP BY a.id
) AS subquery
WHERE v_count * t.prix_centimes / 100.0 > a_montant;

-- 4. Vue : Heure la plus affluente par station
CREATE OR REPLACE VIEW heure_affluence_par_station AS
SELECT s.nom AS nom_station, date_trunc('hour', v.date_heure_validation) AS heure_affluante
FROM validations v
JOIN stations s ON v.id_station = s.id
GROUP BY s.nom, heure_affluante
ORDER BY COUNT(v.id) DESC;

-- 5. Vue : Nombre d'abonnements actifs par tranche de zone
CREATE OR REPLACE VIEW abonnements_par_zone AS
SELECT t.zone_min, t.zone_max, COUNT(a.id) AS nb_abonnements
FROM abonnements a
JOIN tarifications t ON a.id_tarification = t.id
WHERE a.date_fin >= CURRENT_DATE
GROUP BY t.zone_min, t.zone_max
ORDER BY nb_abonnements DESC, t.zone_min, t.zone_max;
