-- Boutique de Guitare — Séquences et déclencheurs
BEGIN
    FOR s IN (SELECT sequence_name FROM user_sequences
              WHERE sequence_name IN ('SEQ_FABRICANTS','SEQ_CLIENTS','SEQ_PRODUITS','SEQ_PANIERS'))
    LOOP EXECUTE IMMEDIATE 'DROP SEQUENCE '||s.sequence_name; END LOOP;
END;
/

CREATE SEQUENCE seq_fabricants START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_clients    START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_produits   START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_paniers    START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_fabricants_bi BEFORE INSERT ON fabricants FOR EACH ROW
BEGIN :NEW.id_manu := COALESCE(:NEW.id_manu, seq_fabricants.NEXTVAL); END;
/
CREATE OR REPLACE TRIGGER trg_clients_bi BEFORE INSERT ON clients FOR EACH ROW
BEGIN :NEW.id_client := COALESCE(:NEW.id_client, seq_clients.NEXTVAL); END;
/
CREATE OR REPLACE TRIGGER trg_produits_bi BEFORE INSERT ON produits FOR EACH ROW
BEGIN :NEW.id_produit := COALESCE(:NEW.id_produit, seq_produits.NEXTVAL); END;
/
CREATE OR REPLACE TRIGGER trg_paniers_bi BEFORE INSERT ON paniers FOR EACH ROW
BEGIN
    :NEW.id_panier    := COALESCE(:NEW.id_panier, seq_paniers.NEXTVAL);
    :NEW.date_creation := COALESCE(:NEW.date_creation, SYSDATE);
END;
/

SELECT object_name, status FROM user_objects
WHERE object_name IN ('TRG_FABRICANTS_BI','TRG_CLIENTS_BI','TRG_PRODUITS_BI','TRG_PANIERS_BI');
