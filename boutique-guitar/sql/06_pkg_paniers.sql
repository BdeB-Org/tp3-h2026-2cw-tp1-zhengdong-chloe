-- Boutique de Guitare — Package PANIERS
CREATE OR REPLACE PACKAGE pkg_paniers AS
    ex_not_found     EXCEPTION; PRAGMA EXCEPTION_INIT(ex_not_found,     -20031);
    ex_invalid_input EXCEPTION; PRAGMA EXCEPTION_INIT(ex_invalid_input, -20032);
    ex_client_absent EXCEPTION; PRAGMA EXCEPTION_INIT(ex_client_absent, -20033);
    PROCEDURE get_all;
    PROCEDURE get_by_id(p_id IN paniers.id_panier%TYPE);
    PROCEDURE get_by_client(p_id_client IN paniers.id_client%TYPE);
    PROCEDURE create_one(p_id_client IN paniers.id_client%TYPE, p_date IN paniers.date_creation%TYPE DEFAULT SYSDATE);
    PROCEDURE update_one(p_id IN paniers.id_panier%TYPE, p_id_client IN paniers.id_client%TYPE, p_date IN paniers.date_creation%TYPE DEFAULT NULL);
    PROCEDURE delete_one(p_id IN paniers.id_panier%TYPE);
END pkg_paniers;
/

CREATE OR REPLACE PACKAGE BODY pkg_paniers AS

    PROCEDURE p_err(p_code IN PLS_INTEGER, p_msg IN VARCHAR2) IS
    BEGIN
        OWA_UTIL.STATUS_LINE(400,'Bad Request',FALSE);
        APEX_JSON.OPEN_OBJECT;
        APEX_JSON.WRITE('status','error'); APEX_JSON.WRITE('code',p_code); APEX_JSON.WRITE('message',p_msg);
        APEX_JSON.CLOSE_OBJECT;
    END;

    PROCEDURE p_check_client(p_id_client IN paniers.id_client%TYPE) IS
        v_ct NUMBER;
    BEGIN
        IF p_id_client IS NULL THEN RAISE_APPLICATION_ERROR(-20032,'L''ID client est obligatoire.'); END IF;
        SELECT COUNT(*) INTO v_ct FROM clients WHERE id_client=p_id_client;
        IF v_ct = 0 THEN RAISE_APPLICATION_ERROR(-20033,'Client inexistant.'); END IF;
    END;

    PROCEDURE p_write(p_id_pan IN NUMBER, p_id_cli IN NUMBER, p_nom_cli IN VARCHAR2, p_date IN DATE) IS
    BEGIN
        APEX_JSON.OPEN_OBJECT;
        APEX_JSON.WRITE('id_panier',    p_id_pan);
        APEX_JSON.WRITE('id_client',    p_id_cli);
        APEX_JSON.WRITE('nom_client',   p_nom_cli);
        APEX_JSON.WRITE('date_creation',TO_CHAR(p_date,'YYYY-MM-DD'));
        APEX_JSON.CLOSE_OBJECT;
    END;

    PROCEDURE get_all IS
        v_n NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_n FROM paniers;
        APEX_JSON.OPEN_OBJECT; APEX_JSON.WRITE('status','success'); APEX_JSON.WRITE('count',v_n);
        APEX_JSON.OPEN_ARRAY('items');
        FOR r IN (SELECT pa.id_panier,pa.id_client,cl.nom_client,pa.date_creation
                  FROM paniers pa JOIN clients cl ON cl.id_client=pa.id_client ORDER BY pa.date_creation DESC)
        LOOP p_write(r.id_panier,r.id_client,r.nom_client,r.date_creation); END LOOP;
        APEX_JSON.CLOSE_ARRAY; APEX_JSON.CLOSE_OBJECT;
    EXCEPTION WHEN OTHERS THEN p_err(-20099,'Erreur : '||SQLERRM);
    END;

    PROCEDURE get_by_id(p_id IN paniers.id_panier%TYPE) IS
        v_id NUMBER; v_id_cli NUMBER; v_nom VARCHAR2(100); v_date DATE;
    BEGIN
        SELECT pa.id_panier,pa.id_client,cl.nom_client,pa.date_creation
        INTO v_id,v_id_cli,v_nom,v_date
        FROM paniers pa JOIN clients cl ON cl.id_client=pa.id_client WHERE pa.id_panier=p_id;
        APEX_JSON.OPEN_OBJECT; APEX_JSON.WRITE('status','success');
        APEX_JSON.OPEN_OBJECT('item'); p_write(v_id,v_id_cli,v_nom,v_date); APEX_JSON.CLOSE_OBJECT;
        APEX_JSON.CLOSE_OBJECT;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN p_err(-20031,'Panier introuvable.');
        WHEN OTHERS THEN p_err(-20099,'Erreur : '||SQLERRM);
    END;

    PROCEDURE get_by_client(p_id_client IN paniers.id_client%TYPE) IS
        v_n NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_n FROM paniers WHERE id_client=p_id_client;
        APEX_JSON.OPEN_OBJECT; APEX_JSON.WRITE('status','success'); APEX_JSON.WRITE('count',v_n);
        APEX_JSON.OPEN_ARRAY('items');
        FOR r IN (SELECT pa.id_panier,pa.id_client,cl.nom_client,pa.date_creation
                  FROM paniers pa JOIN clients cl ON cl.id_client=pa.id_client
                  WHERE pa.id_client=p_id_client ORDER BY pa.date_creation DESC)
        LOOP p_write(r.id_panier,r.id_client,r.nom_client,r.date_creation); END LOOP;
        APEX_JSON.CLOSE_ARRAY; APEX_JSON.CLOSE_OBJECT;
    EXCEPTION WHEN OTHERS THEN p_err(-20099,'Erreur : '||SQLERRM);
    END;

    PROCEDURE create_one(p_id_client IN paniers.id_client%TYPE, p_date IN paniers.date_creation%TYPE DEFAULT SYSDATE) IS
        v_id paniers.id_panier%TYPE;
    BEGIN
        p_check_client(p_id_client);
        INSERT INTO paniers(id_client,date_creation) VALUES(p_id_client,COALESCE(p_date,SYSDATE)) RETURNING id_panier INTO v_id;
        COMMIT;
        OWA_UTIL.STATUS_LINE(201,'Created',FALSE);
        APEX_JSON.OPEN_OBJECT; APEX_JSON.WRITE('status','created'); APEX_JSON.WRITE('id_panier',v_id); APEX_JSON.CLOSE_OBJECT;
    EXCEPTION
        WHEN ex_invalid_input THEN p_err(-20032,'L''ID client est obligatoire.');
        WHEN ex_client_absent THEN p_err(-20033,'Client inexistant.');
        WHEN OTHERS THEN ROLLBACK; p_err(-20099,'Erreur : '||SQLERRM);
    END;

    PROCEDURE update_one(p_id IN paniers.id_panier%TYPE, p_id_client IN paniers.id_client%TYPE, p_date IN paniers.date_creation%TYPE DEFAULT NULL) IS
        v_rows NUMBER;
    BEGIN
        p_check_client(p_id_client);
        UPDATE paniers SET id_client=p_id_client, date_creation=COALESCE(p_date,SYSDATE) WHERE id_panier=p_id;
        v_rows := SQL%ROWCOUNT; COMMIT;
        IF v_rows = 0 THEN RAISE_APPLICATION_ERROR(-20031,'Panier introuvable.'); END IF;
        APEX_JSON.OPEN_OBJECT; APEX_JSON.WRITE('status','updated'); APEX_JSON.WRITE('rows_updated',v_rows); APEX_JSON.CLOSE_OBJECT;
    EXCEPTION
        WHEN ex_not_found THEN p_err(-20031,'Panier introuvable.');
        WHEN ex_invalid_input THEN p_err(-20032,'L''ID client est obligatoire.');
        WHEN ex_client_absent THEN p_err(-20033,'Client inexistant.');
        WHEN OTHERS THEN ROLLBACK; p_err(-20099,'Erreur : '||SQLERRM);
    END;

    PROCEDURE delete_one(p_id IN paniers.id_panier%TYPE) IS
        v_rows NUMBER;
    BEGIN
        DELETE FROM paniers WHERE id_panier=p_id;
        v_rows := SQL%ROWCOUNT; COMMIT;
        IF v_rows = 0 THEN RAISE_APPLICATION_ERROR(-20031,'Panier introuvable.'); END IF;
        APEX_JSON.OPEN_OBJECT; APEX_JSON.WRITE('status','deleted'); APEX_JSON.WRITE('rows_deleted',v_rows); APEX_JSON.CLOSE_OBJECT;
    EXCEPTION
        WHEN ex_not_found THEN p_err(-20031,'Panier introuvable.');
        WHEN OTHERS THEN ROLLBACK; p_err(-20099,'Erreur : '||SQLERRM);
    END;

END pkg_paniers;
/
SELECT object_name, object_type, status FROM user_objects WHERE object_name='PKG_PANIERS' ORDER BY object_type;
