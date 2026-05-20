-- Boutique de Guitare — Package PRODUITS
CREATE OR REPLACE PACKAGE pkg_produits AS
    ex_not_found     EXCEPTION; PRAGMA EXCEPTION_INIT(ex_not_found,     -20021);
    ex_invalid_input EXCEPTION; PRAGMA EXCEPTION_INIT(ex_invalid_input, -20022);
    ex_invalid_prix  EXCEPTION; PRAGMA EXCEPTION_INIT(ex_invalid_prix,  -20023);
    PROCEDURE get_all;
    PROCEDURE get_by_id(p_id IN produits.id_produit%TYPE);
    PROCEDURE get_by_fabricant(p_id_manu IN produits.id_manu%TYPE);
    PROCEDURE create_one(p_nom IN produits.nom_produit%TYPE, p_prix IN produits.prix_produit%TYPE, p_id_manu IN produits.id_manu%TYPE DEFAULT NULL);
    PROCEDURE update_one(p_id IN produits.id_produit%TYPE, p_nom IN produits.nom_produit%TYPE, p_prix IN produits.prix_produit%TYPE, p_id_manu IN produits.id_manu%TYPE DEFAULT NULL);
    PROCEDURE delete_one(p_id IN produits.id_produit%TYPE);
END pkg_produits;
/

CREATE OR REPLACE PACKAGE BODY pkg_produits AS

    PROCEDURE p_err(p_code IN PLS_INTEGER, p_msg IN VARCHAR2) IS
    BEGIN
        OWA_UTIL.STATUS_LINE(400,'Bad Request',FALSE);
        APEX_JSON.OPEN_OBJECT;
        APEX_JSON.WRITE('status','error'); APEX_JSON.WRITE('code',p_code); APEX_JSON.WRITE('message',p_msg);
        APEX_JSON.CLOSE_OBJECT;
    END;

    PROCEDURE p_validate(p_nom IN VARCHAR2, p_prix IN NUMBER) IS
    BEGIN
        IF p_nom IS NULL OR LENGTH(TRIM(p_nom)) = 0 THEN RAISE_APPLICATION_ERROR(-20022,'Le nom du produit est obligatoire.'); END IF;
        IF p_prix IS NULL OR p_prix < 0 THEN RAISE_APPLICATION_ERROR(-20023,'Le prix doit être positif ou nul.'); END IF;
    END;

    PROCEDURE p_write(p_id IN NUMBER, p_nom IN VARCHAR2, p_prix IN NUMBER, p_id_manu IN NUMBER, p_nom_manu IN VARCHAR2) IS
    BEGIN
        APEX_JSON.OPEN_OBJECT;
        APEX_JSON.WRITE('id_produit',  p_id);
        APEX_JSON.WRITE('nom_produit', p_nom);
        APEX_JSON.WRITE('prix_produit',p_prix);
        APEX_JSON.WRITE('id_manu',     p_id_manu);
        APEX_JSON.WRITE('nom_manu',    p_nom_manu);
        APEX_JSON.CLOSE_OBJECT;
    END;

    PROCEDURE get_all IS
        v_n NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_n FROM produits;
        APEX_JSON.OPEN_OBJECT; APEX_JSON.WRITE('status','success'); APEX_JSON.WRITE('count',v_n);
        APEX_JSON.OPEN_ARRAY('items');
        FOR r IN (SELECT p.id_produit,p.nom_produit,p.prix_produit,p.id_manu,f.nom_manu
                  FROM produits p LEFT JOIN fabricants f ON f.id_manu=p.id_manu ORDER BY p.nom_produit)
        LOOP p_write(r.id_produit,r.nom_produit,r.prix_produit,r.id_manu,r.nom_manu); END LOOP;
        APEX_JSON.CLOSE_ARRAY; APEX_JSON.CLOSE_OBJECT;
    EXCEPTION WHEN OTHERS THEN p_err(-20099,'Erreur : '||SQLERRM);
    END;

    PROCEDURE get_by_id(p_id IN produits.id_produit%TYPE) IS
        v_id NUMBER; v_nom VARCHAR2(150); v_prix NUMBER; v_id_manu NUMBER; v_nom_manu VARCHAR2(100);
    BEGIN
        SELECT p.id_produit,p.nom_produit,p.prix_produit,p.id_manu,f.nom_manu
        INTO v_id,v_nom,v_prix,v_id_manu,v_nom_manu
        FROM produits p LEFT JOIN fabricants f ON f.id_manu=p.id_manu WHERE p.id_produit=p_id;
        APEX_JSON.OPEN_OBJECT; APEX_JSON.WRITE('status','success');
        APEX_JSON.OPEN_OBJECT('item'); p_write(v_id,v_nom,v_prix,v_id_manu,v_nom_manu); APEX_JSON.CLOSE_OBJECT;
        APEX_JSON.CLOSE_OBJECT;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN p_err(-20021,'Produit introuvable.');
        WHEN OTHERS THEN p_err(-20099,'Erreur : '||SQLERRM);
    END;

    PROCEDURE get_by_fabricant(p_id_manu IN produits.id_manu%TYPE) IS
        v_n NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_n FROM produits WHERE id_manu=p_id_manu;
        APEX_JSON.OPEN_OBJECT; APEX_JSON.WRITE('status','success'); APEX_JSON.WRITE('count',v_n);
        APEX_JSON.OPEN_ARRAY('items');
        FOR r IN (SELECT p.id_produit,p.nom_produit,p.prix_produit,p.id_manu,f.nom_manu
                  FROM produits p LEFT JOIN fabricants f ON f.id_manu=p.id_manu
                  WHERE p.id_manu=p_id_manu ORDER BY p.nom_produit)
        LOOP p_write(r.id_produit,r.nom_produit,r.prix_produit,r.id_manu,r.nom_manu); END LOOP;
        APEX_JSON.CLOSE_ARRAY; APEX_JSON.CLOSE_OBJECT;
    EXCEPTION WHEN OTHERS THEN p_err(-20099,'Erreur : '||SQLERRM);
    END;

    PROCEDURE create_one(p_nom IN produits.nom_produit%TYPE, p_prix IN produits.prix_produit%TYPE, p_id_manu IN produits.id_manu%TYPE DEFAULT NULL) IS
        v_id produits.id_produit%TYPE;
    BEGIN
        p_validate(p_nom,p_prix);
        INSERT INTO produits(nom_produit,prix_produit,id_manu) VALUES(TRIM(p_nom),p_prix,p_id_manu) RETURNING id_produit INTO v_id;
        COMMIT;
        OWA_UTIL.STATUS_LINE(201,'Created',FALSE);
        APEX_JSON.OPEN_OBJECT; APEX_JSON.WRITE('status','created'); APEX_JSON.WRITE('id_produit',v_id); APEX_JSON.CLOSE_OBJECT;
    EXCEPTION
        WHEN ex_invalid_input THEN p_err(-20022,'Le nom du produit est obligatoire.');
        WHEN ex_invalid_prix  THEN p_err(-20023,'Le prix doit être positif ou nul.');
        WHEN OTHERS THEN ROLLBACK; p_err(-20099,'Erreur : '||SQLERRM);
    END;

    PROCEDURE update_one(p_id IN produits.id_produit%TYPE, p_nom IN produits.nom_produit%TYPE, p_prix IN produits.prix_produit%TYPE, p_id_manu IN produits.id_manu%TYPE DEFAULT NULL) IS
        v_rows NUMBER;
    BEGIN
        p_validate(p_nom,p_prix);
        UPDATE produits SET nom_produit=TRIM(p_nom),prix_produit=p_prix,id_manu=p_id_manu WHERE id_produit=p_id;
        v_rows := SQL%ROWCOUNT; COMMIT;
        IF v_rows = 0 THEN RAISE_APPLICATION_ERROR(-20021,'Produit introuvable.'); END IF;
        APEX_JSON.OPEN_OBJECT; APEX_JSON.WRITE('status','updated'); APEX_JSON.WRITE('rows_updated',v_rows); APEX_JSON.CLOSE_OBJECT;
    EXCEPTION
        WHEN ex_not_found THEN p_err(-20021,'Produit introuvable.');
        WHEN ex_invalid_input THEN p_err(-20022,'Le nom du produit est obligatoire.');
        WHEN ex_invalid_prix  THEN p_err(-20023,'Le prix doit être positif ou nul.');
        WHEN OTHERS THEN ROLLBACK; p_err(-20099,'Erreur : '||SQLERRM);
    END;

    PROCEDURE delete_one(p_id IN produits.id_produit%TYPE) IS
        v_rows NUMBER;
    BEGIN
        DELETE FROM produits WHERE id_produit=p_id;
        v_rows := SQL%ROWCOUNT; COMMIT;
        IF v_rows = 0 THEN RAISE_APPLICATION_ERROR(-20021,'Produit introuvable.'); END IF;
        APEX_JSON.OPEN_OBJECT; APEX_JSON.WRITE('status','deleted'); APEX_JSON.WRITE('rows_deleted',v_rows); APEX_JSON.CLOSE_OBJECT;
    EXCEPTION
        WHEN ex_not_found THEN p_err(-20021,'Produit introuvable.');
        WHEN OTHERS THEN ROLLBACK; p_err(-20099,'Erreur : '||SQLERRM);
    END;

END pkg_produits;
/
SELECT object_name, object_type, status FROM user_objects WHERE object_name='PKG_PRODUITS' ORDER BY object_type;
