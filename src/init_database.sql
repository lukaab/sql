-- Création des types ENUM pour les valeurs contraintes
CREATE TYPE moyen_transport AS ENUM ('metro', 'rer');
CREATE TYPE statut_dossier_client AS ENUM ('incomplet', 'validation', 'valide', 'rejete');

-- Table des lignes de transport
CREATE TABLE lignes (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(32) NOT NULL UNIQUE,
    type moyen_transport NOT NULL,
    capacite_max INT NOT NULL
);

-- Table des stations
CREATE TABLE stations (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(255) NOT NULL UNIQUE,
    zone INT NOT NULL
);

-- Table des arrêts (relation entre stations et lignes)
CREATE TABLE arrets (
    id SERIAL PRIMARY KEY,
    id_station INT NOT NULL REFERENCES stations(id) ON DELETE CASCADE,
    id_ligne INT NOT NULL REFERENCES lignes(id) ON DELETE CASCADE
);

-- Table des horaires
CREATE TABLE horaires (
    id SERIAL PRIMARY KEY,
    id_arret INT NOT NULL REFERENCES arrets(id) ON DELETE CASCADE,
    horaire TIME NOT NULL
);

-- Table des adresses clients
CREATE TABLE adresses_client (
    id SERIAL PRIMARY KEY,
    ligne_1 TEXT NOT NULL,
    ligne_2 TEXT,
    ville VARCHAR(255) NOT NULL,
    departement VARCHAR(255) NOT NULL,
    code_postal VARCHAR(5) NOT NULL,
    pays VARCHAR(255) NOT NULL
);

-- Table des dossiers clients
CREATE TABLE dossiers_client (
    id SERIAL PRIMARY KEY,
    statut statut_dossier_client NOT NULL,
    prenoms TEXT NOT NULL,
    nom_famille TEXT NOT NULL,
    date_naissance DATE NOT NULL,
    id_adresse_residence INT NOT NULL REFERENCES adresses_client(id) ON DELETE CASCADE,
    id_adresse_facturation INT REFERENCES adresses_client(id) ON DELETE SET NULL,
    email VARCHAR(128),
    tel VARCHAR(15),
    iban VARCHAR(34),
    bic VARCHAR(11),
    date_creation TIMESTAMP DEFAULT NOW()
);

-- Table des supports (tickets et abonnements)
CREATE TABLE supports (
    id SERIAL PRIMARY KEY,
    identifiant VARCHAR(12) NOT NULL,
    date_achat TIMESTAMP NOT NULL
);

-- Table des tarifications
CREATE TABLE tarifications (
    id SERIAL PRIMARY KEY,
    nom TEXT NOT NULL UNIQUE,
    zone_min INT NOT NULL,
    zone_max INT NOT NULL,
    prix_centimes INT NOT NULL
);

-- Table des abonnements
CREATE TABLE abonnements (
    id SERIAL PRIMARY KEY,
    id_support INT NOT NULL REFERENCES supports(id) ON DELETE CASCADE,
    id_dossier INT NOT NULL REFERENCES dossiers_client(id) ON DELETE CASCADE,
    id_tarification INT NOT NULL REFERENCES tarifications(id) ON DELETE CASCADE,
    date_debut TIMESTAMP NOT NULL,
    date_fin TIMESTAMP NOT NULL
);

-- Table des tickets
CREATE TABLE tickets (
    id SERIAL PRIMARY KEY,
    id_support INT NOT NULL REFERENCES supports(id) ON DELETE CASCADE,
    date_achat TIMESTAMP NOT NULL,
    date_expiration TIMESTAMP NOT NULL,
    prix_unitaire_centimes INT NOT NULL,
    id_station INT NOT NULL REFERENCES stations(id) ON DELETE CASCADE,
    date_heure_validation TIMESTAMP NOT NULL
);

-- Table des validations (passages des usagers)
CREATE TABLE validations (
    id SERIAL PRIMARY KEY,
    id_support INT NOT NULL REFERENCES supports(id) ON DELETE CASCADE,
    id_station INT NOT NULL REFERENCES stations(id) ON DELETE CASCADE,
    date_heure_validation TIMESTAMP NOT NULL
);
