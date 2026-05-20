-- Boutique de Guitare — Données initiales
DELETE FROM paniers; DELETE FROM produits; DELETE FROM clients; DELETE FROM fabricants;

BEGIN
    FOR s IN (SELECT sequence_name FROM user_sequences WHERE sequence_name IN
              ('SEQ_FABRICANTS','SEQ_CLIENTS','SEQ_PRODUITS','SEQ_PANIERS'))
    LOOP EXECUTE IMMEDIATE 'DROP SEQUENCE '||s.sequence_name; END LOOP;
END;
/
CREATE SEQUENCE seq_fabricants START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_clients    START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_produits   START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_paniers    START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

-- Fabricants
INSERT INTO fabricants(nom_manu,telephone) VALUES('Gibson','1-800-444-2766');
INSERT INTO fabricants(nom_manu,telephone) VALUES('Fender','1-800-856-9801');
INSERT INTO fabricants(nom_manu,telephone) VALUES('Martin','1-888-343-5842');
INSERT INTO fabricants(nom_manu,telephone) VALUES('Taylor','1-619-258-1207');
INSERT INTO fabricants(nom_manu,telephone) VALUES('PRS','1-410-827-1801');
INSERT INTO fabricants(nom_manu,telephone) VALUES('Ibanez','1-516-935-3840');

-- Clients
INSERT INTO clients(nom_client,telephone,address) VALUES('Archambault, Gilles','514-555-0101','4212 rue Saint-Denis, Montréal, QC');
INSERT INTO clients(nom_client,telephone,address) VALUES('Tremblay, Sophie','438-555-0202','145 avenue Mont-Royal E, Montréal, QC');
INSERT INTO clients(nom_client,telephone,address) VALUES('Côté, Jean-Pierre','450-555-0303','88 boul. des Laurentides, Laval, QC');
INSERT INTO clients(nom_client,telephone,address) VALUES('Bouchard, Émilie','418-555-0404','22 rue Saint-Jean, Québec, QC');
INSERT INTO clients(nom_client,telephone,address) VALUES('Lefebvre, Marc','819-555-0505','310 rue Sherbrooke, Sherbrooke, QC');
INSERT INTO clients(nom_client,telephone,address) VALUES('Gauthier, Karine','514-555-0606','1001 rue de la Commune O, Montréal, QC');

-- Produits
INSERT INTO produits(nom_produit,prix_produit,id_manu) VALUES('Gibson Les Paul Standard 60s',3499.99,1);
INSERT INTO produits(nom_produit,prix_produit,id_manu) VALUES('Gibson SG Standard',1999.99,1);
INSERT INTO produits(nom_produit,prix_produit,id_manu) VALUES('Gibson J-45 Acoustique',2899.99,1);
INSERT INTO produits(nom_produit,prix_produit,id_manu) VALUES('Fender Stratocaster Player',1149.99,2);
INSERT INTO produits(nom_produit,prix_produit,id_manu) VALUES('Fender Telecaster Professional',1999.00,2);
INSERT INTO produits(nom_produit,prix_produit,id_manu) VALUES('Fender Acoustasonic Stratocaster',2499.99,2);
INSERT INTO produits(nom_produit,prix_produit,id_manu) VALUES('Martin D-28 Acoustique',3999.99,3);
INSERT INTO produits(nom_produit,prix_produit,id_manu) VALUES('Martin SC-13E',1699.99,3);
INSERT INTO produits(nom_produit,prix_produit,id_manu) VALUES('Taylor 314ce Grand Auditorium',2499.99,4);
INSERT INTO produits(nom_produit,prix_produit,id_manu) VALUES('Taylor Academy 10e',549.99,4);
INSERT INTO produits(nom_produit,prix_produit,id_manu) VALUES('PRS SE Custom 24',899.99,5);
INSERT INTO produits(nom_produit,prix_produit,id_manu) VALUES('PRS Core Custom 24',3999.99,5);
INSERT INTO produits(nom_produit,prix_produit,id_manu) VALUES('Ibanez RG550',999.99,6);
INSERT INTO produits(nom_produit,prix_produit,id_manu) VALUES('Ibanez AZ2402',1999.99,6);

-- Paniers
INSERT INTO paniers(id_client,date_creation) VALUES(1,TO_DATE('2026-04-10','YYYY-MM-DD'));
INSERT INTO paniers(id_client,date_creation) VALUES(2,TO_DATE('2026-04-22','YYYY-MM-DD'));
INSERT INTO paniers(id_client,date_creation) VALUES(3,TO_DATE('2026-05-01','YYYY-MM-DD'));
INSERT INTO paniers(id_client,date_creation) VALUES(1,TO_DATE('2026-05-15','YYYY-MM-DD'));
INSERT INTO paniers(id_client,date_creation) VALUES(5,SYSDATE);

COMMIT;

SELECT 'FABRICANTS' entite,COUNT(*) total FROM fabricants UNION ALL
SELECT 'CLIENTS',COUNT(*) FROM clients UNION ALL
SELECT 'PRODUITS',COUNT(*) FROM produits UNION ALL
SELECT 'PANIERS',COUNT(*) FROM paniers;
