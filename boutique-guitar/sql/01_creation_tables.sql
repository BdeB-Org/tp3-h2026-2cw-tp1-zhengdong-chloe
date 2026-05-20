-- Boutique de Guitare — Création des tables
BEGIN
    FOR t IN (SELECT table_name FROM user_tables
              WHERE table_name IN ('PANIERS','PRODUITS','FABRICANTS','CLIENTS')
              ORDER BY CASE table_name WHEN 'PANIERS' THEN 1 WHEN 'PRODUITS' THEN 2
                                       WHEN 'FABRICANTS' THEN 3 ELSE 4 END)
    LOOP EXECUTE IMMEDIATE 'DROP TABLE '||t.table_name||' CASCADE CONSTRAINTS'; END LOOP;
END;
/

CREATE TABLE fabricants (
    id_manu   NUMBER(10)    CONSTRAINT pk_fabricants PRIMARY KEY,
    nom_manu  VARCHAR2(100) CONSTRAINT nn_fab_nom NOT NULL,
    telephone VARCHAR2(20),
    CONSTRAINT ck_fab_nom CHECK (LENGTH(TRIM(nom_manu)) > 0)
);

CREATE TABLE clients (
    id_client  NUMBER(10)    CONSTRAINT pk_clients PRIMARY KEY,
    nom_client VARCHAR2(100) CONSTRAINT nn_cli_nom NOT NULL,
    telephone  VARCHAR2(20),
    address    VARCHAR2(200),
    CONSTRAINT ck_cli_nom CHECK (LENGTH(TRIM(nom_client)) > 0)
);

CREATE TABLE produits (
    id_produit   NUMBER(10)   CONSTRAINT pk_produits PRIMARY KEY,
    nom_produit  VARCHAR2(150) CONSTRAINT nn_prod_nom NOT NULL,
    prix_produit NUMBER(10,2)  CONSTRAINT nn_prod_prix NOT NULL,
    id_manu      NUMBER(10)    CONSTRAINT fk_prod_manu REFERENCES fabricants(id_manu) ON DELETE SET NULL,
    CONSTRAINT ck_prod_nom  CHECK (LENGTH(TRIM(nom_produit)) > 0),
    CONSTRAINT ck_prod_prix CHECK (prix_produit >= 0)
);

CREATE TABLE paniers (
    id_panier     NUMBER(10) CONSTRAINT pk_paniers PRIMARY KEY,
    id_client     NUMBER(10) CONSTRAINT nn_pan_cli NOT NULL
                             CONSTRAINT fk_pan_client REFERENCES clients(id_client) ON DELETE CASCADE,
    date_creation DATE DEFAULT SYSDATE CONSTRAINT nn_pan_date NOT NULL
);

SELECT table_name FROM user_tables
WHERE table_name IN ('FABRICANTS','CLIENTS','PRODUITS','PANIERS') ORDER BY 1;
